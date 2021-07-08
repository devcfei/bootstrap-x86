#include "init.h"

/**
 * [TSS](https://nju-projectn.github.io/i386-manual/s07_01.htm)
 * 
 * 
 * 
 */



struct tss_struct{
	unsigned int backlink;
	unsigned int esp0;
	unsigned int ss0;
	unsigned int esp1;
	unsigned int ss1;
	unsigned int esp2;
	unsigned int ss2;

	unsigned int cr3;
	unsigned int eip;
	unsigned int eflags;

	unsigned int eax;
	unsigned int ecx;
	unsigned int edx;
	unsigned int ebx;
	
	unsigned int esp;
	unsigned int ebp;
	unsigned int esi;
	unsigned int edi;
	unsigned int es;
	unsigned int cs;
	unsigned int ss;
	unsigned int ds;
	unsigned int fs;
	unsigned int gs;
	unsigned int ldt;
	
	unsigned int trap_iomapbase;


};


struct tss_struct *task0;
struct tss_struct *task1;



void tss_task0()
{

    print("tss_task0 \n", clr_yellow);
	tss_switch_asm(1);

}

void tss_task1()
{
	print("tss_task1\n", clr_green);
	tss_switch_asm(0);
}

void tss_init()
{
    if(104 != sizeof(struct tss_struct))
    {
        print("[ERROR]:tss_struct size not 104\n", clr_red);
    }
	

	task0 = (struct tss_struct *) 0x00040000;
	task1 = (struct tss_struct *) 0x00050000;

	/*initial task 0*/
	task0->backlink = 0;
	task0->esp0 = 0x0;	/** */
	task0->ss0 = 0x38;	/** */
	task0->esp1 = 0;
	task0->ss1 = 0;
	task0->esp2 = 0;
	task0->ss2 = 0;

	task0->cr3 = 0;
	task0->eip = (unsigned int)task0_asm;	/** the tss_task0 */
	task0->eflags = 2;

	task0->eax = 0;
	task0->ecx = 0;
	task0->edx = 0;
	task0->ebx = 0;

	task0->esp = 0;	/** task0 stack */
	task0->ebp = 0;
	task0->esi = 0;
	task0->edi = 0;
	task0->es = 0x10;	/** data selector */	
	task0->cs = 0x8;		/** code selector */	
	task0->ss = 0x38;	/** data selector */	
	task0->ds = 0x10;	/** data selector */	
	task0->fs = 0;
	task0->gs = 0;
	task0->ldt = 0;

	task0->trap_iomapbase = sizeof(struct tss_struct);

	/*initial task 1, copy the task0 and make difference*/
	*task1 = *task0;

	task1->ss0 = 0x40;	/** */
	task1->eip = (unsigned int) task1_asm;	/** */
	task1->ss = 0x40;	/** */


}

void tss_switch(int id)
{
	if (id == 0)
	{
		tss_load(0);
		tss_switch_asm(0);
	}
	else if (id == 1)
	{
		tss_load(1);
		tss_switch_asm(1);
	}
	else
	{
		print("[ERROR]:tss_switch invalid task id\n", clr_red);
	}
}
