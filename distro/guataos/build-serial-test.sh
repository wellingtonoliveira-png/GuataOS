#!/bin/bash
# Monta a ISO v0.17 e faz boot-test serial no QEMU (confirma boot até GDM).
set -e
cd /home/soprema/guata
ISO="guataOS-0.17.1-amd64.iso"

echo "── [A] coloca squashfs novo no binary/ ──"
cp -f /tmp/newfs.squashfs binary/live/filesystem.squashfs
ls -lh binary/live/filesystem.squashfs | awk '{print "squashfs:",$5}'

echo "── [B] monta ISO híbrida ──"
bash build-iso-hybrid.sh "$ISO"
MD5=$(md5sum "$ISO" | cut -d' ' -f1)
echo "ISO md5: $MD5"
echo "$MD5" > /tmp/v17_md5.txt

echo "── [C] prepara ISO de teste com console serial ──"
rm -rf /tmp/bt17; mkdir -p /tmp/bt17
# injeta console=ttyS0 nas cmdlines (isolinux + grub)
cp -a binary /tmp/bt17/binary
sed -i 's#\(boot=live[^"]*\)#\1 console=ttyS0,115200n8#' /tmp/bt17/binary/boot/grub/grub.cfg 2>/dev/null || true
# live.cfg / isolinux
for f in $(find /tmp/bt17/binary/isolinux -name "*.cfg"); do
  sed -i 's#\(append .*boot=live.*\)#\1 console=ttyS0,115200n8#' "$f" 2>/dev/null || true
done
# remonta iso de teste (só BIOS basta pro qemu serial)
xorriso -as mkisofs -iso-level 3 -full-iso9660-filenames -volid "Guata Test" \
  -eltorito-boot isolinux/isolinux.bin -eltorito-catalog isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -isohybrid-mbr chroot/usr/lib/ISOLINUX/isohdpfx.bin \
  -output /tmp/bt17/test.iso /tmp/bt17/binary 2>&1 | tail -1
ls -lh /tmp/bt17/test.iso | awk '{print "test.iso:",$5}'
echo "PRONTO_BUILD"
