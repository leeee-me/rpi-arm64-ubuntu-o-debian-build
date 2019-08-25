#!/bin/sh
cd build
S=$(pwd)

sudo apt-get install gcc-aarch64-linux-gnu dpkg-dev
sudo apt-get install bc bison flex libssl-dev 

CROSS=aarch64-linux-gnu-

git clone https://github.com/raspberrypi/tools.git
cd tools/armstubs
git checkout 7f4a937e1bacbc111a22552169bc890b4bb26a94
make armstub8-gic.bin
cp armstub8-gic.bin $S/boot/armstub8-gic.bin


git clone --depth=1 -b rpi-4.19.y https://github.com/raspberrypi/linux.git
cd linux
mkdir kernel-build
make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS bcm2711_defconfig
make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS -j4

KERNEL_VERSION=`cat ./kernel-build/include/generated/utsrelease.h | sed -e 's/.*"\(.*\)".*/\1/'` 

make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS install INSTALL_PATH=$S/boot
sudo make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS modules_install INSTALL_MOD_PATH=$S/rootfs INSTALL_FW_PATH=$S/rootfs/lib/firmware
sudo make ARCH=arm64 O=./kernel-build/ CROSS_COMPILE=$CROSS headers_install INSTALL_HDR_PATH=$S/rootfs/usr

#sudo depmod --basedir $S/rootfs/ "$KERNEL_VERSION"

cp kernel-build/arch/arm64/boot/Image $S/boot/kernel8.img
cp kernel-build/arch/arm64/boot/dts/broadcom/*.dtb $S/boot
rm $S/boot/*dts*
rm $S/boot/*old
rm $S/boot/Image
rm $S/boot/u-boot*
rm $S/boot/boot.scr
rm $S/boot/initrd.img

cd ..

sudo chroot rootfs/ mkinitramfs -o /root/initrd.img $KERNEL_VERSION
sudo mv rootfs/root/initrd.img $S/boot

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

echo RPI_TARGET=rpi4b > ./.RPi-Target

make -C linux ARCH=arm64 O=./kernel-build CROSS_COMPILE=$CROSS -j4 bindeb-pkg
mkdir deb-pkg
mv linux/linux-* deb-pkg

echo "Debian packages of linux-image and linux-headers are generated, "
echo "Please note that vmlinuz is gzip-compressed Image(.gz), and it must be gunziped as Image for u-boot"

