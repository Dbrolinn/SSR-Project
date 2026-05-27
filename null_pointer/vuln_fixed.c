// vuln.c — compile with: gcc -O2 -o vuln vuln.c
#include <stdio.h>
#include <string.h>

void process_request(char *user_input) {

    if (user_input == NULL) {
        fprintf(stderr, "Error: null input rejected\n");
        return;
    }

    char first = *user_input;    

    char buf[256];
    strncpy(buf, user_input, sizeof(buf) - 1);
    printf("Processing: %s\n", buf);
}

int main(void) {
    process_request("hello");   
    process_request(NULL);      
    return 0;
}
