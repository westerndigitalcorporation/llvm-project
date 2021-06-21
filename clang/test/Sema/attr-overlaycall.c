// RUN: %clang_cc1 -triple riscv32 -fcomrv -fsyntax-only -verify %s
// RUN: %clang_cc1 -triple riscv64 -fcomrv -fsyntax-only -verify %s

int notAFunction __attribute__((overlaycall));
// expected-warning@-1 {{'overlaycall' attribute only applies to functions}}

void incompatForwardDecl(int x);
void __attribute__((overlaycall)) incompatForwardDecl(int x) {}
// expected-error@-1 {{redeclaration of 'incompatForwardDecl' must not have the RISC-V 'overlaycall' attribute}}
// expected-note@-3 {{previous definition is here}}

static void staticcall() __attribute__((overlaycall)) {}
// expected-error@-1 {{attribute not supported on static functions}}
// expected-warning@-2 {{GCC does not allow 'overlaycall' attribute in this position on a function definition}}

static void __attribute__((overlaycall)) staticcall2(){}
// expected-error@-1 {{attribute not supported on static functions}}
