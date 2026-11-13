#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# GUATÁ — monta a ISO. RODE NUMA MÁQUINA DEBIAN, como root (sudo).
#   sudo ./build.sh
# Precisa de internet e ~15 GB livres. A ISO sai em guata-*.iso (binary.hybrid.iso).
# NÃO roda no ambiente do assistente — o build de ISO precisa de host Debian real.
# ─────────────────────────────────────────────────────────────────────────────
set -e
if [ "$(id -u)" != "0" ]; then echo "Rode como root: sudo ./build.sh"; exit 1; fi

echo "== Instalando o live-build (uma vez) =="
apt-get update
apt-get install -y live-build

echo "== Limpando build anterior =="
lb clean || true

echo "== Configurando (auto/config) =="
lb config

echo "== Construindo a ISO (demora; vai baixar pacotes) =="
lb build

echo
echo "Pronto. Procure o arquivo live-image-amd64.hybrid.iso — renomeie para guata.iso e grave num pen drive."
