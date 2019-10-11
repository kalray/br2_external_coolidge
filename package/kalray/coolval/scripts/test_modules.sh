#!/bin/sh

set -ex

# mount debugfs and activate pr_debug for kernel/module.c
# This is needed to get memory layout of module
# So that check_vmlinux.sh is able to validate kernel module relocs
DEBUGFSDIR="/sys/kernel/debug/"
if [ -d "${DEBUGFSDIR}" ]; then
	mount -t debugfs none /sys/kernel/debug/
	echo 'file kernel/module.c +p' > /sys/kernel/debug/dynamic_debug/control
	modprobe module_tests
	echo 'file kernel/module.c -p' > /sys/kernel/debug/dynamic_debug/control
fi

# Load ext2+loop and create/mount a small ext2 file system
# in order to exercise kernel modules a bit more.
modprobe ext2
modprobe loop
dd if=/dev/zero of=ext2.raw bs=1M count=1
losetup /dev/loop0 ext2.raw
mkfs.ext2 /dev/loop0
mkdir /extmnt /extmnt2
mount -o loop -t ext2 ext2.raw /extmnt
echo "EXT2 TEST: OK" > /extmnt/msg
umount /extmnt
mount -o loop -t ext2 ext2.raw /extmnt2
cat /extmnt2/msg
umount /extmnt2
rm -rf /extmnt /extmnt2 ext2.raw

modprobe k1c_dma_noc_test
modprobe -r k1c_dma_noc_test

