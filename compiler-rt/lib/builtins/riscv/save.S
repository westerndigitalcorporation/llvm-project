//===-- save_3_0.S - save up to 12 callee-saved registers -----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Multiple entry points depending on number of registers to save
//
//===----------------------------------------------------------------------===//

#include "save_restore.h"

  .text
  .align 2

  .globl  __riscv_save_12
  .type   __riscv_save_12,@function
__riscv_save_12:
  addi   sp, sp, -16*STRIDE
  mv     t1, zero
  STORE  s11, (3*STRIDE)(sp)
  j      .Lriscv_save_11_8

	.globl  __riscv_save_11
	.type   __riscv_save_11,@function
	.globl  __riscv_save_10
	.type   __riscv_save_10,@function
	.globl  __riscv_save_9
	.type   __riscv_save_9,@function
	.globl  __riscv_save_8
	.type   __riscv_save_8,@function
__riscv_save_11:
__riscv_save_10:
__riscv_save_9:
__riscv_save_8:
  addi   sp, sp, -16*STRIDE
  li     t1, -4*STRIDE
.Lriscv_save_11_8:
  STORE  s10, (4*STRIDE)(sp)
  STORE  s9,  (5*STRIDE)(sp)
  STORE  s8,  (6*STRIDE)(sp)
  STORE  s7,  (7*STRIDE)(sp)
  j      .Lriscv_save_7_4

	.globl  __riscv_save_7
	.type   __riscv_save_7,@function
	.globl  __riscv_save_6
	.type   __riscv_save_6,@function
	.globl  __riscv_save_5
	.type   __riscv_save_5,@function
	.globl  __riscv_save_4
	.type   __riscv_save_4,@function
__riscv_save_7:
__riscv_save_6:
__riscv_save_5:
__riscv_save_4:
  addi   sp, sp, -16*STRIDE
  li     t1, -8*STRIDE
.Lriscv_save_7_4:
  STORE  s6, (8*STRIDE)(sp)
  STORE  s5, (9*STRIDE)(sp)
  STORE  s4, (10*STRIDE)(sp)
  STORE  s3, (11*STRIDE)(sp)
  STORE  s2, (12*STRIDE)(sp)
  STORE  s1, (13*STRIDE)(sp)
  STORE  s0, (14*STRIDE)(sp)
  STORE  ra, (15*STRIDE)(sp)
  sub    sp, sp, t1
  jr     t0

	.globl  __riscv_save_3
	.type   __riscv_save_3,@function
	.globl  __riscv_save_2
	.type   __riscv_save_2,@function
	.globl  __riscv_save_1
	.type   __riscv_save_1,@function
	.globl  __riscv_save_0
	.type   __riscv_save_0,@function
__riscv_save_3:
__riscv_save_2:
__riscv_save_1:
__riscv_save_0:
  addi    sp, sp, -4*STRIDE
  STORE   s2,  (0*STRIDE)(sp)
  STORE   s1,  (1*STRIDE)(sp)
  STORE   s0,  (2*STRIDE)(sp)
  STORE   ra,  (3*STRIDE)(sp)
  jr      t0
