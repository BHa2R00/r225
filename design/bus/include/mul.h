typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int data : 32;
  }f;
}mul_t_a;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int data : 32;
  }f;
}mul_t_b;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int data : 32;
  }f;
}mul_t_p_l;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int data : 32;
  }f;
}mul_t_p_h;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int setb   :  1;
    volatile unsigned int uns    :  1;
    volatile unsigned int unused : 30;
  }f;
}mul_t_ctrl;

typedef struct
{
volatile mul_t_a    a    ;
volatile mul_t_b    b    ;
volatile mul_t_p_l  p_l  ;
volatile mul_t_p_h  p_h  ;
volatile mul_t_ctrl ctrl ;
}mul_t;

