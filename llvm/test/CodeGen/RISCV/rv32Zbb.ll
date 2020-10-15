; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I
; RUN: llc -mtriple=riscv32 -mattr=+experimental-b -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32IB
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbb -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32IB

define i32 @slo(i32 %a, i32 %b) nounwind {
; RV32I-NOT:    slo a0, a0, a1
;
; RV32IB-LABEL: slo:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    slo a0, a0, a1
; RV32IB-NEXT:    ret
  %neg = xor i32 %a, -1
  %shl = shl i32 %neg, %b
  %neg1 = xor i32 %shl, -1
  ret i32 %neg1
}

define i32 @sro(i32 %a, i32 %b) nounwind {
; RV32I-NOT:    sro a0, a0, a1
;
; RV32IB-LABEL: sro:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    sro a0, a0, a1
; RV32IB-NEXT:    ret
  %neg = xor i32 %a, -1
  %shr = lshr i32 %neg, %b
  %neg1 = xor i32 %shr, -1
  ret i32 %neg1
}

declare i32 @llvm.ctlz.i32(i32, i1)

define i32 @ctlz_i32(i32 %a) nounwind {
; RV32I-NOT:    clz a0, a0
;
; RV32IB-LABEL: ctlz_i32:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    beqz a0, .LBB2_2
; RV32IB-NEXT:  # %bb.1: # %cond.false
; RV32IB-NEXT:    clz a0, a0
; RV32IB-NEXT:    ret
; RV32IB-NEXT:  .LBB2_2:
; RV32IB-NEXT:    addi a0, zero, 32
; RV32IB-NEXT:    ret
  %1 = call i32 @llvm.ctlz.i32(i32 %a, i1 false)
  ret i32 %1
}

declare i32 @llvm.cttz.i32(i32, i1)

define i32 @cttz_i32(i32 %a) nounwind {
; RV32I-NOT:    ctz a0, a0
;
; RV32IB-LABEL: cttz_i32:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    beqz a0, .LBB3_2
; RV32IB-NEXT:  # %bb.1: # %cond.false
; RV32IB-NEXT:    ctz a0, a0
; RV32IB-NEXT:    ret
; RV32IB-NEXT:  .LBB3_2:
; RV32IB-NEXT:    addi a0, zero, 32
; RV32IB-NEXT:    ret
  %1 = call i32 @llvm.cttz.i32(i32 %a, i1 false)
  ret i32 %1
}

declare i32 @llvm.ctpop.i32(i32)

define i32 @ctpop_i32(i32 %a) nounwind {
; RV32I-NOT:    pcnt a0, a0
;
; RV32IB-LABEL: ctpop_i32:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    pcnt a0, a0
; RV32IB-NEXT:    ret
  %1 = call i32 @llvm.ctpop.i32(i32 %a)
  ret i32 %1
}

define i32 @sextb(i32 %a) nounwind {
; RV32I-NOT:    sext.b a0, a0
;
; RV32IB-LABEL: sextb:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    sext.b a0, a0
; RV32IB-NEXT:    ret
  %shl = shl i32 %a, 24
  %shr = ashr exact i32 %shl, 24
  ret i32 %shr
}

define i32 @sexth(i32 %a) nounwind {
; RV32I-NOT:    sext.h a0, a0
;
; RV32IB-LABEL: sexth:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    sext.h a0, a0
; RV32IB-NEXT:    ret
  %shl = shl i32 %a, 16
  %shr = ashr exact i32 %shl, 16
  ret i32 %shr
}

define i32 @min(i32 %a, i32 %b) nounwind {
; RV32I-NOT:    min a0, a0, a1
;
; RV32IB-LABEL: min:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    min a0, a0, a1
; RV32IB-NEXT:    ret
  %cmp = icmp slt i32 %a, %b
  %cond = select i1 %cmp, i32 %a, i32 %b
  ret i32 %cond
}

define i32 @max(i32 %a, i32 %b) nounwind {
; RV32I-NOT:    max a0, a0, a1
;
; RV32IB-LABEL: max:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    max a0, a0, a1
; RV32IB-NEXT:    ret
  %cmp = icmp sgt i32 %a, %b
  %cond = select i1 %cmp, i32 %a, i32 %b
  ret i32 %cond
}

define i32 @minu(i32 %a, i32 %b) nounwind {
; RV32I-NOT:    minu a0, a0, a1
;
; RV32IB-LABEL: minu:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    minu a0, a0, a1
; RV32IB-NEXT:    ret
  %cmp = icmp ult i32 %a, %b
  %cond = select i1 %cmp, i32 %a, i32 %b
  ret i32 %cond
}

define i32 @maxu(i32 %a, i32 %b) nounwind {
; RV32I-NOT:    maxu a0, a0, a1
;
; RV32IB-LABEL: maxu:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    maxu a0, a0, a1
; RV32IB-NEXT:    ret
  %cmp = icmp ugt i32 %a, %b
  %cond = select i1 %cmp, i32 %a, i32 %b
  ret i32 %cond
}
