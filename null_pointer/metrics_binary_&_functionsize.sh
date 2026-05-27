#!/bin/bash
#NULL POINTER CHECK REMOVAL: compile, run, assembly, statistics
#
#  Expects in this directory:
#    vuln.c        (vulnerable: dereference before null check)
#    vuln_fixed.c  (fixed: null check before dereference)

CC=${CC:-gcc}

pause() {
    echo ""
    read -r -p ">>> Press ENTER to continue (or Ctrl-C to abort)... " _
    echo ""
}

# check files exist
for f in vuln.c vuln_fixed.c; do
    if [ ! -f "$f" ]; then
        echo "ERROR: $f not found in this directory."
        exit 1
    fi
done

"$CC" --version | head -n1

# COMPILE
echo ""
echo " COMPILING ALL VERSIONS"
echo ""

"$CC" -O0 -o vuln_O0    vuln.c
echo "   vuln_O0    : gcc -O0 (unoptimized)"

"$CC" -O2 -o vuln_O2    vuln.c
echo "   vuln_O2    : gcc -O2 (optimized)"

"$CC" -O2 -fno-delete-null-pointer-checks -o vuln_flag vuln.c
echo "   vuln_flag  : gcc -O2 -fno-delete-null-pointer-checks (with special flag)"

"$CC" -O2 -o vuln_fixed vuln_fixed.c
echo "   vuln_fixed : gcc -O2 (fixed code)"

echo ""
echo "   Compilation complete."

# RUN
pause
echo " RUNNING ALL VERSIONS"
echo ""

echo " vuln_O0 (unoptimized)"
./vuln_O0
echo "[exit code: $?]"
echo ""

echo " vuln_O2 (optimized)"
./vuln_O2
echo "[exit code: $?]"
echo ""

echo " vuln_flag (flag fix)"
./vuln_flag
echo "[exit code: $?]"
echo ""

echo " vuln_fixed (code fix)"
./vuln_fixed
echo "[exit code: $?]"

# GENERATE ASSEMBLY
pause
echo " GENERATING ASSEMBLY FILES"
echo ""

"$CC" -O0 -S -o asm_O0.s    vuln.c
"$CC" -O2 -S -o asm_O2.s    vuln.c
"$CC" -O2 -fno-delete-null-pointer-checks -S -o asm_flag.s vuln.c
"$CC" -O2 -S -o asm_fixed.s vuln_fixed.c

echo "   Generated: asm_O0.s  asm_O2.s  asm_flag.s  asm_fixed.s"

# ASSEMBLY ANALYSIS (grep)
pause
echo " ASSEMBLY ANALYSIS"
echo ""
echo "The null check appears as 'test rdi, rdi' followed by a conditional jump."
echo "If it is present, the check survived. If absent, the compiler removed it."
echo ""

echo " vuln_O2 ( 0 = check REMOVED)"
count=$(objdump -d vuln_O2 | grep -c "test.*rdi")
echo "   test rdi found: $count times"
echo ""

echo " vuln_flag (>= 1 = check PRESENT)"
count=$(objdump -d vuln_flag | grep -c "test.*rdi")
echo "   test rdi found: $count times"
echo ""

echo " vuln_fixed (>= 1 = check PRESENT)"
count=$(objdump -d vuln_fixed | grep -c "test.*rdi")
echo "   test rdi found: $count times"
echo ""

echo "To compare assembly files run:"
echo "   diff asm_O0.s asm_O2.s | less"

# STATISTICS
pause
echo " BINARY SIZES"
echo ""
ls -la vuln_O0 vuln_O2 vuln_flag vuln_fixed
echo ""
size vuln_O0 vuln_O2 vuln_flag vuln_fixed
echo ""

echo " FUNCTION SIZE (process_request instruction count)"
echo ""
for b in vuln_O0 vuln_O2 vuln_flag vuln_fixed; do
    cnt=$(objdump -d "$b" | awk '/^.*<process_request>:$/,/^$/' | grep -v "^$\|process_request" | wc -l)
    printf "   %-14s %s instructions\n" "$b" "$cnt"
done
echo ""

echo " NULL CHECK PRESENCE SUMMARY (if output is: 0=removed, >=1=present)"
echo ""
for b in vuln_O0 vuln_O2 vuln_flag vuln_fixed; do
    cnt=$(objdump -d "$b" | grep -c "test.*rdi")
    printf "   %-14s %s\n" "$b" "$cnt"
done
echo ""
echo " ALL TESTS COMPLETE"