#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <alloca.h>

__attribute__((noinline))
void touch_pages(volatile char *buf, unsigned long n) {
    for (unsigned long i = 0; i < n; i += 4096)
        buf[i] = (char)(i & 0xff);
    buf[n - 1] = 'X';
}

void process(unsigned long n) {
    char *buffer = (char *) alloca(n); /* explicit stack allocation */
    touch_pages(buffer, n);
    printf("[alloca] allocated %lu bytes, buffer[n-1]=%c\n", n, buffer[n-1]);
}

int main(int argc, char **argv) {
    unsigned long n = (argc > 1) ? strtoul(argv[1], NULL, 10) : 64;
    printf(" alloca() stack exhaustion\n");
    printf("Requested allocation: %lu bytes\n", n);
    process(n);
    printf("[alloca] returned normally\n");
    return 0;
}
