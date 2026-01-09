typedef union
{
    volatile uint32_t r;
    struct
    {
        volatile uint32_t enable                          : 1 ;
        volatile uint32_t update                          : 1 ;
        volatile uint32_t oneshot                         : 1 ;
        volatile uint32_t irq_enable                      : 1 ;
        volatile uint32_t hit                             : 1 ;
        volatile uint32_t unused0                         : 27;
    }f;
}hwtimer_t_ctrl;

typedef union
{
    volatile uint32_t r;
    struct
    {
        volatile uint32_t cnt                             : 32;
    }f;
}hwtimer_t_load;

typedef union
{
    volatile uint32_t r;
    struct
    {
        volatile uint32_t cnt                             : 32;
    }f;
}hwtimer_t_store;
typedef struct
{
volatile hwtimer_t_ctrl                                           ctrl                          ; //0x0
volatile hwtimer_t_load                                           load                          ; //0x4
volatile hwtimer_t_store                                          store                         ; //0x8
}hwtimer_t;

