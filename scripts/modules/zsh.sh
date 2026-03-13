#!/bin/bash

DOTFILES_DIR=~/dotfiles
CUSTOM_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
CUSTOM_THEMES_DIR="$HOME/.oh-my-zsh/custom/themes"

link_file() {
    local source_file="$DOTFILES_DIR/$1"
    local target_link="$HOME/$2"

    mkdir -p "$(dirname "$target_link")"

    if [ -e "$target_link" ] || [ -L "$target_link" ]; then
        echo "Fazendo backup de $target_link para $target_link.backup"
        mv "$target_link" "$target_link.backup"
    fi

    echo "Linkando $source_file -> $target_link"
    ln -s "$source_file" "$target_link"
}


if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "--- Instalando Oh My Zsh ---"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh já está instalado."
fi


echo "--- Instalando plugins e temas do Oh My Zsh ---"

# (Seus blocos de git clone de plugins continuam aqui...)
if [ ! -d "$CUSTOM_PLUGINS_DIR/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$CUSTOM_PLUGINS_DIR/zsh-autosuggestions"
fi

if [ ! -d "$CUSTOM_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$CUSTOM_PLUGINS_DIR/zsh-syntax-highlighting"
fi

if [ ! -d "$CUSTOM_PLUGINS_DIR/zsh-you-should-use" ]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$CUSTOM_PLUGINS_DIR/zsh-you-should-use"
fi

if [ ! -d "$CUSTOM_THEMES_DIR/spaceship-prompt" ]; then
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$CUSTOM_THEMES_DIR/spaceship-prompt" --depth=1
    
    # Cria o link simbólico para o Oh My Zsh reconhecer o tema
    ln -s "$CUSTOM_THEMES_DIR/spaceship-prompt/spaceship.zsh-theme" "$CUSTOM_THEMES_DIR/spaceship.zsh-theme"
fi

echo "--- Criando links simbolicos ---"
link_file "zsh/zshrc" ".zshrc"

echo "Linkando arquivos .zsh personalizados..."
for item in $DOTFILES_DIR/zsh/custom/*; do
    if [ -e "$item" ]; then
        item_name=$(basename "$item")
        link_file "zsh/custom/$item_name" ".oh-my-zsh/custom/$item_name"
    fi
done

sudo chsh -s $(which zsh) $USER

echo "--- Zsh configurado com sucesso! ---"

exec zsh
