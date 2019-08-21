#!/bin/sh
cd build
S=$(pwd)

sudo apt-get install u-boot-tools

CROSS=aarch64-linux-gnu-

git clone --depth 1 --branch v2017.11 git://git.denx.de/u-boot.git v2017.11
cd v2017.11
make CROSS_COMPILE=$CROSS rpi_3_defconfig
make CROSS_COMPILE=$CROSS

sudo cp u-boot.bin $S/boot

cat <<"EOM" > u-boot-script.txt
setenv fdtfile bcm2837-rpi-3-b.dtb
setenv kernel_addr_r 0x01000000
setenv ramdisk_addr_r 0x02100000
fatload mmc 0:1 ${kernel_addr_r} Image
fatload mmc 0:1 ${ramdisk_addr_r} initrd.img
setenv initrdsize $filesize
booti ${kernel_addr_r} ${ramdisk_addr_r}:${initrdsize} ${fdt_addr_r}
EOM

mkimage -A arm64 -O linux -T script -d u-boot-script.txt boot.scr
sudo cp boot.scr $S/boot
cd ..

git clone --depth=1 -b rpi-4.19.y https://github.com/raspberrypi/linux.git
cd linux
make ARCH=arm64 CROSS_COMPILE=$CROSS bcmrpi3_defconfig
make ARCH=arm64 CROSS_COMPILE=$CROSS -j4

make ARCH=arm64 CROSS_COMPILE=$CROSS install INSTALL_PATH=$S/boot
sudo make ARCH=arm64 CROSS_COMPILE=$CROSS modules_install INSTALL_MOD_PATH=$S/rootfs
sudo make ARCH=arm64 CROSS_COMPILE=$CROSS headers_install INSTALL_HDR_PATH=$S/rootfs/usr

sudo cp arch/arm64/boot/Image $S/boot/Image
sudo cp arch/arm64/boot/dts/broadcom/bcm* $S/boot
sudo rm $S/boot/*dts*
sudo rm $S/boot/*old

cd ..
KERNELVER=`ls rootfs/lib/modules/`

sudo chroot rootfs/ mkinitramfs -o /root/initrd.img $KERNELVER
sudo mv rootfs/root/initrd.img $S/boot

cat <<"EOM" > $S/boot/config.txt

# Serial console output!
enable_uart=1

# 64bit-mode
arm_control=0x200

# Use U-Boot
kernel=u-boot.bin

device_tree_address=0x100
device_tree_end=0x8000
EOM

echo "earlyprintk dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait" > $S/boot/cmdline.txt

cd $S

make -C linux ARCH=arm64 CROSS_COMPILE=$CROSS -j4 bindeb-pkg
mkdir deb-pkg
mv linux-* deb-pkg

echo "Debian packages of linux-image and linux-headers are generated, "
echo "Please note that vmlinuz is gzip-compressed Image(.gz), and it must be gunziped as Image for u-boot"

