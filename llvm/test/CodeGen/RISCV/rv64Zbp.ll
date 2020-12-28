; RUN: llc -mtriple=riscv64 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64I
; RUN: llc -mtriple=riscv64 -mattr=+experimental-b -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64IB
; RUN: llc -mtriple=riscv64 -mattr=+experimental-zbp -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64IB

define i64 @gorc1(i64 %a) nounwind {
; RV64I-NOT:    orc.p a0, a0
;
; RV64IB-LABEL: gorc1:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    orc.p a0, a0
; RV64IB-NEXT:    ret
  %and = shl i64 %a, 1
  %shl = and i64 %and, -6148914691236517206
  %and1 = lshr i64 %a, 1
  %shr = and i64 %and1, 6148914691236517205
  %or = or i64 %shr, %a
  %or2 = or i64 %or, %shl
  ret i64 %or2
}

define i64 @gorc2(i64 %a) nounwind {
; RV64I-NOT:    orc2.n a0, a0
;
; RV64IB-LABEL: gorc2:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    orc2.n a0, a0
; RV64IB-NEXT:    ret
  %and = shl i64 %a, 2
  %shl = and i64 %and, -3689348814741910324
  %and1 = lshr i64 %a, 2
  %shr = and i64 %and1, 3689348814741910323
  %or = or i64 %shr, %a
  %or2 = or i64 %or, %shl
  ret i64 %or2
}

define i64 @gorc4(i64 %a) nounwind {
; RV64I-NOT:    orc4.b a0, a0
;
; RV64IB-LABEL: gorc4:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    orc4.b a0, a0
; RV64IB-NEXT:    ret
  %and = shl i64 %a, 4
  %shl = and i64 %and, -1085102592571150096
  %and1 = lshr i64 %a, 4
  %shr = and i64 %and1, 1085102592571150095
  %or = or i64 %shr, %a
  %or2 = or i64 %or, %shl
  ret i64 %or2
}

define i64 @gorc8(i64 %a) nounwind {
; RV64I-NOT:    orc8.h a0, a0
;
; RV64IB-LABEL: gorc8:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    orc8.h a0, a0
; RV64IB-NEXT:    ret
  %and = shl i64 %a, 8
  %shl = and i64 %and, -71777214294589696
  %and1 = lshr i64 %a, 8
  %shr = and i64 %and1, 71777214294589695
  %or = or i64 %shr, %a
  %or2 = or i64 %or, %shl
  ret i64 %or2
}

define i64 @gorc16(i64 %a) nounwind {
; RV64I-NOT:    orc16.w a0, a0
;
; RV64IB-LABEL: gorc16:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    orc16.w a0, a0
; RV64IB-NEXT:    ret
  %and = shl i64 %a, 16
  %shl = and i64 %and, -281470681808896
  %and1 = lshr i64 %a, 16
  %shr = and i64 %and1, 281470681808895
  %or = or i64 %shr, %a
  %or2 = or i64 %or, %shl
  ret i64 %or2
}

define i64 @gorc32(i64 %a) nounwind {
; RV64I-NOT:    orc32 a0, a0
;
; RV64IB-LABEL: gorc32:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    orc32 a0, a0
; RV64IB-NEXT:    ret
  %shl = shl i64 %a, 32
  %shr = lshr i64 %a, 32
  %or = or i64 %shr, %a
  %or2 = or i64 %or, %shl
  ret i64 %or2
}

define i64 @grev1(i64 %a) nounwind {
; RV64I-NOT:    rev.p a0, a0
;
; RV64IB-LABEL: grev1:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    rev.p a0, a0
; RV64IB-NEXT:    ret
  %and = shl i64 %a, 1
  %shl = and i64 %and, -6148914691236517206
  %and1 = lshr i64 %a, 1
  %shr = and i64 %and1, 6148914691236517205
  %or = or i64 %shl, %shr
  ret i64 %or
}

define i64 @grev2(i64 %a) nounwind {
; RV64I-NOT:    rev2.n a0, a0
;
; RV64IB-LABEL: grev2:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    rev2.n a0, a0
; RV64IB-NEXT:    ret
  %and = shl i64 %a, 2
  %shl = and i64 %and, -3689348814741910324
  %and1 = lshr i64 %a, 2
  %shr = and i64 %and1, 3689348814741910323
  %or = or i64 %shl, %shr
  ret i64 %or
}

define i64 @grev4(i64 %a) nounwind {
; RV64I-NOT:    rev4.b a0, a0
;
; RV64IB-LABEL: grev4:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    rev4.b a0, a0
; RV64IB-NEXT:    ret
  %and = shl i64 %a, 4
  %shl = and i64 %and, -1085102592571150096
  %and1 = lshr i64 %a, 4
  %shr = and i64 %and1, 1085102592571150095
  %or = or i64 %shl, %shr
  ret i64 %or
}

define i64 @grev8(i64 %a) nounwind {
; RV64I-NOT:    rev8.h a0, a0
;
; RV64IB-LABEL: grev8:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    rev8.h a0, a0
; RV64IB-NEXT:    ret
  %and = shl i64 %a, 8
  %shl = and i64 %and, -71777214294589696
  %and1 = lshr i64 %a, 8
  %shr = and i64 %and1, 71777214294589695
  %or = or i64 %shl, %shr
  ret i64 %or
}

define i64 @grev16(i64 %a) nounwind {
; RV64I-NOT:    rev16.w a0, a0
;
; RV64IB-LABEL: grev16:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    rev16.w a0, a0
; RV64IB-NEXT:    ret
  %and = shl i64 %a, 16
  %shl = and i64 %and, -281470681808896
  %and1 = lshr i64 %a, 16
  %shr = and i64 %and1, 281470681808895
  %or = or i64 %shl, %shr
  ret i64 %or
}

define i64 @grev32(i64 %a) nounwind {
; RV64I-NOT:    rev32 a0, a0
;
; RV64IB-LABEL: grev32:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    rev32 a0, a0
; RV64IB-NEXT:    ret
  %shl = shl i64 %a, 32
  %shr = lshr i64 %a, 32
  %or = or i64 %shl, %shr
  ret i64 %or
}

declare i64 @llvm.bswap.i64(i64)

define i64 @bswap_i64(i64 %a) {
; RV64I-NOT:    rev8 a0, a0
;
; RV64IB-LABEL: bswap_i64:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    rev8 a0, a0
; RV64IB-NEXT:    ret
  %1 = call i64 @llvm.bswap.i64(i64 %a)
  ret i64 %1
}

declare i64 @llvm.bitreverse.i64(i64)

define i64 @bitreverse_i64(i64 %a) nounwind {
; RV64IB-NOT:    rev a0, a0
;
; RV64IB-LABEL: bitreverse_i64:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    rev a0, a0
; RV64IB-NEXT:    ret
  %1 = call i64 @llvm.bitreverse.i64(i64 %a)
  ret i64 %1
}

define i64 @shfl1(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    zip.n a0, a0
;
; RV64IB-LABEL: shfl1:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    zip.n a0, a0
; RV64IB-NEXT:    ret
  %and = and i64 %a, -7378697629483820647
  %shl = shl i64 %a, 1
  %and1 = and i64 %shl, 4919131752989213764
  %or = or i64 %and1, %and
  %shr = lshr i64 %a, 1
  %and2 = and i64 %shr, 2459565876494606882
  %or3 = or i64 %or, %and2
  ret i64 %or3
}

define i64 @shfl2(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    zip2.b a0, a0
;
; RV64IB-LABEL: shfl2:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    zip2.b a0, a0
; RV64IB-NEXT:    ret
  %and = and i64 %a, -4340410370284600381
  %shl = shl i64 %a, 2
  %and1 = and i64 %shl, 3472328296227680304
  %or = or i64 %and1, %and
  %shr = lshr i64 %a, 2
  %and2 = and i64 %shr, 868082074056920076
  %or3 = or i64 %or, %and2
  ret i64 %or3
}

define i64 @shfl4(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    zip4.h a0, a0
;
; RV64IB-LABEL: shfl4:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    zip4.h a0, a0
; RV64IB-NEXT:    ret
  %and = and i64 %a, -1148435428713435121
  %shl = shl i64 %a, 4
  %and1 = and i64 %shl, 1080880403494997760
  %or = or i64 %and1, %and
  %shr = lshr i64 %a, 4
  %and2 = and i64 %shr, 67555025218437360
  %or3 = or i64 %or, %and2
  ret i64 %or3
}

define i64 @shfl8(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    zip8.w a0, a0
;
; RV64IB-LABEL: shfl8:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    zip8.w a0, a0
; RV64IB-NEXT:    ret
  %and = and i64 %a, -72056494543077121
  %shl = shl i64 %a, 8
  %and1 = and i64 %shl, 71776119077928960
  %or = or i64 %and1, %and
  %shr = lshr i64 %a, 8
  %and2 = and i64 %shr, 280375465148160
  %or3 = or i64 %or, %and2
  ret i64 %or3
}

define i64 @shfl16(i64 %a, i64 %b) nounwind {
; RV64I-NOT:    zip16 a0, a0
;
; RV64IB-LABEL: shfl16:
; RV64IB:       # %bb.0:
; RV64IB-NEXT:    zip16 a0, a0
; RV64IB-NEXT:    ret
  %and = and i64 %a, -281474976645121
  %shl = shl i64 %a, 16
  %and1 = and i64 %shl, 281470681743360
  %or = or i64 %and1, %and
  %shr = lshr i64 %a, 16
  %and2 = and i64 %shr, 4294901760
  %or3 = or i64 %or, %and2
  ret i64 %or3
}
