#define _DEFAULT_SOURCE // Required for explicit_bzero in glibc
#include <stdio.h>
#include <string.h>
#include <stdint.h>

// Macro to prevent the compiler from inlining functions into main
#define NOINLINE __attribute__((noinline))

/* classic memset
 * The compiler notes that 'secret' is local, its address never escapes
 * to the outside of the function, and it is destroyed on 'return'. 
 * Therefore, the final memset will be 100% DELETED in -O2 and -O3.
 */
NOINLINE uint32_t process_secret_insecure(const char* input) {
    char secret[64];
    strncpy(secret, input, sizeof(secret) - 1);
    
    // Simulation of local processing (generating a hash)
    uint32_t hash = 0;
    for (int i = 0; i < 64; i++) {
        hash += secret[i] * 31;
    }

    // the vulnerability is the compiler will delete this line
    memset(secret, 0, sizeof(secret)); 
    
    return hash;
}

/*
 * mitigation A: Cast to Volatile pointer
 * Forces the compiler to respect memory writes, 
 * bypassing the Dead Store analysis.
 */
NOINLINE uint32_t process_secret_volatile(const char* input) {
    char secret[64];
    strncpy(secret, input, sizeof(secret) - 1);
    
    uint32_t hash = 0;
    for (int i = 0; i < 64; i++) {
        hash += secret[i] * 31;
    }

    // the mitigation, forced write via volatile pointer
    volatile char* v_secret = (volatile char*)secret;
    for (size_t i = 0; i < sizeof(secret); i++) {
        v_secret[i] = 0;
    }
    
    return hash;
}

/*
 * Mitigation B: Compiler Memory Barrier (GCC/Clang specific)
 * Tells the compiler: "Assume memory might be read here, 
 * so do not delete anything written previously".
 */
NOINLINE uint32_t process_secret_barrier(const char* input) {
    char secret[64];
    strncpy(secret, input, sizeof(secret) - 1);
    
    uint32_t hash = 0;
    for (int i = 0; i < 64; i++) {
        hash += secret[i] * 31;
    }

    memset(secret, 0, sizeof(secret));
    
    // Inline assembly memory barrier, the mitigation
    __asm__ __volatile__("" : : "r"(secret) : "memory");
    
    return hash;
}

/*
 * Mitigation C: explicit_bzero (POSIX/Linux Standard)
 * Library function specifically designed to never be optimized away.
 */
NOINLINE uint32_t process_secret_explicit(const char* input) {
    char secret[64];
    strncpy(secret, input, sizeof(secret) - 1);
    
    uint32_t hash = 0;
    for (int i = 0; i < 64; i++) {
        hash += secret[i] * 31;
    }

    // secure OS API 
    explicit_bzero(secret, sizeof(secret));
    
    return hash;
}

int main() {
    const char* my_password = "SuperSecretPassword123!";
    
    printf("=== Starting Secret Processing ===\n");
    
    uint32_t h1 = process_secret_insecure(my_password);
    uint32_t h2 = process_secret_volatile(my_password);
    uint32_t h3 = process_secret_barrier(my_password);
    uint32_t h4 = process_secret_explicit(my_password);
    
    printf("Generated hashes: %u, %u, %u, %u\n", h1, h2, h3, h4);
    printf(" Processing Completed \n");
    printf("Inspect the generated Assembly to see what survived\n");
    
    return 0;
}

