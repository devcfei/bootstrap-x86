## Disk

Read the sector 1(the 1st sector) then write to sector 2 in real-mode of x86 processor. 

The BIOS service（int 13h) used

## Test

Run the test and check the disk change by `hexdump`

```bash
cd src/disk
make
hexdump disk.img
```





