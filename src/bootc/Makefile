SRC=$(wildcard *.c)

GCC_WARNINGS=-Wall -Wextra
OPTFLAGS=-Os
CFLAGS=-nostdlib -nostdinc -fno-pic -fno-builtin -fno-stack-protector ${GCC_WARNINGS} \
	   ${OPTFLAGS} -pipe -m32 -march=i386

LD=ld
CC=gcc
ASM=nasm

OBJ=${SRC:.c=.o}


all: mbr.bin bootc.bin
	dd if=mbr.bin of=disk.img bs=512 count=1 seek=0 conv=notrunc 
	dd if=bootc.bin of=disk.img bs=512 count=128 seek=1 conv=notrunc 
	qemu-system-i386 disk.img

mbr.bin: mbr.asm
	${ASM} $< -o mbr.bin


start.o: start.asm
	${ASM} -o $@ $< -f elf

bootc.bin: start.o ${OBJ}
	${LD} -T link.ld -o $@ start.o ${OBJ} -m elf_i386


clean:
	rm -f *.o
	rm -f *.bin
	rm -f *.img

