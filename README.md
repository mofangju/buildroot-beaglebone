# Buildroot for Beaglebone Black

### 1 The Buildroot Out-of-Tree Directory Structure

After GIT clone this repository, please update submodule.
```
    git submodule init
    git submodule update
```
To avoid source code mixed with buildroot or linux kernel, the custome-app directory contains the linux module/driver source codes. 
The br2-external mechanism is adopted, the outside of the Buildroot tree is external directory, as follows.
```
    external/
    ├── board
    │   ├── labs
    │   │   ├── genimage.cfg
    │   │   ├── linux-4.1-sgx.fragment
    │   │   ├── linux.config
    │   │   ├── post-image.sh
    │   │   ├── readme.txt
    │   │   ├── rootfs-overlay
    │   │   │   └── etc
    │   │   │       └── network
    │   │   │           └── interfaces
    │   │   ├── uEnv-nfs.txt
    │   │   ├── uEnv-sd.txt
    │   │   └── uEnv.txt
    │   └── qemu
    │       └── linux.config
    ├── Config.in
    ├── configs
    │   ├── labs_defconfig
    │   └── qemu_defconfig
    ├── external.desc
    ├── external.mk
    └── package
        ├── ldd-misc-modules
        │   ├── Config.in
        │   └── ldd-misc-modules.mk
        ├── ldd-scull
        │   ├── Config.in
        │   └── ldd-scull.mk
        ├── led
        │   ├── Config.in
        │   └── led.mk
        └── sample-app
            ├── Config.in
            └── sample-app.mk
```

### 2 Start to Build

I adopt Buildroot 2018.05 verion.
```
    cd buildroot
    git checkout -b v2018.05 2018.05
```

Make build for beaglebone black as follows.
```
    make BR2_EXTERNAL=$PWD/external -C $PWD/buildroot O=$PWD/output-bbb labs_defconfig
    cd $PWD/output-bbb
    make -C ../buildroot O=$(pwd) menuconfig
    make menuconfig
    make
    make savedefconfig          # Save current config to BR2_DEFCONFIG (minimal config)  
```

If you want to config linux, the following commands are helpful.
```
    make linux-menuconfig       # Run Linux kernel menuconfig
    make linux-savedefconfig    # Run Linux kernel savedefconfig
    make linux-update-defconfig # Save the Linux configuration to the path specified
```
Make build for qemu as follows.
```
    make BR2_EXTERNAL=$PWD/external -C $PWD/buildroot O=$PWD/output-qemu qemu_defconfig
    make -C $PWD/output-qemu
```	
As the results, you will get two directories: output-bbb, output-qemu. 

### 3 Run the Build for Beaglebone Black

#### 3.1 Serial Debug Console Cable 

I get a USB to TTL Serial Debug Cable for Raspberry Pi from
https://www.adafruit.com/product/954.

Install minicom (Linux) or putty (Windows) on the Host computer. Set the
serial port (usb to serial board) to 115200 baud, 8 data bits, no
parity, 1 stop bit, no flow control. 

#### 3.2 Prepare the bootable SD card

Make the bootable SD card.
```
    sudo dd if=/dev/zero of=/dev/sdc bs=1M count=16
    sudo cfdisk /dev/sdc

    sudo mkfs.vfat -F 16 -n boot /dev/sdc1
    sudo mkfs.ext4 -L rootfs -E nodiscard /dev/sdc2
```
NOTE: /dev/sdc maybe different in your machine's configuration. 

#### 3.3 Boot from SD card
My SD card is mounted in /media/bill/boot, I can flash as follows.
```
    cd output-bbb/images
    cp MLO u-boot.img zImage am335x-boneblack.dtb uEnv.txt /media/bill/boot/
    sudo tar -C /media/bill/rootfs -xf rootfs.tar
```

Then the SD card can be used for boot, using following uEnv.txt:
``` 
    bootpart=0:1
    devtype=mmc
    bootdir=
    bootfile=zImage
    bootpartition=mmcblk0p2
    set_mmc1=if test $board_name = A33515BB; then setenv bootpartition mmcblk1p2; fi
    set_bootargs=setenv bootargs console=ttyO0,115200n8 root=/dev/${bootpartition} rw rootfstype=ext4 rootwait
    uenvcmd=run set_mmc1; run set_bootargs;run loadimage;run loadfdt;printenv bootargs;bootz ${loadaddr} - ${fdtaddr} 
```

#### 3.4 Boot from TFTP/NFS server
After setup TFTP server(/tftproot/)and NFS server(/rootfs), execute the following:
```
    cd output-bbb/images
    cp MLO u-boot.img zImage am335x-boneblack.dtb uEnv.txt /tftproot/
    sudo tar -C /rootfs -xf rootfs.tar
```

We can boot from tftp server and NFS server, using following uEnv.txt
```
    fdtfile=am335x-boneblack.dtb
    fdtaddr=0x88000000
    bootfile=zImage
    loadaddr=0x82000000
    console=ttyO0,115200n8
    serverip=192.168.0.104
    ipaddr=192.168.0.105
    rootpath=/rootfs
    netloadfdt=tftp ${fdtaddr} ${fdtfile}
    netloadimage=tftp ${loadaddr} ${bootfile}
    netargs=setenv bootargs console=${console} ${optargs} root=/dev/nfs nfsroot=${serverip}:${rootpath},nolock,nfsvers=3 rw rootwait ip=${ipaddr}
    netboot=echo Booting from network ...; setenv autoload no; run netloadimage; run netloadfdt; run netargs; bootz ${loadaddr} - ${fdtaddr}
    uenvcmd=run netboot
```
### 4 The Examples 

#### 4.1 Simplest sample app
If you want to add some executables in the build, just follow my sample-app example.

#### 4.2 Scull from Linux Dervice Driver  
I will use the example in the book: Linux Device Drivers, Third Edition (https://lwn.net/Kernel/LDD3/).
```
    make ldd-misc-modules-rebuild
    make 
    make update-servers
```
NOTE: I add the customized "make update-servers" to update the tftp and nfs server with the latest build. Please refer to external.mk for details.

Now you can reboot your Beaglebone black to verify if it works.

#### 4.3 GPIO driver for Button and LED

This example need breadboard to setup some circuit connect beaglebone's GPIO, button, and LED. For details, please refer to http://derekmolloy.ie/kernel-gpio-programming-buttons-and-leds. It introduces kobjects and a mechanism for adding your own entries to Sysfs. This allows you to send data to and receive data from the LKM at run time. 

We can use breadboard to connect GPIO with Button LED. I have adapted the source codes a little to work in current linux version.

```
    make led-rebuild
    make 
    make update-servers
```

### 5 Run the build using Qemu and debug linux kernel module

To run in Qemu, execute:
```
    cd output-qemu
    qemu-system-arm -M vexpress-a9 -smp 1 -m 256 -display none \
        -kernel "$OUTPUT_PATH"/images/zImage \
        -dtb "$OUTPUT_PATH"/images/vexpress-v2p-ca9.dtb \
        -drive file="$OUTPUT_PATH"/images/rootfs.ext2,if=sd,format=raw \
        -append "console=ttyAMA0,115200 root=/dev/mmcblk0" \
        -serial mon:stdio \
        -net nic,model=lan9118 -net user
        -s -S
```	

#### 5.1 Start to Debug kernel module using GDB
```
    ~/bbb/output-qemu/build/linux-4.14$ arm-linux-gnueabihf-gdb vmlinux
    GNU gdb (Linaro_GDB-2017.11) 8.0.1.20171119-git
    Copyright (C) 2017 Free Software Foundation, Inc.
    License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
    and "show warranty" for details.
    This GDB was configured as "--host=x86_64-unknown-linux-gnu --target=arm-linux-gnueabihf".
    Type "show configuration" for configuration details.
    For bug reporting instructions, please see:
    <http://www.gnu.org/software/gdb/bugs/>.
    Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.
    For help, type "help".
    Type "apropos word" to search for commands related to "word"...
    Reading symbols from vmlinux...done.
    (gdb) c
    The program is not being run.
    (gdb) target remote :1234
    Remote debugging using :1234
    0x60000000 in ?? ()
    (gdb) c
    Continuing.
```

#### 5.2 Get address In Qemu console
```
    Welcome to Buildroot
    buildroot login: root
    Password: 
    # 
    # 
    # cd /lib/modules/4.14.0/extra/
    # ls
    complete.ko    hellop.ko      scull.ko       seq.ko
    faulty.ko      kdataalign.ko  scull_load     silly.ko
    hello.ko       kdatasize.ko   scull_unload   sleepy.ko
    # ./scull_load
    scull: loading out-of-tree module taints kernel.
    scullsingle registered at fb00008
    sculluid registered at fb00009
    scullwuid registered at fb0000a
    scullpriv registered at fb0000b
    
    # ls -a /sys/module/scull/sections/
    .                          .rodata
    ..                         .rodata.str1.4
    .ARM.exidx                 .strtab
    .alt.smp.init              .symtab
    .bss                       .text
    .data                      .text.fixup
    .gnu.linkonce.this_module  __ex_table
    .note.gnu.build-id         __param
    
    # cat /sys/module/scull/sections/.text
    0x7f000000
```

#### 5.3 Continue to Debug kernel module using GDB

```
    ^C
    Program received signal SIGINT, Interrupt.
    cpu_v7_do_idle () at arch/arm/mm/proc-v7.S:80
    80		ret	lr
    (gdb) add-symbol-file /home/bill/bbb/output-qemu/build/ldd-scull/scull.ko 0x7f000000
    add symbol table from file "/home/bill/bbb/output-qemu/build/ldd-scull/scull.ko" at
    	.text_addr = 0x7f000000
    (y or n) y
    Reading symbols from /home/bill/bbb/output-qemu/build/ldd-scull/scull.ko...done.
    (gdb) l scull_read
    290	 * Data management: read and write
    291	 */
    292	
    293	ssize_t scull_read(struct file *filp, char __user *buf, size_t count,
    294	                loff_t *f_pos)
    295	{
    296		struct scull_dev *dev = filp->private_data; 
    297		struct scull_qset *dptr;	/* the first listitem */
    298		int quantum = dev->quantum, qset = dev->qset;
    299		int itemsize = quantum * qset; /* how many bytes in the listitem */
    (gdb) b main.c:296
    
    # echo "11111" > /dev/scull0
    # cat /dev/scull0
    
       ┌──/home/bill/bbb/output-qemu/build/ldd-scull/./main.c────────────────────────────────────────────────────┐
       │282                     }                                                                                │
       │283                     qs = qs->next;                                                                   │
       │284                     continue;                                                                        │
       │285             }                                                                                        │
       │286             return qs;                                                                               │
       │287     }                                                                                                │
       │288                                                                                                      │
       │289     /*                                                                                               │
       │290      * Data management: read and write                                                               │
       │291      */                                                                                              │
       │292                                                                                                      │
       │293     ssize_t scull_read(struct file *filp, char __user *buf, size_t count,                            │
       │294                     loff_t *f_pos)                                                                   │
    B+ │295     {                                                                                                │
       │296             struct scull_dev *dev = filp->private_data;                                              │
       │297             struct scull_qset *dptr;        /* the first listitem */                                 │
      >│298             int quantum = dev->quantum, qset = dev->qset;                                            │
       │299             int itemsize = quantum * qset; /* how many bytes in the listitem */                      │
       │300             int item, s_pos, q_pos, rest;                                                            │
       │301             ssize_t retval = 0;                                                                      │
       │302                                                                                                      │
       │303             if (down_interruptible(&dev->sem))                                                       │
       │304                     return -ERESTARTSYS;                                                             │
       │305             if (*f_pos >= dev->size)                                                                 │
       │306                     goto out;                                                                        │
       │307             if (*f_pos + count > dev->size)                                                          │
       │308                     count = dev->size - *f_pos;                                                      │
       │309                                                                                                      │
       │310             /* find listitem, qset index, and offset in the quantum */                               │
       └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘
    remote Thread 1 In: scull_read                                                           L298  PC: 0x7f000b0c 
    
    (gdb) n
```	

Enjoy!


