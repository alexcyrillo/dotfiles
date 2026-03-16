#!/bin/bash

# 1. Defina a pasta onde estão suas imagens originais
SOURCE_FOLDER="/home/alex/Imagens/[03] wallpaper/32-9"

# 2. Define o caminho de saída (o mesmo que você enviou)
OUTPUT_PATH="/home/alex/Imagens/[03] wallpaper/sp_part.png"

# 3. Seleciona uma imagem aleatória (jpg, jpeg ou png)
IMAGE=$(find "$SOURCE_FOLDER" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | shuf -n 1)

# 4. Verifica se uma imagem foi encontrada antes de prosseguir
if [ -z "$IMAGE" ]; then
    echo "Nenhuma imagem encontrada em $SOURCE_FOLDER"
    exit 1
fi

# 5. Executa o corte
magick "$IMAGE" -crop 2x1@ +repage "$OUTPUT_PATH"
