pacotes_dnf=(
    "git",
    "zsh",
    "curl",
    "flatpak"
)

for pkg in "${pacotes_dnf[@]}"; do
    sudo dnf install -y "$pkg" || echo "Falha ao instalar $pkg, pulando..."
done

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
