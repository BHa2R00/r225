typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int setb    :  1 ;
    volatile unsigned int ini     :  1 ;
    volatile unsigned int shr     :  6 ;
    volatile unsigned int unused  : 24 ;
  }f;
}fclkdiv_t_ctrl;
typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int value  : 32 ;
  }f;
}fclkdiv_t_dven;
typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int value  : 32 ;
  }f;
}fclkdiv_t_dvsr;
typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int value  : 32 ;
  }f;
}fclkdiv_t_cnt;
typedef struct
{
  volatile fclkdiv_t_ctrl ctrl;
  volatile fclkdiv_t_dven dven;
  volatile fclkdiv_t_dvsr dvsr;
  volatile fclkdiv_t_cnt  cnt ;
}fclkdiv_t;
