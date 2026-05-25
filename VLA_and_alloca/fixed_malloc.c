#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void process(unsigned long n) {
    char *buffer = (char *) malloc(n); /* heap: returns NULL on failure */
    if (buffer == NULL) {
        fprintf(stderr, "[malloc] allocation of %lu bytes failed - rejected\n", n);
        return;
    }
    memset(buffer, 'A', n);
    buffer[0] = 'X';
    printf("[malloc] handled %lu bytes safely, buffer[0]=%c\n", n, buffer[0]);
    free(buffer);
}

int main(int argc, char **argv) {
    unsigned long n = (argc > 1) ? strtoul(argv[1], NULL, 10) : 64;
    printf(" malloc (safe)\n");
    printf("Requested allocation: %lu bytes\n", n);
    process(n);
    printf("[malloc] returned normally\n");
    return 0;
}
