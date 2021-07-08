#include "init.h"
void irq0()
{
    // print(__FUNCTION__,0xb);
    // print("\n",0xb);

    print("#IRQ0 RTC\n",0xb);
    outb(0x20,0x20);
}

void irq1()
{
    print("#IRQ1 Keyboard\n",0xb);
    outb(0x20,0x20);
    //outb(0xA0,0x20);
    inb(0x60);
}

void irq2()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq3()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq4()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq5()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq6()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq7()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq8()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq9()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq10()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq11()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq12()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq13()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq14()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

void irq15()
{
    print(__FUNCTION__,0xb);
    print("\n",0xb);
}

