#!/bin/bash
# GUATÁ — reparo de boot. Funciona de dois jeitos:
#   • rodando DENTRO do sistema instalado  -> conserta a si mesmo (sem live)
#   • rodando no LIVE USB                  -> acha a instalação no disco e conserta
# Corrige o EFI (stub por UUID, nunca o memdisk) e grava um /boot/grub/grub.cfg válido.
set -e
if [ "$(id -u)" != "0" ]; then echo "rode com sudo"; exit 1; fi

MODS="part_gpt part_msdos fat ext2 normal search search_fs_file search_fs_uuid search_label configfile boot linux echo all_video gfxterm font test"
EFI_GUID="c12a7328-f81f-11d2-ba4b-00a0c93ec93b"

# escreve grub.cfg + EFI para um sistema montado em $1 (raiz) com ESP em $1/boot/efi
aplicar() {
  local R="$1" RU KV ESP DISK PN
  RU=$(findmnt -no UUID "$R" 2>/dev/null)
  [ -z "$RU" ] && RU=$(blkid -s UUID -o value "$(findmnt -no SOURCE "$R" 2>/dev/null)" 2>/dev/null)
  KV=$(ls -1 "$R"/boot/vmlinuz-* 2>/dev/null | sed 's#.*/vmlinuz-##' | sort -V | tail -1)
  [ -z "$RU" ] && { echo "✗ não achei a UUID da raiz"; exit 1; }
  [ -z "$KV" ] && { echo "✗ não achei o kernel em $R/boot"; exit 1; }
  echo "  UUID raiz: $RU"
  echo "  Kernel:    $KV"

  # grub.cfg mínimo (sem probing; à prova de NVMe)
  mkdir -p "$R/boot/grub"
  printf 'set timeout=5\nset default=0\nmenuentry "Guatá OS" {\n  search --no-floppy --fs-uuid --set=root %s\n  linux /boot/vmlinuz-%s root=UUID=%s ro quiet splash\n  initrd /boot/initrd.img-%s\n}\n' \
    "$RU" "$KV" "$RU" "$KV" > "$R/boot/grub/grub.cfg"

  # EFI stub: acha por UUID e, se faltar grub.cfg, boota direto
  ESP="$R/boot/efi"
  mkdir -p "$ESP/EFI/guataOS" "$ESP/EFI/BOOT"
  printf 'search --no-floppy --fs-uuid --set=root %s\nif [ -f ($root)/boot/grub/grub.cfg ]; then\n  configfile ($root)/boot/grub/grub.cfg\nelse\n  linux ($root)/boot/vmlinuz-%s root=UUID=%s ro quiet splash\n  initrd ($root)/boot/initrd.img-%s\n  boot\nfi\n' \
    "$RU" "$KV" "$RU" "$KV" > /tmp/g_stub.cfg
  grub-mkstandalone -O x86_64-efi --modules="$MODS" \
    -o "$ESP/EFI/guataOS/grubx64.efi" "boot/grub/grub.cfg=/tmp/g_stub.cfg"
  cp "$ESP/EFI/guataOS/grubx64.efi" "$ESP/EFI/BOOT/BOOTX64.EFI"
  rm -f /tmp/g_stub.cfg

  # NVRAM (best-effort; o EFI/BOOT/BOOTX64.EFI já é fallback universal)
  if command -v efibootmgr >/dev/null 2>&1; then
    local SRC; SRC=$(findmnt -no SOURCE "$ESP" 2>/dev/null)
    [ -n "$SRC" ] && DISK="/dev/$(lsblk -no PKNAME "$SRC" | head -1)" && PN=$(echo "$SRC" | grep -oE '[0-9]+$') \
      && efibootmgr -c -d "$DISK" -p "$PN" -L "guataOS" -l '\EFI\guataOS\grubx64.efi' 2>/dev/null || true
  fi
  sync
}

FSROOT=$(findmnt -no FSTYPE / 2>/dev/null)
if echo "$FSROOT" | grep -qE 'overlay|squashfs|aufs|tmpfs'; then
  # ---------- LIVE: acha a instalação no disco ----------
  echo "== modo LIVE: procurando a instalação no disco =="
  G=/mnt/guata-root; mkdir -p "$G"; ROOTP=""
  for p in $(lsblk -lnpo NAME,FSTYPE | awk '$2=="ext4"{print $1}'); do
    umount "$G" 2>/dev/null || true
    mount "$p" "$G" 2>/dev/null || continue
    if ls "$G"/boot/vmlinuz-* >/dev/null 2>&1 && [ -f "$G/etc/os-release" ]; then ROOTP="$p"; break; fi
    umount "$G" 2>/dev/null || true
  done
  [ -z "$ROOTP" ] && { echo "✗ não achei o guataOS instalado"; exit 1; }
  echo "  Raiz: $ROOTP"
  ESP=$(lsblk -lnpo NAME,PARTTYPE | awk -v g="$EFI_GUID" 'tolower($2)==g{print $1}' | head -1)
  [ -z "$ESP" ] && ESP=$(lsblk -lnpo NAME,FSTYPE | awk '$2=="vfat"{print $1}' | head -1)
  mkdir -p "$G/boot/efi"; mountpoint -q "$G/boot/efi" || mount "$ESP" "$G/boot/efi"
  aplicar "$G"
else
  # ---------- INSTALADO: conserta a si mesmo ----------
  echo "== modo INSTALADO: consertando este sistema =="
  if ! mountpoint -q /boot/efi; then
    ESP=$(lsblk -lnpo NAME,PARTTYPE | awk -v g="$EFI_GUID" 'tolower($2)==g{print $1}' | head -1)
    [ -z "$ESP" ] && ESP=$(lsblk -lnpo NAME,FSTYPE | awk '$2=="vfat"{print $1}' | head -1)
    mkdir -p /boot/efi; mount "$ESP" /boot/efi
  fi
  aplicar "/"
fi

echo ""
echo "════════════════════════════════════════════"
echo "  ✓ PRONTO! Tire o pendrive (se tiver) e reinicie."
echo "    O guataOS vai bootar sozinho agora. 🥾"
echo "════════════════════════════════════════════"
