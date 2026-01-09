typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dir : 31 ;
  }f;
}gpio_t_dir;
typedef struct
{
  volatile gpio_t_dir dir;
}gpio_t;
