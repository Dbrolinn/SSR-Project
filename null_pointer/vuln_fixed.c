// vuln.c — compile with: gcc -O2 -o vuln vuln.c
#include <stdio.h>
#include <string.h>

void process_request(char *user_input) {

    if (user_input == NULL) {
        fprintf(stderr, "Error: null input rejected\n");
        return;
    }

    /* DEREFERENCE HAPPENS FIRST — compiler now knows
       user_input cannot be NULL (or it's UB).       */
    char first = *user_input;     // ← triggers UB assumption

    /* This runs even when user_input IS null at -O2 */
    char buf[256];
    strncpy(buf, user_input, sizeof(buf) - 1);
    printf("Processing: %s\n", buf);
}

int main(void) {
    process_request("hello");   // fine
    process_request(NULL);      // crashes or corrupts memory
    return 0;
}
