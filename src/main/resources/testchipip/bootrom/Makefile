# --------------------------------------------------------------------------
# Targets
# --------------------------------------------------------------------------
bootrom_img  = bootrom.rv64.img bootrom.rv32.img bootrom.radiance.rv32.img \
               bootrom.ibex.rv32.img
bootrom_dump = bootrom.rv64.dump bootrom.rv32.dump bootrom.radiance.rv32.dump \
               bootrom.ibex.rv32.dump

# --------------------------------------------------------------------------
# Toolchain — override on the command line if riscv64-unknown-elf-* is in PATH
#   e.g.  make GCC=riscv64-unknown-elf-gcc
# --------------------------------------------------------------------------
GCC     ?= riscv64-unknown-elf-gcc
OBJCOPY ?= riscv64-unknown-elf-objcopy
OBJDUMP ?= riscv64-unknown-elf-objdump

GCC_32     ?= ${RISCV_32}/riscv64-unknown-elf-gcc
OBJCOPY_32 ?= ${RISCV_32}/riscv64-unknown-elf-objcopy
OBJDUMP_32 ?= ${RISCV_32}/riscv64-unknown-elf-objdump

# --------------------------------------------------------------------------
# Compiler flags
# --------------------------------------------------------------------------
CFLAGS_RV64      = -mabi=lp64  -march=rv64ima_zicsr
CFLAGS_RV32      = -mabi=ilp32 -march=rv32ima_zicsr
CFLAGS_RV32_32 = -mabi=ilp32 -march=rv32imc_zicsr

# --------------------------------------------------------------------------
.PHONY: default img dump clean

default: img dump

img:  $(bootrom_img)
dump: $(bootrom_dump)

# --------------------------------------------------------------------------
# Binary images
# --------------------------------------------------------------------------
%.img: %.elf
	$(OBJCOPY) -O binary --change-addresses=-0x10000 $< $@

# --------------------------------------------------------------------------
# Disassembly
# --------------------------------------------------------------------------
%.dump: %.elf
	$(OBJDUMP) -d $< > $@

# --------------------------------------------------------------------------
# Generic ELF rules
# --------------------------------------------------------------------------
%.rv64.elf: %.S linker.ld
	$(GCC) $(CFLAGS_RV64) -Tlinker.ld $< -nostdlib -static -o $@

%.rv32.elf: %.S linker.ld
	$(GCC) $(CFLAGS_RV32) -Tlinker.ld $< -nostdlib -static -o $@

# --------------------------------------------------------------------------
# Ibex-specific ELF
# --------------------------------------------------------------------------
bootrom.ibex.rv32.elf: bootrom-ibex.S linker-ibex.ld
	$(GCC_32) $(CFLAGS_RV32_32) -Tlinker-ibex.ld $< -nostdlib -static -o $@

bootrom.ibex.rv32.img: bootrom.ibex.rv32.elf
	$(OBJCOPY_32) -O binary --change-addresses=-0x10000 $< $@

bootrom.ibex.rv32.dump: bootrom.ibex.rv32.img
	$(OBJDUMP_32) -d $< > $@

# --------------------------------------------------------------------------
clean:
	rm -f *.elf *.dump *.img