typedef union
{
  volatile unsigned int r;
  struct
  {
    volatile unsigned int pc   : 30 ;
    volatile unsigned int setb :  1 ;
  }f;
}rv32e_t_ctrl;

typedef union { volatile unsigned int r; }rv32e_t_ra;
typedef union { volatile unsigned int r; }rv32e_t_sp;
typedef union { volatile unsigned int r; }rv32e_t_gp;
typedef union { volatile unsigned int r; }rv32e_t_tp;
typedef union { volatile unsigned int r; }rv32e_t_t0;
typedef union { volatile unsigned int r; }rv32e_t_t1;
typedef union { volatile unsigned int r; }rv32e_t_t2;
typedef union { volatile unsigned int r; }rv32e_t_s0;
typedef union { volatile unsigned int r; }rv32e_t_s1;
typedef union { volatile unsigned int r; }rv32e_t_a0;
typedef union { volatile unsigned int r; }rv32e_t_a1;
typedef union { volatile unsigned int r; }rv32e_t_a2;
typedef union { volatile unsigned int r; }rv32e_t_a3;
typedef union { volatile unsigned int r; }rv32e_t_a4;
typedef union { volatile unsigned int r; }rv32e_t_a5;

typedef struct
{
  volatile rv32e_t_ctrl ctrl;
  volatile rv32e_t_ra ra;
  volatile rv32e_t_sp sp;
  volatile rv32e_t_gp gp;
  volatile rv32e_t_tp tp;
  volatile rv32e_t_t0 t0;
  volatile rv32e_t_t1 t1;
  volatile rv32e_t_t2 t2;
  volatile rv32e_t_s0 s0;
  volatile rv32e_t_s1 s1;
  volatile rv32e_t_a0 a0;
  volatile rv32e_t_a1 a1;
  volatile rv32e_t_a2 a2;
  volatile rv32e_t_a3 a3;
  volatile rv32e_t_a4 a4;
  volatile rv32e_t_a5 a5;
}rv32e_t;
