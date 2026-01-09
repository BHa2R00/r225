#define TEXT0_ROM0_A0        0x00000000
#define text0_rom0           ((volatile srom8k_t             *) TEXT0_ROM0_A0       )
#define DATA0_RAM1_A0        0x00002000
#define data0_ram1           ((volatile sram1k_t             *) DATA0_RAM1_A0       )
#define DEV0_CPU0_C_A0       0x00002400
#define dev0_cpu0_c          ((volatile rv32e_t              *) DEV0_CPU0_C_A0      )
#define DEV0_IRQ0_C_A0       0x00002444
#define dev0_irq0_c          ((volatile irq_t                *) DEV0_IRQ0_C_A0      )
#define DEV0_MUL0_C_A0       0x00002448
#define dev0_mul0_c          ((volatile mul_t                *) DEV0_MUL0_C_A0      )
#define DEV0_DIV0_C_A0       0x0000245C
#define dev0_div0_c          ((volatile div_t                *) DEV0_DIV0_C_A0      )
#define DEV0_DEBUG0_A0       0x00002470
#define dev0_debug0          ((volatile debug_t              *) DEV0_DEBUG0_A0      )
#define DEV0_UART_TX0_A0     0x00002484
#define dev0_uart_tx0        ((volatile uart_tx_t            *) DEV0_UART_TX0_A0    )
#define DEV0_UART_RX0_A0     0x00002498
#define dev0_uart_rx0        ((volatile uart_rx_t            *) DEV0_UART_RX0_A0    )
#define DEV0_CGU0_C_A0       0x000024AC
#define dev0_cgu0_c          ((volatile cgu_t                *) DEV0_CGU0_C_A0      )
#define DEV0_FCLKDIV0_C_A0   0x000024BC
#define dev0_fclkdiv0_c      ((volatile fclkdiv_t            *) DEV0_FCLKDIV0_C_A0  )
#define DEV0_HWTIMER0_C_A0   0x000024CC
#define dev0_hwtimer0_c      ((volatile hwtimer_t            *) DEV0_HWTIMER0_C_A0  )
#define DEV0_CRC0_C_A0       0x000024D8
#define dev0_crc0_c          ((volatile crc_t                *) DEV0_CRC0_C_A0      )
#define DEV0_PANNEL_A0       0x000024EC
#define dev0_pannel          ((volatile pannel_t             *) DEV0_PANNEL_A0      )
