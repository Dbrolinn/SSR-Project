#!/bin/bash

SRC="overflow_test.c"
BIN="./test_runner"

# Check if the source file exists
if [ ! -f "$SRC" ]; then
    echo "Error: Cannot find $SRC in the current directory."
    exit 1
fi

# Array of GCC compiler flags to test
# The first empty string "" represents pure default compilation (no flags)
declare -a gcc_flags=(
    "" 
    "-O0"
    "-O2"
    "-O3"
    "-O2 -fwrapv"
    "-O2 -fno-strict-overflow"
    "-O0 -fsanitize=undefined"
)

# Array of Clang compiler flags to test
declare -a clang_flags=(
    ""
    "-O0"
    "-O2"
    "-O3"
    "-O2 -fwrapv"
    "-O0 -fsanitize=undefined"
)

run_compiler_suite() {
    local compiler=$1
    shift
    local flags=("$@")

    echo "##################################################"
    echo " Running test suite for compiler: $compiler"
    echo "##################################################"

    for flag in "${flags[@]}"; do
        # Format the display string for empty flags
        local display_flag=$flag
        if [ -z "$flag" ]; then
            display_flag="(No flags / Default)"
        fi

        echo ">>> Compiling: $compiler $display_flag"
        
        # We purposely don't quote $flag here so multiple arguments (like "-O2 -fwrapv") 
        # are properly split into separate arguments for the compiler.
        $compiler $flag $SRC -o $BIN 2>/dev/null
        
        if [ $? -eq 0 ]; then
            $BIN
            rm $BIN
        else
            # Some sanitizers might not be installed, or builtins might fail on ancient compilers
            echo "    [!] Compilation failed or unsupported flags."
            echo ""
        fi
    done
}

# Run GCC tests
if command -v gcc &> /dev/null; then
    run_compiler_suite "gcc" "${gcc_flags[@]}"
else
    echo "GCC not found, skipping GCC tests."
fi

# Run Clang tests
if command -v clang &> /dev/null; then
    run_compiler_suite "clang" "${clang_flags[@]}"
else
    echo "Clang not found on this system. Skipping Clang tests."
fi

echo "All test suites completed!"
