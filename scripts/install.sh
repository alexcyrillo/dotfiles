#!/bin/bash

set -e 

MODULES_DIR="./modules"

run_module() {
    local script="$1"
    if [ -f "$script" ]; then
        echo "===> Executando: $(basename "$script")"
        source "$script"
    else
        echo "Erro: $script não encontrado."
    fi
}

run_module "$MODULES_DIR/dependencies.sh"
run_module "$MODULES_DIR/zsh.sh"
run_module "$MODULES_DIR/flatpaks.sh"
