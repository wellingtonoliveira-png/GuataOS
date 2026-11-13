# Guatá ID (guata-id / guata-ad) — BETA

Active Directory soberano sobre **Samba AD DC**, com painel web de linguagem humana.

- **Pacotes:** `guata-ad` (provisiona o domínio) · `guata-id` (painel, v1.43)
- **Painel:** porta 80. Diretório por **Pessoas** + **Jornadas** (admissão, troca de setor,
  desligamento), Grupos, Máquinas, GPO, DNS, Auditoria, Saúde, Inventário nativo + QR.
- **Doutrina:** toda tela tem "Ver detalhes técnicos" com o `samba-tool` real.
- **Honesto-bloqueado:** RSOP, CA/PKI, MFA/TOTP, 2º DC — ver docs/doutrina.md.
- **GPO:** usa `samba-tool ... -H /var/lib/samba/private/sam.ldb` (ldb local, sem rede) para
  não travar em SYSVOL por hostname.

Árvore do pacote: `pkg/guata-id/` (DEBIAN, usr/local/sbin backend, usr/share web, etc.).
