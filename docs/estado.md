# Estado vivo do ecossistema (handoff)

> Atualize este arquivo a cada avanço. É o "handoff" que sobrevive à perda de contexto.
> **Data:** 2026-11-08.

## Versões no ar
| Pacote | Versão | Observação |
|---|---|---|
| guata-id | 1.44.0 | AD completo; GPO via ldb local; Saúde dedup DC; inventário+QR |
| guata-ad | 1.2.0 | provisionamento Samba AD DC |
| guata-files | **1.9.1** | Files COMPLETO + ENDURECIDO: TLS, rate-limit, localhost-gate, PBKDF2 (ver seguranca-files.md) |
| guata-dhcp | **1.0.1** | DHCP: escopos, leases, reservas MAC, DDNS (Kea, HTTPS, endurecido) |
| guata-desktop | 0.18.55 | Ocara: categoria Servidores (AD/Files/DHCP) |
| guata-server | 1.2.0 | menu "Adicionar função" (+role DHCP) |
| guata-backupos | 1.1 (ISO) | appliance isolado |
| guataOS | 0.27 | distro base |

## Guatá Files — COMPLETO (v1.8.0)
- [x] Painel + configurador (igual AD), compartilhamentos, níveis (Grupo/Usuário/Todos ×
      Leitura/Edição/Total), camadas (tiers), snapshots, **Proteção ClamAV (v1.7.0)**
- [x] **Multi-origem** (disco local / outro disco / **partição Windows NTFS via ntfs-3g** /
      exFAT/FAT / **NAS CIFS**): aba Armazenamento, lsblk, montar+persistir fstab, barra de
      capacidade, origem por compartilhamento. Honesto: NTFS/NAS = acesso por share (sem tiers finos).
- [x] **Auditoria de arquivos** (vfs_full_audit → rsyslog): liga por pasta, feed de quem
      abriu/gravou/renomeou/apagou com usuário, IP e hora.
- [ ] (futuro) Backup nativo → conecta no Guatá BackupOS · ISO/rebuild + loja Ocara

## Guatá DHCP — COMPLETO (v1.0.0)
- [x] Configurador (detecta placa, auto-preenche faixa) + escopos CRUD (Kea)
- [x] Concessões (leases) ao vivo · [x] Reservas (IP fixo por MAC)
- [x] DDNS → A no DNS do Samba (via conta de máquina, no DC) · [x] pacote + role no guata-server
- Mesmo endurecimento de segurança do Files (TLS, rate-limit, localhost-gate, PBKDF2).

## Guatá Firewall — função futura (SÓ anotar por ora)
Motor **já esboçado**: `roles/guata-firewall/pkg/guata-firewall/usr/local/sbin/guata-firewall-regen`
(gera nftables a partir de regras.json; subcomando `dump`). Falta: backend web + painel +
configurador + pacote. Assets em `brand/firewall/`. **Ordem:** só depois de Files e DHCP.

## Regras do Wellington ativas
- Terminar a lista de uma função antes de pular pra outra (Files → DHCP → …).
- **Tudo BETA** + termos de isenção (ver termos-e-beta.md).
- Zero emoji; não esconde, traduz; nunca inventar; backup sempre separado.
- Lista Mestre (artifact) atualizada a cada versão:
  https://claude.ai/code/artifact/d578cc57-0d0a-46a6-9f48-1ecc502bef82

## Loja Ocara + lançadores de menu (08/11) — FEITO
- Ocara (guata-desktop 0.18.55): categoria **Servidores** com AD/Files/DHCP (instala 1 clique,
  apt do repo), Firewall e Impressão como **em breve**. "Abrir" lança o painel web (onde aparece
  o configurador). Ícones Material Symbols (dns/folder_shared/router/fire/print).
- Cada pacote (guata-id 1.44, files 1.9.1, dhcp 1.0.1) ganhou **lançador no menu** com o **ícone da
  marca** (256px em hicolor) que abre o painel: AD http://localhost, Files https://localhost:8080,
  DHCP https://localhost:8082. postinst atualiza desktop-database + icon-cache.

## PENDENTE DE SEGURANÇA (importante)
- **guata-id (painel AD) ainda é HTTP** em 0.0.0.0:80 — mesma classe que corrigi no Files, e o AD
  guarda o dado MAIS sensível (todo o domínio). Aplicar o mesmo endurecimento (TLS, rate-limit,
  localhost-gate, PBKDF2) no guata-id-web. Recomendado fazer logo.
