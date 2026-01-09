typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int a_0 : 8 ;
    volatile unsigned int a_1 : 8 ;
    volatile unsigned int a_2 : 8 ;
    volatile unsigned int a_3 : 8 ;
    volatile unsigned int a_4 : 8 ;
  }f;
}imuxsel_t_a_0_to_3;
typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int a_4 : 8 ;
    volatile unsigned int a_5 : 8 ;
    volatile unsigned int unused6 : 8 ;
    volatile unsigned int unused7 : 8 ;
    volatile unsigned int unused8 : 8 ;
  }f;
}imuxsel_t_a_4_to_7;
typedef struct
{
volatile imuxsel_t_a_0_to_3 a_0_to_3 ;
volatile imuxsel_t_a_4_to_7 a_4_to_7 ;
}imuxsel_t;
