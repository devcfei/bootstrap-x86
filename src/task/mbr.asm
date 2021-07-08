%define org_start 7c00h


boot:
	org org_start  
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
DESC_SG_NULL: 		;SELECTOR: 0x0
	dd 0x00000000
	dd 0x00000000  
DESC_SG_CODE:		;SELECTOR: 0x8
	dw 0xFFFF   ; Bits 0-15		 +
	dw 0x0000   ; Bits 16-31	 |	Base: 0x00000000
	db 0x00     ; Bits 32-39	 |	Length: 0xffff
	db 10011010b; Bits 40-47	 |
	db 11001111b; Bits 48-55	 |
	db 0x00     ; Bits 56-63	 +
DESC_SG_DATA:		;SELECTOR: 0x10
	dw 0xFFFF   ; Bits 0-15 	 +
	dw 0x0000   ; Bits 16-31	 |	Base: 0x00000000
	db 0x00     ; Bits 32-39	 |	Length: 0xffff
	db 10010010b; Bits 40-47	 |
	db 11001111b; Bits 48-55	 |
	db 0x00     ; Bits 56-63	 +
DESC_SG_VIDEO:		;SELECTOR: 0x18
	dd 0x8000FFFF	; Base: 0x000b8000, Length 0xffff
	dd 0x0040920B  
DESC_SG_STACK:		;SELECTOR: 0x20
	dd 0x0000FFFF	; Base: 0x00000000, Length 0xffff
	dd 0x00409600

DESC_SG_TSS0:		;SELECTOR: 0x28
	dw 0x0068   ; Bits 0-15 	 +
	dw 0x0000   ; Bits 16-31	 |	Base: 0x00040000
	db 0x04     ; Bits 32-39	 |	Length: 0x0068
	db 10001001b; Bits 40-47	 |	40..43: 32-bit TSS 44: System Descriptor 45..46: ring 0 47: Segment is in memory
	db 11000000b; Bits 48-55	 |
	db 0x00     ; Bits 56-63	 +

DESC_SG_TSS1:		;SELECTOR: 0x30
	dw 0x0068   ; Bits 0-15 	 +
	dw 0x0000   ; Bits 16-31	 |	Base: 0x00050000
	db 0x05     ; Bits 32-39	 |	Length: 0x0068
	db 10001001b; Bits 40-47	 |
	db 11000000b; Bits 48-55	 |
	db 0x00     ; Bits 56-63	 +

DESC_SG_STACK0:		;SELECTOR: 0x38
	dd 0x0000FFFF	; Base: 0x00070000, Length 0xffff
	dd 0x00409607

DESC_SG_STACK1:		;SELECTOR: 0x40
	dd 0x0000FFFF	; Base: 0x00080000, Length 0xffff
	dd 0x00409608


GDT_END:  
  
;Selector
	SLCT_NULL	equ DESC_SG_NULL - GDT_START  
	SLCT_CODE	equ DESC_SG_CODE - GDT_START  
	SLCT_DATA	equ DESC_SG_DATA - GDT_START  
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
	
	;-----------------------------------------
	; Clean the screen
	;-----------------------------------------
	call CleanScreen
	;jmp $
	;-----------------------------------------
	; Read 128 sectors from HDD to 0x30000
	;-----------------------------------------
	call SectorRead

	;-----------------------------------------
	; Setup GDT and jmp to 32bit mode
	;-----------------------------------------
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

	;-----------------------------------------
	; clear Interrupt
	;-----------------------------------------
	cli	; clear Interrupt

	;-----------------------------------------
	; Enalbe Protected Mode
	;-----------------------------------------
	mov eax, cr0    
	or  eax, 0x1    
	mov cr0, eax  

	;-----------------------------------------
	; Jump to 32bit code
	;-----------------------------------------
	jmp dword SLCT_CODE:(pmStart); now CS is the Selector



CleanScreen:
	mov ah, 07h		; tells BIOS to scroll down window
	mov al, 00h		; clear entire window
    mov bh, 07h		; white on black
	mov cx, 00h		; specifies top left of screen as (0,0)
	mov dh, 18h		; 18h = 24 rows of chars
	mov dl, 4fh		; 4fh = 79 cols of chars
	int 10h			; calls video interrupt
	ret	

SectorRead:
	mov ax, 3000h		; Set ES:BX to 800h:0000h
	mov es, ax
	mov bx, 0000h
	
	mov al, 128		; Sector count = 128, 64K=128 sectors
	mov dl, 80h		; Hard disk 80h=C: 81h=D:
	mov dh, 0		; Disk heads
	mov ch, 0		; Disk cylinders
	mov cl, 2		; Sector number
	mov ah, 2		; Read
	int 13h
	ret


[bits 32]  
pmStart:
	; Set data segment for VIDEO selector
	mov eax, SLCT_VIDEO 
	mov ds, eax  
	
	mov ebx, MSG  
	mov esi, 0  
	mov edi, 0  
.loop:    
	mov al, [cs: ebx+esi]  
	test al, al
	je start_code
	mov ah, 0x4	; set Red
	mov [edi], ax 
	inc esi  
	add edi, 2  
	jmp .loop  

	

start_code:
	mov ax, SLCT_DATA
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov esp, 0x90000    ; stack begins from 0x90000


	; load TR
	; mov ax, 0x28
	; ltr ax,

	; jump to c
	jmp dword SLCT_CODE:30000h
	
.tail:
	jmp $ 
	MSG db  'Already in protect mode...',0  	
.fill:
	times 510-($-$$) db 0
	dw 0xaa55 	; MBR signature