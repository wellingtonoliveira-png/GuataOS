# Guatá Server (guata-server) — BETA · v1.1.0

A "casca" que transforma o guataOS em servidor de funções.

- `usr/local/bin/guata-server` — abre o menu.
- `usr/local/sbin/guata-server-funcoes` — menu whiptail "Funções do servidor": mostra
  estado (ativo/instalado/disponível/em breve) e "Adicionar função" = `apt-get install <pkg>`
  + abre o configurador. Roles: ad, files, (firewall, dhcp, print — futuras).

`sudo apt install guata-server && sudo guata-server`.
