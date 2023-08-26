C_SOURCES := $(wildcard kernel/*.c)\
			 $(wildcard kernel/drivers/*.c)\
			 $(wildcard kernel/lib/*.c)\
			 $(wildcard kernel/fs/*.c)
GCC_FLAGS := -fno-stack-protector\
			 -I kernel/include\
			 -g\
			 -c
LD_SOURCES := *.asm_o *.o
QEMU_FLAGS := -machine pc\
			  -vga cirrus\
			  -m 256M\
			  -cdrom iLauncherOS.iso
ROOTFS = $(shell find initrd)
TEXTTORM = initrd/
TMPVAR := $(ROOTFS)
ROOTFS = $(subst $(TEXTTORM),, $(TMPVAR))

default: emu

install-requirements:
	@sudo apt install $(cat requirements.txt)

build:
	@ls iLauncherKernel && rm -rf iLauncherKernel || echo
	@ls iLauncherKernel || cp -rf ../iLauncherKernel iLauncherKernel || echo
	@ls iLauncherKernel || git clone https://github.com/iLauncherDev/iLauncherKernel
	@make -C iLauncherKernel
	@cp iLauncherKernel/kernel-i386.bin OS_Files/boot/i386/ilauncher-kernel.bin
	@ls iLauncherKernel && rm -rf iLauncherKernel
	@mkilfs initrd/ 512 OS_Files/boot/ilauncher-initrd.ilrdfs ilrdfs 1.0.0.0
	@grub-mkrescue -o iLauncherOS.iso OS_Files -volid iLauncherOS
	@rm -rf *.o *.asm_o *.bin *.md5 || echo
	@md5sum iLauncherOS.iso >> iLauncherOS.iso.md5

run:
	@md5sum -c iLauncherOS.iso.md5 && qemu-system-x86_64 $(QEMU_FLAGS)

run-uefi:
	@md5sum -c iLauncherOS.iso.md5 && qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd $(QEMU_FLAGS)