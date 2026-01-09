typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int rtc    : 16 ;
    volatile unsigned int unused : 16 ;
  }f;
}cgu_t_rtc;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int clk0   :  5 ;
    volatile unsigned int clk1   :  5 ;
    volatile unsigned int clk2   :  5 ;
    volatile unsigned int clk3   :  5 ;
    volatile unsigned int unused : 12 ;
  }f;
}cgu_t_sel;

typedef struct
{
  volatile cgu_t_rtc rtc;
  volatile cgu_t_sel sel;
}cgu_t;
