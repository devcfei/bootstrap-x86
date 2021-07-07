all:
	nasm pmode.asm -o pmode.bin  	
	dd if=pmode.bin of=disk.img bs=512 count=1 seek=0 conv=notrunc 
	qemu-system-i386 disk.img

clean:
	rm -f *.bin
	rm -f *.img