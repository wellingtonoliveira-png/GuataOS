# Guatá 🥾

**O Linux brasileiro continua caminhando.**

Distribuição Linux brasileira baseada em **Debian 13 (trixie)**, com área de trabalho
**GNOME** polida e a **Caixa de Ferramentas** (filosofia "clicar e usar") —
feita para o técnico de TI: um live USB de diagnóstico e resgate que anda no bolso.

*guatá* é um verbo **Guarani**: caminhar, andar, viajar. Um Linux brasileiro feito para
continuar a caminhada.

## Como montar a ISO
Numa máquina **Debian** (não dá pra montar no ambiente do assistente):
```bash
sudo ./build.sh
```
Precisa de internet e ~15 GB livres. No fim, grave a `.iso` num pen drive.

## Estrutura
- `auto/config` — descreve a imagem (Debian trixie, amd64, pt-BR).
- `config/package-lists/desktop.list.chroot` — GNOME + temas/extensões.
- `config/package-lists/tecnico.list.chroot` — a Caixa de Ferramentas.
- `config/hooks/` — branding e scripts (a chegar).
- `config/includes.chroot/` — arquivos injetados (wallpaper, tema, scripts) (a chegar).

## Próximos passos
- Branding: wallpaper, tema GNOME + ícones (visual estilo Deepin), Plymouth (boot), a capivara.
- Scripts "clicar e usar" da Caixa de Ferramentas em `/usr/local/bin`.
- Agente BEACON embutido (monitoramento mão única).
- Calamares (instalador) para a versão desktop.
