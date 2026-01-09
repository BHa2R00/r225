#include "pannel.h"
#include "rv32e.h"
#include "debug.h"
#include "irq.h"
#include "cgu.h"
#include "fclkdiv.h"
#include "hwtimer.h"
#include "txbyte.h"
#include "uart_tx.h"
#include "uart_rx.h"
#include "crc.h"
#include "mul.h"
#include "div.h"
#include "bus.h"

void cpu_ret(void) {
  __asm__ volatile("li ra, 0xffffffff");
}

void cpu_wfi(void) {
  __asm__ volatile("wfi");
}

void halt0 (){
  dev0_irq0_c->mask.r = dev0_irq0_c->mask.r | (1<<0); 
  cpu_wfi(); 
  dev0_irq0_c->mask.r = dev0_irq0_c->mask.r & ~(1<<0); 
}

void data0_hwtimer0_oneshot(uint32_t load) {
  dev0_hwtimer0_c->ctrl.f.oneshot = 1;
  dev0_hwtimer0_c->ctrl.f.irq_enable = 1;
  dev0_hwtimer0_c->load.r = load;
  dev0_hwtimer0_c->ctrl.f.update = 1;
  while(!dev0_hwtimer0_c->ctrl.f.update);
  dev0_irq0_c->mask.r = dev0_irq0_c->mask.r | (1<<1); 
  dev0_hwtimer0_c->ctrl.f.enable = 1;
  while(!dev0_hwtimer0_c->ctrl.f.enable);
  cpu_wfi(); 
  dev0_hwtimer0_c->ctrl.f.hit = 1;
  dev0_irq0_c->mask.r = dev0_irq0_c->mask.r & ~(1<<1);
}

/*
void data0_hwtimer1_oneshot(uint32_t load) {
  dev0_hwtimer1_c->ctrl.f.oneshot = 1;
  dev0_hwtimer1_c->ctrl.f.irq_enable = 1;
  dev0_hwtimer1_c->load.r = load;
  dev0_hwtimer1_c->ctrl.f.update = 1;
  while(!dev0_hwtimer1_c->ctrl.f.update);
  dev0_irq0_c->mask.r = dev0_irq0_c->mask.r | (1<<2); 
  dev0_hwtimer1_c->ctrl.f.enable = 1;
  while(!dev0_hwtimer1_c->ctrl.f.enable);
  cpu_wfi(); 
  dev0_hwtimer1_c->ctrl.f.hit = 1;
  dev0_irq0_c->mask.r = dev0_irq0_c->mask.r & ~(1<<2);
}

void data0_hwtimer2_oneshot(uint32_t load) {
  dev0_hwtimer2_c->ctrl.f.oneshot = 1;
  dev0_hwtimer2_c->ctrl.f.irq_enable = 1;
  dev0_hwtimer2_c->load.r = load;
  dev0_hwtimer2_c->ctrl.f.update = 1;
  while(!dev0_hwtimer2_c->ctrl.f.update);
  dev0_irq0_c->mask.r = dev0_irq0_c->mask.r | (1<<3); 
  dev0_hwtimer2_c->ctrl.f.enable = 1;
  while(!dev0_hwtimer2_c->ctrl.f.enable);
  cpu_wfi(); 
  dev0_hwtimer2_c->ctrl.f.hit = 1;
  dev0_irq0_c->mask.r = dev0_irq0_c->mask.r & ~(1<<3);
}

void data0_hwtimer3_oneshot(uint32_t load) {
  dev0_hwtimer3_c->ctrl.f.oneshot = 1;
  dev0_hwtimer3_c->ctrl.f.irq_enable = 1;
  dev0_hwtimer3_c->load.r = load;
  dev0_hwtimer3_c->ctrl.f.update = 1;
  while(!dev0_hwtimer3_c->ctrl.f.update);
  dev0_irq0_c->mask.r = dev0_irq0_c->mask.r | (1<<4); 
  dev0_hwtimer3_c->ctrl.f.enable = 1;
  while(!dev0_hwtimer3_c->ctrl.f.enable);
  cpu_wfi(); 
  dev0_hwtimer3_c->ctrl.f.hit = 1;
  dev0_irq0_c->mask.r = dev0_irq0_c->mask.r & ~(1<<4);
}
*/

/*
void set_txbyte (uint32_t dven, uint32_t dvsr) {
  dev0_txbyte0->dven.r = dven;
  dev0_txbyte0->dvsr.r = dvsr;
}

void txbyte (char c) {
  dev0_txbyte0->data.f.data = c;
  while(dev0_txbyte0->ctrl.f.busy);
}
*/

char rxbyte(){
  return (char)dev0_debug0->i0.r;
}


void set_uart_tx (uint32_t dven, uint32_t dvsr, uint32_t width, uint32_t crc_width, uint32_t crc_ini, uint32_t crc_tap) {
  dev0_uart_tx0->dven.r = dven;
  dev0_uart_tx0->dvsr.r = dvsr;
  dev0_uart_tx0->ctrl.f.width = width;
  dev0_uart_tx0->ctrl.f.crc_width = crc_width;
  dev0_uart_tx0->crc.f.crc_ini = crc_ini;
  dev0_uart_tx0->crc.f.crc_tap = crc_tap;
}

void uart_tx (char c) {
  dev0_uart_tx0->data.r = (uint32_t)c;
  while(dev0_uart_tx0->ctrl.f.busy);
}

void set_uart_rx (uint32_t dven, uint32_t dvsr, uint32_t width, uint32_t crc_width, uint32_t crc_ini, uint32_t crc_tap) {
  dev0_uart_rx0->dven.r = dven;
  dev0_uart_rx0->dvsr.r = dvsr;
  dev0_uart_rx0->ctrl.f.width = width;
  dev0_uart_rx0->ctrl.f.crc_width = crc_width;
  dev0_uart_rx0->crc.f.crc_sum = crc_ini;
  dev0_uart_rx0->crc.f.crc_tap = crc_tap;
}

uint32_t uart_rx () {
  uint32_t r;
  r = dev0_uart_rx0->data.f.data ;
  while(!dev0_uart_rx0->ctrl.f.idle);
  r = dev0_uart_rx0->data.f.data ;
  /*do {
    r = dev0_uart_rx0->data.f.data;
  } while(!dev0_uart_rx0->ctrl.f.idle);*/
  return r;
}


//void txstr (char* s) { while(*s) txbyte(*s++); }
void txstr (char* s) { while(*s) uart_tx(*s++); }


void crc_set_tap(uint32_t tap) { dev0_crc0_c->tap.r = tap; }
void crc_set_sum(uint32_t sum) { dev0_crc0_c->sum.r = sum; }
void crc_set_dat(uint32_t dat) { dev0_crc0_c->dat.r = dat; }
void crc_wait_cst() { while(dev0_crc0_c->ctl.f.cst); }
uint32_t crc_get_sum() { crc_wait_cst(); return dev0_crc0_c->sum.r; }
void crc_set_xor(uint32_t check) { dev0_crc0_c->xor.r = check; }
uint32_t crc_get_check() { crc_wait_cst(); return dev0_crc0_c->xor.r; }

unsigned int mulu(unsigned int a, unsigned int b) {
  int k;
  for(k=0;k<=0;k++){
    switch(k) {
      case 0 : {
        if(dev0_mul0_c->ctrl.f.setb) break;
        dev0_mul0_c->ctrl.f.uns = 1;
        dev0_mul0_c->a.r = a;
        dev0_mul0_c->b.r = b;
        dev0_mul0_c->ctrl.f.setb = 1;
        while(dev0_mul0_c->ctrl.f.setb);
        dev0_mul0_c->ctrl.f.setb = 0;
        return dev0_mul0_c->p_l.r;
      }
      /*case 1 : {
        if(dev0_mul1_c->ctrl.f.setb) break;
        dev0_mul1_c->ctrl.f.uns = 1;
        dev0_mul1_c->a.r = a;
        dev0_mul1_c->b.r = b;
        dev0_mul1_c->ctrl.f.setb = 1;
        while(dev0_mul1_c->ctrl.f.setb);
        dev0_mul1_c->ctrl.f.setb = 0;
        return dev0_mul1_c->p_l.r;
      }
      case 2 : {
        if(dev0_mul2_c->ctrl.f.setb) break;
        dev0_mul2_c->ctrl.f.uns = 1;
        dev0_mul2_c->a.r = a;
        dev0_mul2_c->b.r = b;
        dev0_mul2_c->ctrl.f.setb = 1;
        while(dev0_mul2_c->ctrl.f.setb);
        dev0_mul2_c->ctrl.f.setb = 0;
        return dev0_mul2_c->p_l.r;
      }
      case 3 : {
        if(dev0_mul3_c->ctrl.f.setb) break;
        dev0_mul3_c->ctrl.f.uns = 1;
        dev0_mul3_c->a.r = a;
        dev0_mul3_c->b.r = b;
        dev0_mul3_c->ctrl.f.setb = 1;
        while(dev0_mul3_c->ctrl.f.setb);
        dev0_mul3_c->ctrl.f.setb = 0;
        return dev0_mul3_c->p_l.r;
      }*/
    }
  }
  while(dev0_mul0_c->ctrl.f.setb);
  dev0_mul0_c->ctrl.f.uns = 1;
  dev0_mul0_c->a.r = a;
  dev0_mul0_c->b.r = b;
  dev0_mul0_c->ctrl.f.setb = 1;
  while(dev0_mul0_c->ctrl.f.setb);
  dev0_mul0_c->ctrl.f.setb = 0;
  return dev0_mul0_c->p_l.r;
}

int mul(int a, int b) {
  int k;
  for(k=0;k<=0;k++){
    switch(k) {
      case 0 : {
        if(dev0_mul0_c->ctrl.f.setb) break;
        dev0_mul0_c->ctrl.f.uns = 0;
        dev0_mul0_c->a.r = *(unsigned int *)&a;
        dev0_mul0_c->b.r = *(unsigned int *)&b;
        dev0_mul0_c->ctrl.f.setb = 1;
        while(dev0_mul0_c->ctrl.f.setb);
        dev0_mul0_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_mul0_c->p_l.r);
      }
      /*case 1 : {
        if(dev0_mul1_c->ctrl.f.setb) break;
        dev0_mul1_c->ctrl.f.uns = 0;
        dev0_mul1_c->a.r = *(unsigned int *)&a;
        dev0_mul1_c->b.r = *(unsigned int *)&b;
        dev0_mul1_c->ctrl.f.setb = 1;
        while(dev0_mul1_c->ctrl.f.setb);
        dev0_mul1_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_mul1_c->p_l.r);
      }
      case 2 : {
        if(dev0_mul2_c->ctrl.f.setb) break;
        dev0_mul2_c->ctrl.f.uns = 0;
        dev0_mul2_c->a.r = *(unsigned int *)&a;
        dev0_mul2_c->b.r = *(unsigned int *)&b;
        dev0_mul2_c->ctrl.f.setb = 1;
        while(dev0_mul2_c->ctrl.f.setb);
        dev0_mul2_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_mul2_c->p_l.r);
      }
      case 3 : {
        if(dev0_mul3_c->ctrl.f.setb) break;
        dev0_mul3_c->ctrl.f.uns = 0;
        dev0_mul3_c->a.r = *(unsigned int *)&a;
        dev0_mul3_c->b.r = *(unsigned int *)&b;
        dev0_mul3_c->ctrl.f.setb = 1;
        while(dev0_mul3_c->ctrl.f.setb);
        dev0_mul3_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_mul3_c->p_l.r);
      }*/
    }
  }
  while(dev0_mul0_c->ctrl.f.setb);
  dev0_mul0_c->ctrl.f.uns = 0;
  dev0_mul0_c->a.r = *(unsigned int *)&a;
  dev0_mul0_c->b.r = *(unsigned int *)&b;
  dev0_mul0_c->ctrl.f.setb = 1;
  while(dev0_mul0_c->ctrl.f.setb);
  dev0_mul0_c->ctrl.f.setb = 0;
  return *(int *)&(dev0_mul0_c->p_l.r);
}


unsigned int divu(unsigned int a, unsigned int b) {
  int k;
  for(k=0;k<=0;k++){
    switch(k) {
      case 0 : {
        if(dev0_div0_c->ctrl.f.setb) break;
        dev0_div0_c->ctrl.f.uns = 1;
        dev0_div0_c->a.r = a;
        dev0_div0_c->b.r = b;
        dev0_div0_c->ctrl.f.setb = 1;
        while(dev0_div0_c->ctrl.f.setb);
        dev0_div0_c->ctrl.f.setb = 0;
        return dev0_div0_c->q.r;
      }
      /*case 1 : {
        if(dev0_div1_c->ctrl.f.setb) break;
        dev0_div1_c->ctrl.f.uns = 1;
        dev0_div1_c->a.r = a;
        dev0_div1_c->b.r = b;
        dev0_div1_c->ctrl.f.setb = 1;
        while(dev0_div1_c->ctrl.f.setb);
        dev0_div1_c->ctrl.f.setb = 0;
        return dev0_div1_c->q.r;
      }
      case 2 : {
        if(dev0_div2_c->ctrl.f.setb) break;
        dev0_div2_c->ctrl.f.uns = 1;
        dev0_div2_c->a.r = a;
        dev0_div2_c->b.r = b;
        dev0_div2_c->ctrl.f.setb = 1;
        while(dev0_div2_c->ctrl.f.setb);
        dev0_div2_c->ctrl.f.setb = 0;
        return dev0_div2_c->q.r;
      }
      case 3 : {
        if(dev0_div3_c->ctrl.f.setb) break;
        dev0_div3_c->ctrl.f.uns = 1;
        dev0_div3_c->a.r = a;
        dev0_div3_c->b.r = b;
        dev0_div3_c->ctrl.f.setb = 1;
        while(dev0_div3_c->ctrl.f.setb);
        dev0_div3_c->ctrl.f.setb = 0;
        return dev0_div3_c->q.r;
      }*/
    }
  }
  while(dev0_div0_c->ctrl.f.setb);
  dev0_div0_c->ctrl.f.uns = 1;
  dev0_div0_c->a.r = a;
  dev0_div0_c->b.r = b;
  dev0_div0_c->ctrl.f.setb = 1;
  while(dev0_div0_c->ctrl.f.setb);
  dev0_div0_c->ctrl.f.setb = 0;
  return dev0_div0_c->q.r;
}

int div(int a, int b) {
  int k;
  for(k=0;k<=0;k++){
    switch(k) {
      case 0 : {
        if(dev0_div0_c->ctrl.f.setb) break;
        dev0_div0_c->ctrl.f.uns = 0;
        dev0_div0_c->a.r = *(unsigned int *)&a;
        dev0_div0_c->b.r = *(unsigned int *)&b;
        dev0_div0_c->ctrl.f.setb = 1;
        while(dev0_div0_c->ctrl.f.setb);
        dev0_div0_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_div0_c->q.r);
      }
      /*case 1 : {
        if(dev0_div1_c->ctrl.f.setb) break;
        dev0_div1_c->ctrl.f.uns = 0;
        dev0_div1_c->a.r = *(unsigned int *)&a;
        dev0_div1_c->b.r = *(unsigned int *)&b;
        dev0_div1_c->ctrl.f.setb = 1;
        while(dev0_div1_c->ctrl.f.setb);
        dev0_div1_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_div1_c->q.r);
      }
      case 2 : {
        if(dev0_div2_c->ctrl.f.setb) break;
        dev0_div2_c->ctrl.f.uns = 0;
        dev0_div2_c->a.r = *(unsigned int *)&a;
        dev0_div2_c->b.r = *(unsigned int *)&b;
        dev0_div2_c->ctrl.f.setb = 1;
        while(dev0_div2_c->ctrl.f.setb);
        dev0_div2_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_div2_c->q.r);
      }
      case 3 : {
        if(dev0_div3_c->ctrl.f.setb) break;
        dev0_div3_c->ctrl.f.uns = 0;
        dev0_div3_c->a.r = *(unsigned int *)&a;
        dev0_div3_c->b.r = *(unsigned int *)&b;
        dev0_div3_c->ctrl.f.setb = 1;
        while(dev0_div3_c->ctrl.f.setb);
        dev0_div3_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_div3_c->q.r);
      }*/
    }
  }
  while(dev0_div0_c->ctrl.f.setb);
  dev0_div0_c->ctrl.f.uns = 0;
  dev0_div0_c->a.r = *(unsigned int *)&a;
  dev0_div0_c->b.r = *(unsigned int *)&b;
  dev0_div0_c->ctrl.f.setb = 1;
  while(dev0_div0_c->ctrl.f.setb);
  dev0_div0_c->ctrl.f.setb = 0;
  return *(int *)&(dev0_div0_c->q.r);
}




unsigned int modu(unsigned int a, unsigned int b) {
  int k;
  for(k=0;k<=0;k++){
    switch(k) {
      case 0 : {
        if(dev0_div0_c->ctrl.f.setb) break;
        dev0_div0_c->ctrl.f.uns = 1;
        dev0_div0_c->a.r = a;
        dev0_div0_c->b.r = b;
        dev0_div0_c->ctrl.f.setb = 1;
        while(dev0_div0_c->ctrl.f.setb);
        dev0_div0_c->ctrl.f.setb = 0;
        return dev0_div0_c->r.r;
      }
      /*case 1 : {
        if(dev0_div1_c->ctrl.f.setb) break;
        dev0_div1_c->ctrl.f.uns = 1;
        dev0_div1_c->a.r = a;
        dev0_div1_c->b.r = b;
        dev0_div1_c->ctrl.f.setb = 1;
        while(dev0_div1_c->ctrl.f.setb);
        dev0_div1_c->ctrl.f.setb = 0;
        return dev0_div1_c->r.r;
      }
      case 2 : {
        if(dev0_div2_c->ctrl.f.setb) break;
        dev0_div2_c->ctrl.f.uns = 1;
        dev0_div2_c->a.r = a;
        dev0_div2_c->b.r = b;
        dev0_div2_c->ctrl.f.setb = 1;
        while(dev0_div2_c->ctrl.f.setb);
        dev0_div2_c->ctrl.f.setb = 0;
        return dev0_div2_c->r.r;
      }
      case 3 : {
        if(dev0_div3_c->ctrl.f.setb) break;
        dev0_div3_c->ctrl.f.uns = 1;
        dev0_div3_c->a.r = a;
        dev0_div3_c->b.r = b;
        dev0_div3_c->ctrl.f.setb = 1;
        while(dev0_div3_c->ctrl.f.setb);
        dev0_div3_c->ctrl.f.setb = 0;
        return dev0_div3_c->r.r;
      }*/
    }
  }
  while(dev0_div0_c->ctrl.f.setb);
  dev0_div0_c->ctrl.f.uns = 1;
  dev0_div0_c->a.r = a;
  dev0_div0_c->b.r = b;
  dev0_div0_c->ctrl.f.setb = 1;
  while(dev0_div0_c->ctrl.f.setb);
  dev0_div0_c->ctrl.f.setb = 0;
  return dev0_div0_c->r.r;
}

int mod(int a, int b) {
  int k;
  for(k=0;k<=0;k++){
    switch(k) {
      case 0 : {
        if(dev0_div0_c->ctrl.f.setb) break;
        dev0_div0_c->ctrl.f.uns = 0;
        dev0_div0_c->a.r = *(unsigned int *)&a;
        dev0_div0_c->b.r = *(unsigned int *)&b;
        dev0_div0_c->ctrl.f.setb = 1;
        while(dev0_div0_c->ctrl.f.setb);
        dev0_div0_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_div0_c->r.r);
      }
      /*case 1 : {
        if(dev0_div1_c->ctrl.f.setb) break;
        dev0_div1_c->ctrl.f.uns = 0;
        dev0_div1_c->a.r = *(unsigned int *)&a;
        dev0_div1_c->b.r = *(unsigned int *)&b;
        dev0_div1_c->ctrl.f.setb = 1;
        while(dev0_div1_c->ctrl.f.setb);
        dev0_div1_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_div1_c->r.r);
      }
      case 2 : {
        if(dev0_div2_c->ctrl.f.setb) break;
        dev0_div2_c->ctrl.f.uns = 0;
        dev0_div2_c->a.r = *(unsigned int *)&a;
        dev0_div2_c->b.r = *(unsigned int *)&b;
        dev0_div2_c->ctrl.f.setb = 1;
        while(dev0_div2_c->ctrl.f.setb);
        dev0_div2_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_div2_c->r.r);
      }
      case 3 : {
        if(dev0_div3_c->ctrl.f.setb) break;
        dev0_div3_c->ctrl.f.uns = 0;
        dev0_div3_c->a.r = *(unsigned int *)&a;
        dev0_div3_c->b.r = *(unsigned int *)&b;
        dev0_div3_c->ctrl.f.setb = 1;
        while(dev0_div3_c->ctrl.f.setb);
        dev0_div3_c->ctrl.f.setb = 0;
        return *(int *)&(dev0_div3_c->r.r);
      }*/
    }
  }
  while(dev0_div0_c->ctrl.f.setb);
  dev0_div0_c->ctrl.f.uns = 0;
  dev0_div0_c->a.r = *(unsigned int *)&a;
  dev0_div0_c->b.r = *(unsigned int *)&b;
  dev0_div0_c->ctrl.f.setb = 1;
  while(dev0_div0_c->ctrl.f.setb);
  dev0_div0_c->ctrl.f.setb = 0;
  return *(int *)&(dev0_div0_c->r.r);
}








#include "sys_wrapper.h"
