#!/bin/sh
cd build
S=$(pwd)

sudo apt-get install gcc-aarch64-linux-gnu dpkg-dev
sudo apt-get install bc bison flex libssl-dev

CROSS=aarch64-linux-gnu-
LINUX_RPI=4.15.y

git clone --depth=1 -b rpi-$LINUX_RPI https://github.com/raspberrypi/linux.git linux-$LINUX_RPI
cd linux-$LINUX_RPI
mkdir kernel-build
make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS bcmrpi3_defconfig
make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS 

KERNEL_VERSION=`cat ./kernel-build/include/generated/utsrelease.h | sed -e 's/.*"\(.*\)".*/\1/'` 

sudo rm -rf $S/rootfs/lib/modules/*
sudo rm -rf $S/boot/config-*
sudo rm -rf $S/boot/System.map-*
sudo rm -rf $S/boot/vmlinuz-*

make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS install INSTALL_PATH=$S/boot
sudo make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS modules_install INSTALL_MOD_PATH=$S/rootfs INSTALL_FW_PATH=$S/rootfs/lib/firmware
sudo make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS headers_install INSTALL_HDR_PATH=$S/rootfs/usr

cp kernel-build/arch/arm64/boot/Image $S/boot/Image
cp kernel-build/arch/arm64/boot/dts/broadcom/*.dtb $S/boot
sudo rm -rf $S/boot/*dts*
sudo rm -rf $S/boot/*old
sudo rm -rf $S/boot/kernel*img
sudo rm -rf $S/boot/arm*bin

cd $S

sudo chroot rootfs/ mkinitramfs -o /root/initrd.img $KERNEL_VERSION
sudo mv rootfs/root/initrd.img $S/boot

cd ..
