# guataOS — a distro base

Distribuição brasileira baseada em **Debian 13 / GNOME**, construída com **live-build**
(ISO híbrida BIOS+UEFI). É o chão onde as funções de servidor rodam.

## Build
- `distro/guataos/build-iso-hybrid.sh` — gera a ISO híbrida.
- `distro/guataos/config/` — configuração live-build: `package-lists/`, `hooks/`,
  `bootloaders/`, `includes.chroot/` (arquivos injetados na imagem: apps, wallpapers,
  greeter, temas). **Binários compilados (.so) são excluídos do git** — regeneráveis.
- `distro/guataos/VERSION` — versão corrente.

## Atualizações (OTA)
`distro/guataos/publicar-update.sh` publica pacotes de atualização pelo **mesmo repo APT**
assinado. O app "Atualizações" do guataOS consome esse repo.

## Identidade
Dock transparente, "GUATÁ Ajustes", ArtCraft, login glassmorphism (LightDM + web-greeter),
wallpapers de biomas brasileiros. Marca em `brand/`.

## Relação com o ecossistema
`apt install guata-server` transforma o guataOS desktop em **"Guatá Server OS"**, de onde
se adicionam as funções (AD, Files, Firewall, DHCP).
