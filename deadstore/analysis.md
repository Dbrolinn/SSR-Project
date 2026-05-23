# Dead Store Elimination (DSE) and Password Wiping

*A Case Study on Compiler-Introduced Security Bugs (CISBs)*

---

# Table of Contents

1. [Introduction](#1-introduction)
2. [Vulnerability Analysis](#2-vulnerability-analysis)

   * [2.1 Insecure Implementation](#21-insecure-implementation)
   * [2.2 Compilation Results](#22-compilation-results)
   * [2.3 Assembly Evidence](#23-assembly-evidence)
3. [Mitigation Strategies](#3-mitigation-strategies)

   * [Mitigation A — Volatile Pointer Cast](#mitigation-a--volatile-pointer-cast)
   * [Mitigation B — Compiler Memory Barrier](#mitigation-b--compiler-memory-barrier)
   * [Mitigation C — Secure OS-Level APIs](#mitigation-c--secure-os-level-apis)
4. [Key Findings](#4-key-findings)
5. [Conclusion](#5-conclusion)

---

# 1. Introduction

Dead Store Elimination (DSE) is a compiler optimization technique that removes memory writes that are never read before the associated variable goes out of scope.

While this optimization improves performance, it introduces serious security risks when developers attempt to erase sensitive information such as:

* Passwords
* Cryptographic keys
* Authentication tokens
* Session secrets

In many cases, developers rely on functions like `memset()` to clear sensitive buffers before returning from a function. However, modern compilers may recognize these writes as unnecessary and silently remove them during optimization.

This creates a **Compiler-Introduced Security Bug (CISB)** where sensitive plaintext data remains in memory and becomes vulnerable to:

* Memory disclosure attacks
* Crash dump analysis
* Cold boot attacks
* Information leakage vulnerabilities

---

# 2. Vulnerability Analysis

## 2.1 Insecure Implementation

The following implementation uses the standard C library function `memset()` to scrub a secret buffer:

```c
uint32_t process_secret_insecure(const char* input) {
    char secret[64];

    strncpy(secret, input, sizeof(secret) - 1);

    // ... Processing secret to generate a hash ...

    // [VULNERABILITY] Standard memory scrub
    memset(secret, 0, sizeof(secret));

    return hash;
}
```

### Security Issue

Although the wipe appears correct at the source-code level, the compiler may remove it entirely because:

* `secret` is never read after the `memset()`
* The write has no observable program effect
* The operation is classified as a *dead store*

As a result, the memory wipe may never execute.

---

## 2.2 Compilation Results

The implementation was tested using:

* **GCC 16.1**
* **Clang 22.1.0**

The results demonstrate the gap between **program correctness** and **security guarantees**.

| Compiler         | `-O0`  | `-O2`         | `-O3`         | `-O3` + Mitigation             |
| ---------------- | ------ | ------------- | ------------- | ------------------------------ |
| **GCC 16.1**     | Secure | CISB Detected | CISB Detected | `-fno-builtin-memset` → Secure |
| **Clang 22.1.0** | Secure | CISB Detected | CISB Detected | `-fno-builtin` → Secure        |

> **Important Observation:**
> Traditional mitigation flags such as `-fno-tree-dse` were insufficient in GCC 16.
> The compiler still removed the memory wipe due to aggressive Dead Code Elimination (DCE) and built-in function analysis.

---

## 2.3 Assembly Evidence

### Baseline Build (`-O0`)

The memory wipe is preserved:

```asm
lea     rax, [rbp-80]
mov     edx, 64
mov     esi, 0
mov     rdi, rax
call    memset        ; Memory is safely scrubbed
mov     eax, DWORD PTR [rbp-4]
leave
ret
```

---

### Optimized Build (`-O3` + `-fno-builtin-memset`)

The wipe survives optimization:

```asm
; ... SIMD vectorized operations ...

mov     edx, 64
call    memset        ; Preserved because builtin analysis is disabled
```

---

### Pure Optimized Build (`-O3`)

The `memset()` call is completely removed.

The compiler:

1. Computes the hash
2. Returns immediately
3. Leaves the plaintext secret in stack memory

This demonstrates a real-world compiler-induced security vulnerability.

---

# 3. Mitigation Strategies

Global compiler flags are fragile and compiler-version dependent.

Robust mitigation requires **code-level protections** designed specifically to prevent optimization removal.

---

## Mitigation A — Volatile Pointer Cast

The `volatile` keyword forces the compiler to preserve memory writes.

### Implementation

```c
volatile char* v_secret = (volatile char*)secret;

for (size_t i = 0; i < sizeof(secret); i++) {
    v_secret[i] = 0;
}
```

### Assembly Evidence (`-O3`)

```asm
.L2:
    mov     BYTE PTR [rax], 0
    lea     rcx, [rsp+64]
    add     rax, 2
    mov     BYTE PTR [rax-1], 0
    cmp     rax, rcx
    jne     .L2
```

### Analysis

✅ Prevents optimization removal
✅ Effective on GCC and Clang
❌ Performance overhead due to byte-wise writes

---

## Mitigation B — Compiler Memory Barrier

A memory barrier prevents the compiler from eliminating or reordering memory operations.

### Implementation

```c
memset(secret, 0, sizeof(secret));

__asm__ __volatile__(
    ""
    :
    : "r"(secret)
    : "memory"
);
```

### Analysis

The compiler must assume the inline assembly may access the memory region.

As a result:

* `memset()` becomes a *live store*
* Dead Store Elimination cannot remove it

### Result

✅ Secure on GCC 16 and Clang 22
✅ Works under `-O3` optimization

---

## Mitigation C — Secure OS-Level APIs

Modern operating systems provide secure memory wiping functions specifically designed to resist optimization.

### Example

```c
explicit_bzero(secret, sizeof(secret));
```

### Equivalent APIs

| Platform    | Secure API           |
| ----------- | -------------------- |
| Linux / BSD | `explicit_bzero()`   |
| Windows     | `SecureZeroMemory()` |
| C11 Annex K | `memset_s()`         |

### Analysis

These APIs are:

* Semantically correct
* Compiler-aware
* Designed for secure erasure

### Result

✅ Secure across all tested compilers
✅ Recommended production solution

---

# 4. Key Findings

| Finding                                  | Impact                                 |
| ---------------------------------------- | -------------------------------------- |
| `memset()` alone is unreliable           | Sensitive data may remain in memory    |
| Modern compilers optimize aggressively   | Security assumptions can fail silently |
| Compiler flags are not portable          | Behavior changes across versions       |
| `volatile` works but impacts performance | Byte-wise clearing is expensive        |
| Memory barriers are effective            | Prevents DSE removal                   |
| Secure APIs are best practice            | Most reliable long-term solution       |

---

# 5. Conclusion

This case study highlights a critical reality of modern systems programming:

> Compilers optimize for correctness and performance — not confidentiality.

Although `memset()` appears secure at the source-code level, aggressive compiler optimizations such as Dead Store Elimination can silently remove memory wipes entirely.

As demonstrated with GCC 16.1 and Clang 22.1.0:

* Standard memory scrubbing is unsafe under optimization
* Traditional compiler flags are insufficient
* Security requires explicit mitigation mechanisms

To safely erase sensitive data, developers should prefer:

1. Secure APIs such as `explicit_bzero()`
2. Compiler memory barriers
3. Carefully implemented `volatile` techniques

Bridging the **Correctness–Security Gap** requires treating compiler behavior as part of the attack surface itself.
