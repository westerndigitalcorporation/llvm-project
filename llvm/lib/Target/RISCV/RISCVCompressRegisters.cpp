//===-- RISCVCompressRegisters.cpp - Add moves to compressible registers --===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass searches for uses of a value in an uncompressible register by
// multiple compressible instructions. Since the register allocator already
// prefers compressible registers this will usually occur when there is a reason
// to use the uncompressible register - such as register zero. In this case,
// where there are compressible registers available the code size can be
// improved with a copy to a compressible register in the case where it allows
// multiple uses to be compressed.
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "RISCVSubtarget.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "riscv-compress-registers"
#define RISCV_COMPRESS_REGISTERS_NAME "RISCV Compress Registers"

namespace {

struct RISCVCompressRegistersOpt : public MachineFunctionPass {
  static char ID;

  bool runOnMachineFunction(MachineFunction &Fn) override;

  RISCVCompressRegistersOpt() : MachineFunctionPass(ID) {}

  StringRef getPassName() const override {
    return RISCV_COMPRESS_REGISTERS_NAME;
  }
};
} // namespace

char RISCVCompressRegistersOpt::ID = 0;
INITIALIZE_PASS(RISCVCompressRegistersOpt, "riscv-compress-registers",
                RISCV_COMPRESS_REGISTERS_NAME, false, false)

// Find a single register which if compressible would allow the given
// instruction to be compressed. If this is not the case return Register(0).
static Register getRegPreventingCompression(const MachineInstr &MI) {
  switch (MI.getOpcode()) {
  default:
    break;
  case RISCV::LW: {
    Register Base = MI.getOperand(1).getReg();
    // Load from stack pointer does not have a requirement for either of the
    // registers to be compressible.
    if (RISCV::SPRegClass.contains(Base))
      break;

    const MachineOperand &MOImm = MI.getOperand(2);
    if (!MOImm.isImm() || !isShiftedUInt<5, 2>(MOImm.getImm()))
      break;

    Register Dest = MI.getOperand(0).getReg();
    bool DestCompressed = RISCV::GPRCRegClass.contains(Dest);
    bool BaseCompressed = RISCV::GPRCRegClass.contains(Base);

    // For loads we can only change the base register since dest is defined
    // rather than used.
    if (!BaseCompressed && DestCompressed)
      return Base;

    break;
  }
  case RISCV::SW: {
    Register Base = MI.getOperand(1).getReg();
    // Store to stack pointer does not have a requirement for either of the
    // registers to be compressible.
    if (RISCV::SPRegClass.contains(Base))
      break;

    const MachineOperand &MOImm = MI.getOperand(2);
    if (!MOImm.isImm() || !isShiftedUInt<5, 2>(MOImm.getImm()))
      break;

    Register Src = MI.getOperand(0).getReg();
    bool SrcCompressed = RISCV::GPRCRegClass.contains(Src);
    bool BaseCompressed = RISCV::GPRCRegClass.contains(Base);

    if (!SrcCompressed && (BaseCompressed || Src == Base))
      return Src;
    if (!BaseCompressed && SrcCompressed)
      return Base;

    break;
  }
  }
  return Register(0);
}

// Check all uses after FirstMI of the given register, determining which can be
// compressed if that register was compressible, and returning which
// compressible register is available to be used instead.
static Register analyzeCompressibleUses(MachineBasicBlock &MBB,
                                        MachineInstr &FirstMI, Register Reg,
                                        SmallVector<MachineInstr *, 8> &MIs) {
  RegScavenger RS;
  RS.enterBasicBlock(MBB);

  for (MachineBasicBlock::instr_iterator I = FirstMI.getIterator(),
                                         E = MBB.instr_end();
       I != E; ++I) {
    MachineInstr &MI = *I;

    // If any of the operands define the register our optimization would not be
    // valid for this or further instructions.
    bool IsRegDefined = false;
    for (const MachineOperand &MO : MI.operands())
      if (MO.isReg() && MO.getReg() == Reg && MO.isDef()) {
        IsRegDefined = true;
        break;
      }
    if (IsRegDefined)
      break;

    // Determine if this is an instruction which would benefit from using the
    // new register.
    Register CandidateReg = getRegPreventingCompression(MI);
    if (CandidateReg != Reg)
      continue;

    // Advance tracking since the value in the new register must be live for
    // this instruction too.
    RS.forward(I);

    MIs.push_back(&MI);
  }

  if (MIs.size() < 2)
    return Register(0);

  // Find a compressible register which will be available from the first
  // instruction we care about to the last.
  return RS.scavengeRegisterBackwards(RISCV::GPRCRegClass,
                                      FirstMI.getIterator(),
                                      /*RestoreAfter=*/false, /*SPAdj=*/0,
                                      /*AllowSpill=*/false);
}

// Update uses of the old register in the given instruction to the new register.
static bool updateOperands(MachineInstr &MI, Register OldReg, Register NewReg) {
  bool Updated = false;
  for (MachineOperand &MO : MI.operands())
    if (MO.isReg() && MO.getReg() == OldReg) {
      MO.setReg(NewReg);
      Updated = true;
    }

  return Updated;
}

bool RISCVCompressRegistersOpt::runOnMachineFunction(MachineFunction &Fn) {
  if (skipFunction(Fn.getFunction()))
    return false;

  const RISCVSubtarget &STI = Fn.getSubtarget<RISCVSubtarget>();
  const RISCVInstrInfo &TII = *STI.getInstrInfo();

  // This optimization only makes sense if compressed instructions are emitted.
  if (!STI.hasStdExtC())
    return false;

  for (MachineBasicBlock &MBB : Fn) {
    LLVM_DEBUG(dbgs() << "MBB: " << MBB.getName() << "\n");
    for (MachineInstr &MI : MBB) {
      // Determine if this instruction would otherwise be compressed if not for
      // an uncompressible register.
      Register Reg = getRegPreventingCompression(MI);
      if (!Reg)
        continue;

      // Determine if there is a set of instructions for which replacing this
      // register with a compressed register is possible and will allow
      // compression.
      SmallVector<MachineInstr *, 8> MIs;
      Register NewReg = analyzeCompressibleUses(MBB, MI, Reg, MIs);
      if (!NewReg)
        continue;

      // Build a copy to the compressed register.
      BuildMI(MBB, MI, MI.getDebugLoc(), TII.get(RISCV::ADDI), NewReg)
          .addReg(Reg)
          .addImm(0);

      // Update the set of instructions to use the compressed register instead.
      // These instructions should now be compressible.
      for (MachineInstr *UpdateMI : MIs)
        updateOperands(*UpdateMI, Reg, NewReg);
    }
  }
  return true;
}

/// Returns an instance of the Compress Registers Optimization pass.
FunctionPass *llvm::createRISCVCompressRegistersOptPass() {
  return new RISCVCompressRegistersOpt();
}
