# Task

1. MBR copy the GDT to 0x7E00
1. MBR load the GDT and jump to 0x30000
1. Excecption start at 0x30000 and jump to kmain



## Demo

![Demo](task.gif)

## Test

```bash
make run -C src/task
```


