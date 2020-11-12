//===-- restore.S - restore up to 12 callee-save registers ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Multiple entry points depending on number of registers to restore
//
//===----------------------------------------------------------------------===//

#include "save_restore.h"

  // All of the entry points are in the same section since we rely on
  // them falling through into each other and don't want the linker to
  // accidentally split them up, garbage collect, or reorder them.
	.text
	.align  2

	.globl  __riscv_restore_12
	.type   __riscv_restore_12,@function
__riscv_restore_12:
  LOAD    s11, (3*STRIDE)(sp)
  addi    sp, sp, 4*STRIDE
  // fallthrough into __riscv_restore_11/10/9/8

	.globl  __riscv_restore_11
	.type   __riscv_restore_11,@function
	.globl  __riscv_restore_10
	.type   __riscv_restore_10,@function
	.globl  __riscv_restore_9
	.type   __riscv_restore_9,@function
	.globl  __riscv_restore_8
	.type   __riscv_restore_8,@function
__riscv_restore_11:
__riscv_restore_10:
__riscv_restore_9:
__riscv_restore_8:
  LOAD    s10, (0*STRIDE)(sp)
  LOAD    s9,  (1*STRIDE)(sp)
  LOAD    s8,  (2*STRIDE)(sp)
  LOAD    s7,  (3*STRIDE)(sp)
  addi    sp, sp, 4*STRIDE
  // fallthrough into __riscv_restore_7/6/5/4

	.globl  __riscv_restore_7
	.type   __riscv_restore_7,@function
	.globl  __riscv_restore_6
	.type   __riscv_restore_6,@function
	.globl  __riscv_restore_5
	.type   __riscv_restore_5,@function
	.globl  __riscv_restore_4
	.type   __riscv_restore_4,@function
__riscv_restore_7:
__riscv_restore_6:
__riscv_restore_5:
__riscv_restore_4:
  LOAD    s6,  (0*STRIDE)(sp) 
  LOAD    s5,  (1*STRIDE)(sp)
  LOAD    s4,  (2*STRIDE)(sp)
  LOAD    s3,  (3*STRIDE)(sp)
  addi    sp, sp, 4*STRIDE
  // fallthrough into __riscv_restore_3/2/1/0

	.globl  __riscv_restore_3
	.type   __riscv_restore_3,@function
	.globl  __riscv_restore_2
	.type   __riscv_restore_2,@function
	.globl  __riscv_restore_1
	.type   __riscv_restore_1,@function
	.globl  __riscv_restore_0
	.type   __riscv_restore_0,@function
__riscv_restore_3:
__riscv_restore_2:
__riscv_restore_1:
__riscv_restore_0:
  LOAD    s2,  (0*STRIDE)(sp)
  LOAD    s1,  (1*STRIDE)(sp)
  LOAD    s0,  (2*STRIDE)(sp)
  LOAD    ra,  (3*STRIDE)(sp)
  addi    sp, sp, 4*STRIDE
  ret
