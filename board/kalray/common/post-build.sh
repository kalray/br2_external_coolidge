#!/bin/sh

set -u
set -e

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE 'ttyGS0' ${TARGET_DIR}/etc/inittab || \
    sed -i '/GENERIC_SERIAL/a\
console::respawn:/sbin/getty -L  ttyGS0 9600 vt100 # USB Gadget' ${TARGET_DIR}/etc/inittab
fi
