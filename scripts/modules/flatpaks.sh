#!/bin/bash

apps=(
    "org.mozilla.firefox"
    "com.spotify.Client"
    "com.valvesoftware.Steam"
    "io.github.Foldex.AdwSteamGtk"
    "com.github.tchx84.Flatseal"
    "org.onlyoffice.desktopeditors"
    "com.rtosta.zapzap"
    "com.discordapp.Discord"
    "io.github.dvlv.boxbuddyrs"
)

for app in "${apps[@]}"; do
    echo "Instalando: $app..."
    # Tenta instalar; se falhar, adiciona ao array de falhas
    flatpak install -y flathub "$app" || falhas+=("$app")
done

