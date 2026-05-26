#!/bin/bash

SRC="padding_test.c"
BIN="./padding_test_run"

if [ ! -f "$SRC" ]; then
    echo "Erro: Não encontro o ficheiro $SRC."
    exit 1
fi

declare -a flags=(
    "-O0"
    "-O2"
    "-O3"
)

echo "##################################################"
echo " Analisando Information Leak via Struct Padding "
echo "##################################################"

for flag in "${flags[@]}"; do
    echo ">>> Compilando com GCC: $flag"
    
    gcc $flag $SRC -o $BIN 2>/dev/null
    
    if [ $? -eq 0 ]; then
        $BIN
        rm $BIN
    else
        echo "    [!] Falha na compilação."
    fi
    echo "--------------------------------------------------"
done