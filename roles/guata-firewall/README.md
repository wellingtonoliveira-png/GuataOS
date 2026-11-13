# Guatá Firewall (guata-firewall) — em construção

Firewall fácil sobre **nftables**, no padrão visual do Guatá. **Só anotado por ora** —
construir depois de Files e DHCP.

## Já esboçado
`usr/local/sbin/guata-firewall-regen` (Python): lê `/etc/guata-firewall/regras.json` e
**gera** o ruleset `table inet guata` (política entrada=drop, established/related aceito,
portas por serviço, DNAT+masquerade para encaminhamentos), aplica com `nft -f`.
Subcomando `dump` imprime o ruleset gerado — transparência "Ver comando".

## Falta
Backend web (porta 8081) + painel (Portas / Encaminhamentos / Registros) + configurador
(perfil Servidor/Estação/Personalizado) + pacote + loja Ocara. Assets em `brand/firewall/`.
