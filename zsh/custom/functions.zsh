# ---------------------------------------------------------------------
# Função para fazer backup (add, commit, push) de todas as
# alterações na pasta ~/dotfiles/zsh/
# ---------------------------------------------------------------------
backup_zsh() {
    # Define o diretório raiz do repositório
    local REPO_DIR=~/dotfiles
    # Define o diretório específico do Zsh para backup
    local ZSH_DIR=~/dotfiles/zsh
    
    echo "Iniciando backup dos arquivos de configuração Zsh..."
    
    # 1. Adiciona ao 'stage' apenas as alterações na pasta zsh/
    echo "-> Adicionando alterações ao stage..."
    git -C "$REPO_DIR" add "$ZSH_DIR"
    
    # 2. Verifica se há alterações no 'stage' *apenas* para o caminho zsh/
    # O '-- $ZSH_DIR' no final é crucial
    if ! git -C "$REPO_DIR" diff --quiet --staged -- "$ZSH_DIR"; then
        echo "-> Novas alterações encontradas. Fazendo commit..."
        
        # Pede uma mensagem de commit
        local commit_message
        echo "Digite a mensagem do commit (ex: 'Atualizar aliases Zsh'):"
        read -p "> " commit_message

        # Se a mensagem estiver vazia, usa uma padrão
        if [ -z "$commit_message" ]; then
            commit_message="Atualizar arquivos de configuração Zsh"
        fi
        
        git -C "$REPO_DIR" commit -m "$commit_message"
        
        echo "-> Enviando para o repositório..."
        git -C "$REPO_DIR" push
    else
        echo "-> Nenhuma alteração nos arquivos Zsh. Nada para enviar."
    fi
    
    echo "Backup Zsh concluído!"
}

# ---------------------------------------------------------------------
# Função para fazer backup de configurações dconf (GNOME)
# Aceita argumentos:
#   keys: Salva apenas os atalhos de teclado
#   exts: Salva apenas as configurações das extensões
#   all:  Salva ambos
# ---------------------------------------------------------------------
backup_dconf() {
    # Define o subdiretório para os backups do dconf
    local DOTFILES_DIR=~/dotfiles/gnome-dconf
    local argument="$1"

    # Garante que o diretório de destino exista
    mkdir -p "$DOTFILES_DIR"

    # --- Funções Internas ---
    # (Elas só existem dentro de 'backup_dconf')

    # Função para fazer backup dos atalhos
    _backup_dconf_keys() {
        echo "-> Fazendo backup dos Atalhos de Teclado..."
        dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > "$DOTFILES_DIR/gnome-keybindings-media.dconf"
        dconf dump /org/gnome/desktop/wm/keybindings/ > "$DOTFILES_DIR/gnome-keybindings-wm.dconf"
        dconf dump /org/gnome/shell/keybindings/ > "$DOTFILES_DIR/gnome-keybindings-shell.dconf"
        
        # O -C $DOTFILES_DIR/.. aponta para a raiz do repositório (~/dotfiles)
        git -C "$DOTFILES_DIR/.." add "$DOTFILES_DIR/gnome-keybindings-media.dconf" \
                                     "$DOTFILES_DIR/gnome-keybindings-wm.dconf" \
                                     "$DOTFILES_DIR/gnome-keybindings-shell.dconf"
    }

    # Função para fazer backup das extensões
    _backup_dconf_exts() {
        echo "-> Fazendo backup das Extensões..."
        dconf dump /org/gnome/shell/extensions/ > "$DOTFILES_DIR/gnome-extensions-settings.dconf"
        
        git -C "$DOTFILES_DIR/.." add "$DOTFILES_DIR/gnome-extensions-settings.dconf"
    }

    # Função para fazer o commit e push (apenas se houver mudanças)
    _git_commit_push() {
        local commit_message="$1"
        
        # O -C $DOTFILES_DIR/.. aponta para a raiz do repositório (~/dotfiles)
        if ! git -C "$DOTFILES_DIR/.." diff --quiet --staged; then
            echo "-> Novas alterações encontradas. Fazendo commit..."
            git -C "$DOTFILES_DIR/.." commit -m "$commit_message"
            
            echo "-> Enviando para o repositório..."
            git -C "$DOTFILES_DIR/.." push
        else
            echo "-> Nenhuma alteração nas configurações do dconf. Nada para enviar."
        fi
    }
    # --- Fim das Funções Internas ---


    # --- Lógica Principal ---
    echo "Iniciando backup do dconf para $DOTFILES_DIR"

    if [ -z "$argument" ]; then
        echo "ERRO: Nenhum argumento fornecido."
        echo "Uso: backup_dconf [keys | exts | all]"
        return 1 # Retorna um erro
    fi

    case "$argument" in
        keys)
            _backup_dconf_keys
            # MENSAGEM ATUALIZADA
            _git_commit_push "Atualizar atalhos de teclado (GNOME)"
            ;;
        exts)
            _backup_dconf_exts
            # MENSAGEM ATUALIZADA
            _git_commit_push "Atualizar configurações de extensões (GNOME)"
            ;;
        all)
            _backup_dconf_keys
            _backup_dconf_exts
            # MENSAGEM ATUALIZADA
            _git_commit_push "Atualizar configurações dconf (GNOME)"
            ;;
        *)
            echo "ERRO: Argumento '$argument' inválido."
            echo "Uso: backup_dconf [keys | exts | all]"
            return 1 # Retorna um erro
            ;;
    esac

    echo "Backup do dconf concluído!"
}
