#include <stdio.h>
#include <string.h>

/* Classic stack buffer overflow: copies an unbounded input into a
   fixed 16-byte buffer. With a stack canary, overwriting past the
   buffer corrupts the canary and triggers "stack smashing detected". */
void vulnerable(const char *input) {
    char buf[16];
    strcpy(buf, input);                /* overflow if strlen(input) >= 16 */
    printf("buf = %s\n", buf);
}

int main(int argc, char **argv) {
    const char *in = (argc > 1) ? argv[1] : "short";
    printf("=== Stack canary demo ===\n");
    vulnerable(in);
    printf("returned normally\n");
    return 0;
}
