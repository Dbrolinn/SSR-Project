#!/usr/bin/env bash
#
#  To run do:   chmod +x cisb_stack_tests.sh && bash cisb_stack_tests.sh
#
#  Demonstrates:
#    1. VLA & alloca stack exhaustion (vulnerable vs fixed)
#    2. -Wvla detection (warning only; binary still vulnerable)
#    3. Assembly differences (variable vs probed vs constant stack growth)
#    4. Statistics + stack canary + FORTIFY_SOURCE
#
###############################################################################

CC=${CC:-gcc}
SMALL=64
BIG=8000000000000000        # 8e15 bytes: crashes the stack and fails malloc

pause() {
    echo
    read -r -p ">>> Press ENTER to continue (or Ctrl-C to abort)... " _
    echo
}

run() {
    # run "description" command args...
    local desc="$1"; shift
    echo "----------------------------------------------------------------"
    echo "  $desc"
    echo "\$ $*"
    "$@"
    local rc=$?
    echo "[exit code: $rc]   (139 = SIGSEGV, 134 = SIGABRT, 0 = clean)"
    return 0
}


# check if gcc is installed

if ! command -v "$CC" >/dev/null 2>&1; then
    echo "ERROR: compiler '$CC' not found. Install gcc:  sudo apt install gcc"
    exit 1
fi
# files needed
REQUIRED="vuln_vla.c vuln_alloca.c fixed_buffer.c fixed_malloc.c canary_test.c fortify_test.c"
missing=0
for f in $REQUIRED; do
    if [ ! -f "$f" ]; then
        echo "ERROR: required source file not found: $f"
        missing=1
    fi
done
if [ "$missing" -ne 0 ]; then
    echo "Place all .c files in this directory and re-run."
    exit 1
fi

echo ""
echo "  CISB STACK-ALLOCATION TEST HARNESS"
echo ""
"$CC" --version | head -n1
echo "SMALL allocation = $SMALL bytes"
echo "BIG   allocation = $BIG bytes"
echo "Source files found: OK"

# COMPILE EVERYTHING
echo
echo ">> Compiling all versions..."

# vulnerable VLA / alloca at -O2 
"$CC" -O2 -o vla_vuln               vuln_vla.c
"$CC" -O2 -o alloca_vuln            vuln_alloca.c

# VLA with -Wvla (DETECTION only, so warning printed, binary still vulnerable)
echo " -Wvla warning output:"
"$CC" -O2 -Wvla -o vla_warned       vuln_vla.c

# VLA / alloca with stack-clash protection (MITIGATION)
"$CC" -O2 -fstack-clash-protection -o vla_clash    vuln_vla.c
"$CC" -O2 -fstack-clash-protection -o alloca_clash vuln_alloca.c

# safe code fixes (no extra flags)
"$CC" -O2 -o fixed_buf              fixed_buffer.c
"$CC" -O2 -o fixed_malloc           fixed_malloc.c

# also build an -O0 VLA
"$CC" -O0 -o vla_vuln_O0            vuln_vla.c

echo "   Compilation complete."

# RUN ALL VERSIONS with the small value, and then with the big value
pause
echo ""
echo " RUNNING ALL VERSIONS (small=$SMALL, big=$BIG)"
echo ""

echo; echo " VLA (vulnerable, -O2) "
run "VLA small"  ./vla_vuln    "$SMALL"
run "VLA big"    ./vla_vuln    "$BIG"

echo; 

echo; echo " alloca (vulnerable, -O2)"
run "alloca small" ./alloca_vuln "$SMALL"
run "alloca big"   ./alloca_vuln "$BIG"

echo; echo " VLA + stack-clash-protection (mitigation)"
run "vla_clash small" ./vla_clash "$SMALL"
run "vla_clash big"   ./vla_clash "$BIG"

echo; echo " fixed buffer (safe code)"
run "fixed_buf small" ./fixed_buf "$SMALL"
run "fixed_buf big"   ./fixed_buf "$BIG"

echo; echo " malloc (safe code)"
run "fixed_malloc small" ./fixed_malloc "$SMALL"
run "fixed_malloc big"   ./fixed_malloc "$BIG"

# tHE -Wvla detection
pause
echo ""
echo " -Wvla DETECTION (warning only; binary still vulnerable)"
echo ""
echo " -Wvla flag warns at COMPILE time but does NOT change the binary."
echo " vla_warned behaves identically to vla_vuln."
echo
run "vla_warned small" ./vla_warned "$SMALL"
run "vla_warned big"   ./vla_warned "$BIG"
echo
echo "Are the two binaries identical?"
if cmp -s vla_vuln vla_warned; then
    echo "   YES, vla_vuln and vla_warned are byte-identical."
fi

# ASSEMBLY code generation and grep used to prove and capture the lines
pause
echo ""
echo " ASSEMBLY ANALYSIS"
echo ""
"$CC" -O2 -S -o asm_vla.s                          vuln_vla.c
"$CC" -O2 -fstack-clash-protection -S -o asm_vla_clash.s vuln_vla.c
"$CC" -O2 -S -o asm_fixed_buf.s                    fixed_buffer.c
echo "Generated: asm_vla.s  asm_vla_clash.s  asm_fixed_buf.s"
echo

echo " VARIABLE (register) stack growth in the VLA version (asm_vla.s):"
echo "   A 'sub' of %rsp by a REGISTER = runtime-sized growth, no probing."
grep -nE 'sub[lq]?[[:space:]]+%r[a-z0-9]+,[[:space:]]*%rsp' asm_vla.s \
    || echo "   (pattern not found by grep -- open asm_vla.s and look for sub ...,%rsp)"
echo

echo " PAGE-PROBING introduced by -fstack-clash-protection (asm_vla_clash.s):"
echo "   Look for a per-page subtract and a probe write into (%rsp)."
grep -nE '\$4096|0x1000' asm_vla_clash.s \
    || echo "   (no 4096 constant found -- open the file and look for the probe loop)"
grep -nE 'or[lq]?[[:space:]]+\$0,[[:space:]]*\(%rsp\)' asm_vla_clash.s \
    || echo "   (no 'or \$0,(%rsp)' probe found, gcc version may emit a different probe)"
echo

echo " CONSTANT stack growth in the fixed-buffer version (asm_fixed_buf.s):"
echo "   A 'sub' of %rsp by a CONSTANT = bounded, compile-time-known growth."
grep -nE 'sub[lq]?[[:space:]]+\$[0-9]+,[[:space:]]*%rsp' asm_fixed_buf.s \
    || echo "   (pattern not found -- open asm_fixed_buf.s and look for sub \$N,%rsp)"

# STATISTICS + the two extra tests (canary, fortify)
pause
echo ""
echo " STATISTICS"
echo ""

echo " Binary sizes (ELF section sizes):"
size vla_vuln vla_clash alloca_vuln fixed_buf fixed_malloc 2>/dev/null

echo
echo " Instruction count of process() in each binary:"
for b in vla_vuln vla_clash alloca_vuln fixed_buf fixed_malloc; do
    cnt=$(objdump -d "$b" 2>/dev/null \
          | awk '/<process>:/,/^$/' \
          | grep -cE '^[[:space:]]*[0-9a-f]+:')
    printf "   %-14s %s instructions\n" "$b" "$cnt"
done

echo
echo " Exit codes on BIG input ($BIG bytes):"
for b in vla_vuln vla_clash fixed_buf fixed_malloc; do
    ./"$b" "$BIG" >/dev/null 2>&1
    printf "   %-14s exit code %s\n" "$b" "$?"
done
echo "   (139 = SIGSEGV/crash, 0 = clean rejection)"

# STACK CANARY

echo
echo ""
echo " STACK CANARY (-fstack-protector-all)"
echo ""
# Isolate the canary effect: disable fortify in BOTH builds.
"$CC" -O2 -D_FORTIFY_SOURCE=0 -fno-stack-protector  -o canary_off canary_test.c
"$CC" -O2 -D_FORTIFY_SOURCE=0 -fstack-protector-all -o canary_on  canary_test.c
LONG=$(printf 'A%.0s' {1..64})        # 64-char string overflows buf[16]

echo "Overflowing a 16-byte buffer with a 64-char string:"
echo
echo " WITHOUT canary, silent corruption or raw segfault:"
run "canary OFF" ./canary_off "$LONG"
echo " WITH canary, detected and aborted cleanly:"
run "canary ON"  ./canary_on  "$LONG"
echo " With the canary, look for: stack smashing detected (exit 134)"

# _FORTIFY_SOURCE
echo
echo ""
echo " _FORTIFY_SOURCE (compiler-added bounds checks)"
echo ""
# Isolate the fortify effect: disable canary in BOTH builds.
"$CC" -O2 -fno-stack-protector -D_FORTIFY_SOURCE=0 -o fortify_off fortify_test.c
"$CC" -O2 -fno-stack-protector -D_FORTIFY_SOURCE=2 -o fortify_on  fortify_test.c

echo "Same overflow, but isolating the _FORTIFY_SOURCE effect:"
echo
echo " WITHOUT fortify, strcpy is unchecked:"
run "fortify OFF" ./fortify_off "$LONG"
echo " WITH fortify, strcpy becomes __strcpy_chk and aborts:"
run "fortify ON"  ./fortify_on  "$LONG"
echo " With fortify, look for: buffer overflow detected (exit 134)"

echo
echo ""
echo "  ALL TESTS COMPLETE."
echo "  Generated files: binaries, asm_*.s assembly dumps."
echo "  check the exit codes and assembly greps above for report if needed."
