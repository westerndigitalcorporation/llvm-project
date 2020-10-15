; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I
; RUN: llc -mtriple=riscv32 -mattr=+experimental-b -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32IB
; RUN: llc -mtriple=riscv32 -mattr=+experimental-zbs -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32IB

define i32 @sbclr(i32 %a, i32 %b) nounwind {
; RV32I-NOT:    sbclr a0, a0, a1
;
; RV32IB-LABEL: sbclr:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    sbclr a0, a0, a1
; RV32IB-NEXT:    ret
  %shl = shl i32 1, %b
  %neg = xor i32 %shl, -1
  %and = and i32 %neg, %a
  ret i32 %and
}

define i32 @sbset(i32 %a, i32 %b) nounwind {
; RV32I-NOT:    sbset a0, a0, a1
;
; RV32IB-LABEL: sbset:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    sbset a0, a0, a1
; RV32IB-NEXT:    ret
  %shl = shl i32 1, %b
  %or = or i32 %shl, %a
  ret i32 %or
}

define dso_local i32 @sbinv(i32 %a, i32 %b) nounwind {
; RV32I-NOT:    sbinv a0, a0, a1
;
; RV32IB-LABEL: sbinv:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    sbinv a0, a0, a1
; RV32IB-NEXT:    ret
  %shl = shl i32 1, %b
  %xor = xor i32 %shl, %a
  ret i32 %xor
}

define i32 @sbext(i32 %a, i32 %b) nounwind {
; RV32I-NOT:    sbext a0, a0, a1
;
; RV32IB-LABEL: sbext:
; RV32IB:       # %bb.0:
; RV32IB-NEXT:    sbext a0, a0, a1
; RV32IB-NEXT:    ret
  %shr = lshr i32 %a, %b
  %and = and i32 %shr, 1
  ret i32 %and
}
