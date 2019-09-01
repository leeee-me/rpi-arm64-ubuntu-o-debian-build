#!/bin/sh
mkdir build
cd build
T=$(pwd)

echo "prepare rootfs"
sudo apt-get install debootstrap qemu-user-static
sudo apt-get install debian-archive-keyring
sudo mkdir rootfs
sudo debootstrap --arch armhf --foreign --variant minbase --no-check-gpg buster rootfs http://mirrordirector.raspbian.org/raspbian/
sudo cp /usr/bin/qemu-arm-static rootfs/usr/bin
sudo mkdir -p rootfs/usr/share/keyrings/
sudo cp /usr/share/keyrings/debian-archive-keyring.gpg rootfs/usr/share/keyrings/
sudo chroot rootfs /debootstrap/debootstrap --second-stage

sudo mkdir -p rootfs/etc/apt/sources.list.d/
sudo cp ../raspbian-apt-sources.list rootfs/etc/apt/sources.list
sudo cp ../raspbian-apt-sources-raspi.list rootfs/etc/apt/sources.list.d/raspi.list
sudo cp /etc/resolv.conf rootfs/etc/resolv.conf
sudo cp /run/systemd/resolve/resolv.conf rootfs/etc/resolv.conf

wget http://archive.raspbian.org/raspbian.public.key --quiet -O - | sudo tee rootfs/raspbian.public.key > /dev/null
sudo chroot rootfs apt-key add raspbian.public.key

wget http://archive.raspberrypi.org/debian/raspberrypi.gpg.key --quiet -O - | sudo tee rootfs/raspberrypi.gpg.key > /dev/null
sudo chroot rootfs apt-key add raspberrypi.gpg.key

sudo chroot rootfs apt-get update
sudo DEBIAN_FRONTEND=noninteractive chroot rootfs apt-get install locales
sudo sed -i 's/# en_US/en_US/g' rootfs/etc/locale.gen 
sudo DEBIAN_FRONTEND=noninteractive chroot rootfs locale-gen 
sudo DEBIAN_FRONTEND=noninteractive chroot rootfs apt-get upgrade
sudo DEBIAN_FRONTEND=noninteractive chroot rootfs apt-get install sudo ssh net-tools ethtool wireless-tools init iputils-ping rsyslog bash-completion ifupdown tzdata --no-install-recommends

sudo rm rootfs/raspbian.public.key
sudo rm rootfs/raspberrypi.gpg.key

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

