typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int data   : 32;
  }f;
}uart_rx_t_data;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dven   : 32;
  }f;
}uart_rx_t_dven;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int dvsr   : 32;
  }f;
}uart_rx_t_dvsr;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int sb          :  6;
    volatile unsigned int width       :  6;
    volatile unsigned int idle        :  1;
    volatile unsigned int irq_enable_idle :  1;
    volatile unsigned int irq_idle        :  1;
    volatile unsigned int irq_unmask_idle :  1;
    volatile unsigned int crc_width   :  6;
    volatile unsigned int unused      : 10;
  }f;
}uart_rx_t_ctrl;

typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int crc_sum     : 16;
    volatile unsigned int crc_tap     : 16;
  }f;
}uart_rx_t_crc;

typedef struct
{
volatile uart_rx_t_data data ;
volatile uart_rx_t_dven dven ;
volatile uart_rx_t_dvsr dvsr ;
volatile uart_rx_t_ctrl ctrl ;
volatile uart_rx_t_crc  crc  ;
}uart_rx_t;

