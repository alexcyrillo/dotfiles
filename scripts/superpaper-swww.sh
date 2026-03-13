#!/bin/bash
# Local: /home/alex/superpaper-swww.sh

IMAGE=$1

# Garante que o daemon está rodando
swww query || swww-daemon & sleep 1

# Divide a imagem exatamente em 2 partes
magick "$IMAGE" -crop 2x1@ +repage "/home/alex/Imagens/[03] wallpaper/.crop_wpp/sp_part.jpg"

# Aplica especificamente em cada monitor identificado no seu log
swww img -o DP-2 "/home/alex/Imagens/[03] wallpaper/.crop_wpp/sp_part-0.jpg"
swww img -o DP-3 "/home/alex/Imagens/[03] wallpaper/.crop_wpp/sp_part-1.jpg"
