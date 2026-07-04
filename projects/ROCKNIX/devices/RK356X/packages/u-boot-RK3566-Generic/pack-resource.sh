#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)
#
# Pack Powkiddy-only resource.img with SARADC HWID file names for U-Boot.

set -e

: "${PKG_BUILD:?PKG_BUILD is required}"
: "${DTB_DIR:?DTB_DIR is required}"
: "${OUT:?OUT is required}"

RSCE_TMP="${PKG_BUILD}/.resource_pack"
TOOL="${PKG_BUILD}/tools/resource_tool"

declare -A HWID_DTBS=(
  [383]="rk3566-powkiddy-rgb30.dtb"
  [635]="rk3566-powkiddy-rk2023.dtb"
  [765]="rk3566-powkiddy-rgb10max3.dtb"
  [245]="rk3566-powkiddy-rgb20-pro.dtb"
)

rm -rf "${RSCE_TMP}"
mkdir -p "${RSCE_TMP}"

for adc in "${!HWID_DTBS[@]}"; do
  dtb="${HWID_DTBS[$adc]}"
  src="${DTB_DIR}/${dtb}"
  base="${dtb%.dtb}"
  dst="${base}#_saradc_ch1=${adc}.dtb"

  if [ ! -f "${src}" ]; then
    echo "ERROR: missing ${src}" >&2
    exit 1
  fi
  cp "${src}" "${RSCE_TMP}/${dst}"
done

cp "${DTB_DIR}/rk3566-powkiddy-rgb30.dtb" "${RSCE_TMP}/rk-kernel.dtb"

"${TOOL}" --pack --root="${RSCE_TMP}" --image="${OUT}" \
  $(find "${RSCE_TMP}" -type f | sort)

echo "Packed ${OUT}"
