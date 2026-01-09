typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int data : 32;
  }f;
}div_t_a;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int data : 32;
  }f;
}div_t_b;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int data : 32;
  }f;
}div_t_q;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int data : 32;
  }f;
}div_t_r;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int setb   :  1;
    volatile unsigned int uns    :  1;
    volatile unsigned int unused : 30;
  }f;
}div_t_ctrl;

typedef struct
{
volatile div_t_a    a    ;
volatile div_t_b    b    ;
volatile div_t_q    q    ;
volatile div_t_r    r    ;
volatile div_t_ctrl ctrl ;
}div_t;

