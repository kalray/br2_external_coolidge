#!/bin/sh
set -eu

echo "Generating vmlinux with L2$ firmware"

vmlinux=${BINARIES_DIR}/vmlinux
l2_cache_bin=${BUILD_DIR}/l2-firmware-custom/bin/l2_cache_bin
section=".rm_firmware"

rm_fw_sec_size_in_hex=$(kvx-linux-readelf -W --sections $vmlinux | grep $section | grep '[[:space:]]*\['  | sed -e 's/\[.*\]//g'|awk '{print $5}')
rm_fw_sec_size=$(printf "%d" 0x$rm_fw_sec_size_in_hex)

l2_cache_size=$(stat --printf="%s" $l2_cache_bin)

if [ "$rm_fw_sec_size" -lt "$l2_cache_size" ]; then
	echo "L2 Firmware is too big for vmlinux"
	exit 1
fi

kvx-linux-objcopy --update-section $section=${l2_cache_bin} ${vmlinux} ${BINARIES_DIR}/vmlinux_l2
mv ${BINARIES_DIR}/vmlinux_l2 ${vmlinux}
