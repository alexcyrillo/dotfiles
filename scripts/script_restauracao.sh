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
echo "para a pasta ~/.ssh/ AGORA."
echo ""
read -p "Após copiar a chave, pressione [Enter] para definir as permissões..."

# Define as permissões APÓS o usuário copiar o arquivo
if [ -f "$private_key_path" ]; then
    chmod 600 "$private_key_path"
    echo "Permissões da chave privada ($private_key_filename) definidas."
else
    echo "AVISO: Chave privada $private_key_path não encontrada."
    echo "A clonagem do repositório provavelmente falhará."
fi


# ---
# FASE 2: CLONE DO REPOSITÓRIO
# ---
echo "--- Clonando repositório dotfiles ---"
if [ ! -d "$DOTFILES_DIR" ]; then
    
    echo "Cole a URL SSH completa do seu repositório dotfiles (ex: git@github.com:usuario/dotfiles.git)"
    read -p "URL do Repositório: " repo_url

    if [ -z "$repo_url" ]; then
        echo "ERRO: Nenhuma URL de repositório inserida. Abortando."
        exit 1
    fi

    echo "Clonando $repo_url para $DOTFILES_DIR"
    git clone "$repo_url" "$DOTFILES_DIR"
    
    if [ $? -ne 0 ]; then
        echo "ERRO: Falha ao clonar o repositório."
        echo "Verifique se a chave SSH foi copiada corretamente e se a URL '$repo_url' está correta."
        exit 1
    fi
else
    echo "Repositório dotfiles já existe em $DOTFILES_DIR. Pulando clonagem."
fi


# ---
# FASE 3: PÓS-CLONE (Links Simbólicos)
# ---

# ---
# Função para criar links simbólicos com backup
# ---
link_file() {
    local source_file="$DOTFILES_DIR/$1"
    local target_link="$HOME/$2"

    # Garante que o diretório de destino exista (ex: ~/.config)
    mkdir -p "$(dirname "$target_link")"

    # Se o arquivo/link de destino já existir, faz backup
    if [ -e "$target_link" ] || [ -L "$target_link" ]; then
        echo "Fazendo backup de $target_link para $target_link.backup"
        mv "$target_link" "$target_link.backup"
    fi

    echo "Linkando $source_file -> $target_link"
    ln -s "$source_file" "$target_link"
}

echo "--- Configurando Links Simbólicos ---"

# ---
# 4. Configurar Links do SSH (config, known_hosts, etc.)
# ---
echo "--- Linkando arquivos de configuração do SSH ---"
link_file "ssh/config" ".ssh/config"
link_file "ssh/known_hosts" ".ssh/known_hosts"
link_file "ssh/id_ed25519.pub" ".ssh/id_ed25519.pub"
echo "Links do SSH criados."

# ---
# 5. Instalar Oh My Zsh
# ---
# O script do OMZ criará a pasta real ~/.oh-my-zsh/custom
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "--- Instalando Oh My Zsh ---"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh já está instalado."
fi

# ---
# 6. Configurar Zsh (Links)
# ---
echo "--- Configurando Zsh ---"
# Linka o .zshrc
link_file "zsh/zshrc" ".zshrc"

# Garante que a pasta custom (real) exista
mkdir -p $HOME/.oh-my-zsh/custom

# Itera e linka TODOS os itens (arquivos E pastas) da pasta custom do repositório
echo "Linkando arquivos .zsh personalizados, funções e scripts de completar..."
for item in $DOTFILES_DIR/zsh/custom/*; do
    # Verifica se o item existe (evita erros em pastas 'custom' vazias)
    if [ -e "$item" ]; then
        item_name=$(basename "$item")
        # Linka o item (ex: 'aliases.zsh' ou '_dotfiles_bkp') para dentro da pasta real ~/.oh-my-zsh/custom/
        link_file "zsh/custom/$item_name" ".oh-my-zsh/custom/$item_name"
    fi
done
echo "Links do Zsh criados."


# ---
# 7. Instalar Plugins do Zsh (listados no .zshrc)
# ---
echo "--- Instalando plugins do Oh My Zsh ---"
# Define o caminho para a pasta REAL de plugins
CUSTOM_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

if [ ! -d "$CUSTOM_PLUGINS_DIR/zsh-autosuggestions" ]; then
    echo "Instalando zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM_PLUGINS_DIR/zsh-autosuggestions"
fi

if [ ! -d "$CUSTOM_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    echo "Instalando zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM_PLUGINS_DIR/zsh-syntax-highlighting"
fi

if [ ! -d "$CUSTOM_PLUGINS_DIR/zsh-you-should-use" ]; then
    echo "Instalando you-should-use..."
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$CUSTOM_PLUGINS_DIR/zsh-you-should-use"
fi
echo "Plugins instalados."


# ---
# 8. (NOVO) Restaurar Configurações dconf (GNOME)
# ---
echo "--- Restaurando configurações dconf (GNOME) ---"

# Define o novo caminho do subdiretório
# (ERRO CORRIGIDO: 'local' removido)
DCONF_DIR="$DOTFILES_DIR/gnome-dconf"

if command -v dconf &> /dev/null; then
    
    # 1. Restaurar Extensões
    if [ -f "$DCONF_DIR/gnome-extensions-settings.dconf" ]; then
        echo "Carregando configurações das extensões..."
        dconf load /org/gnome/shell/extensions/ < "$DCONF_DIR/gnome-extensions-settings.dconf"
    fi
    
    # 2. Restaurar Atalhos de Mídia/Personalizados
    if [ -f "$DCONF_DIR/gnome-keybindings-media.dconf" ]; then
        echo "Carregando atalhos de mídia/personalizados..."
        dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$DCONF_DIR/gnome-keybindings-media.dconf"
    fi
    
    # 3. Restaurar Atalhos do Gerenciador de Janelas
    if [ -f "$DCONF_DIR/gnome-keybindings-wm.dconf" ]; then
        echo "Carregando atalhos do gerenciador de janelas..."
        dconf load /org/gnome/desktop/wm/keybindings/ < "$DCONF_DIR/gnome-keybindings-wm.dconf"
    fi
    
    # 4. Restaurar Atalhos do Shell
    if [ -f "$DCONF_DIR/gnome-keybindings-shell.dconf" ]; then
        echo "Carregando atalhos do shell..."
        dconf load /org/gnome/shell/keybindings/ < "$DCONF_DIR/gnome-keybindings-shell.dconf"
    fi
    
    echo "Configurações dconf do GNOME restauradas."
else
    echo "AVISO: Comando 'dconf' não encontrado. Pulando restauração do dconf."
fi


echo ""
echo "--- Instalação Concluída! ---"
echo "Pode ser necessário alterar seu shell padrão para Zsh com: chsh -s \$(which zsh)"
echo "Feche e reabra seu terminal (ou saia e entre na sessão) para usar o Zsh."
