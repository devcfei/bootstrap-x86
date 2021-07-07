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
DESC_SG_NULL:
	dd 0x00000000
	dd 0x00000000  
DESC_SG_CODE:
	dw 0xFFFF   ; Bits 0-15
	dw 0x0000   ; Bits 16-31
	db 0x00     ; Bits 32-39
	db 10011010b; Bits 40-47
	db 11001111b; Bits 48-55
	db 0x00     ; Bits 56-63
DESC_SG_DATA:
	dw 0xFFFF   ; Bits 0-15
	dw 0x0000   ; Bits 16-31
	db 0x00     ; Bits 32-39
	db 10010010b; Bits 40-47
	db 11001111b; Bits 48-55
	db 0x00     ; Bits 56-63
DESC_SG_VIDEO:
	dd 0x8000FFFF	; Base: 0x000b8000, Length 0xffff
	dd 0x0040920B  
DESC_SG_STACK:
	dd 0x0000FFFF	; Base: 0x00000000, Length 0xffff
	dd 0x00409600  
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
	; Read the Sector 1(LBA1) from HDD to 0x8000
	;-----------------------------------------
	call SectorRead
	;mov ax, 800h		; Set ES:DI to 800h:0000h
	;mov es, ax
	;mov di, 0000h
	;call do_e820
	;call SectorWrite
	;jmp $
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


	cli	; clear Interrupt
	
	; Enalbe Protected Mode
	mov eax, cr0    
	or  eax, 0x1    
	mov cr0, eax  

	jmp dword SLCT_CODE:(pm32_start); now CS is the Selector



CleanScreen:
	mov ah, 07h		; tells BIOS to scroll down window
	mov al, 00h		; clear entire window
    mov bh, 07h    	; white on black
	mov cx, 00h  	; specifies top left of screen as (0,0)
	mov dh, 18h		; 18h = 24 rows of chars
	mov dl, 4fh		; 4fh = 79 cols of chars
	int 10h			; calls video interrupt
	ret	

SectorRead:
	mov ax, 800h		; Set ES:BX to 800h:0000h
	mov es, ax
	mov bx, 0000h
	
	mov al, 16		; Sector count = 1, 64K=128 sectors
	mov dl, 80h		; Hard disk 80h=C: 81h=D:
	mov dh, 0		; Disk heads
	mov ch, 0		; Disk cylinders
	mov cl, 2		; Sector number
	mov ah, 2		; Read
	int 13h
	ret


SectorWrite:
	mov ax, 800h		; Set ES:BX to 800h:0000h
	mov es, ax
	mov bx, 0000h
	
	mov al, 1		; Sector count = 1
	mov dl, 80h		; Hard disk 80h=C: 81h=D:
	mov dh, 0		; Disk heads
	mov ch, 0		; Disk cylinders
	mov cl, 3		; Sector number
	mov ah, 3  		; Write
	int 13h
	ret

; use the INT 0x15, eax= 0xE820 BIOS function to get a memory map
; inputs: es:di -> destination buffer for 24 byte entries
; outputs: bp = entry count, trashes all registers except esi
mmap_ent:
	dw 0xfafa

do_e820:
	xor ebx, ebx		; ebx must be 0 to start
	xor bp, bp		; keep an entry count in bp
	mov edx, 0x0534D4150	; Place "SMAP" into edx
	mov eax, 0xe820
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24		; ask for 24 bytes
	int 0x15
	jc short .failed	; carry set on first call means "unsupported function"
	mov edx, 0x0534D4150	; Some BIOSes apparently trash this register?
	cmp eax, edx		; on success, eax must have been reset to "SMAP"
	jne short .failed
	test ebx, ebx		; ebx = 0 implies list is only 1 entry long (worthless)
	je short .failed
	jmp short .jmpin
.e820lp:
	mov eax, 0xe820		; eax, ecx get trashed on every int 0x15 call
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24		; ask for 24 bytes again
	int 0x15
	jc short .e820f		; carry set means "end of list already reached"
	mov edx, 0x0534D4150	; repair potentially trashed register
.jmpin:
	jcxz .skipent		; skip any 0 length entries
	cmp cl, 20		; got a 24 byte ACPI 3.X response?
	jbe short .notext
	test byte [es:di + 20], 1	; if so: is the "ignore this data" bit clear?
	je short .skipent
.notext:
	mov ecx, [es:di + 8]	; get lower uint32_t of memory region length
	or ecx, [es:di + 12]	; "or" it with upper uint32_t to test for zero
	jz .skipent		; if length uint64_t is 0, skip entry
	inc bp			; got a good entry: ++count, move to next storage spot
	add di, 24
.skipent:
	test ebx, ebx		; if ebx resets to 0, list is complete
	jne short .e820lp
.e820f:
	mov [mmap_ent], bp	; store the entry count
	clc			; there is "jc" on end of list to this point, so the carry must be cleared
	ret
.failed:
	stc			; "function unsupported" error exit
	ret


[bits 32]  
pm32_start:
	; Set data segment
	mov eax, SLCT_VIDEO 
	mov ds, eax  
	
	mov ebx, MSG  
	mov esi, 0  
	mov edi, 0  
.lp:    
	mov al, [cs: ebx+esi]  
	test al, al
	je .end
	mov ah, 0x4	; set Red
	mov [edi], ax 
	inc esi  
	add edi, 2  
	jmp .lp  
.end:
	

start_code:
	mov ax, SLCT_DATA
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov esp, 0x90000    ; stack begins from 0x90000

	jmp dword SLCT_CODE:8000h
	
.tail:
	jmp $ 
	MSG db  'Already in protect mode...',0  	
.fill:
	times 510-($-$$) db 0
	dw 0xaa55 	; MBR signature