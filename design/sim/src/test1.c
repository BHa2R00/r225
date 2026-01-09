#include <stdint.h>
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


int main(){

  //set_txbyte(50, 2);
  set_uart_tx(50, 2, 8, 1, 1, 0);
  set_uart_rx(50, 2, 8, 1, 1, 0);

  int a, b=0,c=1;
  dev0_debug0->o0.r = 0;
  while((dev0_debug0->o0.r)<(1<<23)){
    //while(dev0_debug0->main.f.boot == 0);
    a = b;
    b = c;
    c = a+b;
    dev0_debug0->o0.r = c;
  }
/*
  dev0_fclkdiv0_c->dven.r = 17;
  dev0_fclkdiv0_c->dvsr.r = 3;
  dev0_fclkdiv0_c->ctrl.f.setb = 1;

  dev0_fclkdiv1_c->dven.r = 120;
  dev0_fclkdiv1_c->dvsr.r = 13;
  dev0_fclkdiv1_c->ctrl.f.setb = 1;

  dev0_fclkdiv2_c->dven.r = 200;
  dev0_fclkdiv2_c->dvsr.r = 51;
  dev0_fclkdiv2_c->ctrl.f.setb = 1;
  
  dev0_fclkdiv3_c->dven.r = 3;
  dev0_fclkdiv3_c->dvsr.r = 1;
  dev0_fclkdiv3_c->ctrl.f.setb = 1;

  b=0,c=1;
  dev0_debug0->o1.r = 0;
  while((dev0_debug0->o1.r)<(1<<13)){
    a = b;
    b = c;
    c = a+b;
    dev0_debug0->o1.r = c;
  }

  data0_hwtimer3_oneshot(10);

  b=0,c=1;
  dev0_debug0->o0.r = 0;
  while((dev0_debug0->o0.r)<(1<<27)){
    a = b;
    b = c;
    c = a+b;
    dev0_debug0->o0.r = c;
  }
  
  data0_hwtimer2_oneshot(20);

  b=0,c=1;
  dev0_debug0->o1.r = 0;
  while((dev0_debug0->o1.r)<(1<<17)){
    a = b;
    b = c;
    c = a+b;
    dev0_debug0->o1.r = c;
  }
  
  dev0_fclkdiv0_c->ctrl.f.setb = 0;

  b=0,c=1;
  dev0_debug0->o0.r = 0;
  while((dev0_debug0->o0.r)<(1<<31)){
    a = b;
    b = c;
    c = a+b;
    dev0_debug0->o0.r = c;
  }

  //printf("shit!\n\rurmom is so fat\n\r");
  txstr("shit!\n\rurmom is so fat\n\r");
  txstr("Llanfairpwllgwyngyllgogerychwyrndrobwllllantysiliogogogoch\n\r");

  txstr("crc test start\n\r");
  crc_set_tap(0x1234);
  for(a=0;a<3;a++){
    crc_set_sum(0x123-a);                // renew check sum
    for(b=0;b<3;b++){
      crc_set_dat(0x321-b);              // set data
      dev0_debug0->o1.r = crc_get_sum(); // get check sum
    }
  }
  txstr("crc test end\n\r");
*/
//  uint32_t d, e, f;
//  int g, h, i;
/*
  txstr("mul test start\n\r");
  for(d=18;d<21;d++){
    for(e=77;e>33;e--){
      dev0_debug0->o0.r = d;
      dev0_debug0->o0.r = e;
      f = __mulusi3(d , e);
      dev0_debug0->o1.r = f;
    }
  }
  for(g=-8;g<5;g++){
    for(h=17;h>-23;h--){
      dev0_debug0->o0.r = g;
      dev0_debug0->o0.r = h;
      i = __mulsi3(g , h);
      dev0_debug0->o1.r = i;
    }
  }
  txstr("mul test end\n\r");
*/ 
/*
  txstr("div test start\n\r");
  for(d=0;d<10;d=d+2){
    for(e=15;e>5;e=e-3){
      dev0_debug0->o0.r = d;
      dev0_debug0->o0.r = e;
      f = __divusi3(d , e);
      dev0_debug0->o1.r = f;
    }
  }
  for(g=-5;g<15;g=g+3){
    for(h=5;h>-15;h=h-4){
      dev0_debug0->o0.r = g;
      dev0_debug0->o0.r = h;
      i = __divsi3(g , h);
      dev0_debug0->o1.r = i;
    }
  }
  txstr("div test end\n\r");
*/

  /*printf("mod test start\n\r");
  for(d=0;d<10;d=d+2){
    for(e=15;e>5;e=e-3){
      dev0_debug0->o0.r = d;
      dev0_debug0->o0.r = e;
      f = __modusi3(d , e);
      dev0_debug0->o1.r = f;
    }
  }
  for(g=-5;g<15;g=g+3){
    for(h=5;h>-15;h=h-4){
      dev0_debug0->o0.r = g;
      dev0_debug0->o0.r = h;
      i = __modsi3(g , h);
      dev0_debug0->o1.r = i;
    }
  }
  printf("mod test end\n\r");*/

  //txstr("shit!\n\rurmom is so fat\n\r");
  //txstr("Llanfairpwllgwyngyllgogerychwyrndrobwllllantysiliogogogoch\n\r");
  //for(a=0;a<=5;a++) printf("a=%d\n", a);

  /*b=0,c=1;
  while(c<(1<<10)){
    a = b;
    b = c;
    c = a+b;
    printf("c=%d\n\r", c);
  }*/

  /*print_char('s');
  print_char('h');
  print_char('i');
  print_char('t');
  print_char('\n');
  print_char('\r');*/

  //char* s1 = "shit!\n\rurmom is so fat\n\r";
  //print_str(s1);
  //char* s2 = "Llanfairpwllgwyngyllgogerychwyrndrobwllllantysiliogogogoch\n\r";
  //print_str(s2);
  
  printf("shit!\n\rurmom is so fat\n\r");
  //printf("Llanfairpwllgwyngyllgogerychwyrndrobwllllantysiliogogogoch\n\r");

  /*b=0,c=1;
  dev0_debug0->o0.r = 0;
  while((dev0_debug0->o0.r)<(1<<10)){
    a = b;
    b = c;
    c = a+b;
    dev0_debug0->o0.r = c;
    print_dec(c);
    print_str("\n\r");
  }*/
  
  /*b=0,c=1;
  while(c<(1<<10)){
    a = b;
    b = c;
    c = a+b;
    print_dec(c);
    print_str("\n\r");
  }*/


  b=0,c=1;
  while(c<(1<<9)){
    a = b;
    b = c;
    c = a+b;
    printf("a=%d, b=%d, c=%d\n\r", a, b, c);
  }

  for(a=0;a<5;a++) { 
    char ch;
    scanf("%c", &ch);
    if(ch == 'u') printf("urmom!\n\r");
    else if(ch == 's') printf("shit!\n\r");
    else if(ch == 'w') printf("what the fuck!\n\r");
    else if(ch == 'L') printf("Llanfairpwllgwyngyllgogerychwyrndrobwllllantysiliogogogoch\n\r");
    else printf("%x\n\r", (int)ch); 
  }


  printf("crc test start\n\r");
  crc_set_tap(0x1234);
  for(a=0;a<3;a++){
    crc_set_sum(0x123-a);                // renew check sum
    for(b=0;b<3;b++){
      crc_set_dat(0x321-b);              // set data
      c = crc_get_sum();
      printf("a = %d, b = %d, sum = %d\n\r", a, b, c); // get check sum
    }
  }
  printf("crc test end\n\r");

/*
  printf("xip test start\n\r");
  for(a=0x2000;a<0x208A;a+=4) {
    printf("a=%x, d=%x\n\r", a, r32(a));
  }
  printf("xip test end\n\r");
*/
  






  cpu_ret();
  while(1){
    char ch;
    scanf("%c", &ch);
    printf("%x\n\r", dev0_cgu0_c->rtc.r);
  }
  return 0;
}

