#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <signal.h>
#include <setjmp.h>
#include <string.h>

#define NOINLINE __attribute__((noinline))
static sigjmp_buf env;

enum results{
        TEST_OK = 0,
        TEST_FAILED,
        TEST_SIGSEGV,
        TEST_UBSAN,
        TEST_ASAN
};
volatile enum results result = TEST_OK;

void 
__ubsan_on_report(void) {
        result = TEST_UBSAN;
}

void 
__asan_on_error(void) {
        result = TEST_ASAN;
}

void 
shandler(int snum) {
        (void)snum;
        result = TEST_SIGSEGV;
        siglongjmp(env, 1);
}

NOINLINE 
bool safe_precheck(int *p) {
        if (!p) 
                return false;
        *p = 10;
        return true;
}

NOINLINE 
bool deref_before_check(int *p) {
        int value = 0;
        value = *p;
        // ...
        if (!p)
                return false;

        *p = 10 + value;
        return true;
}

NOINLINE 
bool buffered_access(int *p, int b) {
        int tmp = *p;
        int a = 1;
        if (!p || a + b < 2)
                return false;

        tmp = 123;
        return tmp == 123;
}

NOINLINE 
bool explicit_null(void) {
        int *p = NULL;
        *p = 10;
        return true;
}

NOINLINE 
bool use_after_free(void) {
        int *p = malloc(sizeof(int));
        if (!p)
                return false;

        *p = 42;
        free(p);
        int value = *p;
        return value != 0;
}

NOINLINE 
bool null_after_free(void) {
        int *p = malloc(sizeof(int));
        if (!p)
                return false;

        *p = 99;
        free(p);
        p = NULL;
        int value = *p;
        return value != 0;
}

NOINLINE 
bool change_ptrs(void) {
        int *p = malloc(sizeof(int));
        if (!p)
                return false;

        int *a = p;
        free(a);
        a = NULL;
        int value = *p;
        return value != 0;
}

int 
run_test(int id) {
        result = TEST_OK;
        int x = 5;

        if (sigsetjmp(env, 1) == 0) {
                bool ret = false;
                switch (id) {
                case 0:  { ret = safe_precheck(&x);         break; }
                case 1:  { ret = safe_precheck(NULL);       break; }
                case 2:  { ret = deref_before_check(&x);    break; }
                case 3:  { ret = deref_before_check(NULL);  break; }
                case 4:  { ret = buffered_access(&x, 10);   break; }
                case 5:  { ret = buffered_access(NULL,  0); break; }
                case 6:  { ret = buffered_access(NULL, 10); break; }
                case 7:  { ret = explicit_null();           break; }
                case 8:  { ret = use_after_free();          break; }
                case 9:  { ret = null_after_free();         break; }
                case 10: { ret = change_ptrs();             break; }
                default: break;
                }

                if (!ret && result == TEST_OK) {
                        result = TEST_FAILED;
                }
        }
        return result;
}

int 
main(int argc, char *argv[]) {
        signal(SIGSEGV, shandler);
        if (argc != 2) {
                printf("./argv[0] <test_id>");
                return 1;
        }
        result = run_test(atoi(argv[1]));
        printf("%d\n", result);
        return 0;
}