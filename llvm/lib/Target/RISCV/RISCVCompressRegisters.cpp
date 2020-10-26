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

// Given an offset for a load/store, return the adjustment required to the base
// register such that the address can be accessed with a compressible offset.
// Return 0 if the offset is already compressible.
int64_t
getBaseAdjustForCompression (int64_t offset) {
  if (isShiftedUInt<5, 2>(offset))
    return 0;
  return offset & ~(0b1111100);
}
// Find a single register which if compressible would allow the given
// instruction to be compressed. If this is not the case return Register(0).
static RegImmPair getRegPreventingCompression(const MachineInstr &MI) {
  int64_t NewBaseAdjust = 0;

  switch (MI.getOpcode()) {
  default:
    break;
  case RISCV::LW: {
    const MachineOperand &MOImm = MI.getOperand(2);
    if (!MOImm.isImm())
      break;

    int64_t Offset = MOImm.getImm();

    NewBaseAdjust = getBaseAdjustForCompression (Offset);

    Register Base = MI.getOperand(1).getReg();
    // Load from stack pointer does not have a requirement for either of the
    // registers to be compressible and the offset can be a 6 bit immediate
    // scaled by 4.
    if (RISCV::SPRegClass.contains(Base)) {
      if (!isShiftedUInt<6,2>(Offset) && NewBaseAdjust)
        return RegImmPair(Base, NewBaseAdjust);
      break;
    }

    Register Dest = MI.getOperand(0).getReg();
    bool DestCompressed = RISCV::GPRCRegClass.contains(Dest);
    bool BaseCompressed = RISCV::GPRCRegClass.contains(Base);

    // For loads we can only change the base register since dest is defined
    // rather than used.
    if ((!BaseCompressed || NewBaseAdjust) && DestCompressed)
      return RegImmPair(Base, NewBaseAdjust);

    break;
  }
  case RISCV::SW: {
    const MachineOperand &MOImm = MI.getOperand(2);
    if (!MOImm.isImm())
      break;

    int64_t Offset = MOImm.getImm();

    NewBaseAdjust = getBaseAdjustForCompression (Offset);

    Register Base = MI.getOperand(1).getReg();
    // Store to stack pointer does not have a requirement for either of the
    // registers to be compressible and the offset can be a 6 bit immediate
    // scaled by 4.
    if (RISCV::SPRegClass.contains(Base)) {
      if (!isShiftedUInt<6,2>(Offset) && NewBaseAdjust)
        return RegImmPair(Base, NewBaseAdjust);
      break;
    }

    Register Src = MI.getOperand(0).getReg();
    bool SrcCompressed = RISCV::GPRCRegClass.contains(Src);
    bool BaseCompressed = RISCV::GPRCRegClass.contains(Base);

    // Cannot resolve uncompressible offset if we are resolving src reg
    if (!SrcCompressed && (BaseCompressed || Src == Base) && !NewBaseAdjust)
      return RegImmPair(Src, NewBaseAdjust);
    if ((!BaseCompressed || NewBaseAdjust) && SrcCompressed)
      return RegImmPair(Base, NewBaseAdjust);

    break;
  }
  }
  return RegImmPair(Register(0), 0);
}

// Check all uses after FirstMI of the given register, determining which can be
// compressed if that register (and offset if applicable) was compressible, and
// returning which compressible register is available to be used instead.
static Register analyzeCompressibleUses(MachineBasicBlock &MBB,
                                        MachineInstr &FirstMI,
                                        RegImmPair RegImm,
                                        SmallVector<MachineInstr *, 8> &MIs) {
  RegScavenger RS;
  RS.enterBasicBlock(MBB);

  for (MachineBasicBlock::instr_iterator I = FirstMI.getIterator(),
                                         E = MBB.instr_end();
       I != E; ++I) {
    MachineInstr &MI = *I;

    // If this register is uncompressed and any of the operands define it, this
    // optimization would not be valid for this or further instructions. If the
    // register is already compressed then a new base register could still be
    // introduced to optimize "lw a0,LargeOffset(a0)" to
    // "lw a0,SmallOffest(NewBase)".
    bool DefinesUncompReg = false;
    for (const MachineOperand &MO : MI.operands())
      if (MO.isReg() && MO.getReg() == RegImm.Reg && MO.isDef()
          && MI.getOpcode() != RISCV::LW) {
        DefinesUncompReg = true;
        break;
      }
    if (DefinesUncompReg)
      break;

    // Determine if this is an instruction which would benefit from using the
    // new register.
    RegImmPair CandidateRegImm = getRegPreventingCompression(MI);
    if (CandidateRegImm.Reg != RegImm.Reg || CandidateRegImm.Imm != RegImm.Imm)
      continue;

    // Advance tracking since the value in the new register must be live for
    // this instruction too.
    RS.forward(I);

    MIs.push_back(&MI);
  }

  // Adjusting the base requires an uncompressed addi instruction, therefore 3
  // uses are required for a code size reduction (2 uses would break even on
  // code size whilst adding an unnecessary instruction). If no adjustment is
  // required then only a c.addi is needed to copy the register and 2 uses would
  // be required for a code size reduction.
  if (MIs.size() < 2 || (RegImm.Imm != 0 && MIs.size() < 3))
    return Register(0);

  // Find a compressible register which will be available from the first
  // instruction we care about to the last.
  return RS.scavengeRegisterBackwards(RISCV::GPRCRegClass,
                                      FirstMI.getIterator(),
                                      /*RestoreAfter=*/false, /*SPAdj=*/0,
                                      /*AllowSpill=*/false);
}

// Update uses of the old register in the given instruction to the new register.
// Return false if no further instructions should be updated.
static bool updateOperands(MachineInstr &MI, RegImmPair OldRegImm, Register NewReg) {
  bool UpdatesAllowed = true;

  // Update registers
  for (MachineOperand &MO : MI.operands())
    if (MO.isReg() && MO.getReg() == OldRegImm.Reg) {
      if (MO.isReg() && MO.getReg() == OldRegImm.Reg && MO.isDef()) {
        assert (MI.getOpcode() == RISCV::LW);
        // Don't allow any more updates after optimizing LW where OldReg is
        // defined and don't update this register.
        UpdatesAllowed = false;
        continue;
      }
      // Update reg
      MO.setReg(NewReg);
    }

  // Update offset
  if (MI.getOpcode() == RISCV::LW || MI.getOpcode() == RISCV::SW) {
    MachineOperand &MOImm = MI.getOperand(2);
    MOImm.setImm(MOImm.getImm() & (0b1111100));
  }

  return UpdatesAllowed;
}

bool RISCVCompressRegistersOpt::runOnMachineFunction(MachineFunction &Fn) {
  if (skipFunction(Fn.getFunction()) || !Fn.getFunction().hasOptSize())
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
      // an uncompressible register or offset.
      RegImmPair RegImm = getRegPreventingCompression(MI);
      if (!RegImm.Reg && RegImm.Imm == 0)
        continue;

      // Determine if there is a set of instructions for which replacing this
      // register with a compressed register is possible and will allow
      // compression.
      SmallVector<MachineInstr *, 8> MIs;
      Register NewReg = analyzeCompressibleUses(MBB, MI, RegImm, MIs);
      if (!NewReg)
        continue;

      assert(isInt<12>(RegImm.Imm));
      BuildMI(MBB, MI, MI.getDebugLoc(), TII.get(RISCV::ADDI), NewReg)
        .addReg(RegImm.Reg)
        .addImm(RegImm.Imm);

      // Update the set of instructions to use the compressed register instead.
      // These instructions should now be compressible.
      for (MachineInstr *UpdateMI : MIs)
        if (!updateOperands(*UpdateMI, RegImm, NewReg))
          break;
    }
  }
  return true;
}

/// Returns an instance of the Compress Registers Optimization pass.
FunctionPass *llvm::createRISCVCompressRegistersOptPass() {
  return new RISCVCompressRegistersOpt();
}
