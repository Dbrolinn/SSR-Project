#!/bin/bash
#  STRICT ALIASING / TYPE PUNNING
#
#  For each (compiler, model, optimization level) it builds and runs the
#  program 100 times, records how many runs exhibited the bug,
#  and records the binary size. Results are written to results_bug4.csv.
#
#  Expects in this directory:
#    vuln.c       -> model M=0
#    fixed.c      -> model M=1
#
#  Compilers tried: gcc, clang
#  Optimization levels: O0 O1 O2 O3

N=100
OPTS="O0 O1 O2 O3"               # optimization levels to test
FUNC="validate"             # function name for assembly analysis
CSV="results_bug4.csv"

BYPASS_MARKER="stayed 1000"
# (fixed.c never prints this)

# Discover available compilers
COMPILERS=""
for cc in gcc clang; do
    command -v "$cc" >/dev/null 2>&1 && COMPILERS="$COMPILERS $cc"
done

# Check source files
for f in vuln.c fixed.c; do
    [ -f "$f" ] || { echo "ERROR: $f not found in this directory."; exit 1; }
done

echo "  BUG 4 - STRICT ALIASING"
echo "Compilers : $COMPILERS"
echo "Opt levels: $OPTS"
echo "Iterations per cell: $N"
echo "Bug = run prints 'stayed 1000'"
echo ""

stddev() {
    awk -v n="$1" -v k="$2" 'BEGIN{
        if (n<=1){ print "0.000"; exit }
        p = k/n;
        # variance of n values that are k ones and (n-k) zeros
        # sum((x-p)^2) = k*(1-p)^2 + (n-k)*(0-p)^2
        ss = k*(1-p)*(1-p) + (n-k)*p*p;
        var = ss/(n-1);
        s = sqrt(var);
        printf "%.3f", s;
    }'
}

echo "compiler,model,opt,bug,iterations,bug_count,mu,sigma,size_bytes,mem_reads" > "$CSV"

# experiment loops
for CC in $COMPILERS; do
    for MODEL in 0 1; do
        if [ "$MODEL" -eq 0 ]; then SRC="vuln.c"; else SRC="fixed.c"; fi
        for O in $OPTS; do
            BIN="exp_${CC}_m${MODEL}_${O}"
            ASM="exp_${CC}_m${MODEL}_${O}.s"

            # compile (binary + assembly)
            if ! "$CC" -"$O" -o "$BIN" "$SRC" 2>/dev/null; then
                echo "  [skip] $CC -$O $SRC failed to compile"
                continue
            fi
            "$CC" -"$O" -S -o "$ASM" "$SRC" 2>/dev/null

            # run N times, count bug occurrences
            bug_count=0
            for i in $(seq 1 "$N"); do
                out=$(./"$BIN" 2>/dev/null)

                if [ "$i" -eq 1 ]; then
                    first_out=$(echo "$out" | tr '\n' ' | ')
                fi

                echo "$out" | grep -q "$BYPASS_MARKER" && bug_count=$((bug_count+1))
            done

            # statistics
            mu=$(awk -v k="$bug_count" -v n="$N" 'BEGIN{printf "%.3f", k/n}')
            sigma=$(stddev "$N" "$bug_count")

            # binary size in bytes
            sz=$(stat -c%s "$BIN" 2>/dev/null || wc -c < "$BIN")

            # assembly memory reads in the target function
            reads=$(objdump -d "$BIN" 2>/dev/null \
                    | awk "/<${FUNC}>:/,/^\$/" \
                    | grep -c "mov.*(%")

            # save record
            echo "$CC,$MODEL,$O,b4,$N,$bug_count,$mu,$sigma,$sz,$reads" >> "$CSV"
            printf "  %-6s M=%s %-3s  bug=%s/%s  mu=%s sigma=%s  size=%sB  reads=%s\n" \
                   "$CC" "$MODEL" "$O" "$bug_count" "$N" "$mu" "$sigma" "$sz" "$reads"
            printf "%s\n" "$first_out"
        done
    done
done

echo ""
echo "Raw results written to: $CSV"
echo ""

# LaTeX table fragment.
LATEX="table_bug4.tex"
{
    echo "% Columns: CC = compiler, M = model (0=vuln,1=fixed), O = opt level,"
    echo "%          Bug = bug id, mu = mean bug rate, sigma = std dev, sz = binary size"
    echo "\\begin{tabular}{llllrrr}"
    echo "\\toprule"
    echo "CC & M & O & Bug & \$\\mu\$ & \$\\sigma\$ & sz \\\\"
    echo "\\midrule"
    tail -n +2 "$CSV" | while IFS=, read -r cc model opt bug iters bcount mu sigma sz reads; do
        szkb=$(awk -v b="$sz" 'BEGIN{printf "%.1f", b/1024}')
        printf "%s & %s & %s & %s & %s/%s & %s & %s kB \\\\\\\\\n" \
               "$cc" "$model" "$opt" "$bug" "$bcount" "$iters" "$sigma" "$szkb"
    done
    echo "\\bottomrule"
    echo "\\end{tabular}"
} > "$LATEX"

echo "LaTeX table written to: $LATEX"
echo ""
echo " LaTeX table preview "
cat "$LATEX"
echo ""
echo "NOTE ON VARIANCE: for a deterministic compiler, all N runs of one binary"
echo "The meaningful variation is ACROSS cells: gcc vs clang, O0/O1/O2/O3, and model 0 vs 1."
echo "That cross-cell pattern is the experimental result to discuss."
