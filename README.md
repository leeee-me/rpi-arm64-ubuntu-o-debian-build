# rpi3-arm64-ubuntu
Build RPi3 boot and Ubuntu system root rootfs with u-boot support in arm64 / aarch64

This project is inspired by https://github.com/chainsx/ubuntu64-rpi/tree/ubuntu-18.04-arm64/buildbuildfirmware.sh.
However, I do not fork it. Instead, I revised and leave here for future improvement.

These recipe of scripts already were verified on an amd64 Ubuntu 16.04 LTS with Raspberry Pi 3 Model B v1.2. THe verified target is arm64 Ubuntu 18.04 LTS.

Study the scripts themselves and then customize anything you would like to have.

$ ./buildrootfs.sh
$ ./buildfirmware.sh
$ ./buildkernel.sh
$ ./buildimage.sh

Then you obtained image of "ubuntu-18.04-aarch64-raspberrypi.img", and you could place it on to your micro SD card. I strongly suggest you connect your RPi 3 with UART cable and watch it booted on a console/terminal emulator (PuTTY, TeraTerm, minicom, etc)

