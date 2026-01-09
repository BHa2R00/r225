typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int value  : 32 ;
  }f;
}irq_t_mask;
typedef struct
{
  volatile irq_t_mask mask;
}irq_t;
