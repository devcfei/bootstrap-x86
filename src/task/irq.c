#include "init.h"
void irq0()
{
    // print(__FUNCTION__,clr_lightblue);
    // print("\n",clr_lightblue);

    print("#IRQ0 RTC\n",clr_lightblue);
    outb(0x20,0x20);
}

void irq1()
{
    print("#IRQ1 Keyboard\n",clr_lightblue);
    outb(0x20,0x20);
    //outb(0xA0,0x20);
    inb(0x60);
}

void irq2()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq3()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq4()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq5()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq6()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq7()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq8()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq9()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq10()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq11()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq12()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq13()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq14()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

void irq15()
{
    print(__FUNCTION__,clr_lightblue);
    print("\n",clr_lightblue);
}

