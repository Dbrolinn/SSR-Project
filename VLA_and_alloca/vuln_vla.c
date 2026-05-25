#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* noinline sink: the compiler cannot see through it, so it is forced to
   allocate the VLA for real and touch every page. This prevents the
   optimizer from deleting the allocation as dead code at -O2.            */
__attribute__((noinline))
void touch_pages(volatile char *buf, unsigned long n) {
    for (unsigned long i = 0; i < n; i += 4096)
        buf[i] = (char)(i & 0xff);     /* write one byte per page */
    buf[n - 1] = 'X';                  /* touch the very last byte */
}

void process(unsigned long n) {
    char buffer[n];                    /* VLA: runtime-sized stack alloc */
    touch_pages(buffer, n);
    printf("[vla] allocated %lu bytes, buffer[n-1]=%c\n", n, buffer[n-1]);
}

int main(int argc, char **argv) {
    unsigned long n = (argc > 1) ? strtoul(argv[1], NULL, 10) : 64;
    printf(" VLA stack exhaustion\n");
    printf("Requested allocation: %lu bytes\n", n);
    process(n);
    printf("[vla] returned normally\n");
    return 0;
}
