## Boot to C


The MBR read the LBA1 from HDD, switch CPU to **Protected Mode** then jump 32 bit C code


## Demo

![Demo](bootc.gif)


## Test


```bash
cd src/bootc
make
```

