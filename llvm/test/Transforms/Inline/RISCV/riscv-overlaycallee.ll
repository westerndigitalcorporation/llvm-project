; RUN: opt -inline -S %s | FileCheck %s
; RUN: opt -passes='cgscc(inline)' -S %s | FileCheck %s

define void @f() {
entry:
  tail call void @g()
  unreachable

; CHECK-LABEL: @f
; CHECK: call
}

define void @g() #0 {
entry:
; CHECK-LABEL: @g
  unreachable
}

attributes #0 = { "overlay-call" }
