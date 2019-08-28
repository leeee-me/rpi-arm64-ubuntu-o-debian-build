#!/bin/sh
cd build
S=$(pwd)

sudo apt-get install gcc-aarch64-linux-gnu dpkg-dev
sudo apt-get install bc bison flex libssl-dev u-boot-tools

CROSS=aarch64-linux-gnu-
LINUX_RPI=4.15.y

git clone --depth 1 --branch v2018.11 git://git.denx.de/u-boot.git v2018.11
cd v2018.11
make CROSS_COMPILE=$CROSS rpi_3_defconfig
make CROSS_COMPILE=$CROSS

sudo cp u-boot.bin $S/boot

cat <<"EOM" > u-boot-script.txt
setenv fdt_addr_r 0x03000000
fdt addr ${fdt_addr_r}
fdt get value bootargs /chosen bootargs
setenv kernel_addr_r 0x01000000
setenv ramdisk_addr_r 0x03100000
fatload mmc 0:1 ${kernel_addr_r} vmlinuz
fatload mmc 0:1 ${ramdisk_addr_r} initrd.img
setenv initrdsize $filesize
booti ${kernel_addr_r} ${ramdisk_addr_r}:${initrdsize} ${fdt_addr_r}
EOM

mkimage -A arm64 -O linux -T script -d u-boot-script.txt boot.scr
sudo cp boot.scr $S/boot
cd ..

git clone --depth=1 -b rpi-$LINUX_RPI https://github.com/raspberrypi/linux.git linux-$LINUX_RPI
cd linux-$LINUX_RPI
mkdir kernel-build
make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS bcmrpi3_defconfig
make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS -j$(nproc)

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
mv $S/boot/vmlinuz-$KERNEL_VERSION $S/boot/vmlinuz
sudo rm -rf $S/boot/*dts*
sudo rm -rf $S/boot/*old
sudo rm -rf $S/boot/kernel*img
sudo rm -rf $S/boot/arm*bin

cd ..

sudo chroot rootfs/ mkinitramfs -o /root/initrd.img $KERNEL_VERSION
sudo mv rootfs/root/initrd.img $S/boot

cat <<"EOM" > $S/boot/config.txt

enable_uart=1
kernel=u-boot.bin
device_tree_address=0x03000000
dtparam=i2c_arm=on
dtparam=spi=on
arm_64bit=1

EOM

echo "earlyprintk dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait" > $S/boot/cmdline.txt

cd $S

echo RPI_TARGET=rpi3b-uboot-2 > ./.RPi-Target

make -C linux-$LINUX_RPI ARCH=arm64 O=./kernel-build CROSS_COMPILE=$CROSS -j$(nproc) bindeb-pkg
mkdir deb-pkg
mv linux-$LINUX_RPI/linux-*deb deb-pkg

echo "Debian packages of linux-image and linux-headers are generated, "
echo "Please note that vmlinuz is gzip-compressed Image(.gz), and it must be gunziped as uncompressed Image for u-boot's aarch64 booti command"

