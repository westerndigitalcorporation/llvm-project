
// Helper macros:
//   LOAD    The appropriate mnemonic for the load instruction which
//           depends on XLEN.
//   STORE   The appropriate mnemonic for the store instruction which
//           depends on XLEN.
//   STRIDE  The width of the loads/stores in bytes, equivalent to the stride
//           between each save/restored register.
#if __riscv_xlen == 32
  #define LOAD lw
  #define STORE sw
  #define STRIDE 4
#elif __riscv_xlen == 64
  #define LOAD ld
  #define STORE sd
  #define STRIDE 8
#else
  #error "xlen must be 32 or 64 for save-restore implementation
#endif

