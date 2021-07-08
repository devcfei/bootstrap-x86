#include "init.h"



void delay()
{
    volatile int count = 1000000000;
    while (count--)
        ;
}



void apic_init()
{
    outb(0x20,0x11);
    outb(0xa0,0x11);

    outb(0x21,0x20);
    outb(0xa1,0x28);

    outb(0x21,0x04);
    outb(0xa1,0x02);

    outb(0x21,0x01);
    outb(0xa1,0x01);

    /*allow kbd*/
    outb(0x21,~0x2);
    outb(0xa1,~0x0);
}

void rtc_init()
{
    outb(0x43,0x37);
    outb(0x40,0x9c);
    outb(0x40,0x2e);
}


void kmain()
{
    print("\n",0x5);

    print("Setup IDT for Interrupt...\n", 0xa); /*light green*/

    isr_disable();

    idt_init();

    idt_load();

    apic_init();

    rtc_init();

    isr_enable();


    halt();

    while (1)
    {
        delay();
    }
}
