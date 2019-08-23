#!/bin/sh
cd build
D=$(pwd)
mkdir boot

# Obtain boot firmware except those 32-bit stuffs (plus those debug info and VideoCore)
git clone --depth 1 -b stable https://github.com/raspberrypi/firmware.git
cp -r firmware/boot/* $D/boot
rm $D/boot/*.dtb
rm $D/boot/*kernel*
rm -rf firmware

# Obtain official firmware from Linux kernel org
cd $D/rootfs/lib
sudo git clone --depth 1 https://github.com/rpi-distro/firmware-nonfree.git
sudo mv firmware-nonfree firmware
sudo rm -rf firmware/.git

cd $D
