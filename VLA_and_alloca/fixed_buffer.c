#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_BUFFER 4096               

void process(unsigned long n) {
    if (n > MAX_BUFFER) {              /* reject oversized requests */
        fprintf(stderr, "[fixed-buf] request %lu exceeds limit %d - rejected\n",
                n, MAX_BUFFER);
        return;
    }
    char buffer[MAX_BUFFER];           /* fixed bounded stack allocation */
    memset(buffer, 'A', n);
    buffer[0] = 'X';
    printf("[fixed-buf] handled %lu bytes safely, buffer[0]=%c\n", n, buffer[0]);
}

int main(int argc, char **argv) {
    unsigned long n = (argc > 1) ? strtoul(argv[1], NULL, 10) : 64;
    printf(" Fixed-buffer (safe)\n");
    printf("Requested allocation: %lu bytes\n", n);
    process(n);
    printf("[fixed-buf] returned normally\n");
    return 0;
}
