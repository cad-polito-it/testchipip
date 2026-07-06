/* ================================================================
     * Ibex boot ROM (Chipyard). Two Ibex-specific constraints:
     *  1) reset PC = boot_addr_i + 0x80  -> reset vector at 0x10080
     *  2) mtvec is WARL-forced to vectored: {base[31:8],6'b0,2'b01}.
     *     interrupts -> base + 4*cause ; exceptions -> base+0.
     *     wakeup IPI = machine software interrupt = cause 3 -> base+0xC.
     * ================================================================ */

    /* 0x10000: anchor so objcopy's binary origin == ROM_BASE (see linker) */
    .section .text.resetanchor, "ax", @progbits
    j _hang80

    /* 0x10080: Ibex reset vector — trampoline only */
    .section .text.hang80, "ax", @progbits
    .globl _hang80
_hang80:
    j _hang

    /* 0x10100: reset path — set the vectored trap base, enable the
     * software interrupt, sleep until the frontend server posts the IPI */
    .section .text.hang, "ax", @progbits
    .globl _hang
_hang:
    la    a0, _trap_vec        /* 256-aligned; Ibex forces vectored mode */
    csrw  mtvec, a0
    li    a0, (1 << 3)         /* mie.MSIE  */
    csrw  mie, a0
    li    a0, (1 << 3)         /* mstatus.MIE (global) */
    csrs  mstatus, a0
1:  wfi
    j     1b

    /* 0x10200: vectored trap table (256-aligned) + dispatch.
     * norvc is REQUIRED: with RVC, `j` compresses to a 2-byte c.j and the
     * 4-byte-per-slot stride breaks. Forcing 32-bit JALs keeps slot N at
     * base + 4*N. */
    .section .text.vec, "ax", @progbits
    .balign 256
    .option push
    .option norvc
    .globl _trap_vec
_trap_vec:
    j _park                    /* +0x00  all synchronous exceptions */
    j _park                    /* +0x04  cause 1 */
    j _park                    /* +0x08  cause 2 */
    j _boot                    /* +0x0C  cause 3 = M software interrupt (IPI) */
    .option pop

_park:
    j _park                    /* deterministic, identifiable hang on any stray trap */

_boot:
    /* single-hart Ibex; reached only via the IPI slot, so set up everything */
    li    a1, 0x02000000       /* CLINT base = &MSIP[0] */
    sw    zero, 0(a1)          /* ack: clear our own MSIP so it can't re-fire */
    li    t0, 0x1000
    lw    a0, 0(t0)            /* payload entry (written by TSI/FESVR) */
    csrw  mepc, a0
    csrr  a0, mhartid          /* a0 = 0 -> payload arg0 */
    la    a1, _dtb             /* a1 -> DTB -> payload arg1 */
    li    a2, (1 << 7)         /* mstatus.MPIE */
    csrc  mstatus, a2          /* payload starts with interrupts off */
    mret

    /* 0x10300: device tree blob, appended by the build */
    .section .rodata.dtb, "a", @progbits
    .globl _dtb
_dtb: