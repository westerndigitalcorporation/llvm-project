; RUN: opt -S -mtriple=amdgcn-- -amdgpu-lower-module-lds < %s | FileCheck %s
; RUN: opt -S -mtriple=amdgcn-- -passes=amdgpu-lower-module-lds < %s | FileCheck %s

; CHECK: %llvm.amdgcn.module.lds.t = type { float, float }

@func = addrspace(3) global float undef, align 4

; @kern is only used from a kernel so it is left unchanged
; CHECK: @kern = addrspace(3) global float undef, align 4
@kern = addrspace(3) global float undef, align 4

; @func is only used from a non-kernel function so is rewritten
; CHECK-NOT: @func
; @both is used from a non-kernel function so is rewritten
; CHECK-NOT: @both
; sorted both < func, so @both at null and @func at 4
@both = addrspace(3) global float undef, align 4

; CHECK: @llvm.amdgcn.module.lds = internal addrspace(3) global %llvm.amdgcn.module.lds.t undef, align 4

; CHECK-LABEL: @get_func()
; CHECK: %0 = load i32, i32* inttoptr (i64 add (i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* getelementptr inbounds (%llvm.amdgcn.module.lds.t, %llvm.amdgcn.module.lds.t addrspace(3)* @llvm.amdgcn.module.lds, i32 0, i32 1) to i32 addrspace(3)*) to i32*) to i64), i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* getelementptr inbounds (%llvm.amdgcn.module.lds.t, %llvm.amdgcn.module.lds.t addrspace(3)* @llvm.amdgcn.module.lds, i32 0, i32 1) to i32 addrspace(3)*) to i32*) to i64)) to i32*), align 4
define i32 @get_func() local_unnamed_addr #0 {
entry:
  %0 = load i32, i32* inttoptr (i64 add (i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* @func to i32 addrspace(3)*) to i32*) to i64), i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* @func to i32 addrspace(3)*) to i32*) to i64)) to i32*), align 4
  ret i32 %0
}

; CHECK-LABEL: @set_func(i32 %x)
; CHECK:  store i32 %x, i32* inttoptr (i64 add (i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (%llvm.amdgcn.module.lds.t addrspace(3)* @llvm.amdgcn.module.lds to i32 addrspace(3)*) to i32*) to i64), i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (%llvm.amdgcn.module.lds.t addrspace(3)* @llvm.amdgcn.module.lds to i32 addrspace(3)*) to i32*) to i64)) to i32*), align 4
define void @set_func(i32 %x) local_unnamed_addr #1 {
entry:
  store i32 %x, i32* inttoptr (i64 add (i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* @both to i32 addrspace(3)*) to i32*) to i64), i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* @both to i32 addrspace(3)*) to i32*) to i64)) to i32*), align 4
  ret void
}

; CHECK-LABEL: @timestwo()
; CHECK: call void @llvm.donothing() [ "ExplicitUse"(%llvm.amdgcn.module.lds.t addrspace(3)* @llvm.amdgcn.module.lds) ]
; CHECK: %ld = load i32, i32* inttoptr (i64 add (i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (%llvm.amdgcn.module.lds.t addrspace(3)* @llvm.amdgcn.module.lds to i32 addrspace(3)*) to i32*) to i64), i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* @kern to i32 addrspace(3)*) to i32*) to i64)) to i32*), align 4
; CHECK: %mul = mul i32 %ld, 2
; CHECK: store i32 %mul, i32* inttoptr (i64 add (i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* @kern to i32 addrspace(3)*) to i32*) to i64), i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (%llvm.amdgcn.module.lds.t addrspace(3)* @llvm.amdgcn.module.lds to i32 addrspace(3)*) to i32*) to i64)) to i32*), align 4
define amdgpu_kernel void @timestwo() {
  %ld = load i32, i32* inttoptr (i64 add (i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* @both to i32 addrspace(3)*) to i32*) to i64), i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* @kern to i32 addrspace(3)*) to i32*) to i64)) to i32*), align 4
  %mul = mul i32 %ld, 2
  store i32 %mul, i32* inttoptr (i64 add (i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* @kern to i32 addrspace(3)*) to i32*) to i64), i64 ptrtoint (i32* addrspacecast (i32 addrspace(3)* bitcast (float addrspace(3)* @both to i32 addrspace(3)*) to i32*) to i64)) to i32*), align 4
  ret void
}
