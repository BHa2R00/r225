typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int data   :  8;
    volatile unsigned int unused : 24;
  }f;
}txbyte_t_data;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dven   : 32;
  }f;
}txbyte_t_dven;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dvsr   : 32;
  }f;
}txbyte_t_dvsr;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int sb     :  4;
    volatile unsigned int busy   :  1;
    volatile unsigned int irq_enable_idle :  1;
    volatile unsigned int irq_idle        :  1;
    volatile unsigned int irq_unmask_idle :  1;
    volatile unsigned int unused : 24;
  }f;
}txbyte_t_ctrl;

typedef struct
{
volatile txbyte_t_data data ;
volatile txbyte_t_dven dven ;
volatile txbyte_t_dvsr dvsr ;
volatile txbyte_t_ctrl ctrl ;
}txbyte_t;

