#!/bin/bash
# Script de Bootstrap para configuração de novo ambiente (Fedora)
# Este script deve ser baixado e executado ANTES de clonar o repositório.

DOTFILES_DIR=~/dotfiles

# ---
# FASE 1: PRÉ-CLONE (Dependências e SSH)
# ---

# ---
# 1. Instalar dependências (para Fedora)
# ---
echo "--- Iniciando configuração ---"
echo "--- Instalando dependências (Git, Zsh, Curl) ---"
echo "Você precisará da sua senha de administrador (sudo)."
sudo dnf install -y git zsh curl

# Verifica se a instalação foi bem-sucedida
if [ $? -ne 0 ]; then
    echo "ERRO: Falha ao instalar dependências. Abortando."
    exit 1
fi
echo "Dependências instaladas."


# ---
# 2. Configurar Git
# ---
echo "--- Configurando Git ---"
echo "Esta informação será usada para configurar o Git."
read -p "Digite seu nome de usuário do Git (ex: seu usuário do GitHub): " git_user
read -p "Digite seu email do Git: " git_email
git config --global user.name "$git_user"
git config --global user.email "$git_email"
echo "Git configurado."


# ---
# 3. Configurar Chave Privada SSH (Apenas a chave)
# ---
echo "--- Configurando SSH (Chave Privada) ---"
if [ ! -d "$HOME/.ssh" ]; then
    mkdir ~/.ssh
    echo "Pasta ~/.ssh criada."
fi
chmod 700 ~/.ssh

echo ""
echo "--- AÇÃO MANUAL NECESSÁRIA (SSH) ---"

# Define o nome padrão da chave privada
default_key_filename="id_ed25519"

echo "Para clonar o repositório, sua chave privada é necessária."
read -p "Digite o nome da sua chave privada (padrão: $default_key_filename): " private_key_filename

# Se a entrada estiver vazia, usa o padrão
if [ -z "$private_key_filename" ]; then
    private_key_filename="$default_key_filename"
    echo "Nenhum nome inserido. Usando o padrão: $private_key_filename"
fi

private_key_path="$HOME/.ssh/$private_key_filename"

echo "Copie sua chave privada ($private_key_filename) do seu cofre"
echo "para a pasta ~/.ssh/
