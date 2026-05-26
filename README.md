# SSR-Project: Trusting the Compiler (CISB Analysis)

## Overview
This repository is dedicated to the analysis and demonstration of **Compiler-Introduced Security Bugs (CISBs)**. CISBs occur when modern compilers (like GCC or Clang) aggressively optimize code based on Undefined Behavior (UB) rules, inadvertently removing security-critical code. 

The project contains various Proofs of Concept  and test suites evaluating how different compilers and optimization levels (for example, `-O0`, `-O2`, `-O3`) impact the security of C applications.

## Recommended Environment
To ensure accurate reproduction of compiler behaviors and seamless execution of the bash scripts, we highly recommend running these tests in a **Linux environment**. 

**Ideal Setup:**
* **OS:** Ubuntu 22.04 LTS / 20.04 LTS (since this was the version of the virtual machine used)

*Note: Running these tests on macOS or Windows natively may yield different results due to differences in standard libraries and default compiler architectures.*

## Dependencies & Installation
Before running the tests, you need to install the essential compilers (`gcc` and `clang`) and build utilities. 

Run the following commands on your terminal to install everything required:

```bash
sudo apt update
sudo apt install -y build-essential gcc clang make bash coreutils
