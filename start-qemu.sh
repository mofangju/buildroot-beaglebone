#!/bin/bash

OUTPUT_PATH="output-qemu"
qemu-system-arm -M vexpress-a9 -smp 1 -m 256 -display none \
    -kernel "$OUTPUT_PATH"/images/zImage \
    -dtb "$OUTPUT_PATH"/images/vexpress-v2p-ca9.dtb \
    -drive file="$OUTPUT_PATH"/images/rootfs.ext2,if=sd,format=raw \
    -append "console=ttyAMA0,115200 root=/dev/mmcblk0" \
    -serial mon:stdio \
    -net nic,model=lan9118 -net user \
    -s -S
