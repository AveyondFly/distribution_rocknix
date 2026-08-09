#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

[ -z "$SYSTEM_ROOT" ] && SYSTEM_ROOT=""
[ -z "$BOOT_ROOT" ] && BOOT_ROOT="/flash"
[ -z "$BOOT_PART" ] && BOOT_PART=$(df "$BOOT_ROOT" | tail -1 | awk {' print $1 '})

# identify the boot device
if [ -z "$BOOT_DISK" ]; then
  case $BOOT_PART in
    /dev/mmcblk*)
      BOOT_DISK=$(echo $BOOT_PART | sed -e "s,p[0-9]*,,g")
      ;;
  esac
fi

# mount $BOOT_ROOT rw
mount -o remount,rw $BOOT_ROOT

echo "Updating device trees..."
mkdir -p $BOOT_ROOT/device_trees
cp -f $SYSTEM_ROOT/usr/share/bootloader/device_trees/* $BOOT_ROOT/device_trees/

UPDATE_DTB_SOURCE="$BOOT_ROOT/device_trees/sun55i-a527-cubie-a5e.dtb"
if [ -f "$UPDATE_DTB_SOURCE" ]; then
  echo "Updating dtb.img from $(basename $UPDATE_DTB_SOURCE)..."
  cp -f "$UPDATE_DTB_SOURCE" "$BOOT_ROOT/dtb.img"
fi

# Allwinner sun55iw3 BSP: boot0 @ 8KiB, boot_package (u-boot+dtb) @ 16400KiB
if [ -f $SYSTEM_ROOT/usr/share/bootloader/boot0_sdcard_sun55iw3p1.bin ]; then
  echo "Updating boot0 on: $BOOT_DISK..."
  dd if=$SYSTEM_ROOT/usr/share/bootloader/boot0_sdcard_sun55iw3p1.bin \
    of=$BOOT_DISK bs=1K seek=8 conv=fsync,notrunc &>/dev/null
fi

if [ -f $SYSTEM_ROOT/usr/share/bootloader/boot_package.fex ]; then
  echo "Updating boot_package on: $BOOT_DISK..."
  dd if=$SYSTEM_ROOT/usr/share/bootloader/boot_package.fex \
    of=$BOOT_DISK bs=8K seek=2050 conv=fsync,notrunc &>/dev/null
fi

# mount $BOOT_ROOT ro
sync
mount -o remount,ro $BOOT_ROOT

echo "UPDATE" > /storage/.boot.hint
