#!/bin/sh
cd build
S=$(pwd)

sudo apt-get install dpkg-dev
sudo apt-get install bc bison flex libssl-dev 

CROSS=arm-linux-gnueabihf-
LINUX_RPI=4.19.y

git clone https://github.com/raspberrypi/tools.git

cd $S

CROSS=$PWD/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin/arm-linux-gnueabihf-

git clone --depth=1 -b rpi-$LINUX_RPI https://github.com/raspberrypi/linux.git linux-$LINUX_RPI
cd linux-$LINUX_RPI
make ARCH=arm CROSS_COMPILE=$CROSS bcm2709_defconfig
make ARCH=arm CROSS_COMPILE=$CROSS -j$(nproc)

sudo rm -rf $S/rootfs/lib/modules/*
sudo rm -rf $S/boot/config-*
sudo rm -rf $S/boot/System.map-*
sudo rm -rf $S/boot/vmlinuz-*

make ARCH=arm CROSS_COMPILE=$CROSS install INSTALL_PATH=$S/boot
sudo make ARCH=arm CROSS_COMPILE=$CROSS modules_install INSTALL_MOD_PATH=$S/rootfs INSTALL_FW_PATH=$S/rootfs/lib/firmware
sudo make ARCH=arm CROSS_COMPILE=$CROSS headers_install INSTALL_HDR_PATH=$S/rootfs/usr

cp arch/arm/boot/Image $S/boot/kernel7.img
cp arch/arm/boot/dts/bcm*.dtb $S/boot
sudo rm -rf $S/boot/*dts*
sudo rm -rf $S/boot/*old
sudo rm -rf $S/boot/Image
sudo rm -rf $S/boot/u-boot*
sudo rm -rf $S/boot/boot.scr
sudo rm -rf $S/boot/initrd.img

cd ..

cat <<"EOM" > $S/boot/config.txt

# Serial console output!
enable_uart=1

# Use kernel7.img
kernel=kernel7.img

dtparam=i2c_arm=on
dtparam=spi=on

EOM

echo "earlyprintk dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait" > $S/boot/cmdline.txt

cd $S

echo RPI_VER=rpi3b-knl32b > ./.RPi-Target

cd linux-$LINUX_RPI
make ARCH=arm CROSS_COMPILE=$CROSS -j$(nproc) bindeb-pkg
cd ..

mkdir deb-pkg
mv linux-*deb deb-pkg
mv linux-*changes linux-*info linux-$LINUX_RPI

echo "Debian packages of linux-image and linux-headers are generated, "
