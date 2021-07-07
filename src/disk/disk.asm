%define org_start 7c00h


boot:
	org org_start
	cli
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	sti
	
	;=============
	mov ax, cs
	mov ds, ax
	mov es, ax
	call screenClean
	call messagePrint
	call sectorRead
	call sectorWrite
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

sectorRead:
	mov ax, 0		; Set ES:BX to 0:0200h
	mov es, ax
	mov bx, 200h
	
	mov al, 1		; Sector count = 1
	mov dl, 80h		; Hard disk 80h=C: 81h=D:
	mov dh, 0		; Disk heads
	mov ch, 0		; Disk cylinders
	mov cl, 1		; Sector number 1
	mov ah, 2		; Read
	int 13h
	ret
	
sectorWrite:
	mov ax, 0		; Set ES:BX to 0:0200h
	mov es, ax
	mov bx, 200h
	
	mov al, 1		; Sector count = 1
	mov dl, 80h		; Hard disk 80h=C: 81h=D:
	mov dh, 0		; Disk heads
	mov ch, 0		; Disk cylinders
	mov cl, 2		; Sector number 2
	mov ah, 3  		; Write
	int 13h
	ret
	
messagePrint:
	mov bp, strMessage
	mov cx, [szMessage]
	mov ax, 01301h
	mov bx, 000ch
	mov dx, 0000h
	int 10h;
	ret
	
strMessage:
	db "Write sector 1 to sector 2!"
szMessage:
	db $-strMessage

fillPad:
	times 510-($-$$) db 0;
	dw 0xaa55				; MBR signature