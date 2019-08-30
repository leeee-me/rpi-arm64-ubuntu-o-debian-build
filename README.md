# rpi-arm64-ubuntu-o-debian-build

Build RPi3/RPi4 boot and Ubuntu system root rootfs with u-boot bootloader support in arm64 / aarch64

This project is inspired by https://github.com/chainsx/ubuntu64-rpi/tree/ubuntu-18.04-arm64/build.
However, I do not fork it. Instead, I revised it and left it here for future improvement.

This recipe of scripts already were verified on an amd64 Ubuntu 16.04 LTS with Raspberry Pi 3 Model B v1.2. The verified target is arm64 Ubuntu 18.04 LTS.

(<br>
Updated: Raspberry Pi 4 Model B is coming now. I modified the scripts by some known and explored workarounds by
https://blog.cloudkernels.net/posts/rpi4-64bit-image/<br>
https://jamesachambers.com/raspberry-pi-ubuntu-server-18-04-2-installation-guide/<br>
)


Study the scripts themselves and then customize anything you would like to have.
<pre>
$ ./buildrootfs.sh
$ ./buildfirmware.sh
$ ./buildkernel-uboot-rpi3.sh  # this is RPi3 kernel boot with u-boot
  or
  ./buildkernel-uboot-rpi3-2.sh # this is RPi3 kernel boot with newer 4.15.y and v2018.11 u-boot supported booti with vmlinuz (insight from Ubuntu Bionic RPi3 server prebuilt)
  or
$ ./buildkernel-armstub-rpi3.sh # this is RPi3 kernel boot by default stub (to support 4.19.y boot directly since u-boot cannot boot up the new firmware? possibly here? Will check this later.
  https://github.com/raspberrypi/firmware/issues/1157
  or
$ ./buildkernel-armstub-rpi4.sh # this is RPi4 kernel boot with armstub8 (temp workaround solution)
$ ./buildimage.sh
</pre>
Then you obtained image of "${VER}-arm64-${RPT_VER}.img", and you could place it on to your micro SD card. 
<pre>
$ xzcat DISTRIB-RELEASE-arm64-RPI_TARGET.img.xz | pv | sudo dd of=/dev/sdX
</pre>

<b>If you need mmcli/nmcli to support 3G/LTE modem (cdc-wdm0/wwan0), suggest to use Debian distrib instead of Ubuntu Bionic. I tried it and that did not work correctly on some QMI mPCIe modem such as EC25/EG25.</b>

I strongly suggest you to connect your RPi 3 with a UART/USB cable and watch it booting-up on a console/terminal emulator (PuTTY, TeraTerm, minicom, etc)
You could rebuild the kernel all the time when the upstream kernel is upgraded, then just replace the following stuffs in your microSD card:
<pre>
/boot/vmlinuz-`uname -r`
/boot/System.map-`uname -r`
/boot/config-`uname -r`
/boot/initrd.img
/boot/Image
/lib/modules/`uname -r`
</pre>

Now I added make command to generate kernel's debian packages (linux-image & linux-headers) for convenience of kernel upgrade. At the same time, these can be used to build customer (3rd-party) kernel modules. However, you need to manually work on RPi3's /boot kernel replacement. The vmlinuz is gziped Image(.gz), and you need to gunzip vmlinuz and name it as Image, so that u-boot can load it correctly.

I learned from Armbian and now I am going to study on how to generate linux-kernel-dtb package. Stay tuned.

<pre>

U-Boot 2017.11 (Jul 27 2018 - 15:18:45 +0800)

DRAM:  948 MiB
RPI 3 Model B (0xa02082)
MMC:   sdhci@7e300000: 0
*** Warning - bad CRC, using default environment

In:    serial
Out:   vidconsole
Err:   vidconsole
Net:   No ethernet found.
starting USB...
USB0:   Core Release: 2.80a
scanning bus 0 for devices... 3 USB Device(s) found
       scanning usb for storage devices... 0 Storage Device(s) found
Hit any key to stop autoboot:  0
switch to partitions #0, OK
mmc0 is current device
Scanning mmc 0:1...
Found U-Boot script /boot.scr
reading /boot.scr
353 bytes read in 13 ms (26.4 KiB/s)
## Executing script at 02000000
reading Image
15137280 bytes read in 898 ms (16.1 MiB/s)
reading initrd.img
9186959 bytes read in 559 ms (15.7 MiB/s)
## Flattened Device Tree blob at 00000100
   Booting using the fdt blob at 0x000100
   Loading Ramdisk to 3a683000, end 3af45e8f ... OK
   reserving fdt memory region: addr=0 size=1000
   Loading Device Tree to 000000003a679000, end 000000003a6826ad ... OK

Starting kernel ...

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 4.14.58-v8+ (me@ubuntu) (gcc version 8.1.0 (GCC)) #1 SMP PREEMPT Fri Jul 27 15:40:04 CST 2018
[    0.000000] Boot CPU: AArch64 Processor [410fd034]
[    0.000000] Machine model: Raspberry Pi 3 Model B Rev 1.2
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] efi: UEFI not found.
[    0.000000] cma: Reserved 8 MiB at 0x0000000039c00000
[    0.000000] percpu: Embedded 22 pages/cpu @ffffffc57b379000 s50456 r8192 d31464 u90112
[    0.000000] Detected VIPT I-cache on CPU0
[    0.000000] CPU features: enabling workaround for ARM erratum 845719
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 238896
[    0.000000] Kernel command line: 8250.nr_uarts=1 bcm2708_fb.fbwidth=656 bcm2708_fb.fbheight=416 bcm2708_fb.fbswap=1 vc_mem.mem_base=0x3ec00000 vc_mem.mem_size=0x40000000  earlyprintk dwc_otg.lpm_enable=0 console=ttyS0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 131072 (order: 8, 1048576 bytes)
[    0.000000] Inode-cache hash table entries: 65536 (order: 7, 524288 bytes)
[    0.000000] Memory: 919568K/970752K available (7036K kernel code, 894K rwdata, 4048K rodata, 2752K init, 686K bss, 42992K reserved, 8192K cma-reserved)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     modules : 0xffffff8000000000 - 0xffffff8008000000   (   128 MB)
[    0.000000]     vmalloc : 0xffffff8008000000 - 0xffffffbebfff0000   (   250 GB)
[    0.000000]       .text : 0xffffff8979680000 - 0xffffff8979d60000   (  7040 KB)
[    0.000000]     .rodata : 0xffffff8979d60000 - 0xffffff897a160000   (  4096 KB)
[    0.000000]       .init : 0xffffff897a160000 - 0xffffff897a410000   (  2752 KB)
[    0.000000]       .data : 0xffffff897a410000 - 0xffffff897a4efa00   (   895 KB)
[    0.000000]        .bss : 0xffffff897a4efa00 - 0xffffff897a59b468   (   687 KB)
[    0.000000]     fixed   : 0xffffffbefe7fb000 - 0xffffffbefec00000   (  4116 KB)
[    0.000000]     PCI I/O : 0xffffffbefee00000 - 0xffffffbeffe00000   (    16 MB)
[    0.000000]     vmemmap : 0xffffffbf00000000 - 0xffffffc000000000   (     4 GB maximum)
[    0.000000]               0xffffffbf15000000 - 0xffffffbf15ed0000   (    14 MB actual)
[    0.000000]     memory  : 0xffffffc540000000 - 0xffffffc57b400000   (   948 MB)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
[    0.000000] ftrace: allocating 25371 entries in 100 pages
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]  Tasks RCU enabled.
[    0.000000] NR_IRQS: 64, nr_irqs: 64, preallocated irqs: 0
[    0.000000] arch_timer: cp15 timer(s) running at 19.20MHz (phys).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x46d987e47, max_idle_ns: 440795202767 ns
[    0.000006] sched_clock: 56 bits at 19MHz, resolution 52ns, wraps every 4398046511078ns
[    0.000230] Console: colour dummy device 80x25
[    0.001059] console [tty1] enabled
[    0.001100] Calibrating delay loop (skipped), value calculated using timer frequency.. 38.40 BogoMIPS (lpj=19200)
[    0.001145] pid_max: default: 32768 minimum: 301
[    0.001490] Mount-cache hash table entries: 2048 (order: 2, 16384 bytes)
[    0.001537] Mountpoint-cache hash table entries: 2048 (order: 2, 16384 bytes)
[    0.002562] Disabling memory control group subsystem
[    0.007086] ASID allocator initialised with 32768 entries
[    0.009080] Hierarchical SRCU implementation.
[    0.011334] EFI services will not be available.
[    0.013146] smp: Bringing up secondary CPUs ...
[    0.020347] Detected VIPT I-cache on CPU1
[    0.020412] CPU1: Booted secondary processor [410fd034]
[    0.027448] Detected VIPT I-cache on CPU2
[    0.027493] CPU2: Booted secondary processor [410fd034]
[    0.034559] Detected VIPT I-cache on CPU3
[    0.034601] CPU3: Booted secondary processor [410fd034]
[    0.034742] smp: Brought up 1 node, 4 CPUs
[    0.034869] SMP: Total of 4 processors activated.
[    0.034898] CPU features: detected feature: 32-bit EL0 Support
[    0.034927] CPU features: detected feature: Kernel page table isolation (KPTI)
[    0.038225] CPU: All CPU(s) started at EL2
[    0.038276] alternatives: patching kernel code
[    0.039606] devtmpfs: initialized
[    0.051988] random: get_random_u32 called from bucket_table_alloc+0x108/0x270 with crng_init=0
[    0.052689] Enabled cp15_barrier support
[    0.052729] Enabled setend support
[    0.053046] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 1911260446275000 ns
[    0.053099] futex hash table entries: 1024 (order: 5, 131072 bytes)
[    0.053779] pinctrl core: initialized pinctrl subsystem
[    0.054032] DMI not present or invalid.
[    0.054364] NET: Registered protocol family 16
[    0.059230] cpuidle: using governor menu
[    0.059658] vdso: 2 pages (1 code @ ffffff8979d67000, 1 data @ ffffff897a414000)
[    0.059707] hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
[    0.063175] DMA: preallocated 256 KiB pool for atomic allocations
[    0.063335] Serial: AMBA PL011 UART driver
[    0.065911] bcm2835-mbox 3f00b880.mailbox: mailbox enabled
[    0.066566] uart-pl011 3f201000.serial: could not find pctldev for node /soc/gpio@7e200000/uart0_pins, deferring probe
[    0.100105] bcm2835-dma 3f007000.dma: DMA legacy API manager at ffffff800801d000, dmachans=0x1
[    0.101881] SCSI subsystem initialized
[    0.102167] usbcore: registered new interface driver usbfs
[    0.102249] usbcore: registered new interface driver hub
[    0.102389] usbcore: registered new device driver usb
[    0.102620] dmi: Firmware registration failed.
[    0.103011] raspberrypi-firmware soc:firmware: Attached to firmware from 2018-07-03 14:15
[    0.104454] clocksource: Switched to clocksource arch_sys_counter
[    0.202010] VFS: Disk quotas dquot_6.6.0
[    0.202138] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    0.202368] FS-Cache: Loaded
[    0.202703] CacheFiles: Loaded
[    0.213132] NET: Registered protocol family 2
[    0.213953] TCP established hash table entries: 8192 (order: 4, 65536 bytes)
[    0.214094] TCP bind hash table entries: 8192 (order: 5, 131072 bytes)
[    0.214309] TCP: Hash tables configured (established 8192 bind 8192)
[    0.214578] UDP hash table entries: 512 (order: 2, 16384 bytes)
[    0.214647] UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
[    0.214954] NET: Registered protocol family 1
[    0.215580] RPC: Registered named UNIX socket transport module.
[    0.215608] RPC: Registered udp transport module.
[    0.215631] RPC: Registered tcp transport module.
[    0.215653] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.215950] Trying to unpack rootfs image as initramfs...
[    0.983600] Freeing initrd memory: 8968K
[    0.990320] hw perfevents: enabled with armv8_pmuv3 PMU driver, 7 counters available
[    0.992286] workingset: timestamp_bits=46 max_order=18 bucket_order=0
[    1.002821] FS-Cache: Netfs 'nfs' registered for caching
[    1.003623] NFS: Registering the id_resolver key type
[    1.003677] Key type id_resolver registered
[    1.003702] Key type id_legacy registered
[    1.006234] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)
[    1.006464] io scheduler noop registered
[    1.006492] io scheduler deadline registered (default)
[    1.006822] io scheduler cfq registered
[    1.006850] io scheduler mq-deadline registered
[    1.006876] io scheduler kyber registered
[    1.010368] BCM2708FB: allocated DMA memory f9c50000
[    1.010430] BCM2708FB: allocated DMA channel 0 @ ffffff800801d000
[    1.014561] Console: switching to colour frame buffer device 82x26
[    1.018849] Serial: 8250/16550 driver, 1 ports, IRQ sharing enabled
[    1.021998] bcm2835-rng 3f104000.rng: hwrng registered
[    1.023655] vc-mem: phys_addr:0x00000000 mem_base=0x3ec00000 mem_size:0x40000000(1024 MiB)
[    1.027363] gpiomem-bcm2835 3f200000.gpiomem: Initialised: Registers at 0x3f200000
[    1.030630] cacheinfo: Unable to detect cache hierarchy for CPU 0
[    1.044381] brd: module loaded
[    1.057249] loop: module loaded
[    1.058807] Loading iSCSI transport class v2.0-870.
[    1.061232] libphy: Fixed MDIO Bus: probed
[    1.062876] usbcore: registered new interface driver lan78xx
[    1.064470] usbcore: registered new interface driver smsc95xx
[    1.065960] dwc_otg: version 3.00a 10-AUG-2012 (platform bus)
[    1.067772] dwc_otg 3f980000.usb: base=0x082b0000
[    1.269509] Core Release: 2.80a
[    1.271020] Setting default values for core params
[    1.272588] Finished setting default values for core params
[    1.474423] Using Buffer DMA mode
[    1.475991] Periodic Transfer Interrupt Enhancement - disabled
[    1.477586] Multiprocessor Interrupt Enhancement - disabled
[    1.479175] OTG VER PARAM: 0, OTG VER FLAG: 0
[    1.480735] Dedicated Tx FIFOs mode
[    1.482712] WARN::dwc_otg_hcd_init:1046: FIQ DMA bounce buffers: virt = 0x08181000 dma = 0xf9c44000 len=9024
[    1.485723] FIQ FSM acceleration enabled for :
[    1.485723] Non-periodic Split Transactions
[    1.485723] Periodic Split Transactions
[    1.485723] High-Speed Isochronous Endpoints
[    1.485723] Interrupt/Control Split Transaction hack enabled
[    1.492747] WARN::hcd_init_fiq:486: MPHI regs_base at 0x08045000
[    1.494272] dwc_otg 3f980000.usb: DWC OTG Controller
[    1.495736] dwc_otg 3f980000.usb: new USB bus registered, assigned bus number 1
[    1.497285] dwc_otg 3f980000.usb: irq 15, io mem 0x00000000
[    1.498813] Init: Port Power? op_state=1
[    1.500278] Init: Power Port (0)
[    1.501959] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.503487] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.505007] usb usb1: Product: DWC OTG Controller
[    1.506493] usb usb1: Manufacturer: Linux 4.14.58-v8+ dwc_otg_hcd
[    1.507990] usb usb1: SerialNumber: 3f980000.usb
[    1.510127] hub 1-0:1.0: USB hub found
[    1.511620] hub 1-0:1.0: 1 port detected
[    1.514236] usbcore: registered new interface driver usb-storage
[    1.515792] IR NEC protocol handler initialized
[    1.517172] IR RC5(x/sz) protocol handler initialized
[    1.518547] IR RC6 protocol handler initialized
[    1.519924] IR JVC protocol handler initialized
[    1.521271] IR Sony protocol handler initialized
[    1.522625] IR SANYO protocol handler initialized
[    1.523969] IR Sharp protocol handler initialized
[    1.525254] IR MCE Keyboard/mouse protocol handler initialized
[    1.526559] IR XMP protocol handler initialized
[    1.528694] bcm2835-wdt 3f100000.watchdog: Broadcom BCM2835 watchdog timer
[    1.530346] bcm2835-cpufreq: min=600000 max=1200000
[    1.532139] sdhci: Secure Digital Host Controller Interface driver
[    1.533525] sdhci: Copyright(c) Pierre Ossman
[    1.535232] mmc-bcm2835 3f300000.mmc: could not get clk, deferring probe
[    1.537000] sdhost-bcm2835 3f202000.mmc: could not get clk, deferring probe
[    1.538547] Error: Driver 'sdhost-bcm2835' is already registered, aborting...
[    1.539986] sdhci-pltfm: SDHCI platform and OF driver helper
[    1.542992] ledtrig-cpu: registered to indicate activity on CPUs
[    1.544672] hidraw: raw HID events driver (C) Jiri Kosina
[    1.546356] usbcore: registered new interface driver usbhid
[    1.547860] usbhid: USB HID core driver
[    1.549637] Initializing XFRM netlink socket
[    1.551131] NET: Registered protocol family 17
[    1.552719] Key type dns_resolver registered
[    1.555295] registered taskstats version 1
[    1.564969] uart-pl011 3f201000.serial: cts_event_workaround enabled
[    1.566663] 3f201000.serial: ttyAMA0 at MMIO 0x3f201000 (irq = 72, base_baud = 0) is a PL011 rev2
[    1.571769] console [ttyS0] disabled
[    1.573419] 3f215040.serial: ttyS0 at MMIO 0x0 (irq = 151, base_baud = 31250000) is a 16550
[    1.721564] Indeed it is in host mode hprt0 = 00021501
[    1.796735] random: fast init done
[    1.888502] usb 1-1: new high-speed USB device number 2 using dwc_otg
[    1.888672] Indeed it is in host mode hprt0 = 00001101
[    2.077907] usb 1-1: New USB device found, idVendor=0424, idProduct=9514
[    2.077917] usb 1-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    2.078594] hub 1-1:1.0: USB hub found
[    2.078755] hub 1-1:1.0: 5 ports detected
[    2.376482] usb 1-1.1: new high-speed USB device number 3 using dwc_otg
[    2.501479] usb 1-1.1: New USB device found, idVendor=0424, idProduct=ec00
[    2.501490] usb 1-1.1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    2.506191] smsc95xx v1.0.6
[    2.712803] smsc95xx 1-1.1:1.0 eth0: register 'smsc95xx' at usb-3f980000.usb-1.1, smsc95xx USB 2.0 Ethernet, b8:27:eb:2c:66:d0
[    2.741356] console [ttyS0] enabled
[    2.747760] mmc-bcm2835 3f300000.mmc: mmc_debug:0 mmc_debug2:0
[    2.755351] mmc-bcm2835 3f300000.mmc: DMA channel allocated
[    2.787304] sdhost: log_buf @ ffffff80080b5000 (f9c47000)
[    2.816483] mmc1: queuing unknown CIS tuple 0x80 (2 bytes)
[    2.825206] mmc1: queuing unknown CIS tuple 0x80 (3 bytes)
[    2.833899] mmc1: queuing unknown CIS tuple 0x80 (3 bytes)
[    2.843743] mmc1: queuing unknown CIS tuple 0x80 (7 bytes)
[    2.850696] mmc0: sdhost-bcm2835 loaded - DMA enabled (>1)
[    2.852498] of_cfs_init
[    2.852617] of_cfs_init: OK
[    2.870585] Freeing unused kernel memory: 2752K
[    2.963180] mmc0: host does not support reading read-only switch, assuming write-enable
[    2.980985] mmc0: new high speed SDHC card at address e624
[    2.988679] bounce: isa pool size: 16 pages
[    2.994547] mmcblk0: mmc0:e624 SB16G 14.8 GiB
[    3.006857]  mmcblk0: p1 p2
[    3.015871] mmc1: new high speed SDIO card at address 0001
[    3.286265] smsc95xx 1-1.1:1.0 enxb827eb2c66d0: renamed from eth0
[    3.765390] random: crng init done
[    8.619790] EXT4-fs (mmcblk0p2): INFO: recovery required on readonly filesystem
[    8.629015] EXT4-fs (mmcblk0p2): write access will be enabled during recovery
[    8.704719] EXT4-fs (mmcblk0p2): recovery complete
[    8.713035] EXT4-fs (mmcblk0p2): mounted filesystem with ordered data mode. Opts: (null)
[    9.316763] systemd[1]: System time before build time, advancing clock.
[    9.473598] NET: Registered protocol family 10
[    9.481174] Segment Routing with IPv6
[    9.504238] ip_tables: (C) 2000-2006 Netfilter Core Team
[    9.539485] systemd[1]: systemd 237 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 +IDN -PCRE2 default-hierarchy=hybrid)
[    9.566651] systemd[1]: Detected architecture arm64.
[    9.587785] systemd[1]: Set hostname to <ubuntu-pi>.
[    9.894549] systemd[1]: File /lib/systemd/system/systemd-journald.service:36 configures an IP firewall (IPAddressDeny=any), but the local system does not support BPF/cgroup based firewalling.
[    9.916711] systemd[1]: Proceeding WITHOUT firewalling in effect! (This warning is only shown for the first loaded unit using IP firewalling.)
[   10.125327] systemd[1]: Set up automount Arbitrary Executable File Formats File System Automount Point.
[   10.141638] systemd[1]: Started Dispatch Password Requests to Console Directory Watch.
[   10.156167] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[   10.170249] systemd[1]: Reached target Local Encrypted Volumes.
[   10.180643] systemd[1]: Reached target Paths.
[   11.495131] brcmfmac: brcmf_c_preinit_dcmds: CLM version = API: 12.2 Data: 7.11.15 Compiler: 1.24.2 ClmImport: 1.24.1 Creation: 2014-05-26 10:53:55 Inc Data: 9.10.39 Inc Compiler: 1.29.4 Inc ClmImport: 1.36.3 Creation: 2017-10-23 03:47:14

Ubuntu 18.04 LTS ubuntu-pi ttyS0

ubuntu-pi login: ubuntu
Password:
Last login: Sun Jan 28 15:58:33 UTC 2018 on ttyS0
Welcome to Ubuntu 18.04 LTS (GNU/Linux 4.14.58-v8+ aarch64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ubuntu-pi:~$ uname -a
Linux ubuntu-pi 4.14.58-v8+ #1 SMP PREEMPT Fri Jul 27 15:40:04 CST 2018 aarch64 aarch64 aarch64 GNU/Linux

</pre>
