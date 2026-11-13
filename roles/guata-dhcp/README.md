# Guatá DHCP (guata-dhcp) — BETA · v1.0.0

Servidor DHCP soberano sobre **Kea** (o isc-dhcp-server saiu do Debian 13). Painel web
idêntico ao AD/Files (porta **8082, HTTPS**), com o mesmo endurecimento de segurança.

## Funções
- **Configurador**: detecta a placa de rede, auto-preenche a faixa pelo IP, cria o 1º escopo.
- **Escopos** (CRUD): rede/máscara, faixa (pool), gateway, DNS, lease, domínio — por sub-rede.
- **Concessões (leases)** ao vivo: IP, MAC, nome, expiração — de `kea-leases4.csv`; "Reservar" direto.
- **Reservas** (IP fixo por MAC): CRUD, validação de MAC/IP.
- **DDNS**: registra os hosts no **DNS do Guatá AD** (A record, via conta de máquina, no DC).

## Motor / arquivos
`guata-dhcp-web` (Python, 8082, TLS) · `guata-dhcp-regen` (gera `/etc/kea/kea-dhcp4.conf`,
valida com `kea-dhcp4 -t`, reinicia Kea) · `guata-dhcp-ddns-sync` (leases → `samba-tool dns`).
Registro em `/etc/guata-dhcp/config.json`. Segurança: igual Files 1.9.0.
