# guata-ad — provisionamento do domínio (BETA)

Prepara o servidor como **Samba Active Directory Domain Controller**: pacotes, `smb.conf`,
Kerberos, DNS interno, provisionamento do domínio. É a base que o **Guatá ID** administra.

Deixa `/etc/guata-ad/provisionado` — é o marcador que o Guatá Files lê para oferecer o
modo "mesmo servidor". Árvore: `pkg/guata-ad/`.
