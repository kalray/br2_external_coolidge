#!/bin/sh

echo "Generating vmlinux_l2"

k1-linux-objcopy --update-section .rm_firmware=${BUILD_DIR}/k1c-firmware/l2_cache_bin ${BINARIES_DIR}/vmlinux ${BINARIES_DIR}/vmlinux_l2
