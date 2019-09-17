#!/bin/sh

#set -x
cd build
T=$(pwd)

cd rootfs
sudo mount -t sysfs sysfs sys/
sudo mount -t proc  proc proc/
sudo mount -o bind /dev dev/
sudo mount -o bind /dev/pts dev/pts
sudo mkdir -p boot
cd ..

cp deb-pkg/linux-*deb rootfs/tmp

for i in deb-pkg/linux-*deb; do
	sudo chroot rootfs env -i HOME="/root" PATH="/bin:/usr/bin:/sbin:/usr/sbin" TERM="$TERM" dpkg -i /tmp/$(basename $i)
done

sudo rm -f rootfs/tmp/linux-*deb

cd rootfs
sudo umount ./dev/pts
sudo umount ./dev
sudo umount ./proc
sudo umount ./sys

sudo rm -i lib/modules/*/source
cd ..

cp -i rootfs/boot/* boot/

sudo rm -f rootfs/boot/*

#set +x
