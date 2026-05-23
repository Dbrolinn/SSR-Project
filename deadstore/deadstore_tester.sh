#!/bin/bash

SRC="deadstore_test.c"
BASE_BIN_DIR="./bin_out"
BASE_ASM_DIR="./asm_out"

# Verificar se o código fonte existe
if [ ! -f "$SRC" ]; then
    echo "Error: Cannot find $SRC in the current directory."
    exit 1
fi

# Flags para o GCC
declare -a gcc_flags=(
    "-O0"
    "-O2"
    "-O3"
    "-O3 -fno-tree-dse"
    "-O3 -fno-builtin-memset"
)

# Flags para o Clang
declare -a clang_flags=(
    "-O0"
    "-O2"
    "-O3"
    "-O3 -fno-builtin"
)

run_compiler_suite() {
    local compiler=$1
    shift
    local flags=("${@}")
    
    local bin_dir="$BASE_BIN_DIR/$compiler"
    local asm_dir="$BASE_ASM_DIR/$compiler"
    
    mkdir -p "$bin_dir"
    mkdir -p "$asm_dir"

    echo "##################################################"
    echo " Generating Assembly with: $compiler"
    echo "##################################################"

    for flag in "${flags[@]}"; do
        local safe_flag_name=$(echo "$flag" | tr ' -' '__' | sed 's/^_//')
        local asm_file="$asm_dir/dse_${safe_flag_name}.s"
        local bin_file="$bin_dir/dse_${safe_flag_name}"

        echo ">>> Compiling with flag: $flag"
        
        # Gerar o executável
        $compiler $flag "$SRC" -o "$bin_file" 2>/dev/null
        local compile_status=$?

        # Gerar o Assembly (Intel syntax, sem tabelas de debug para facilitar a leitura humana)
        $compiler $flag -S -masm=intel -fno-asynchronous-unwind-tables "$SRC" -o "$asm_file" 2>/dev/null
        
        if [ $compile_status -eq 0 ]; then
            echo "    [OK] Saved to $asm_file"
        else
            echo "    [!] Compilation failed for flag: $flag"
        fi
    done
    echo ""
}

# Limpar pastas antigas para garantir resultados frescos
rm -rf "$BASE_BIN_DIR" "$BASE_ASM_DIR"

# Correr para GCC
if command -v gcc &> /dev/null; then
    run_compiler_suite "gcc" "${gcc_flags[@]}"
else
    echo "GCC not found."
fi

# Correr para Clang
if command -v clang &> /dev/null; then
    run_compiler_suite "clang" "${clang_flags[@]}"
else
    echo "Clang not found."
fi

echo "=================================================="
echo " Compilation Pipeline Finished!"
echo " Navigate to the $BASE_ASM_DIR/ directory and open"
echo " the .s files in VSCode/Vim to verify the CISBs."
echo "=================================================="