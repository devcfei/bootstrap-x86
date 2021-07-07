all:
	nasm stage2.asm -o stage2.bin
	dd if=stage2.bin of=disk.img bs=512 count=2 seek=0 conv=notrunc 
	qemu-system-i386 disk.img

clean:
	rm -f *.bin
	rm -f *.img