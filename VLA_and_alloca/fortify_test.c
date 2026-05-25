#include <stdio.h>
#include <string.h>

/* With -D_FORTIFY_SOURCE the compiler knows buf is 16 bytes and replaces
   strcpy with strcpy_chk, which aborts at runtime if the copy overflows. */
int main(int argc, char **argv) {
    char buf[16];
    const char *in = (argc > 1) ? argv[1] : "short";
    printf(" FORTIFY_SOURCE\n");
    strcpy(buf, in);                   /* overflow if strlen(in) >= 16 */
    printf("buf = %s\n", buf);
    return 0;
}
