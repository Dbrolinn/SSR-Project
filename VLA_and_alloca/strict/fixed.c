#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define MAX_LEN 64

/* FIXED: no type punning. We use memcpy to move bytes between the two
   views, so the compiler cannot assume non-aliasing — the result is
   always correct regardless of optimization level. */
int validate(int *as_int) {
    *as_int = 1000;
    short s = 64;
    memcpy(as_int, &s, sizeof(short));  /* defined: overwrite low half */
    
    if (*as_int > MAX_LEN)
        return 0;
    return 1;
}

int main(void) {
    int storage;
    int result = validate(&storage);
    printf("final stored value read via int = %d\n", storage);
    if (result) printf("changed to 64\n");
    else        printf("stayed 1000\n");
    return 0;
}
