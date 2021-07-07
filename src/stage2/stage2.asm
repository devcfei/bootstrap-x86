%define org_start 7c00h


boot:
	org 0x7C00
	mov ax, cs
	mov ds, ax
	mov es, ax

    ;mov ax, 07E0h		; 07E0h = (07C00h+200h)/10h, beginning of stack segment.
	mov ax, 0800h		; 0800h = (07E00h+200h)/10h, beginning of stack segment.
	mov ss, ax
	mov sp, 2000h		; 8k of stack space.

    call screenClean

    push 0000h
	call cursorMove
	add sp, 2

	push msg
	call printString
	add sp, 2

	call sectorRead

	;call sectorWrite
	jmp stage2


	jmp $


screenClean:
	push bp
	mov bp, sp
	pusha

	mov ah, 07h		; tells BIOS to scroll down window
	mov al, 00h		; clear entire window
    mov bh, 07h    	; white on black
	mov cx, 00h  	; specifies top left of screen as (0,0)
	mov dh, 18h		; 18h = 24 rows of chars
	mov dl, 4fh		; 4fh = 79 cols of chars
	int 10h			; calls video interrupt
	popa
	mov sp, bp
	pop bp
	ret	

cursorMove:
	push bp
	mov bp, sp
	pusha
	mov dx, [bp+4] 		; get the argument from the stack. |bp| = 2, |arg| = 2
	mov ah, 02h 		; set cursor position
	mov bh, 00h		    ; page 0 - doesn't matter, we're not using double-buffering
	int 10h
	popa
	mov sp, bp
	pop bp
	ret

printString:
	push bp
	mov bp, sp
	pusha
	mov si, [bp+4]	 	; grab the pointer to the data
	mov bh, 00h	        ; page number, 0 again
	mov bl, 00h		    ; foreground color, irrelevant - in text mode
	mov ah, 0Eh  		; print character to TTY
 .char:
	mov al, [si]   		; get the current char from our pointer position
	add si, 1		    ; keep incrementing si until we see a null char
	or al, 0
	je .return        	; end if the string is done
	int 10h         	; print the character if we're not done
	jmp .char	  	    ; keep looping
 .return:
	popa
	mov sp, bp
	pop bp
	ret
	

sectorRead:
	mov ax, 07c0h		; Set ES:BX to 07c0h:0200h
	mov es, ax
	mov bx, 200h
	
	mov al, 1		; Sector count = 1
	mov dl, 80h		; Hard disk 80h=C: 81h=D:
	mov dh, 0		; Disk heads
	mov ch, 0		; Disk cylinders
	mov cl, 2		; Sector number
	mov ah, 2		; Read
	int 13h
	ret

sectorWrite:
	mov ax, 07c0h		; Set ES:BX to 07c0h:0200h
	mov es, ax
	mov bx, 200h
	
	mov al, 1		; Sector count = 1
	mov dl, 80h		; Hard disk 80h=C: 81h=D:
	mov dh, 0		; Disk heads
	mov ch, 0		; Disk cylinders
	mov cl, 3		; Sector number
	mov ah, 3  		; Write
	int 13h
	ret


msg:
	db "Booting...",13,0

msg_dot:
	db ".",13,0


fill:
	times 510-($-$$) db 0;
	dw 0xaa55				; MBR signature

;=================================================================
; Stage 2 start from 07e00h
; 	Video RAM start 0x000b8000
;=================================================================
stage2:
    push 0100h
	call cursorMove
	add sp, 2

	push msg2
	call printString
	add sp, 2

	push 0201h
	call cursorMove
	add sp, 2

vram:
	mov ax, 0b800h
	mov ds, ax
	mov di, 320 ; 160*2 the line 2
	mov al, 'q'
	mov [di], al
	add di,1
	mov ah, 0x4
	mov [di], ah

	jmp $

msg2:
	db "Booting to Stage2...",13, 0	

	times ((0x400) - ($ - $$)) db 0x00
