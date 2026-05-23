#!/bin/bash

echo " BINARY SIZE ANALYSIS "
ls -la vuln_00 vuln_02 vuln_flag fixed
echo ""
echo "Section sizes (size command):"
size vuln_00 vuln_02 vuln_flag fixed
echo ""

echo " FUNCTION INSTRUCTION COUNT (function parse_packet)"
# Counting total lines of assembly in the parse_packet function
v00_lines=$(objdump -d vuln_00   | awk '/^.*<parse_packet.*>:$/,/^$/' | grep -v "^$\|parse_packet" | wc -l)
v02_lines=$(objdump -d vuln_02   | awk '/^.*<parse_packet.*>:$/,/^$/' | grep -v "^$\|parse_packet" | wc -l)
vfl_lines=$(objdump -d vuln_flag | awk '/^.*<parse_packet.*>:$/,/^$/' | grep -v "^$\|parse_packet" | wc -l)
vfx_lines=$(objdump -d fixed     | awk '/^.*<parse_packet.*>:$/,/^$/' | grep -v "^$\|parse_packet" | wc -l)

echo "vuln_00   (-O0)            : $v00_lines instructions"
echo "vuln_02   (-O2 Vulnerable) : $v02_lines instructions"
echo "vuln_flag (-O2 Mitigated)  : $vfl_lines instructions"
echo "fixed     (-O2 Code Fixed) : $vfx_lines instructions"
echo ""

echo " MEMORY READ VERIFICATION "

# Checking how many times memory is actually read inside parse_packet
v00_reads=$(objdump -d vuln_00 | awk '/^.*<parse_packet.*>:$/,/^$/' | grep -c "mov.*(%")
v02_reads=$(objdump -d vuln_02 | awk '/^.*<parse_packet.*>:$/,/^$/' | grep -c "mov.*(%")
vfx_reads=$(objdump -d fixed   | awk '/^.*<parse_packet.*>:$/,/^$/' | grep -c "mov.*(%")

echo "Memory reads in vuln_00   (-O0)  : $v00_reads (Expected: High, no cache)"
echo "Memory reads in vuln_02   (-O2)  : $v02_reads (Expected: Low, bug bypassed read)"
echo "Memory reads in fixed     (-O2)  : $vfx_reads (Expected: Restored, memcpy forced read)"

echo ""
echo "To compare assembly files visually, run:"
echo "diff asm_00.s asm_02.s | less"
