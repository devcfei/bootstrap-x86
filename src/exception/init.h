#ifndef __INIT_H__
#define __INIT_H__

void outb(unsigned short port, unsigned char val);
unsigned char inb(unsigned short port);

void print(const char *msg, unsigned color);

void isr_enable();
void isr_disable();
void halt();
void idt_init();
void idt_load();




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


#endif /*__INIT_H__*/