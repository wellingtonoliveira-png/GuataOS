# Arquitetura

## Modelo de funções (roles)
Um servidor base **Debian 13 / guataOS**. O pacote `guata-server` instala um menu
(`guata-server-funcoes`, whiptail) que lista as funções e seu estado
(ativo / instalado / disponível / em breve). "Adicionar função" = `apt-get install <pkg>`
seguido da abertura do configurador daquela função.

```
guataOS (desktop)  ──apt install guata-server──►  "Guatá Server OS"
                                                   ├─ apt install guata-ad     (Guatá ID)
                                                   ├─ apt install guata-files  (Arquivos)
                                                   ├─ apt install guata-firewall
                                                   └─ apt install guata-dhcp
```

## Entrega: repositório APT assinado
Todos os pacotes vão para um **repo APT próprio** (`apt-ftparchive` + assinatura GPG),
publicado num servidor de distribuição. O cliente adiciona o repositório e instala com
`apt` (Debian/guataOS) ou `dnf` (Oracle Linux / RHEL, via repo `el9`).

## Painéis web
Cada função tem um backend Python 3 (stdlib `ThreadingHTTPServer`, SPA) servindo um
`index.html` único. Sessões por cookie (HttpOnly, SameSite=Strict). Portas:

| Função | Porta | Serviço systemd |
|---|---|---|
| Guatá ID | 80 | — |
| Guatá Files | 8080 | `guata-files-web` |
| Guatá Firewall | 8081 (previsto) | `guata-firewall-web` |

## AD + Files no MESMO servidor
`guata-files` detecta se a máquina **já é** o Guatá AD (checa
`/etc/guata-ad/provisionado` ou `smb.conf` com "active directory domain controller") e
oferece o modo **"mesmo" (MODO=dc)**:
- Não ingressa no domínio (a máquina **é** o domínio);
- Compartilha usando os grupos do próprio AD (`samba-tool group list`, referência `@"grupo"`);
- O `smbd` roda sob o `samba-ad-dc` (o `smbd.service` fica mascarado — correto num DC).

Caminho all-in-one: `apt install guata-ad` (provisiona) → `apt install guata-files` (modo "mesmo").

## Snapshots multi-filesystem (anti-ransomware)
`rsync --link-dest` (hardlinks — funciona em **qualquer** disco, inclusive ext4) +
`shadow_copy2` do Samba → o usuário vê "Versões Anteriores" no Windows. Restauração é
**não-destrutiva** (cria pasta "Restaurado em…").

## Firewall (motor)
`guata-firewall-regen` (Python) lê um registro `regras.json` e **gera** um ruleset
`nftables` (`table inet guata`) aplicado com `nft -f`. Política de entrada drop por padrão,
established/related aceito, portas liberadas por serviço, DNAT + masquerade para
encaminhamentos. Subcomando `dump` imprime o ruleset gerado (transparência "Ver comando").

## Pilha técnica por baixo
Samba AD DC, Samba file server (vfs acl_xattr, shadow_copy2), POSIX ACLs, winbind/kinit,
nftables, ClamAV, CUPS (print, roadmap), Kea/isc-dhcp (DHCP, roadmap). Tudo open-source.
