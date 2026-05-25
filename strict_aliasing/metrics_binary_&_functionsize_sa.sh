#!/bin/bash
#  STRICT ALIASING — compile, run, assembly, statistics
#
#  Expects in this directory:
#    vuln.c   (vulnerable: via pointer cast)
#    fixed.c  (fixed: uses memcpy instead of cast)

CC=${CC:-gcc}

pause() {
    echo ""
    read -r -p ">>> Press ENTER to continue (or Ctrl-C to abort)... " _
    echo ""
}

# check files exist
for f in vuln.c fixed.c; do
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

"$CC" -O0 -o vuln_00    vuln.c
echo "   vuln_00    : gcc -O0 (unoptimized, reads correct)"

"$CC" -O2 -o vuln_02    vuln.c
echo "   vuln_02    : gcc -O2 (optimized, STALE READ)"

"$CC" -O2 -fno-strict-aliasing -o vuln_flag vuln.c
echo "   vuln_flag  : gcc -O2 -fno-strict-aliasing  (flag fix, reads correct)"

"$CC" -O2 -o fixed      fixed.c
echo "   fixed      : gcc -O2 (code fix, memcpy)"

echo ""
echo "   Compilation complete."

# RUN
pause
echo " RUNNING ALL VERSIONS"
echo ""
echo "Look at the 'value after ntohl' line and whether the packet is"
echo "DROPPED (correct) or PROCESSED (security bypassed)."
echo ""

echo " vuln_00 (unoptimized)"
./vuln_00
echo "[exit code: $?]"
echo ""

echo " vuln_02 (optimized)"
./vuln_02
echo "[exit code: $?]"
echo ""

echo " vuln_flag (flag fix) "
./vuln_flag
echo "[exit code: $?]"
echo ""

echo " fixed (code fix, memcpy) "
./fixed
echo "[exit code: $?]"

# GENERATE ASSEMBLY
pause
echo " GENERATING ASSEMBLY FILES"
echo ""

"$CC" -O0 -S -o asm_00.s    vuln.c
"$CC" -O2 -S -o asm_02.s    vuln.c
"$CC" -O2 -fno-strict-aliasing -S -o asm_flag.s vuln.c
"$CC" -O2 -S -o asm_fixed.s fixed.c

echo "   Generated: asm_00.s  asm_02.s  asm_flag.s  asm_fixed.s"

# ASSEMBLY ANALYSIS (grep)
pause
echo " ASSEMBLY ANALYSIS"
echo ""
echo " Memory loads in validate_packet per version"
echo ""

v00_reads=$(objdump -d vuln_00   | awk '/^.*<validate_packet.*>:$/,/^$/' | grep -c "mov.*(%")
v02_reads=$(objdump -d vuln_02   | awk '/^.*<validate_packet.*>:$/,/^$/' | grep -c "mov.*(%")
vfl_reads=$(objdump -d vuln_flag | awk '/^.*<validate_packet.*>:$/,/^$/' | grep -c "mov.*(%")
vfx_reads=$(objdump -d fixed     | awk '/^.*<validate_packet.*>:$/,/^$/' | grep -c "mov.*(%")

echo "   vuln_00   (-O0)            : $v00_reads reads  (high = no caching, correct)"
echo "   vuln_02   (-O2 vulnerable) : $v02_reads reads  (low = stale cached value, BUG)"
echo "   vuln_flag (-O2 flag fix)   : $vfl_reads reads  (restored, compiler forced to reload)"
echo "   fixed     (-O2 code fix)   : $vfx_reads reads  (correct, memcpy avoids aliasing)"
echo ""

echo " Checking for ntohl call in each version"
echo ""
for b in vuln_00 vuln_02 vuln_flag fixed; do
    cnt=$(objdump -d "$b" | awk '/^.*<validate_packet.*>:$/,/^$/' | grep -c "ntohl\|bswap")
    printf "   %-14s ntohl/bswap: %s\n" "$b" "$cnt"
done
echo ""

echo "if we want to compare assembly files visually, run:"
echo "   diff asm_00.s asm_02.s | less"

# STATISTICS
pause
echo " BINARY SIZES"
echo ""
ls -la vuln_00 vuln_02 vuln_flag fixed
echo ""
size vuln_00 vuln_02 vuln_flag fixed
echo ""

echo " FUNCTION SIZE ( instruction count)"
echo ""
v00_lines=$(objdump -d vuln_00   | awk '/^.*<validate_packet.*>:$/,/^$/' | grep -v "^$\|validate_packet" | wc -l)
v02_lines=$(objdump -d vuln_02   | awk '/^.*<validate_packet.*>:$/,/^$/' | grep -v "^$\|validate_packet" | wc -l)
vfl_lines=$(objdump -d vuln_flag | awk '/^.*<validate_packet.*>:$/,/^$/' | grep -v "^$\|validate_packet" | wc -l)
vfx_lines=$(objdump -d fixed     | awk '/^.*<validate_packet.*>:$/,/^$/' | grep -v "^$\|validate_packet" | wc -l)

echo "   vuln_00   (-O0)            : $v00_lines instructions"
echo "   vuln_02   (-O2 vulnerable) : $v02_lines instructions"
echo "   vuln_flag (-O2 flag fix)   : $vfl_lines instructions"
echo "   fixed     (-O2 code fix)   : $vfx_lines instructions"
echo ""

echo " MEMORY READ SUMMARY"
echo ""
echo "   vuln_00   (-O0)  : $v00_reads reads  (no caching)"
echo "   vuln_02   (-O2)  : $v02_reads reads  (stale read = BUG)"
echo "   vuln_flag (-O2)  : $vfl_reads reads  (reload forced by flag)"
echo "   fixed     (-O2)  : $vfx_reads reads  (correct, memcpy)"
echo ""
echo " ALL TESTS COMPLETE"