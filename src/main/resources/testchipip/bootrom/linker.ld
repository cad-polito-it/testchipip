OUTPUT_ARCH("riscv")
ENTRY(_hang80)

SECTIONS
{
  ROM_BASE = 0x10000;

  . = ROM_BASE;                 /* 0x10000 : image anchor (objcopy origin) */
  .text.resetanchor : { KEEP(*(.text.resetanchor)) }

  . = ROM_BASE + 0x080;         /* 0x10080 : reset vector (trampoline) */
  .text.hang80 : { KEEP(*(.text.hang80)) }

  . = ROM_BASE + 0x100;         /* 0x10100 : reset path */
  .text.hang : { KEEP(*(.text.hang)) }

  . = ROM_BASE + 0x200;         /* 0x10200 : vectored trap table + dispatch (256-aligned!) */
  .text.vec : { KEEP(*(.text.vec)) }

  . = ROM_BASE + 0x300;         /* 0x10300 : DTB */
  .rodata.dtb : { KEEP(*(.rodata.dtb)) }
}