inline void outb(unsigned short port, unsigned char val)
{
    asm volatile("outb %1, %0" ::"dN"(port), "a"(val));
}

inline unsigned char inb(unsigned short port)
{
    unsigned char ret;
    asm volatile("inb %1, %0"
                 : "=a"(ret)
                 : "dN"(port));
    return ret;
}

#define VIDEO_MEMORY 0xb8000

static int cpx;
static int cpy;

void setcursor(int x, int y)
{
    unsigned short pos = y * 80 + x;
    outb(0x3d4, 14);

    outb(0x3d5, (pos >> 8) & 0xff);
    outb(0x3d4, 15);

    outb(0x3d5, pos & 0xff);
}

void clean()
{
    char *fb = (char *)VIDEO_MEMORY;
    int count = 80 * 25;

    while (count--)
    {
        *fb++ = ' ';
        *fb++ = 0x7;
    }
    cpx = 0;
    cpy = 0;
    setcursor(cpx, cpy);
}

void scrollup()
{
    char *fb = (char *)VIDEO_MEMORY;
    for (int line = 0; line < 25; line++)
        for (int i = 0; i < 160; i++)
            fb[line * 160 + i] = fb[(line + 1) * 160 + i];
    cpy--;
    setcursor(cpx, cpy);
}

void print(char *msg, unsigned color)
{
    char *fb = (char *)VIDEO_MEMORY;
    char *next = msg;

    while (*next)
    {
        if (*next == '\n')
        {
            cpx = 0;
            cpy++;
            fb[cpy * 160 + cpx * 2] = ' ';
            next++;
            continue;
        }
        fb[cpy * 160 + cpx * 2] = *next;
        fb[cpy * 160 + cpx * 2 + 1] = color;
        next++;
        cpx++;
        if (cpx == 80)
        {
            cpx = 0;
            cpy++;
        }
    }
    if (cpy == 25)
        scrollup();

    setcursor(cpx, cpy);
}

void delay()
{
    volatile int count = 10000000;
    while (count--)
        ;
}

void kmain()
{
    clean();

    print("Executing our C code...\n", 0xa); /*light green*/

    while (1)
    {
        delay();
    }
}
