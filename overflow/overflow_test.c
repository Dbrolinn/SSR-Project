#include <stdio.h>
#include <limits.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

// Prevent the compiler from aggressively inlining functions into main.
// This mimics real-world scenarios where functions live in different files.
#define NOINLINE __attribute__((noinline))

// 1. Original naive check without buffer
NOINLINE bool check_overflow_nobuff(int x, int offset) {
    return (x + offset < x);
}

// 2. Original naive check with buffer
NOINLINE bool check_overflow_buff(int x, int offset) {
    int buff = x + offset;
    return (buff < x);
}

// 3. The Pre-condition Check
NOINLINE bool check_overflow_precondition(int x, int offset) {
    if (offset > 0 && x > INT_MAX - offset) return true;
    if (offset < 0 && x < INT_MIN - offset) return true;
    return false;
}

// 4. The Unsigned Cast Check
NOINLINE bool check_overflow_unsigned(int x, int offset) {
    return ((unsigned int)x + (unsigned int)offset < (unsigned int)x);
}

// 5. Compiler Intrinsic
NOINLINE bool check_overflow_builtin(int x, int offset) {
    int result;
    return __builtin_add_overflow(x, offset, &result);
}

// 6. Pointer Arithmetic (Pointer overflow is also UB)
NOINLINE bool check_pointer_overflow(char *base, int offset) {
    return (base + offset < base);
}

// =====================================================================
// Evaluation Engine
// =====================================================================
void evaluate(const char* name, bool check_result, bool actual_overflow) {
    printf("  %-38s \t", name);

    if (actual_overflow && !check_result) {
        // The math overflowed, but the check missed it!
        printf("[CISB DETECTED] (Compiler eliminated check)\n");
    }
    else if (!actual_overflow && check_result) {
        // The math was fine, but the check triggered anyway!
        printf("[LOGIC FLAW] (False Positive)\n");
    }
    else {
        // The check agreed with mathematical reality
        printf("[CORRECT]\n");
    }
}

int main() {
    srand(time(NULL));

    int x = INT_MAX;
    char *high_ptr = (char *)(uintptr_t) UINTPTR_MAX - 5;

    int lower_bound = -20;
    int upper_bound = 20;
    int offset = rand() % (upper_bound - lower_bound + 1) + lower_bound;


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
