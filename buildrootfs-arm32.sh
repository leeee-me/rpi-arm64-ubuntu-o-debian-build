#!/bin/sh
mkdir build
cd build
T=$(pwd)

echo "prepare rootfs"
sudo apt-get install debootstrap binfmt-support qemu-user-static
sudo update-binfmts --enable qemu-arm

sudo mkdir rootfs
# For Ubuntu archive keyring
sudo mkdir -p rootfs/usr/share/keyrings/
sudo cp /usr/share/keyrings/ubuntu-archive-keyring.gpg rootfs/usr/share/keyrings/
sudo qemu-debootstrap --arch armhf bionic rootfs
# Debain only
#sudo qemu-debootstrap --include=debian-archive-keyring --arch armhf buster rootfs

cd rootfs
sudo mount -t sysfs sysfs sys/
sudo mount -t proc  proc proc/
sudo mount -o bind /dev dev/
sudo mount -o bind /dev/pts dev/pts
cd ..

echo "raspberrypi" | sudo tee rootfs/etc/hostname
cat <<EOM > /dev/stdout | sudo tee rootfs/etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
127.0.1.1       raspberrypi
EOM

HOST_HOSTNAME=`hostname`
sudo chroot rootfs env -i /bin/hostname -F /etc/hostname

sudo chroot rootfs apt-get update
sudo chroot rootfs env -i HOME="/root" PATH="/bin:/usr/bin:/sbin:/usr/sbin" TERM="$TERM" DEBIAN_FRONTEND="noninteractive" \
        apt-get --yes -o DPkg::Options::=--force-confdef install  --no-install-recommends whiptail

sudo chroot rootfs env -i HOME="/root" PATH="/bin:/usr/bin:/sbin:/usr/sbin" TERM="$TERM" \
        apt-get --yes -o DPkg::Options::=--force-confdef install  --no-install-recommends locales
sudo chroot rootfs env -i HOME="/root" PATH="/bin:/usr/bin:/sbin:/usr/sbin" TERM="$TERM" SHELL="/bin/bash" \
        dpkg-reconfigure locales

sudo chroot rootfs env -i HOME="/root" PATH="/bin:/usr/bin:/sbin:/usr/sbin" TERM="$TERM" \
	apt-get --yes -o DPkg::Options::=--force-confdef install  --no-install-recommends sudo ssh net-tools ethtool wireless-tools init iputils-ping rsyslog bash-completion ifupdown 

sudo chroot rootfs env -i HOME="/root" PATH="/bin:/usr/bin:/sbin:/usr/sbin" TERM="$TERM" \
        apt-get --yes -o DPkg::Options::=--force-confdef upgrade

sudo chroot rootfs useradd -G sudo,adm -m -s /bin/bash pi
sudo chroot rootfs sh -c "echo 'pi:raspberry' | chpasswd"

sudo chroot rootfs apt-get --yes clean
sudo chroot rootfs apt-get --yes autoclean
sudo chroot rootfs apt-get --yes autoremove

sudo chroot rootfs env -i /bin/hostname $HOST_HOSTNAME

cd rootfs
sudo umount ./dev/pts
sudo umount ./dev
sudo umount ./proc
sudo umount ./sys
cd ..

cat <<"EOM" > /dev/stdout | sudo tee rootfs/etc/fstab
proc            /proc           proc    defaults                  0       0
/dev/mmcblk0p1  /boot           vfat    defaults                  0       2
/dev/mmcblk0p2  /               ext4    defaults,noatime          0       1
EOM

cd $T

touch .RPi-Target
echo "RPI_VER=" > .RPi-Target
echo "ROOTFS=armhf" >> .RPi-Target

