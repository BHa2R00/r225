.section .text.entry
.global _start
.type _start, @function
_start:
  la    sp, __stack_start
  la    s0, __data_start
  la    s1, __data_end
  la    t0, __bss_start
  la    t1, __bss_end
  la    t2, __heap_start
//  la    t3, __heap_end
  bge   t0, t1, bss_clear_done
bss_clear_loop:
  sw    zero, 0(t0) 
  addi  t0, t0, 4
  blt   t0, t1, bss_clear_loop
bss_clear_done:
  la    gp, __global_pointer$
//  jal   ra, __libc_init_array
  li    a0, 0
  li    a1, 0
  li    a2, 0
  jal   ra, main
exit_loop:
  j     exit_loop
.section .sdata
__global_pointer$:
    .word 0
