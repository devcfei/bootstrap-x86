#include "init.h"



void delay()
{
    volatile int count = 1000000000;
    while (count--)
        ;
}

void kmain()
{
    print("\n",0x5);

    print("Setup IDT for exception...\n", 0xa); /*light green*/

    isr_disable();

    idt_init();

    idt_load();

    isr_enable();

    for(int i=0;i<10;++i)
    {
        int a=10/(6-i);
        print("a\n",a);
        delay();
    }

    halt();

    while (1)
    {
        delay();
    }
}
