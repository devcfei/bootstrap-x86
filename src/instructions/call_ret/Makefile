all:
	nasm call_ret.asm -o mbr.bin  	
	dd if=mbr.bin of=disk.img bs=512 count=1 seek=0 conv=notrunc 

run: all
	qemu-system-i386 disk.img

dbg: all
	qemu-system-i386 disk.img -gdb tcp::1234 -S

clean:
	rm -f *.bin
	rm -f *.img