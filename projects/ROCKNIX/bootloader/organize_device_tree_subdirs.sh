#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)
#
# Sort flat device_trees/*.dtb into per-subdevice subdirectories using config.xml.
# Usage: organize_device_tree_subdirs.sh <DEVICE> <config.xml> <device_trees_dir>

set -e

DEVICE="${1:?DEVICE required}"
CONFIGXML="${2:?config.xml required}"
DT_DIR="${3:?device_trees dir required}"

[ -d "${DT_DIR}" ] || exit 0
[ -f "${CONFIGXML}" ] || exit 0
command -v xmlstarlet >/dev/null 2>&1 || exit 0

SUBDEVICES=$(xmlstarlet sel -t -m "//rocknix/${DEVICE}/*[@mkimage_options]" -v "name()" -n "${CONFIGXML}" 2>/dev/null) || exit 0
[ -n "${SUBDEVICES}" ] || exit 0

for sub in ${SUBDEVICES}; do
  mkdir -p "${DT_DIR}/${sub}"
  for dtb_base in $(xmlstarlet sel -t -m "//rocknix/${DEVICE}/${sub}/file" -v "." -n "${CONFIGXML}" 2>/dev/null); do
    if [ -f "${DT_DIR}/${dtb_base}.dtb" ]; then
      mv "${DT_DIR}/${dtb_base}.dtb" "${DT_DIR}/${sub}/"
    fi
  done
done
