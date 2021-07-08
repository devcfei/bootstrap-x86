#ifndef __INIT_H__
#define __INIT_H__

void outb(unsigned short port, unsigned char val);
unsigned char inb(unsigned short port);

#define clr_black 0x0
#define clr_blue 0x1
#define clr_green 0x2
#define clr_cyan 0x3
#define clr_red 0x4
#define clr_megenta 0x5
#define clr_brown 0x6
#define clr_lightgray 0x7
#define clr_darkgray 0x8
#define clr_lightblue 0x9
#define clr_lightgreen 0xA
#define clr_lightcyan 0xB
#define clr_lightred 0xC
#define clr_pink 0xD
#define clr_yellow 0xE
#define clr_white 0xF

void print(const char *msg, unsigned color);

void isr_enable();
void isr_disable();
void halt();
void idt_init();
void idt_load();
void note();




void exception0();
void exception1();
void exception2();
void exception3();
void exception4();
void exception5();
void exception6();
void exception7();
void exception8();
void exception9();
void exception10();
void exception11();
void exception12();
void exception13();
void exception14();
void exception15();
void exception16();
void exception17();
void exception18();
void exception19();
void exception20();
void exception21();
void exception22();
void exception23();
void exception24();
void exception25();
void exception26();
void exception27();
void exception28();
void exception29();
void exception30();
void exception31();
void exception32();




void irq0();
void irq1();
void irq2();
void irq3();
void irq4();
void irq5();
void irq6();
void irq7();
void irq8();
void irq9();
void irq10();
void irq11();
void irq12();
void irq13();
void irq14();
void irq15();



void tss_init();
void tss_load(int id);
void tss_switch(int id);
void tss_switch_asm(int id);
void task0_asm();
void task1_asm();

#endif /*__INIT_H__*/