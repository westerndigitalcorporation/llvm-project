// RUN: %clang_cc1 %s -triple riscv32-unknown-elf -verify -fsyntax-only -fcomrv
// RUN: %clang_cc1 %s -triple riscv64-unknown-elf -verify -fsyntax-only -fcomrv

namespace {
class foo {
public:
  static int X() __attribute__((overlaycall)) { return 0; } // expected-error {{RISC-V 'overlaycall' attribute not supported on static functions}}
};
} // end of anonymous namespace

namespace X {
  class bar {
  public:
    static int X() __attribute__((overlaycall)) { return 1; }
  };
} // end of namespace X

extern "C" {
int main(void) { return foo::X() + X::bar::X(); }
}
