#!/bin/sh
set -eu

echo "Generating vmlinux with L2$ firmware"

vmlinux=${BINARIES_DIR}/vmlinux
l2_cache_bin=${BUILD_DIR}/kvx-firmware-custom/l2_cache_bin
section=".rm_firmware"

rm_fw_sec_size=$(kvx-linux-readelf -W --sections $vmlinux | grep $section | grep '[[:space:]]*\['  | sed -e 's/\[.*\]//g'|awk '{print $5}')

l2_cache_size=$(stat --printf="%s" $l2_cache_bin)

if [ "$rm_fw_sec_size" -lt "$rm_fw_sec_size" ]; then
	echo "L2 Firmware is too big for vmlinux"
	exit 1
fi

kvx-linux-objcopy --update-section $section=${l2_cache_bin} ${vmlinux} ${BINARIES_DIR}/vmlinux_l2
mv ${BINARIES_DIR}/vmlinux_l2 ${vmlinux}
