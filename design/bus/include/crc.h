typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dat : 32;  // 1-depth fifo read write 
  }f;
}crc_t_dat;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int tap : 32; // tap value 
  }f;
}crc_t_tap;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int sum : 32; // crc, write to renew crc 
  }f;
}crc_t_sum;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int bitmode :  1; // 0: from 0 to msb, 1: from msb to 0 
    volatile unsigned int ldb     :  3; // load data byte, msb = ldb*8-1
    volatile unsigned int bth     :  5; // bit counter 
    volatile unsigned int dma     :  1; // enable dma 
    volatile unsigned int cst     :  1; // cst, 1 for idle -> req 
    volatile unsigned int unused  :  5;
    volatile unsigned int cnt     : 16; // byte counter, write crc to reset 
  }f;
}crc_t_ctl;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int check : 32; // xor checker !=0 -> error 
  }f;
}crc_t_xor;

typedef struct
{
volatile crc_t_dat dat  ; // data
volatile crc_t_tap tap  ; // tap
volatile crc_t_sum sum  ; // sum
volatile crc_t_ctl ctl  ; // ctrl 
volatile crc_t_xor xor  ; // check 
}crc_t;

