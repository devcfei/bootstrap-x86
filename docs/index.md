# Bootstrap x86



## Getting start

1. Install WSL in Windows, or real Linux machine for GNU toolchain, NASM and QEMU
    ```bash
    sudo apt install build-essential nasm qemu
    ```
2. Install X server in Windows machine(Optional if working in Linux)
    - [VcXsrv](https://sourceforge.net/projects/vcxsrv/)
    - [mobaxterm](https://mobaxterm.mobatek.net/)

3. Set the DISPLAY environment(Optional if working in Linux)
    ```bash
    DISPLAY=hostname:0.0 # hostnname is the IP or hostname of X server
    ```
4. Start with a section, e.g. the hello section

## Sections 

- `hello` - [Hello world of x86](hello/hello.md) (Done)
- `disk` - [Disk operations in real-mode](disk/disk.md) (Done)
- `stage2` - [2 stages boot](stage2/stage2.md) (Done)
- `pmode` - [Protected mode](pmode/pmode.md) (Done)
- `bootc` - [Boot to C](bootc/bootc.md) (Done)
- `exception` - [IDT and exception](exception/exception.md) (Done)
- `interrupt` - [IDT and interrupt](interrupt/interrupt.md) (Done)
- `task` - [TR, TSS and task](#) (Planning)
- `lmode` - [Long mode](#) (Planning)