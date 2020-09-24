; RUN: llc -mtriple=riscv32 -mattr=+c -filetype=obj < %s \
; RUN:   | llvm-objdump -d --triple=riscv32 --mattr=+c -M no-aliases - \
; RUN:   | FileCheck -check-prefix=RV32IC %s

define void @store_common_value(i32* %a, i32* %b, i32* %c) {
; RV32IC-LABEL: <store_common_value>:
; RV32IC:      c.li a3, 0
; RV32IC-NEXT: c.sw a3, 0(a0)
; RV32IC-NEXT: c.sw a3, 0(a1)
; RV32IC-NEXT: c.sw a3, 0(a2)
; RV32IC-NEXT: c.jr ra
entry:
  store i32 0, i32* %a
  store i32 0, i32* %b
  store i32 0, i32* %c
  ret void
}

define void @store_common_ptr() {
; RV32IC-LABEL: <store_common_ptr>:
; RV32IC:      c.li a0, 1
; RV32IC-NEXT: c.li a1, 0
; RV32IC-NEXT: c.sw a0, 0(a1)
; RV32IC-NEXT: c.li a0, 3
; RV32IC-NEXT: c.sw a0, 0(a1)
; RV32IC-NEXT: c.li a0, 5
; RV32IC-NEXT: c.sw a0, 0(a1)
; RV32IC-NEXT: c.jr ra
entry:
  store volatile i32 1, i32* inttoptr (i32 0 to i32*)
  store volatile i32 3, i32* inttoptr (i32 0 to i32*)
  store volatile i32 5, i32* inttoptr (i32 0 to i32*)
  ret void
}

define void @load_common_ptr() {
; RV32IC-LABEL: <load_common_ptr>:
; RV32IC:      c.li a1, 0
; RV32IC-NEXT: c.lw a0, 0(a1)
; RV32IC-NEXT: c.lw a0, 0(a1)
; RV32IC-NEXT: c.lw a0, 0(a1)
; RV32IC-NEXT: c.jr ra
entry:
  %a = load volatile i32, i32* inttoptr (i32 0 to i32*)
  %b = load volatile i32, i32* inttoptr (i32 0 to i32*)
  %c = load volatile i32, i32* inttoptr (i32 0 to i32*)
  ret void
}
