#!/usr/bin/env bash
# MARINKA 67 OS — автоматическая сборка ISO (Debian 12 + XFCE + live-build)
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

if [ "$(id -u)" -ne 0 ]; then
  echo "Запустите с sudo:  sudo ./build.sh"; exit 1
fi

echo ">>> [1/4] Установка инструментов сборки"
apt-get update
apt-get install -y live-build debootstrap xorriso squashfs-tools debian-archive-keyring \
                   mtools dosfstools syslinux-utils isolinux syslinux-common grub-pc-bin grub-efi-amd64-bin

echo ">>> [2/4] Подготовка рабочей папки"
rm -rf build && mkdir build
cp -a config build/config
cp -a auto build/auto
cd build
chmod +x auto/* config/hooks/live/*.hook.chroot

echo ">>> [3/4] Настройка (lb config)"
lb clean --purge >/dev/null 2>&1 || true
lb config

echo ">>> [4/4] Сборка ISO (30–60 минут, нужен интернет)"
lb build 2>&1 | tee ../build.log

ISO=$(ls -1 *.iso | head -n1)
mv "$ISO" ../MARINKA_67.iso
cd ..
sha256sum MARINKA_67.iso | tee MARINKA_67.iso.sha256
echo
echo "ГОТОВО:  $(pwd)/MARINKA_67.iso"
