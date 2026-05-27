#include <stdio.h>
#include <limits.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>
#include <float.h>

#define NOINLINE __attribute__((noinline))

// Data Structures

#if defined(TYPE_INT16)
    typedef int16_t test_type;
    typedef int16_t offset_type;
    #define TYPE_MAX SHRT_MAX
#elif defined(TYPE_UINT)
    typedef unsigned int test_type;
    typedef unsigned int offset_type;
    #define TYPE_MAX UINT_MAX
#elif defined(TYPE_DOUBLE)
    typedef double test_type;
    typedef double offset_type;
    #define TYPE_MAX DBL_MAX
#elif defined(TYPE_POINTER)
    typedef char* test_type;
    typedef int offset_type;
    #define TYPE_MAX ((char *)(uintptr_t) UINTPTR_MAX - 5)
#else
    typedef int test_type;
    typedef int offset_type;
    #define TYPE_MAX INT_MAX
#endif

// Test Functions

#if defined(MODEL_NAIVE)
NOINLINE bool check(test_type x, offset_type offset) {
    return (x + offset < x);
}

#elif defined(MODEL_BUFFER)
NOINLINE bool check(test_type x, offset_type offset) {
    test_type buff = x + offset;
    return (buff < x);
}

#elif defined(MODEL_SAFE)
NOINLINE bool check(test_type x, offset_type offset) {
#if defined(TYPE_POINTER) || defined(TYPE_DOUBLE)
    return false;
#else
    if (offset > 0 && x > TYPE_MAX - offset) return true;
    return false;
#endif
}

#elif defined(MODEL_BUILTIN)
NOINLINE bool check(test_type x, offset_type offset) {
#if defined(TYPE_POINTER) || defined(TYPE_DOUBLE)
    return false;
#else
    test_type result;
    return __builtin_add_overflow(x, offset, &result);
#endif
}

#elif defined(MODEL_SHIFT_UB)
NOINLINE bool check(test_type x, offset_type offset) {
#if defined(TYPE_POINTER) || defined(TYPE_DOUBLE)
    return false;
#else
    return ((1 << offset) == 0);
#endif
}
#endif

// Evaluation Functions

void evaluate(bool check_result, bool actual_overflow) {
    if (actual_overflow && !check_result) {
        printf("CISB_DETECTED\n");
    }
    else if (!actual_overflow && check_result) {
        printf("LOGIC_FLAW\n");
    }
    else {
        printf("CORRECT\n");
    }
}

int main(int argc, char *argv[]) {
    if (argc < 2) return 1;
    int raw_offset = atoi(argv[1]);

    bool actual_overflow = false;
    test_type x;
    offset_type offset;

#if defined(TYPE_INT16)
    x = SHRT_MAX;
    offset = (int16_t)raw_offset;
    actual_overflow = false;
#elif defined(TYPE_UINT)
    x = UINT_MAX;
    offset = (unsigned int)raw_offset;
    actual_overflow = true;
#elif defined(TYPE_DOUBLE)
    x = DBL_MAX;
    offset = (raw_offset > 0) ? DBL_MAX : 0.0;
    actual_overflow = false;
#elif defined(TYPE_POINTER)
    x = TYPE_MAX;
    offset = raw_offset * 10;
    actual_overflow = true;
#elif defined(MODEL_SHIFT_UB)
    x = 1;
    offset = (raw_offset > 0) ? 32 : 15;
    actual_overflow = (offset >= 32); 
#else
    x = INT_MAX;
    offset = raw_offset;
    int dummy;
    actual_overflow = __builtin_add_overflow(x, offset, &dummy);
#endif
    evaluate(check(x, offset), actual_overflow);

    return 0;
}