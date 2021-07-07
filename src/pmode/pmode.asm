	org 0x7C00  
	jmp start  



;******************************************************************************
;       GDT MANUAL
;******************************************************************************
; GDT is an 8 byte QWORD value that describes properties for the descriptor.
; They are of the format:
;
;    Bits 0-15: Bits 0-15 of the Segment Limit
;    Bits 16-39: Bits 0-23 of the Base Address
;    Bit 40: Access bit (Used with Virtual Memory)
;    Bits 41-43: Descriptor Type
;    Bit 43: Executable segment
;    0: Data Segment
;    1: Code Segment
;    Bit 42: Expansion direction (Data segments), conforming (Code Segments)
;    Bit 41: Readable and Writable
;    0: Read only (Data Segments); Execute only (Code Segments)
;    1: Read and write (Data Segments); Read and Execute (Code Segments)
;    Bit 44: Descriptor Bit
;    0: System Descriptor
;    1: Code or Data Descriptor
;    Bits 45-46: Descriptor Privilege Level
;    0: (Ring 0) Highest
;    3: (Ring 3) Lowest
;    Bit 47 Segment is in memory (Used with Virtual Memory)
;    Bits 48-51: Bits 16-19 of the segment limit
;    Bits 52: Reserved for OS use (we can do whatever we want here)
;    Bit 53: Reserved-Should be zero
;    Bit 54: Segment type
;    0: 16 bit
;    1: 32 bit
;    Bit 55: Granularity
;    0: None
;    1: Limit gets multiplied by 4K
;    Bits 56-63: Bits 24-32 of the base address
;******************************************************************************
  
GDT_START: 
DESC_SG_NULL:
	dd 0x00000000
	dd 0x00000000  
DESC_SG_CODE:
	dd 0x7C0001FF
	dd 0x00409A00	; Base: 0x00007c00, Length 0x1ff
DESC_SG_VIDEO:
	dd 0x8000FFFF	; Base: 0x000b8000, Length 0xffff
	dd 0x0040920B  
DESC_SG_STACK:
	dd 0x00007A00	; Base: 0x00000000, Length 0x7a00
	dd 0x00409600  
GDT_END:  
  
;Selector
	SLCT_NULL	equ DESC_SG_NULL - GDT_START  
	SLCT_CODE	equ DESC_SG_CODE - GDT_START  
	SLCT_VIDEO	equ DESC_SG_VIDEO - GDT_START  
	SLCT_STACK	equ DESC_SG_STACK - GDT_START   
	GDT_SIZE_DWORD equ (GDT_END - GDT_START) / 4  
	  
GDTR:
	GDT_BOUND	dw  GDT_END - GDT_START - 1
	GDT_BASE	dd  0x7E00   
	      	
[bits 16]
start:  
	mov ax, cs  
	mov ss, ax  
	mov sp, 0x7C00  


    call screenClean

    push 0000h
	call cursorMove
	add sp, 2

	push msgBoot
	call printString
	add sp, 2

    push 0100h
	call cursorMove
	add sp, 2

pmodeSetup:
	; ds:si source GDT
	mov ax, cs  
	mov ds, ax  
	mov si, GDT_START  

	; es:di destination GDT
	mov ax, [cs:GDT_BASE]  
	mov dx, [cs:GDT_BASE+2]  
	mov bx, 16  
	div bx
	mov es, ax  
	mov di, 0  
	; copy the GDT
	mov cx, GDT_SIZE_DWORD  
	cld  
	rep movsd  

	; load GDT
	lgdt [cs: GDTR]


	cli	; clear Interrupt
	
	; Enalbe Protected Mode
	mov eax, cr0    
	or  eax, 0x1    
	mov cr0, eax  

	jmp dword SLCT_CODE:(pm32_start - 0x7C00); now CS is the Selector

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

[bits 32]  
pm32_start:
	; Set data segment
	mov eax, SLCT_VIDEO 
	mov ds, eax  
	
	mov ebx, msgPmode-0x7C00  
	mov esi, 0  
	mov edi, 160  
.lp:    
	mov al, [cs: ebx+esi]  
	test al, al
	je .end
	mov ah, 0x2	; set Green
	mov [edi], ax 
	inc esi  
	add edi, 2  
	jmp .lp  
.end:

	
.tail:
	jmp $ 
	msgPmode db  'Already in protect mode...',0
	msgBoot: db "Booting...",13,0
.fill:
	times 510-($-$$) db 0
	dw 0xaa55 	; MBR signature