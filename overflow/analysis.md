# Bounds Check Elimination and Logic Flaws in Overflow Detection

*A Case Study on Compiler-Introduced Security Bugs (CISBs)*

---

# Table of Contents

1. [Introduction](#1-introduction)
2. [Methodology & Detection Strategies](#2-methodology--detection-strategies)
3. [Results Analysis — Positive Offset Scenario](#3-results-analysis--positive-offset-scenario-cisb)

   * [3.1 Aggressive Elimination at `-O3`](#31-aggressive-elimination-at--o3)
   * [3.2 Mitigation via Compiler Flags](#32-mitigation-via-compiler-flags-category-a)
4. [Results Analysis — Negative Offset Scenario](#4-results-analysis--negative-offset-scenario-logic-flaws)

   * [4.1 False Positive Illusion](#41-the-false-positive-illusion)
   * [4.2 Failure of the Unsigned Cast](#42-the-failure-of-the-unsigned-cast)
5. [Bulletproof Mitigations](#5-bulletproof-mitigations-category-b)

   * [5.1 Safe Pre-Condition Checking](#51-safe-pre-condition-checking)
   * [5.2 Compiler Builtin Intrinsics](#52-compiler-builtin-intrinsics)
6. [Key Findings](#6-key-findings)
7. [Conclusion](#7-conclusion)

---

# 1. Introduction

In C and C++, signed integer overflow and pointer overflow are classified as **Undefined Behavior (UB)**.

Modern compilers operate under the **No-UB assumption**, meaning they optimize programs under the assumption that undefined behavior never occurs during execution.

As a consequence, naive overflow checks that rely on overflow behavior may be mathematically optimized away.

For example:

```c id="95k5f1"
if (x + offset < x)
```

A compiler may conclude:

* Overflow is undefined
* Therefore `x + offset` can never wrap around
* Therefore the condition is impossible

The optimizer then removes the security check entirely.

This creates a severe **Compiler-Introduced Security Bug (CISB)** where protections against:

* Buffer overflows
* Integer wrapping
* Memory corruption

are silently stripped from the final binary.

---

# 2. Methodology & Detection Strategies

To evaluate compiler behavior, six overflow detection strategies were implemented.

## Tested Detection Methods

| Strategy           | Description                                         |
| ------------------ | --------------------------------------------------- |
| Naive Check        | `if (x + offset < x)`                               |
| Naive with Buffer  | `int buff = x + offset; if (buff < x)`              |
| Safe Pre-Condition | `if (x > INT_MAX - offset)`                         |
| Unsigned Cast      | `if ((unsigned)x + (unsigned)offset < (unsigned)x)` |
| Compiler Builtin   | `__builtin_add_overflow(x, offset, &res)`           |
| Pointer Math       | `if (ptr + offset < ptr)`                           |

---

## Experimental Update

Previous experiments used a fixed positive offset.

The updated methodology introduced randomized offsets in a range such as:

```text id="3jsg31"
[-20, 20]
```

This enabled evaluation of:

1. Compiler optimization aggressiveness
2. Mathematical correctness under dynamic input conditions

---

# 3. Results Analysis — Positive Offset Scenario (CISB)

## Test Case

```text id="vs0f4v"
x = INT_MAX
offset = 3
```

This operation produces a signed integer overflow.

Ground truth:

```text id="9w2ksg"
OVERFLOW OCCURS
```

---

## 3.1 Aggressive Elimination at `-O3`

Under high optimization (`-O3`), both GCC 16 and Clang 22 aggressively removed overflow checks.

### Naive Check

```c id="2u0g6m"
if (x + offset < x)
```

The compiler assumes the expression is algebraically impossible and removes the branch entirely.

---

### Pointer Arithmetic Check

```c id="0vj9c4"
if (ptr + offset < ptr)
```

This was also eliminated due to undefined behavior assumptions regarding pointer overflow.

---

### Naive with Buffer

```c id="c7rlz0"
int buff = x + offset;

if (buff < x)
```

Even with a temporary variable, modern optimizers perform:

* Value propagation
* Constant reasoning
* Dead branch elimination

The security check was still removed.

---

## 3.2 Mitigation via Compiler Flags (Category A)

Compiler escape-hatch flags were tested.

### Example

```bash id="vud7gj"
gcc -O2 -fwrapv
```

The `-fwrapv` flag forces signed integer arithmetic to wrap predictably.

### Observed Behavior

| Check Type         | Result               |
| ------------------ | -------------------- |
| Naive with Buffer  | Survived             |
| Direct Naive Check | Sometimes eliminated |

### Key Observation

Compiler flags are fragile because behavior depends heavily on:

* AST structure
* Optimization pass order
* Compiler version
* Internal value propagation rules

Flags alone cannot be considered reliable security guarantees.

---

# 4. Results Analysis — Negative Offset Scenario (Logic Flaws)

## Test Case

```text id="kef80i"
x = INT_MAX
offset = -5
```

This operation does **not** overflow.

Ground truth:

```text id="9q5dd0"
NO OVERFLOW
```

However, naive overflow checks failed catastrophically.

---

## 4.1 The False Positive Illusion

### Example

```c id="wz76d8"
if (x + offset < x)
```

Substituting values:

```c id="h6x0bg"
if (INT_MAX - 5 < INT_MAX)
```

This evaluates to:

```text id="d9bghm"
TRUE
```

The code incorrectly signals an overflow.

---

## Security Impact

This flaw creates severe logic vulnerabilities:

* False alarms
* Application instability
* Incorrect security enforcement
* Potential Denial of Service (DoS)

The check is fundamentally invalid for dynamic or attacker-controlled input.

---

## 4.2 The Failure of the Unsigned Cast

Developers often attempt to avoid signed UB by casting to unsigned integers.

### Example

```c id="q3v3x7"
if ((unsigned)x + (unsigned)offset < (unsigned)x)
```

---

## Observed Failures

| Scenario      | Result          |
| ------------- | --------------- |
| `offset = 3`  | Missed overflow |
| `offset = -5` | False positive  |

---

## Mathematical Explanation

### Values

```text id="ggf0pn"
INT_MAX = 0x7FFFFFFF
```

Adding `3`:

```text id="3h0w3j"
0x7FFFFFFF + 3 = 0x80000002
```

This exceeds the signed integer boundary, but:

* It does **not** overflow the unsigned boundary
* `0x80000002` is still less than `0xFFFFFFFF`

Therefore:

```c id="8gf1d4"
(unsigned)x + (unsigned)offset < (unsigned)x
```

evaluates to:

```text id="xih1hh"
FALSE
```

The overflow is completely missed.

---

# 5. Bulletproof Mitigations (Category B)

The experiments prove that naive overflow checks are vulnerable to:

1. Compiler optimization removal
2. Fundamental mathematical flaws

Secure software must instead rely on robust mitigation strategies.

---

## 5.1 Safe Pre-Condition Checking

The safest approach is validating boundaries *before* performing arithmetic.

### Implementation

```c id="s33yl0"
NOINLINE bool check_overflow_precondition(int x, int offset) {

    if (offset > 0 && x > INT_MAX - offset)
        return true;

    if (offset < 0 && x < INT_MIN - offset)
        return true;

    return false;
}
```

---

## Why It Works

This method:

* Avoids Undefined Behavior entirely
* Handles positive and negative offsets safely
* Remains optimizer-safe

### Result

✅ Correct across all compilers
✅ Correct across all optimization levels
✅ Correct for all tested offset signs

---

## 5.2 Compiler Builtin Intrinsics

Modern compilers provide hardware-aware overflow intrinsics.

### Example

```c id="6pmq1j"
int dummy;

return __builtin_add_overflow(x, offset, &dummy);
```

---

## Why It Works

Compiler intrinsics:

* Use hardware overflow flags directly
* Avoid UB assumptions
* Prevent optimization-based removal

### Result

✅ Universally correct
✅ Industry-recommended solution

---

# 6. Key Findings

| Finding                                   | Impact                              |
| ----------------------------------------- | ----------------------------------- |
| Naive overflow checks are unsafe          | Compiler may remove them            |
| Signed UB enables dangerous optimizations | Security logic disappears silently  |
| Negative offsets break naive logic        | Causes false positives              |
| Unsigned casts are unreliable             | Misses signed overflow conditions   |
| Compiler flags are fragile                | Behavior varies by compiler/version |
| Pre-condition validation is reliable      | UB-free and optimizer-safe          |
| Builtin intrinsics are best practice      | Hardware-backed overflow detection  |

---

# 7. Conclusion

Attempting to detect overflow by triggering overflow itself is fundamentally flawed.

The experiments demonstrated two major problems:

1. **Compiler-Introduced Security Bugs (CISBs)**
   Optimizers remove checks under the No-UB assumption.

2. **Mathematical Logic Failures**
   Naive checks produce false positives and false negatives under real-world runtime conditions.

Modern secure software must avoid naive overflow validation entirely.

Recommended approaches are:

1. Pre-computation boundary validation
2. Compiler overflow intrinsics such as:

   * `__builtin_add_overflow`
   * `std::overflow_error`-aware mechanisms
   * Hardware-assisted arithmetic checks

Security-critical arithmetic must be designed around **well-defined behavior**, not assumptions about compiler behavior or integer wrapping semantics.
