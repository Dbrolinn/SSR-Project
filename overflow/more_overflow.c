#include <stdio.h>
#include <limits.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>
#include <stdint.h>
#include <math.h>

// Prevent the compiler from aggressively inlining functions into main.
// This mimics real-world scenarios where functions live in different files.
#define NOINLINE __attribute__((noinline))

NOINLINE bool 
overflow_int_nobuff(int32_t x, int32_t offset) {
    return (x + offset < x);
}

NOINLINE bool 
overflow_uint_nobuff(uint32_t x, uint32_t offset) {
    return (x + offset < x);
}

NOINLINE bool 
overflow_float_nobuff(float x, float offset) {
    return (x + offset < x);
}

NOINLINE bool 
overflow_double_nobuff(double x, double offset) {
    return (x + offset < x);
}


NOINLINE bool 
overflow_int_buff(int32_t x, int32_t offset) {
    int32_t b = x + offset;
    return (b < x);
}

NOINLINE bool 
overflow_uint_buff(uint32_t x, uint32_t offset) {
    uint32_t b = x + offset;
    return (b < x);
}

NOINLINE bool 
overflow_float_buff(float x, float offset) {
    float b = x + offset;
    return (b < x);
}

NOINLINE bool 
overflow_double_buff(double x, double offset) {
    double b = x + offset;
    return (b < x);
}


NOINLINE bool 
overflow_int_prec(int32_t x, int32_t offset) {
    top_bound = pow(2, sizeof(x)*8) / 2 - 1;
    bot_bound = -top_bound-1;
    if (offset > 0 && x > top_bound - offset) 
        return true;
    if (offset < 0 && x < bot_bound - offset) 
        return true;
    return false;
}



// compiler intrinsic
NOINLINE bool check_overflow_builtin(int x, int offset) {
    int result;
    return __builtin_add_overflow(x, offset, &result);
}

// pointer arithmetic (Pointer overflow is also UB)
NOINLINE bool check_pointer_overflow(char *base, int offset) {
    return (base + offset < base);
}

// Evaluation Engine

void evaluate(const char* name, bool check_result, bool actual_overflow) {
    printf("  %-38s \t", name);

    if (actual_overflow && !check_result) {
        // the math overflowed, but the check missed it
        printf("[CISB DETECTED] (Compiler eliminated check)\n");
    }
    else if (!actual_overflow && check_result) {
        // the math was fine, but the check triggered anyway
        printf("[LOGIC FLAW] (False Positive)\n");
    }
    else {
        // the check agreed with mathematical reality
        printf("[CORRECT]\n");
    }
}

int main() {
    srand(time(NULL));

    int x = INT_MAX;
    char *high_ptr = (char *)(uintptr_t) UINTPTR_MAX - 5;

    // analysis of the offset value initialization
    int lower_bound = -20;
    int upper_bound = 20;
    int offset = rand() % (upper_bound - lower_bound + 1) + lower_bound;
    // int offset = 16;

    int dummy_result;
    bool actual_overflow = __builtin_add_overflow(x, offset, &dummy_result);

    printf("======================================================================\n");
    printf(" Testing x = %d, offset = %d\n", x, offset);
    printf(" Ground Truth: Did it actually overflow? --> %s\n", actual_overflow ? "YES" : "NO");
    printf("----------------------------------------------------------------------\n");

    evaluate("[1] Naive (x + offset < x):", check_overflow_nobuff(x, offset), actual_overflow);
    evaluate("[2] Naive with buffer:", check_overflow_buff(x, offset), actual_overflow);
    evaluate("[3] Safe pre-condition:", check_overflow_precondition(x, offset), actual_overflow);
    evaluate("[4] Unsigned cast wrap:", check_overflow_unsigned(x, offset), actual_overflow);
    evaluate("[5] Compiler builtin:", check_overflow_builtin(x, offset), actual_overflow);
    evaluate("[6] Pointer math:", check_pointer_overflow(high_ptr, offset), actual_overflow);

    printf("======================================================================\n\n");

    return 0;
}
