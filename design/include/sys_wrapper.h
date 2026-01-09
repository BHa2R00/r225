//write & read
#define w32(a,b) *(volatile uint32_t*)(a) = (uint32_t)(b);
#define w16(a,b) *(volatile uint16_t*)(a) = (uint16_t)(b);
#define w8(a,b)  *(volatile uint8_t* )(a) = (uint8_t )(b);
#define r32(a)   *(volatile uint32_t*)(a)
#define r16(a)   *(volatile uint16_t*)(a)
#define r8(a)    *(volatile uint8_t*)(a)




//unsigned int __mulusi3(unsigned int a, unsigned int b) __attribute__((__used__, __externally_visible__, __noinline__));
unsigned int __mulusi3(unsigned int a, unsigned int b) { return mulu(a, b); }
//int __mulsi3(int a, int b) __attribute__((__used__, __externally_visible__, __noinline__));
int __mulsi3(int a, int b) { return mul(a, b); }


//unsigned int __divusi3(unsigned int a, unsigned int b) __attribute__((__used__, __externally_visible__, __noinline__));
unsigned int __divusi3(unsigned int a, unsigned int b) { return divu(a, b); }
//int __divsi3(int a, int b) __attribute__((__used__, __externally_visible__, __noinline__));
int __divsi3(int a, int b) { return div(a, b); }


//unsigned int __modusi3(unsigned int a, unsigned int b) __attribute__((__used__, __externally_visible__, __noinline__));
unsigned int __modusi3(unsigned int a, unsigned int b) { return modu(a, b); }
//int __modsi3(int a, int b) __attribute__((__used__, __externally_visible__, __noinline__));
int __modsi3(int a, int b) { return mod(a, b); }






/*
extern char __bss_end;
static char *heap_end;
void* _sbrk(int incr) {
    if (heap_end == 0) heap_end = &__bss_end;
    char *prev = heap_end;
    heap_end += incr;
    return (void*)prev;
}
*/
extern char __heap_start;
static char *heap_end = 0;
__attribute__((constructor))
void heap_init(void) {
    if (heap_end == 0) {
        heap_end = &__heap_start;
    }
}
void* _sbrk(int incr) {
    char *prev = heap_end;
    heap_end += incr;
    return (void*)prev;
}

ssize_t _write(int fd, const void *buf, size_t count) {
    const char *p = buf;
    (void)fd;
    for (size_t i = 0; i < count; i++) {
        //if (p[i] == '\n') txbyte('\r');
        //txbyte(p[i]);
        if (p[i] == '\n') uart_tx('\r');
        uart_tx(p[i]);
    }
    return count;
}

ssize_t _read(int fd, void *buf, size_t count) {
    (void)fd;
    char *p = buf;
    for (size_t i = 0; i < count; i++) {
        p[i] = rxbyte();
    }
    return count;
}

/* Return failure directly, no errno */
int _close(int fd)        { (void)fd; return -1; }
int _isatty(int fd)       { (void)fd; return 1; }
int _fstat(int fd, struct stat *st) { (void)fd; st->st_mode = S_IFCHR; return 0; }
off_t _lseek(int fd, off_t offset, int whence) { (void)fd; (void)offset; (void)whence; return 0; }
int _open(const char *name, int flags, int mode) { (void)name; (void)flags; (void)mode; return -1; }














static void print_char(char c) {
    //if (c == '\n') txbyte('\r');  // fix CR/LF
    //txbyte(c);
    uart_tx(c);
}

static void print_str(const char *s) {
    while (*s) print_char(*s++);
}

static void print_dec(int val) {
    char buf[16];
    int i = 0;
    if (val == 0) {
        print_char('0');
        return;
    }
    if (val < 0) {
        print_char('-');
        val = -val;
    }
    while (val > 0 && i < 15) {
        buf[i++] = '0' + (val % 10);
        val /= 10;
    }
    while (i--) print_char(buf[i]);
}

static void print_hex(unsigned val) {
    const char *hex = "0123456789ABCDEF";
    char buf[16];
    int i = 0;
    if (val == 0) {
        print_char('0');
        return;
    }
    while (val > 0 && i < 15) {
        buf[i++] = hex[val & 0xF];
        val >>= 4;
    }
    print_char('0'); print_char('x');
    while (i--) print_char(buf[i]);
}

int printf(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    while (*fmt) {
        if (*fmt == '%') {
            fmt++;
            switch (*fmt) {
                case 's': print_str(va_arg(ap, const char*)); break;
                case 'd': print_dec(va_arg(ap, int)); break;
                case 'x': print_hex(va_arg(ap, unsigned)); break;
                case 'c': print_char((char)va_arg(ap, int)); break;
                case '%': print_char('%'); break;
                default:  print_char('?'); break;
            }
        } else {
            print_char(*fmt);
        }
        fmt++;
    }
    va_end(ap);
    return 0;
}
























// 新增：scanf 实现
static char read_char(void) {
    return (char)uart_rx();  // 阻塞读取
}

static void read_str(char *buf, size_t max_len) {
    size_t i = 0;
    char c;
    while (i < max_len - 1) {
        c = read_char();
        if (c == '\r' || c == '\n') {
            buf[i] = '\0';
            uart_tx('\r');
            uart_tx('\n');
            break;
        } else if (c == '\b' || c == 127) {  // 退格
            if (i > 0) {
                i--;
                uart_tx('\b');
                uart_tx(' ');
                uart_tx('\b');
            }
        } else {
            buf[i++] = c;
            uart_tx(c);  // 回显
        }
    }
    if (i >= max_len - 1) buf[i] = '\0';
}

static int parse_int(const char *str, int base) {
    int val = 0;
    int sign = 1;
    if (*str == '-') {
        sign = -1;
        str++;
    }
    while (*str) {
        char c = *str++;
        int digit;
        if (c >= '0' && c <= '9') digit = c - '0';
        else if (base == 16 && c >= 'a' && c <= 'f') digit = c - 'a' + 10;
        else if (base == 16 && c >= 'A' && c <= 'F') digit = c - 'A' + 10;
        else break;
        val = val * base + digit;
    }
    return sign * val;
}

int scanf(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);

    while (*fmt) {
        if (*fmt == '%') {
            fmt++;
            switch (*fmt) {
                case 's': {
                    char *str = va_arg(ap, char*);
                    read_str(str, 128);  // 最大长度 128
                    break;
                }
                case 'c': {
                    char *ch = va_arg(ap, char*);
                    *ch = read_char();
                    break;
                }
                case 'd': {
                    int *val = va_arg(ap, int*);
                    char buf[32];
                    read_str(buf, sizeof(buf));
                    *val = parse_int(buf, 10);
                    break;
                }
                case 'x': {
                    unsigned int *val = va_arg(ap, unsigned int*);
                    char buf[32];
                    read_str(buf, sizeof(buf));
                    *val = (unsigned int)parse_int(buf, 16);
                    break;
                }
                default:
                    fmt++;
                    continue;
            }
        } else if (*fmt == ' ' || *fmt == '\n') {
            // 跳过空格
            while (*fmt == ' ' || *fmt == '\n') fmt++;
            continue;
        } else {
            // 字面匹配（可选实现）
            fmt++;
        }
        fmt++;
    }

    va_end(ap);
    return 0;  // 简单返回 0
}


