#!/usr/bin/env bash
# Converte um ícone do Copilot (squircle verde centrado em fundo preto, 1024px)
# num PNG 512 com cantos arredondados transparentes.
# uso: fazer-icone.sh <origem> <destino.png> [lado] [offx] [offy] [raio]
set -e
SRC="$1"; DEST="$2"
LADO="${3:-840}"; OX="${4:-92}"; OY="${5:-94}"; R="${6:-160}"
TMP=$(mktemp -d)
convert "$SRC" -crop ${LADO}x${LADO}+${OX}+${OY} +repage "$TMP/sq.png"
convert -size ${LADO}x${LADO} xc:black -fill white -draw "roundrectangle 0,0,$((LADO-1)),$((LADO-1)),$R,$R" "$TMP/m.png"
convert "$TMP/sq.png" "$TMP/m.png" -alpha off -compose CopyOpacity -composite -resize 512x512 PNG32:"$DEST"
rm -rf "$TMP"
echo "ok -> $DEST"
