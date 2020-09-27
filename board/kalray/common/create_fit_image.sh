#!/bin/sh
set -eu

BOARD_DIR="$(dirname $0)"
MKIMAGE=$HOST_DIR/bin/mkimage
STRIP=$HOST_DIR/bin/kvx-linux-strip
ITS_FILE=$BOARD_DIR/kernel.its
VMLINUX=$BINARIES_DIR/vmlinux
TEMPKERNEL=
TEMPFILE=

rm_files () {
	if [ ! -z "$TEMPFILE" ]; then
		rm -f $TEMPFILE
	fi
	if [ ! -z "$TEMPKERNEL" ]; then
		rm -f $TEMPKERNEL
	fi
}

trap rm_files EXIT

TEMPKERNEL=$(mktemp)
echo "Stripping kernel"
$STRIP $VMLINUX -o $TEMPKERNEL

echo "Generating FIT image"
TEMPFILE=$(mktemp)
sed "s|KERNEL_IMAGE|$TEMPKERNEL|g" $ITS_FILE > $TEMPFILE
$MKIMAGE -f $TEMPFILE $BINARIES_DIR/kernel.fit
