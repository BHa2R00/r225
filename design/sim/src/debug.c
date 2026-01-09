#include <stddef.h>
#include <stdbool.h>
#include <stdarg.h>
#include <math.h>
#include <stdio.h>
#include <sys/reent.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "dev.h"

int main ()
{
  set_uart_tx(50, 2, 8, 1, 1, 0);
  set_uart_rx(50, 2, 8, 1, 1, 0);
  dev0_debug0->o0.r = 0;
  while((dev0_debug0->o0.r++)<(1<<6)) dev0_debug0->o1.r = dev0_debug0->main.f.boot ? -1 : 0;
  printf("%x\n", dev0_debug0->o1.r);
  cpu_ret();
  while(1);
  return 0;
}
