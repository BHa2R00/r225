
ENTRY(_start)
MEMORY
{
  ROM (rx ) : ORIGIN = 0x00000000, LENGTH = 0x00002000 
  RAM (rwx) : ORIGIN = 0x00002000, LENGTH = 0x00000400 
  DEV (rw ) : ORIGIN = 0x00002400, LENGTH = 0x000000F4 
}

SECTIONS
{
  .text : 
  { 
    __text_start = .;
    *(.text.entry)
    *(.text .text.*)
    __text_end = .;
  } > ROM
  .rodata : 
  {
    __rodata_start = .;
    *(.rodata .rodata.*)
    __rodata_end = .;
  } > ROM
  .data : 
  { 
    __data_start = .;
    *(.data .data.*)
    __data_end = .;
  } > RAM
  _data_load = LOADADDR(.data);
  .bss : 
  { 
    __bss_start = .;
    *(.bss .bss.*)
    *(COMMON)
    __bss_end = .;
  } > RAM
  __heap_start = .;
  __heap_end = ORIGIN(RAM) + LENGTH(RAM) - 0x100;
  __stack_start = ORIGIN(RAM) + LENGTH(RAM) - 4;
  __stack_size = 0x100;
  __stack_end = __stack_start - __stack_size;
  .tdata :
  {
    __tdata_start = .;
    *(.tdata .tdata.*)
  } > RAM 
  .tbss : 
  {
    __tbss_start = .;
    *(.tbss .tbss.*)
    __tbss_end = .;
  } > RAM 
  __executable_start = ORIGIN(ROM);
  _end = .;
}
