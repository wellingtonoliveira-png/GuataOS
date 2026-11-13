#!/bin/bash
# uso: processa-som.sh <entrada> <saida.oga> [fade_in] [fade_out]
IN="$1"; OUT="$2"; FI="${3:-0.06}"; FO="${4:-0.45}"
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$IN")
FOS=$(awk -v d="$DUR" -v f="$FO" 'BEGIN{printf "%.2f", d-f}')
MAX=$(ffmpeg -i "$IN" -af volumedetect -f null /dev/null 2>&1 | awk -F': ' '/max_volume/{gsub(/ dB/,"",$2);print $2}')
GAIN=$(awk -v m="$MAX" 'BEGIN{printf "%.1f", -10 - m}')
ffmpeg -y -i "$IN" -af "volume=${GAIN}dB,afade=t=in:st=0:d=${FI},afade=t=out:st=${FOS}:d=${FO}" \
  -c:a libvorbis -q:a 5 "$OUT" >/dev/null 2>&1
NMAX=$(ffmpeg -i "$OUT" -af volumedetect -f null /dev/null 2>&1 | awk -F': ' '/max_volume/{gsub(/ dB/,"",$2);print $2}')
echo "$(basename "$OUT"): dur=${DUR}s  pico_orig=${MAX}  ganho=${GAIN}dB  pico_final=${NMAX} dBFS"
