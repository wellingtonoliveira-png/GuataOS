#!/bin/bash
# Monta a ISO guataOS com BIOS (isolinux) + UEFI (grub-efi) de verdade.
# Necessário porque o live-build antigo (genisoimage) NÃO faz UEFI.
# Pré: binary/ já construído pelo lb build; chroot com syslinux modules + grub-efi.
set -e
cd /home/soprema/guata
OUT="${1:-guataOS-0.6-amd64.iso}"
APPEND="boot=live components quiet splash username=tecnico hostname=guata locales=pt_BR.UTF-8 keyboard-layouts=br timezone=America/Sao_Paulo"

echo "── [0] /live/vmlinuz + initrd.img (kernel mais novo) + live.cfg BIOS ──"
KV=$(ls -1 binary/live/vmlinuz-* 2>/dev/null | sort -V | tail -1)
IV=$(ls -1 binary/live/initrd.img-* 2>/dev/null | sort -V | tail -1)
if [ -n "$KV" ] && [ -n "$IV" ]; then
  cp -f "$KV" binary/live/vmlinuz
  cp -f "$IV" binary/live/initrd.img
  echo "  usando: $(basename "$KV") / $(basename "$IV")"
else
  echo "  !! kernel versionado não encontrado em binary/live/"; exit 1
fi
cat > binary/isolinux/live.cfg <<LIVECFG
label live-amd64
	menu label ^GuataOS (Live)
	menu default
	kernel /live/vmlinuz
	append initrd=/live/initrd.img $APPEND
label live-amd64-failsafe
	menu label GuataOS (Live - modo seguro)
	kernel /live/vmlinuz
	append initrd=/live/initrd.img $APPEND nomodeset
LIVECFG
# auto-boot do live sem depender do vesamenu (falha em algumas BIOS/VM): default=label
sed -i -e 's/^default .*/default live-amd64/' -e 's/^prompt .*/prompt 0/' binary/isolinux/isolinux.cfg
grep -q '^default live-amd64' binary/isolinux/isolinux.cfg || echo "default live-amd64" >> binary/isolinux/isolinux.cfg
echo "  live.cfg gerado; isolinux default=live-amd64"

echo "── [1] BIOS: módulos c32 no isolinux ──"
for m in ldlinux libcom32 libutil libmenu libgpl; do
  cp -f chroot/usr/lib/syslinux/modules/bios/$m.c32 binary/isolinux/
done
ls binary/isolinux/*.c32 | xargs -n1 basename | tr '\n' ' '; echo
# auto-boot em 10s (era timeout 0 = espera pra sempre)
sed -i 's/^timeout .*/timeout 100/' binary/isolinux/isolinux.cfg
grep '^timeout' binary/isolinux/isolinux.cfg

echo "── [2] grub.cfg real (menu UEFI) ──"
mkdir -p binary/boot/grub binary/EFI/BOOT
cat > binary/boot/grub/grub.cfg <<EOF
set default=0
set timeout=10
insmod all_video
insmod gfxterm
menuentry "guataOS (Live)" {
    linux /live/vmlinuz $APPEND
    initrd /live/initrd.img
}
menuentry "guataOS (Live - modo seguro / nomodeset)" {
    linux /live/vmlinuz $APPEND nomodeset
    initrd /live/initrd.img
}
EOF

echo "── [3] stub embutido no bootx64.efi ──"
cat > /tmp/stub.cfg <<'EOF'
search --no-floppy --set=root --file /live/vmlinuz
set prefix=($root)/boot/grub
configfile ($root)/boot/grub/grub.cfg
EOF

echo "── [4] bootx64.efi (grub standalone) ──"
grub-mkstandalone \
  --format=x86_64-efi \
  --output=/tmp/bootx64.efi \
  --modules="part_gpt part_msdos fat iso9660 search search_fs_file search_label normal linux boot configfile echo gfxterm all_video efi_gop efi_uga font test" \
  --locales="" --themes="" \
  "boot/grub/grub.cfg=/tmp/stub.cfg"
ls -lh /tmp/bootx64.efi | awk '{print "bootx64.efi:",$5}'

echo "── [5] efi.img (FAT com EFI/BOOT/BOOTX64.EFI) ──"
rm -f /tmp/efi.img
dd if=/dev/zero of=/tmp/efi.img bs=1M count=8 status=none
mkfs.vfat -n GUATAEFI /tmp/efi.img >/dev/null
mmd -i /tmp/efi.img ::/EFI ::/EFI/BOOT
mcopy -i /tmp/efi.img /tmp/bootx64.efi ::/EFI/BOOT/BOOTX64.EFI
cp /tmp/efi.img binary/boot/grub/efi.img
cp /tmp/bootx64.efi binary/EFI/BOOT/BOOTX64.EFI

echo "── [6] xorriso: monta ISO híbrida (BIOS+UEFI) ──"
xorriso -as mkisofs \
  -iso-level 3 -full-iso9660-filenames -volid "Guata Live" \
  -eltorito-boot isolinux/isolinux.bin \
  -eltorito-catalog isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  -isohybrid-mbr chroot/usr/lib/ISOLINUX/isohdpfx.bin \
  -output "$OUT" \
  binary 2>&1 | tail -4

echo "── PRONTO ──"
ls -lh "$OUT"
file "$OUT" | cut -d, -f1-3
xorriso -indev "$OUT" -report_el_torito plain 2>/dev/null | grep -iE "Pltf|img path" | head
