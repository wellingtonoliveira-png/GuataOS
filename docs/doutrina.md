# Doutrina do produto Guatá

Princípios inegociáveis. Valem para toda função do ecossistema.

## 1. Não esconde, traduz
Toda ação tem tradução humana **e** evidência técnica. O painel mostra "Criar usuário",
mas também oferece **"Ver detalhes técnicos"** com o comando real (`samba-tool …`,
`nft …`, `setfacl …`). O administrador nunca é cego — o Guatá é a camada fácil por cima
do motor real, não uma caixa-preta.

## 2. Nunca inventar
Não fingimos funcionalidade que o motor não entrega. Quando algo não é nativo, dizemos
a verdade e oferecemos o caminho honesto. Exemplos recusados de propósito:
- **RSOP / Laudo LGPD com ICP-Brasil/PAdES/HSM** — Samba não tem motor RSOP nem assinatura
  ICP-Brasil nativa → fazemos o **relatório de conformidade honesto** no lugar.
- **Central de Certificados (CA)** — é um produto de PKI de verdade (step-ca/openssl), não fakeável.
- **MFA/TOTP, estado de ticket Kerberos em tempo real** — Samba não entrega nativamente.
- **2º controlador + replicação DRS** — a matriz aparece sozinha quando o 2º DC for promovido.

Fingir isso queima numa auditoria real. A confiança vale mais que a tela bonita.

## 3. Nenhum botão cosmético
Todo botão faz algo real. Se não faz, não existe.

## 4. Zero emoji
Nenhum emoji em qualquer app — nem ✓/✕. Só **ícones SVG premium**. Identidade visual séria.

## 5. Cara Guatá
Todos os apps compartilham a mesma identidade: sidebar navy, cards, tipografia, barra de
disco, e os **mascotes capivara** no configurador. O CSS do Guatá ID é a fonte — Files e
Firewall reaproveitam o mesmo `<style>`.

## 6. Segurança e LGPD por concepção
Sessões HttpOnly/SameSite, autenticação real (kinit/Kerberos ou hash local no bootstrap),
nada de credencial em claro, princípio do menor privilégio. Pensado desde o desenho.

## 7. AD = tarefas humanas
No Guatá ID, o diretório é organizado por **Pessoas** e **jornadas** (admissão, troca de
setor, desligamento), não por jargão de LDAP. A técnica existe embaixo, a linguagem é humana.

## 8. Multi-dispositivo e multilíngue
Telas respondem em larguras reais. Interface em pt-BR (e espanhol no roadmap).

## 9. Backup sempre separado
O BackupOS é **appliance isolado** — se o servidor cair ou for sequestrado, o backup
sobrevive. Por isso **não** vira uma role do mesmo servidor.
