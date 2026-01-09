typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int i : 32 ;
  }f;
}debug_t_i;
typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int o : 32 ;
  }f;
}debug_t_o;
typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int boot   :  1 ;
    volatile unsigned int unused : 31 ;
  }f;
}debug_t_main;
typedef struct
{
  volatile debug_t_o o0;
  volatile debug_t_i i0;
  volatile debug_t_o o1;
  volatile debug_t_i i1;
  volatile debug_t_main main;
}debug_t;
