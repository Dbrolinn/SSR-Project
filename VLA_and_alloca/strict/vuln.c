#include <stdio.h>
#include <stdint.h>
#include <string.h>

#define MAX_LEN 65

/* Classic strict-aliasing trigger: write through a short*, read through
   an int*. The compiler assumes short* and int* never alias, so it may
   reorder/cache the int read across the short write. */
int validate(int *as_int, short *as_short) {
    *as_int = 1000;          /* large value (1000 > MAX_LEN) via int*  */
    *as_short = 64;          /* shrink low half via short* (aliases!)  */
    
    if (*as_int > MAX_LEN)   /* may use cached 1000, OR see new value  */
        return 0;            /* drop */
    return 1;                /* process */
}

int main(void) {
    int storage;
    /* both pointers refer to the SAME memory */
    int result = validate(&storage, (short *)&storage);
    printf("final stored value reading as the int pointer = %d\n", storage);
    if (result) printf("changed to 64\n");
    else        printf("stayed 1000\n");
    return 0;
}
