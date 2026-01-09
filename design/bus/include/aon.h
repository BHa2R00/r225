typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int setb   :  1;
    volatile unsigned int ini    :  1;
    volatile unsigned int unused : 32;
  }f;
}aon_t_fast_clk_ctrl;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int shr : 32;
  }f;
}aon_t_fast_clk_shr;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dven : 32;
  }f;
}aon_t_fast_clk_dven;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dvsr : 32;
  }f;
}aon_t_fast_clk_dvsr;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int setb   :  1;
    volatile unsigned int ini    :  1;
    volatile unsigned int unused : 32;
  }f;
}aon_t_slow_clk_ctrl;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int shr : 32;
  }f;
}aon_t_slow_clk_shr;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dven : 32;
  }f;
}aon_t_slow_clk_dven;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dvsr : 32;
  }f;
}aon_t_slow_clk_dvsr;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int setb   :  1;
    volatile unsigned int ini    :  1;
    volatile unsigned int unused : 32;
  }f;
}aon_t_sleep_clk_ctrl;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int shr : 32;
  }f;
}aon_t_sleep_clk_shr;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dven : 32;
  }f;
}aon_t_sleep_clk_dven;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dvsr : 32;
  }f;
}aon_t_sleep_clk_dvsr;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int hwsetb : 16;
    volatile unsigned int ret    : 16;
  }f;
}aon_t_cpu_ctrl;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int counter : 32;
  }f;
}aon_t_counter;


typedef struct
{
volatile aon_t_fast_clk_ctrl fast_clk_ctrl;
volatile aon_t_fast_clk_shr  fast_clk_shr ;
volatile aon_t_fast_clk_dven fast_clk_dven;
volatile aon_t_fast_clk_dvsr fast_clk_dvsr;
volatile aon_t_slow_clk_ctrl slow_clk_ctrl;
volatile aon_t_slow_clk_shr  slow_clk_shr ;
volatile aon_t_slow_clk_dven slow_clk_dven;
volatile aon_t_slow_clk_dvsr slow_clk_dvsr;
volatile aon_t_sleep_clk_ctrl sleep_clk_ctrl;
volatile aon_t_sleep_clk_shr  sleep_clk_shr ;
volatile aon_t_sleep_clk_dven sleep_clk_dven;
volatile aon_t_sleep_clk_dvsr sleep_clk_dvsr;
volatile aon_t_cpu_ctrl cpu_ctrl;
volatile aon_t_counter counter;
}aon_t;

