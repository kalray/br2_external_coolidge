#!/bin/sh

echo "Generating vmlinux_l2"

k1-linux-objcopy --update-section .rm_firmware=${TARGET_DIR}/bin/l2_cache_bin ${BINARIES_DIR}/vmlinux ${BINARIES_DIR}/vmlinux_l2
