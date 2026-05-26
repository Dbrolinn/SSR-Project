#!/bin/bash

SRC="overflow_test.c"
BIN="./test_runner"
LATEX_OUT="tabelas_latex.tex"

if [ ! -f "$SRC" ]; then
    echo "Error: Cannot find $SRC in the current directory."
    exit 1
fi

declare -a test_flags=("" "-O0" "-O1" "-O2" "-O3" "-O3 -fwrapv")

echo "% =========================================================" > $LATEX_OUT
echo "% Resultados Extraídos Automaticamente do overflow_tester.sh" >> $LATEX_OUT
echo "% =========================================================" >> $LATEX_OUT
echo "" >> $LATEX_OUT

evaluate_and_log() {
    local compiler=$1
    local type_macro=$2
    local model_macro=$3
    local flag=$4
    local display_flag=$5
    local label=$6

    $compiler $flag -D$type_macro -D$model_macro $SRC -o $BIN 2>/dev/null
    
    if [ $? -eq 0 ]; then
        local binary_size=$(stat -c%s $BIN)
        
        # O argumento '1' diz ao C para disparar o gatilho da vulnerabilidade
        local status_raw=$($BIN -1)
        
        local terminal_status=""
        if [[ "$status_raw" == *"CISB_DETECTED"* ]]; then
            terminal_status="\e[31mVULNERÁVEL \e[0m"
        elif [[ "$status_raw" == *"LOGIC_FLAW"* ]]; then
            terminal_status="\e[33mLOGIC FLAW\e[0m"
        else
            terminal_status="\e[32mSEGURO \e[0m"
        fi
        
        printf "  %-7s | %-15s | %-18s | %-7s B | %b\n" "$compiler" "$display_flag" "$label" "$binary_size" "$terminal_status"
        
        local status_tex=""
        if [[ "$status_raw" == *"CISB_DETECTED"* ]]; then
            status_tex="\textbf{\textcolor{red}{Vulnerable}}"
        elif [[ "$status_raw" == *"LOGIC_FLAW"* ]]; then
            status_tex="\textcolor{orange}{Logic Flaw}"
        else
            status_tex="\textcolor{green}{Secure}}"
        fi
        
        echo "$label & $compiler & \texttt{$display_flag} & $binary_size & $status_tex \\\\" >> $LATEX_OUT
        rm $BIN
    else
        printf "  %-7s | %-15s | %-18s | [!] FALHA NA COMPILAÇÃO\n" "$compiler" "$display_flag" "$label"
    fi
}


echo "######################################################################"
echo " FASE 1: Evolução das Mitigações (Inclui Bug do Ext4 Linux Kernel)"
echo "######################################################################"

echo "\begin{table*}[htbp]" >> $LATEX_OUT
echo "\centering" >> $LATEX_OUT
echo "\caption{Performance and Security Trade-offs (Integer Bounds Check)}" >> $LATEX_OUT
echo "\begin{tabular}{@{}lllcrl@{}}" >> $LATEX_OUT
echo "\toprule" >> $LATEX_OUT
echo "\textbf{Model Strategy} & \textbf{Compiler} & \textbf{Flag} & \textbf{Size (B)} & \textbf{Status (Recall)} \\" >> $LATEX_OUT
echo "\midrule" >> $LATEX_OUT

# ADICIONADO O MODELO DO EXT4 AQUI:
modelos=(
    "MODEL_NAIVE:Naive (Direct)" 
    "MODEL_BUFFER:Naive (w/ Buffer)" 
    "MODEL_SHIFT_UB:Left Shift (Ext4)" 
    "MODEL_SAFE:Pre-condition" 
    "MODEL_BUILTIN:Builtin"
)

for mod_pair in "${modelos[@]}"; do
    mod_macro="${mod_pair%%:*}"
    mod_label="${mod_pair##*:}"
    
    for compiler in "gcc" "clang"; do
        if command -v $compiler &> /dev/null; then
            for flag in "${test_flags[@]}"; do
                display_flag=${flag:-"-O0 (Def)"}
                evaluate_and_log "$compiler" "TYPE_INT" "$mod_macro" "$flag" "$display_flag" "$mod_label"
            done
        fi
    done
    echo "\midrule" >> $LATEX_OUT
    echo "----------------------------------------------------------------------"
done

echo "\bottomrule \end{tabular} \end{table*}" >> $LATEX_OUT
echo "" >> $LATEX_OUT


echo ""
echo "######################################################################"
echo " FASE 2: Impacto dos Tipos de Dados na Norma C (Modelo: NAIVE fixo)"
echo "######################################################################"

echo "\begin{table*}[htbp]" >> $LATEX_OUT
echo "\centering" >> $LATEX_OUT
echo "\caption{Impact of C Standards on Bounds Check Elimination}" >> $LATEX_OUT
echo "\begin{tabular}{@{}lllcrl@{}}" >> $LATEX_OUT
echo "\toprule" >> $LATEX_OUT
echo "\textbf{Data Type} & \textbf{Compiler} & \textbf{Flag} & \textbf{Size (B)} & \textbf{Status (Recall)} \\" >> $LATEX_OUT
echo "\midrule" >> $LATEX_OUT

tipos=("TYPE_INT:int (Signed)" "TYPE_UINT:unsigned int" "TYPE_INT16:int16\_t" "TYPE_DOUBLE:double" "TYPE_POINTER:char* (Pointer)")

for tipo_pair in "${tipos[@]}"; do
    tipo_macro="${tipo_pair%%:*}"
    tipo_label="${tipo_pair##*:}"
    
    for compiler in "gcc" "clang"; do
        if command -v $compiler &> /dev/null; then
            for flag in "${test_flags[@]}"; do
                display_flag=${flag:-"-O0 (Def)"}
                evaluate_and_log "$compiler" "$tipo_macro" "MODEL_NAIVE" "$flag" "$display_flag" "$tipo_label"
            done
        fi
    done
    echo "\midrule" >> $LATEX_OUT
    echo "----------------------------------------------------------------------"
done

echo "\bottomrule \end{tabular} \end{table*}" >> $LATEX_OUT

echo ""
echo "======================================================================"
echo " Teste concluído! O código LaTeX foi guardado no ficheiro:"
echo " -> $LATEX_OUT"
echo "======================================================================"