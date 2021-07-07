%define org_start 7c00h

 
boot:
	org org_start
	mov ax, cs
	mov ds, ax
	mov es, ax
	call screenClean
	call stringPrint
	jmp $
	

screenClean:
	push bp
	mov bp, sp
	pusha

	mov ah, 07h		; tells BIOS to scroll down window
	mov al, 00h		; clear entire window
	mov bh, 07h		; white on black
	mov cx, 00h		; specifies top left of screen as (0,0)
	mov dh, 18h		; 18h = 24 rows of chars
	mov dl, 4fh		; 4fh = 79 cols of chars
	int 10h			; calls video interrupt
	popa
	mov sp, bp
	pop bp
	ret	

stringPrint:
	mov bp, helloString
	mov cx, [helloStringSize]
	mov ax, 01301h
	mov bx, 000ch
	mov dx, 0000h
	int 10h;
	ret
	
helloString:
	db "Hello, world!"
helloStringSize:
	db $-helloString
 
fill:
	times 510-($-$$) db 0;
	dw 0xaa55				; MBR signature