OUTPUT_FORMAT("binary")
ENTRY(kmain)
SECTIONS
{
  . = 0x30000;
  .text : {
    * (.text);
  }
  .data : {
    * (.data);
  }
  .rodata : {
    * (.rodata);
  }
  .bss : {
    * (.bss);
  }

}
