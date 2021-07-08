[extern note]
section .text
align 4


;------------------------------
; outb
;------------------------------
[global outb]
outb: 
	push ebp
	mov ebp,esp
	mov edx,DWORD [ebp+0x8]
	mov eax,DWORD [ebp+0xc]
	out dx,al
	pop ebp
	ret     

;------------------------------
; inb
;------------------------------
[global inb]
inb: 
	push ebp
	mov ebp,esp
	mov edx,DWORD [ebp+0x8]
	in al,dx
	pop ebp
	ret    


;------------------------------
; halt
;------------------------------
[global halt]
halt:
	hlt
	ret

;------------------------------
; isr_enable
;------------------------------
[global isr_enable]
isr_enable:
	sti
	ret
;------------------------------
; isr_disable
;------------------------------
[global isr_disable]
isr_disable:
	cli
	ret


;------------------------------
; construct ISRs
;------------------------------
%macro ISR_EXCEPTION 1
[global isr%1]
[extern exception%1]

isr%1:
	pushad
	cli
	call exception%1
	sti
	popad
	iret
%endmacro


%macro ISR_IRQ 1
[global isr%1]
isr%1:
	pushad
	cli
	; call irq%2
	; sti
	; popad
	; iret
%endmacro

%macro ISR_IRQ_CALL 1
[extern irq%1]
	; pushad
	; cli
	call irq%1
	sti
	popad
	iret
%endmacro

%macro ISR_DEFAULT 1
[global isr%1]
isr%1:
	pushad
	cli
	sti
	popad
	iret
%endmacro

isr_start:
%assign i 0
%rep 32
    ISR_EXCEPTION i
    %assign i i + 1
%endrep

%assign i 32
%assign j 0
%rep 16
    ISR_IRQ i
    ISR_IRQ_CALL j
    %assign i i + 1
    %assign j j + 1
%endrep

%assign i 48
%rep 256-48
    ISR_DEFAULT i
    %assign i i + 1
%endrep

;------------------------------
; construct IDT
;------------------------------

%macro IDT_ENTRY 1
idt%1:
	dw 0x0000
	dw 0x0000
	db 0x00
	db 0x00
	dw 0x0000
%endmacro 

idt_start:
%assign i 0
%rep 256
    IDT_ENTRY i
    %assign i i + 1
%endrep
idt_end:
;------------------------------
; construct IDTR
;------------------------------
idtr:
	dw 0x0000		; limit
	dd 0x00000000	; address



;------------------------------
; idt_init
;------------------------------

[global idt_init]

%macro IDT_INIT 1
	mov eax, isr%1
    mov WORD [idt%1 + 0], ax	; offset lo
	shr eax, 16
	mov WORD [idt%1 + 6], ax	; offset hi
	mov WORD [idt%1 + 2], 8		; selector
	mov BYTE [idt%1 + 5], 0x8e	; attribute 
%endmacro 

idt_init:
	push ebp
	mov ebp, esp

	;
	; initial the IDT
	;
%assign i 0
%rep 256
	IDT_INIT i
    %assign i i + 1
%endrep
	;
	; intial the IDTR
	;
	mov WORD [idtr], 0x7ff 		; limit 0x800-1
	mov eax, idt_start
	mov DWORD [idtr+2], eax 	; address

	pop ebp
	ret



;------------------------------
; idt_load
;------------------------------
[global idt_load]
idt_load:
	lidt [idtr]
	ret


;------------------------------
; tss_load
;------------------------------
[global tss_load]
tss_load:	
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]	; id

	cmp eax, 0
	je tss_load_t0

	cmp eax, 1
	je tss_load_t1

	jmp tss_load_en
tss_load_t0:

	mov ax, 0x28	; TSS0
	ltr ax


	jmp tss_load_en

tss_load_t1:

	mov ax, 0x30	; TSS1
	ltr ax


	jmp tss_load_en

tss_load_en:
	;
	;
	;
	pop ebp
	ret

;------------------------------
; tss_switch
;------------------------------
[global tss_switch_asm]
tss_switch_asm:
	push ebp
	mov ebp, esp

	;
	; initial the TSS
	;
	mov eax, [ebp+8]	; id

	cmp eax, 0
	je tss_switch_asm_t0

	cmp eax, 1
	je tss_switch_asm_t1

	jmp tss_switch_asm_end
tss_switch_asm_t0:
	jmp 0x28:0

tss_switch_asm_t1:

	jmp 0x30:0


	
tss_switch_asm_end:
	;
	;
	;
	pop ebp
	ret




[global task0_asm]
[extern tss_task0]
task0_asm:
	call tss_task0
	iret

[global task1_asm]
[extern tss_task1]
task1_asm:
	call tss_task1
	iret
