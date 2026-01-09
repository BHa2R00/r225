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
}omuxsel_t_a_0_to_3;
typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int a_4 : 8 ;
    volatile unsigned int a_5 : 8 ;
    volatile unsigned int a_6 : 8 ;
    volatile unsigned int a_7 : 8 ;
    volatile unsigned int a_8 : 8 ;
  }f;
}omuxsel_t_a_4_to_7;
typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int a_8 : 8 ;
    volatile unsigned int a_9 : 8 ;
    volatile unsigned int unused10 : 8 ;
    volatile unsigned int unused11 : 8 ;
    volatile unsigned int unused12 : 8 ;
  }f;
}omuxsel_t_a_8_to_11;
typedef struct
{
volatile omuxsel_t_a_0_to_3 a_0_to_3 ;
volatile omuxsel_t_a_4_to_7 a_4_to_7 ;
volatile omuxsel_t_a_8_to_11 a_8_to_11 ;
}omuxsel_t;
