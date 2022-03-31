#include <stdio.h>
#include <stdarg.h>

void Printf(const char *str, ...) {
    va_list ptr; 
    va_start(ptr, str);
    vprintf(str, ptr);
    va_end(ptr);
}

