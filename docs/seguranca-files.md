# Análise de Segurança — Guatá Files

> Auditoria do painel e serviços do Guatá Files (backend `guata-files-web`, scripts
> `guata-files-*`, geração de `smb.conf`/ACLs, configurador). Pedido do Wellington:
> "arquivo é sério, não pode vazar, tem que estar seguro." **Resultado aplicado na v1.9.0.**

## Metodologia
Leitura linha a linha do backend e dos helpers privilegiados; análise de autenticação,
autorização, injeção (shell/fstab/smb.conf), vazamento de credenciais, exposição de rede
e armazenamento de segredos. Correções testadas (unitário + servidor HTTPS ao vivo).

## Achados corrigidos na v1.9.0

| # | Severidade | Achado | Correção |
|---|---|---|---|
| 1 | **ALTA** | Painel em **HTTP** texto puro em `0.0.0.0:8080` — senha do admin e do AD trafegam em claro, sniffáveis na LAN | **TLS self-signed** gerado no `postinst` (RSA 2048, SAN host+localhost+127.0.0.1), TLS ≥1.2; cookie ganha flag **Secure** |
| 2 | **ALTA** | Modo simples: **"primeira senha vence"** — quem logasse primeiro na rede virava admin | Definição da senha inicial **só via localhost** (console/SSH); senha mínima de 6 chars |
| 3 | **ALTA** | Senha do AD exposta no **`ps`** (`net ads join -U admin%senha`) | Senha enviada por **stdin** (`printf | net ads join -U admin`) |
| 4 | **MÉDIA** | **Força-bruta** no login sem limite (modo simples não trava) | **Rate-limit por IP**: 5 falhas → bloqueio progressivo (até 5 min) |
| 5 | **MÉDIA** | `/api/configurar` **pré-autenticação** acionável por qualquer um na LAN (sequestro do 1º setup) | Gate de **localhost** para a configuração inicial |
| 6 | **MÉDIA** | Trustee (grupo/usuário) sem validação → risco de injeção em `smb.conf`/registro | Validação estrita `^[A-Za-z0-9 ._@\-]{1,64}$` |
| 7 | **MÉDIA** | Injeção de linha no `/etc/fstab` pelo caminho do NAS (corrigido antes, v1.8.1/1.8.2) | Regex de string inteira (`bash [[ =~ ]]`) + rejeição de controle |
| 8 | **BAIXA** | Hash da senha do painel em **sha256 sem sal** | **PBKDF2-HMAC-SHA256** (120k iterações, sal); migra o hash legado no próximo login |
| 9 | **BAIXA** | Sem cabeçalhos anti-clickjacking / cache de API | `X-Frame-Options: DENY`, CSP `frame-ancestors 'none'`, `Referrer-Policy`, `Cache-Control: no-store` nas APIs |
| 10 | **BAIXA** | `/etc/guata-files` e `guata-files.log` com permissão frouxa | `chmod 700` no diretório, `600` no log (pode conter host/nomes) |

## Já estava correto (boas práticas presentes)
- Sessão por cookie **HttpOnly + SameSite=Strict**, token de 128 bits (`secrets`).
- Autenticação **real**: `kinit`/Kerberos no modo domínio (respeita bloqueio do AD).
- Toda rota de API (exceto sessão/estado/configurar pré-setup) exige token válido.
- `/assets/` com `os.path.normpath` + verificação de prefixo (sem path traversal).
- Nomes de compartilhamento sanitizados (`_san`); restauração de snapshot **não-destrutiva**
  e `snap` validado por regex `@GMT-...`; `.snapshots` com `veto files`.
- Helpers privilegiados chamados via **argv** (lista), sem `shell=True` (sem shell injection).

## Riscos residuais e recomendações (roadmap)
- **Certificado self-signed**: cifra o tráfego, mas o navegador avisa. *Recomendado:* emitir
  o cert pela CA interna do domínio (quando houver) ou importar o cert raiz nos clientes.
  Com cert confiável, ligar **HSTS**.
- **Bind `0.0.0.0`**: o painel fica em todas as interfaces. *Recomendado:* restringir por
  firewall à rede de administração, ou acessar via túnel SSH e manter só localhost.
  (Aqui entra bem o futuro **Guatá Firewall**.)
- **Serviço roda como root** (necessário p/ Samba/ACL/mount) → um RCE no painel = root.
  Mitigado por auth forte; manter superfície mínima e pacote atualizado.
- **Credenciais CIFS do NAS** em texto no arquivo `.cred-*` (`600`) — exigência do
  `mount.cifs`; mantido restrito a root.
- **Modo simples** é mais fraco que o modo domínio (sem política de bloqueio central);
  preferir o modo integrado ao Guatá AD em produção.

## Veredito
Na v1.9.0 os vetores de **vazamento de senha na rede** (o mais crítico para "não pode
vazar") e de **sequestro do primeiro acesso** estão fechados, com força-bruta contida e
tráfego cifrado. Os riscos residuais são de **hardening de implantação** (cert confiável,
firewall), não falhas de código.
