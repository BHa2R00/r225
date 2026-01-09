typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int text0_clk_en         :  1;
    volatile unsigned int text0_rom0_clk_en    :  1;
    volatile unsigned int rom0_clk_en          :  1;
    volatile unsigned int data0_clk_en         :  1;
    volatile unsigned int data0_ram1_clk_en    :  1;
    volatile unsigned int ram1_clk_en          :  1;
    volatile unsigned int dev0_clk_en          :  1;
    volatile unsigned int dev0_cpu0_c_clk_en   :  1;
    volatile unsigned int cpu0_c_clk_en        :  1;
    volatile unsigned int text0_cpu0_d_clk_en  :  1;
    volatile unsigned int data0_cpu0_d_clk_en  :  1;
    volatile unsigned int dev0_cpu0_d_clk_en   :  1;
    volatile unsigned int cpu0_d_clk_en        :  1;
    volatile unsigned int text0_cpu0_i_clk_en  :  1;
    volatile unsigned int data0_cpu0_i_clk_en  :  1;
    volatile unsigned int dev0_cpu0_i_clk_en   :  1;
    volatile unsigned int cpu0_i_clk_en        :  1;
    volatile unsigned int dev0_irq0_c_clk_en   :  1;
    volatile unsigned int irq0_c_clk_en        :  1;
    volatile unsigned int dev0_mul0_c_clk_en   :  1;
    volatile unsigned int mul0_c_clk_en        :  1;
    volatile unsigned int dev0_div0_c_clk_en   :  1;
    volatile unsigned int div0_c_clk_en        :  1;
    volatile unsigned int dev0_debug0_clk_en   :  1;
    volatile unsigned int debug0_clk_en        :  1;
    volatile unsigned int dev0_uart_tx0_clk_en :  1;
    volatile unsigned int uart_tx0_clk_en      :  1;
    volatile unsigned int dev0_uart_rx0_clk_en :  1;
    volatile unsigned int uart_rx0_clk_en      :  1;
    volatile unsigned int dev0_cgu0_c_clk_en   :  1;
    volatile unsigned int cgu0_c_clk_en        :  1;
    volatile unsigned int dev0_fclkdiv0_c_clk_en :  1;
  }f;
}pannel_t_w0;
typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int fclkdiv0_c_clk_en    :  1;
    volatile unsigned int dev0_hwtimer0_c_clk_en :  1;
    volatile unsigned int hwtimer0_c_clk_en    :  1;
    volatile unsigned int dev0_crc0_c_clk_en   :  1;
    volatile unsigned int crc0_c_clk_en        :  1;
    volatile unsigned int unused               : 27;
  }f;
}pannel_t_w1;

typedef struct
{
 volatile pannel_t_w0 t_w0;
 volatile pannel_t_w1 t_w1;
}pannel_t;
