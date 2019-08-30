#!/bin/sh
mkdir build
cd build
T=$(pwd)

echo "prepare rootfs"
sudo apt-get install debootstrap qemu-user-static
sudo mkdir rootfs
#sudo qemu-debootstrap --arch arm64 bionic rootfs
sudo qemu-debootstrap --arch arm64 buster rootfs
sudo cp /etc/resolv.conf rootfs/etc/resolv.conf
sudo cp /run/systemd/resolve/resolv.conf rootfs/etc/resolv.conf
sudo chroot rootfs locale-gen en_US.UTF-8
sudo chroot rootfs apt-get update
sudo chroot rootfs apt-get upgrade
sudo chroot rootfs apt-get install sudo ssh net-tools ethtool wireless-tools init iputils-ping rsyslog bash-completion ifupdown tzdata --no-install-recommends

sudo chroot rootfs useradd -G sudo,adm -m -s /bin/bash pi
sudo chroot rootfs sh -c "echo 'pi:raspberry' | chpasswd"

echo "raspberrypi" | sudo tee rootfs/etc/hostname
cat <<EOM > /dev/stdout | sudo tee rootfs/etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
127.0.1.1       raspberrypi
EOM

cat <<"EOM" > /dev/stdout | sudo tee rootfs/etc/fstab
proc            /proc           proc    defaults                  0       0
/dev/mmcblk0p1  /boot           vfat    defaults                  0       2
/dev/mmcblk0p2  /               ext4    defaults,noatime          0       1
EOM

cd $T

touch .RPi-Target
echo "RPI_VER=" > .RPi-Target

