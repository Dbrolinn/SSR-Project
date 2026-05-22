// vuln.c — compile with: gcc -O2 -o vuln vuln.c
#include <stdio.h>
#include <string.h>

void process_request(char *user_input) {

    /* DEREFERENCE HAPPENS FIRST — compiler now knows
       user_input cannot be NULL (or it's UB).       */
    //if (user_input == NULL) {
    //    fprintf(stderr, "Error: null input rejected\n");
    //    return;
    //}
    char first = *user_input;     // ← triggers UB assumption

    /* Programmer's security check — silently REMOVED   */
    /* by the compiler at -O2. Dead code by UB logic.   */
    /* change this if to before the char definition to be safe*/
    if (user_input == NULL) {
        fprintf(stderr, "Error: null input rejected\n");
        return;
    }
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
