; RUN: llc -mtriple=riscv64 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64I
; RUN: llc -mtriple=riscv64 -mattr=+experimental-b -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64IB
; RUN: llc -mtriple=riscv64 -mattr=+experimental-zbb -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64IB
; RUN: llc -mtriple=riscv64 -mattr=+experimental-zbp -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64IB

define i64 @andn(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    andn a0, a0, a1
;
; RV64IB-LABEL: andn:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    andn a0, a0, a1
; RV64IB-NEXT:    ret
  %neg = xor i64 %b, -1
  %and = and i64 %neg, %a
  ret i64 %and
}

define i64 @orn(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    orn a0, a0, a1
;
; RV64IB-LABEL: orn:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    orn a0, a0, a1
; RV64IB-NEXT:    ret
  %neg = xor i64 %b, -1
  %or = or i64 %neg, %a
  ret i64 %or
}

define i64 @xnor(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    xnor a0, a0, a1
;
; RV64IB-LABEL: xnor:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    xnor a0, a0, a1
; RV64IB-NEXT:    ret
  %neg = xor i64 %a, -1
  %xor = xor i64 %neg, %b
  ret i64 %xor
}

declare i64 @llvm.fshl.i64(i64, i64, i64)

define i64 @rol(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    rol a0, a0, a1
;
; RV64IB-LABEL: rol:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    rol a0, a0, a1
; RV64IB-NEXT:    ret
  %or = tail call i64 @llvm.fshl.i64(i64 %a, i64 %a, i64 %b)
  ret i64 %or
}

declare i64 @llvm.fshr.i64(i64, i64, i64)

define i64 @ror(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    ror a0, a0, a1
;
; RV64IB-LABEL: ror:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    ror a0, a0, a1
; RV64IB-NEXT:    ret
  %or = tail call i64 @llvm.fshr.i64(i64 %a, i64 %a, i64 %b)
  ret i64 %or
}

define i64 @pack(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    pack a0, a0, a1
;
; RV64IB-LABEL: pack:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    pack a0, a0, a1
; RV64IB-NEXT:    ret
  %shl = and i64 %a, 4294967295
  %shl1 = shl i64 %b, 32
  %or = or i64 %shl1, %shl
  ret i64 %or
}

define i64 @packu(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    packu a0, a0, a1
;
; RV64IB-LABEL: packu:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    packu a0, a0, a1
; RV64IB-NEXT:    ret
  %shr = lshr i64 %a, 32
  %shr1 = and i64 %b, -4294967296
  %or = or i64 %shr1, %shr
  ret i64 %or
}

define i64 @packh(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    packh a0, a0, a1
;
; RV64IB-LABEL: packh:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    packh a0, a0, a1
; RV64IB-NEXT:    ret
  %and = and i64 %a, 255
  %and1 = shl i64 %b, 8
  %shl = and i64 %and1, 65280
  %or = or i64 %shl, %and
  ret i64 %or
}
