# Guatá Server — Ecossistema Soberano

> **BETA.** Software em evolução, fornecido *no estado em que se encontra*. Leia os
> [Termos de Uso e Isenção de Responsabilidade](docs/termos-e-beta.md) antes de usar em produção.

Um servidor base (Debian 13 / guataOS) que ganha **funções (roles)** instaláveis — igual
Windows Server, só que soberano, em português e open-source por baixo. Cada função é um
pacote `.deb` assinado com um **painel web no mesmo padrão visual** e um assistente de
configuração guiado por mascotes.

A tese: **um motor open-source poderoso, vestido de fácil, lindo e soberano.**
O Samba, o nftables, o CUPS já existem e são potentes — o Guatá os veste de produto.

---

## As funções (roles)

| Função | Pacote | Motor por baixo | O que faz | Versão | Estado |
|---|---|---|---|---|---|
| **Guatá ID** (AD) | `guata-id` / `guata-ad` | Samba AD DC | Active Directory: pessoas, grupos, máquinas, GPO, DNS, auditoria | 1.43 / 1.2 | BETA — no ar |
| **Guatá Files** | `guata-files` | Samba + VFS | Servidor de arquivos: compartilhamentos, tiers, snapshots anti-ransomware, ClamAV | 1.7.0 | BETA — no ar |
| **Guatá Firewall** | `guata-firewall` | nftables | Portas por serviço, encaminhamentos (NAT), registros | esboço | em construção |
| **Guatá DHCP** | `guata-dhcp` | Kea / isc-dhcp | Escopos, leases, reservas MAC, DDNS → DNS do Samba | roadmap | fila |
| **Guatá Server** | `guata-server` | — | Menu "Adicionar função" que instala as roles acima | 1.1.0 | BETA — no ar |
| **Guatá Print** | `guata-print` | CUPS | Servidor de impressão: bilhetagem, cotas por usuário, relatórios de custo | 1.0 | BETA — no ar |
| **Guatá BOTO** | `guata-boto` | psql / sqlcmd | Sonar de banco de dados: sessões, bloqueios e queries lentas numa leitura só (PostgreSQL e SQL Server) | 1.1.0 | BETA — no ar |
| **Guatá BackupOS** | (appliance ISO) | PBS / restic | Backup isolado (NÃO é role — appliance separado por segurança) | 1.1 | BETA |

> **Em evolução:** Firewall em construção; MySQL/MariaDB chegando ao BOTO. Contribuições são bem-vindas.

---

## Como o usuário instala

No **Debian / guataOS**:
```bash
sudo apt install guata-server      # traz o menu de funções
sudo guata-server                  # "Adicionar função": AD / Arquivos / Banco (BOTO)...
```

No **Oracle Linux 9 / RHEL** (via repositório `el9`, painel web):
```bash
sudo dnf config-manager --add-repo https://guataos.com.br/el9/guata.repo
sudo dnf install guata-server
guata-server-token                 # mostra a URL do painel + o token de acesso
```

Cada função abre seu **configurador web** (assistente) ao instalar. Tudo também aparece
na **loja Ocara** do guataOS — instalar uma função pela loja transforma o desktop em
"Guatá Server OS".

## Entrega (resumo)

Pacotes `.deb` assinados num **repositório APT próprio** (Debian/guataOS) e pacotes
`.rpm` num repositório **el9** (Oracle Linux / RHEL). O cliente adiciona o repositório
e instala com `apt` ou `dnf`.

---

## Mapa do repositório

```
guata-ecosystem/
├── README.md               ← você está aqui
├── docs/
│   ├── doutrina.md         ← os princípios inegociáveis do produto
│   ├── arquitetura.md      ← modelo de roles, repo APT, AD+Files no mesmo servidor
│   ├── termos-e-beta.md    ← isenção de responsabilidade + rótulo BETA
│   ├── estado.md           ← estado vivo (versões, o que falta) — handoff
│   └── seguranca-files.md  ← análise de segurança do Files (achados + correções)
├── roles/
│   ├── guata-id/ guata-ad/ guata-files/ guata-dhcp/ guata-print/ guata-server/ guata-boto/
│   │   └── pkg/<pacote>/    ← árvore .deb (DEBIAN/, usr/, lib/, etc/)
│   └── */README.md         ← ficha de cada função
├── brand/                  ← logos e mascotes por função
└── site-servidores/        ← página pública /servidores do site Guatá
```

> Este repositório é o **espelho público versionado + documentação** do ecossistema Guatá.

---

## Doutrina em uma linha

**O Guatá não esconde, traduz.** Nenhum botão cosmético, nunca inventar funcionalidade
que não existe de verdade, zero emoji (só SVG premium), segurança e LGPD por concepção.
Detalhes em [docs/doutrina.md](docs/doutrina.md).

---

*Feito com carinho pela equipe · **Wellsystem** · todo sistema é produto Wellsystem.*
