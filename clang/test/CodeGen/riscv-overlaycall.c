// RUN: %clang_cc1 %s -triple=riscv64 -fcomrv -emit-llvm -o - \
// RUN:    | FileCheck %s

int __attribute__((overlaycall)) test_overlay_func(void) {
// CHECK-LABEL: define{{.*}}@test_overlay_func() #0 align 4 {
// CHECK: attributes #0 = {
// CHECK-SAME: "overlay-call"
  return 5;
}
