#!/bin/sh
cd build
sudo apt-get install -y dosfstools dump parted kpartx

sudo dd if=/dev/zero of=image.img bs=1M count=2100
sudo parted image.img mktable msdos
sudo parted image.img --script -- mkpart primary fat32 8192s 2682879s
sudo parted image.img --script -- mkpart primary ext4 2682880s -1

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

sudo mv image.img ubuntu-18.04-aarch64-raspberrypi.img
cd ..
