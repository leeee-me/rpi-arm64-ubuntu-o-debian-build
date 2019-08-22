#!/bin/sh
cd build
sudo apt-get install -y dosfstools dump parted kpartx

sudo dd if=/dev/zero of=image.img bs=1M count=4096
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

. rootfs/etc/lsb-release

sudo mv image.img ubuntu-$DISTRIB_RELEASE-arm64-raspberrypi3.img
sudo xz -1 --verbose ubuntu-$DISTRIB_RELEASE-arm64-raspberrypi3.img
sha256sum ubuntu-$DISTRIB_RELEASE-arm64-raspberrypi3.img.xz > ubuntu-$DISTRIB_RELEASE-arm64-raspberrypi3.img.xz.SHA256SUM
echo "xzcat  ubuntu-$DISTRIB_RELEASE-arm64-raspberrypi3.img.xz | pv | sudo dd of=/dev/sdX"
cd ..
