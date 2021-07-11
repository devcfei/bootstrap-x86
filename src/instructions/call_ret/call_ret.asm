%define org_start 7c00h

 
boot:
	org org_start
	mov ax, cs
	mov ds, ax
	mov es, ax
    ;mov ss, ax
	call screenClean

    mov ax, relocate
    push ax
    
    mov ax, stringPrint
    push ax
    ret

relocate:
    call stringPrint2
	
    
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
	mov bp, msg
	mov cx, [msgSize]
	mov ax, 01301h
	mov bx, 000ch
	mov dx, 0000h   ; line 1
	int 10h;
	ret

stringPrint2:
	mov bp, msg
	mov cx, [msgSize]
	mov ax, 01301h
	mov bx, 000ch
	mov bl, 02h
	mov dx, 0100h   ; line 0
	int 10h;
    ret
	
msg:
	db "instructions: call and ret!"
msgSize:
	db $-msg



fill:
	times 510-($-$$) db 0;
	dw 0xaa55				; MBR signature