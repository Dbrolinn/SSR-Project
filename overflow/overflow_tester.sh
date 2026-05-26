#!/bin/bash

SRC="overflow_test.c"
BIN="./test_runner"
LATEX_OUT="tabelas_latex.tex"

if [ ! -f "$SRC" ]; then
    echo "Error: Cannot find $SRC in the current directory."
    exit 1
fi

# As flags exatas que pediste para ambos os compiladores
declare -a test_flags=("" "-O0" "-O1" "-O2" "-O3" "-O3 -fwrapv")

# Inicializa/limpa o ficheiro de saída LaTeX
echo "% =========================================================" > $LATEX_OUT
echo "% Resultados Extraídos Automaticamente do overflow_tester.sh" >> $LATEX_OUT
echo "% =========================================================" >> $LATEX_OUT
echo "" >> $LATEX_OUT

# Função central que compila, testa e regista os resultados
evaluate_and_log() {
    local compiler=$1
    local type_macro=$2
    local model_macro=$3
    local flag=$4
    local display_flag=$5
    local label=$6

    # Compila injetando o Tipo e o Modelo
    $compiler $flag -D$type_macro -D$model_macro $SRC -o $BIN 2>/dev/null
    
    if [ $? -eq 0 ]; then
        # 1. Tamanho do binário
        local binary_size=$(stat -c%s $BIN)
        
        # 2. Teste Dinâmico (Ground Truth: offset=1)
        local status_raw=$($BIN -1)
        
        # 3. Output Limpo para o Terminal
        local terminal_status=""
        if [[ "$status_raw" == *"CISB_DETECTED"* ]]; then
            terminal_status="\e[31mVULNERÁVEL\e[0m" # Vermelho
        elif [[ "$status_raw" == *"LOGIC_FLAW"* ]]; then
            terminal_status="\e[33mLOGIC FLAW\e[0m"      # Amarelo
        else
            terminal_status="\e[32mSEGURO\e[0m"   # Verde
        fi
        
        # Imprime no terminal de forma tabular
        printf "  %-7s | %-15s | %-18s | %-7s B | %b\n" "$compiler" "$display_flag" "$label" "$binary_size" "$terminal_status"
        
        # 4. Formatação silenciosa para o ficheiro LaTeX
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
echo " FASE 1: Evolução das Mitigações e do 'Buffer' (Tipo: INT Padrão)"
echo "######################################################################"

# Escreve o cabeçalho da Tabela 1 no LaTeX
echo "\begin{table*}[htbp]" >> $LATEX_OUT
echo "\centering" >> $LATEX_OUT
echo "\caption{Performance and Security Trade-offs (Integer Bounds Check)}" >> $LATEX_OUT
echo "\begin{tabular}{@{}lllcrl@{}}" >> $LATEX_OUT
echo "\toprule" >> $LATEX_OUT
echo "\textbf{Model Strategy} & \textbf{Compiler} & \textbf{Flag} & \textbf{Size (B)} & \textbf{Status (Recall)} \\" >> $LATEX_OUT
echo "\midrule" >> $LATEX_OUT

modelos=("MODEL_NAIVE:Naive (Direct)" "MODEL_BUFFER:Naive (w/ Buffer)" "MODEL_SAFE:Pre-condition" "MODEL_BUILTIN:Builtin")

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

# Fecha Tabela 1
echo "\bottomrule \end{tabular} \end{table*}" >> $LATEX_OUT
echo "" >> $LATEX_OUT


echo ""
echo "######################################################################"
echo " FASE 2: Impacto dos Tipos de Dados na Norma C (Modelo: NAIVE fixo)"
echo "######################################################################"

# Escreve o cabeçalho da Tabela 2 no LaTeX
echo "\begin{table*}[htbp]" >> $LATEX_OUT
echo "\centering" >> $LATEX_OUT
echo "\caption{Impact of C Standards on Bounds Check Elimination}" >> $LATEX_OUT
echo "\begin{tabular}{@{}lllcrl@{}}" >> $LATEX_OUT
echo "\toprule" >> $LATEX_OUT
echo "\textbf{Data Type} & \textbf{Compiler} & \textbf{Flag} & \textbf{Size (B)} & \textbf{Status (Recall)} \\" >> $LATEX_OUT
echo "\midrule" >> $LATEX_OUT

tipos=("TYPE_INT:int (Signed)" "TYPE_UINT:unsigned int" "TYPE_INT16:int16_t" "TYPE_DOUBLE:double" "TYPE_POINTER:char* (Pointer)")

for tipo_pair in "${tipos[@]}"; do
    tipo_macro="${tipo_pair%%:*}"
    tipo_label="${tipo_pair##*:}"
    
    for compiler in "gcc" "clang"; do
        if command -v $compiler &> /dev/null; then
            # Na Fase 2, testamos todos os níveis de otimização como pediste
            for flag in "${test_flags[@]}"; do
                display_flag=${flag:-"-O0 (Def)"}
                evaluate_and_log "$compiler" "$tipo_macro" "MODEL_NAIVE" "$flag" "$display_flag" "$tipo_label"
            done
        fi
    done
    echo "\midrule" >> $LATEX_OUT
    echo "----------------------------------------------------------------------"
done

# Fecha Tabela 2
echo "\bottomrule \end{tabular} \end{table*}" >> $LATEX_OUT

echo ""
echo "======================================================================"
echo " Teste concluído! O código LaTeX foi guardado no ficheiro:"
echo " -> $LATEX_OUT"
echo "======================================================================"