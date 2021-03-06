#!/bin/bash
set -eo pipefail

if [[ -z "$1" ]]; then
    echo "usage: $0 <device>"
    exit 1
fi

set -u
DEVICE="$1"

if [[ ! -b "$DEVICE" ]]; then
    echo "$DEVICE is not a block device"
    exit 2
fi

set -x

parted --script "$DEVICE" \
    mklabel msdos \
    mkpart primary fat16 1MiB 500MiB \
    mkpart primary ext4 500MiB 100% \

partprobe "$DEVICE"

mkfs.vfat -n RPI4BOOT "${DEVICE}1"
mkfs.ext4 -L RPI4ROOT "${DEVICE}2"
