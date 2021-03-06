#!/bin/sh
cd build
S=$(pwd)

sudo apt-get install gcc-aarch64-linux-gnu dpkg-dev
sudo apt-get install bc bison flex libssl-dev 

CROSS=aarch64-linux-gnu-
LINUX_RPI=4.19.y

git clone https://github.com/raspberrypi/tools.git
cd tools/armstubs
git checkout 7f4a937e1bacbc111a22552169bc890b4bb26a94
make armstub8-gic.bin
cp armstub8-gic.bin $S/boot/armstub8-gic.bin

cd $S

git clone --depth=1 -b rpi-$LINUX_RPI https://github.com/raspberrypi/linux.git linux-$LINUX_RPI
cd linux-$LINUX_RPI
make ARCH=arm64 CROSS_COMPILE=$CROSS bcm2711_defconfig
make ARCH=arm64 CROSS_COMPILE=$CROSS -j$(nproc)

sudo rm -rf $S/rootfs/lib/modules/*
sudo rm -rf $S/boot/config-*
sudo rm -rf $S/boot/System.map-*
sudo rm -rf $S/boot/vmlinuz-*

make ARCH=arm64 CROSS_COMPILE=$CROSS install INSTALL_PATH=$S/boot
sudo make ARCH=arm64 CROSS_COMPILE=$CROSS modules_install INSTALL_MOD_PATH=$S/rootfs INSTALL_FW_PATH=$S/rootfs/lib/firmware
sudo make ARCH=arm64 CROSS_COMPILE=$CROSS headers_install INSTALL_HDR_PATH=$S/rootfs/usr

cp arch/arm64/boot/Image $S/boot/kernel8.img
cp arch/arm64/boot/dts/broadcom/*.dtb $S/boot
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

# Use kernel8.img
kernel=kernel8.img

device_tree_address=0x03000000
dtparam=i2c_arm=on
dtparam=spi=on
arm_64bit=1

armstub=armstub8-gic.bin
enable_gic=1
total_mem=1024

EOM

echo "earlyprintk dwc_otg.fiq_fix_enable=2 console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 rootflags=noload fsck.repair=yes rootwait" > $S/boot/cmdline.txt

cd $S

echo RPI_VER=rpi4b >> ./.RPi-Target

cd linux-$LINUX_RPI
make ARCH=arm64 CROSS_COMPILE=$CROSS -j$(nproc) bindeb-pkg
cd ..

mkdir deb-pkg
mv linux-*deb deb-pkg
mv linux-*changes linux-*info linux-$LINUX_RPI

echo "Debian packages of linux-image and linux-headers are generated, "
