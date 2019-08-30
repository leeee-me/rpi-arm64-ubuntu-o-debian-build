#!/bin/sh
cd build
sudo apt-get install -y dosfstools dump parted kpartx

# make a 4G size SD card image, 128M for /boot
sudo dd if=/dev/zero of=image.img bs=1M count=2048
sudo parted image.img mktable msdos
sudo parted image.img --script -- mkpart primary fat32 8192s 128MiB
sudo parted image.img --script -- mkpart primary ext4 128MiB -1s

sudo kpartx -av image.img
sleep 1s
ls /dev/mapper
R=/dev/mapper/
partBoot1=`ls /dev/mapper | grep p1`
partRoot1=`ls /dev/mapper | grep p2`
partBoot=$R$partBoot1
partRoot=$R$partRoot1
echo mkfs.vfat $partBoot
sudo mkfs.vfat $partBoot
echo mkfs.ext4 $partRoot
sudo mkfs.ext4 $partRoot
sudo mount $partRoot /mnt
sudo cp -rfp rootfs/* /mnt
sudo mount $partBoot /mnt/boot
sudo cp -rf boot/* /mnt/boot
sudo umount /mnt/boot
sudo umount /mnt
sudo sync
sudo kpartx -d image.img

[ -f rootfs/etc/lsb-release ] && . rootfs/etc/lsb-release && OS_VER=$DISTRIB_ID-$DISTRIB_RELEASE

[ -f rootfs/etc/os-release ] && . rootfs/etc/os-release && OS_VER=$ID-$VERSION_ID

. ./.RPi-Target

[ -z $RPI_VER ] && RPI_VER=raspberrypi
[ -z $OS_VER ] && OS_VER=unknown-none

sudo mv image.img $OS_VER-arm64-$RPI_VER.img
sudo rm -rf $OS_VER-arm64-$RPI_VER.img.xz
sudo xz -1 --verbose $OS_VER-arm64-$RPI_VER.img
sha256sum $OS_VER-arm64-$RPI_VER.img.xz > $OS_VER-arm64-$RPI_VER.img.xz.SHA256SUM
echo "xzcat $OS_VER-arm64-$RPI_VER.img.xz | pv | sudo dd of=/dev/sdX"
cd ..

