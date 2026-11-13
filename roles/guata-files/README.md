# Guatá Files (guata-files) — BETA · v1.7.0

Servidor de arquivos sobre **Samba**, painel web idêntico ao Guatá ID (porta 8080).

## Funções
- **Configurador web** (wizard): entrar no domínio / tudo-junto-no-AD (modo "mesmo") / simples.
- **Compartilhamentos**: criar/listar/remover; caminho de rede e tamanho.
- **Níveis estilo Windows**: por pasta → **Grupo / Usuário / Todos** × **Leitura / Edição /
  Total (owner)**. Gera `valid/read/write/admin users` + ACLs POSIX (`setfacl`).
- **Camadas (tiers)**: Público → Interno → Confidencial → Restrito num clique.
- **Snapshots — voltar no tempo**: `rsync --link-dest` (qualquer FS) + `shadow_copy2`
  (Versões Anteriores no Windows); criar/agendar/restaurar não-destrutivo.
- **Proteção (ClamAV)**: varredura das pastas, quarentena, base de definições, última
  verificação, verificar agora / agendar diária (03h).

## Backend / scripts (usr/local/sbin)
`guata-files-web` (Python, porta 8080) · `guata-files-regen` (gera shares.conf + ACLs) ·
`guata-files-configurar-auto` (configurador não-interativo) · `guata-files-snapshot` ·
`guata-files-scan` (ClamAV → quarentena).

## Falta (ver docs/estado.md)
Multi-origem (local/NAS/NTFS/nuvens), auditoria de arquivos (vfs_full_audit), backup→BackupOS.
