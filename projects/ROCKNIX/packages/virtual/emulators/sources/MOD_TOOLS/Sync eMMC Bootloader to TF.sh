#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)
#
# Copy stock eMMC bootloader (idbloader + U-Boot FIT) to the TF card, and copy
# EmuELEC boot assets (*.dtb, *.bmp, *.png) onto the AURKNIX /flash partition.
#
# Intended for RK3562 handhelds booting AURKNIX from SD while eMMC still has
# the factory EmuELEC install (LABEL=EMUELEC). Always overwrites in place.

set -euo pipefail

SECTOR_SIZE=512
IDBLOADER_SKIP=64
IDBLOADER_COUNT=16320
FIT_SEEK=16384
FIT_COUNT=8192

log() {
  echo "$*"
}

die() {
  log "Error: $*"
  exit 1
}

require_root() {
  [[ "$(id -u)" -eq 0 ]] || die "run as root (sudo)."
}

mmc_type() {
  local dev="$1"
  local base="${dev#/dev/}"
  cat "/sys/block/${base}/device/type" 2>/dev/null || true
}

partition_disk() {
  local part="$1"
  local base="${part#/dev/}"

  if [[ "${base}" =~ ^(mmcblk[0-9]+)p[0-9]+$ ]]; then
    echo "/dev/${BASH_REMATCH[1]}"
    return 0
  fi

  if [[ "${base}" =~ ^(mmcblk[0-9]+)$ ]]; then
    echo "/dev/${base}"
    return 0
  fi

  return 1
}

find_emuelec_partition() {
  local emmc_disk="$1"
  local part label

  for part in "${emmc_disk}"p*; do
    [[ -b "${part}" ]] || continue
    label="$(blkid -s LABEL -o value "${part}" 2>/dev/null || true)"
    [[ "${label}" = "EMUELEC" ]] && { echo "${part}"; return 0; }
  done

  return 1
}

require_root

if ! tr '\0' ' ' < /proc/device-tree/compatible 2>/dev/null | grep -q 'rockchip,rk3562'; then
  die "this tool is only for RK3562 devices (rockchip,rk3562)."
fi

FLASH_PART="$(awk '$2=="/flash"{print $1; exit}' /proc/mounts)"
[[ -n "${FLASH_PART}" && -b "${FLASH_PART}" ]] || die "/flash is not mounted from a block device."

TF_DISK="$(partition_disk "${FLASH_PART}")" || die "could not resolve TF card disk from ${FLASH_PART}."
[[ "$(mmc_type "${TF_DISK}")" = "SD" ]] || die "${TF_DISK} is not an SD card (type=$(mmc_type "${TF_DISK}"))."

EMMC_DISK=""
for dev in /dev/mmcblk*; do
  [[ -b "${dev}" ]] || continue
  [[ "${dev}" =~ p[0-9]+$ ]] && continue
  [[ "$(mmc_type "${dev}")" = "MMC" ]] && EMMC_DISK="${dev}" && break
done
[[ -n "${EMMC_DISK}" && -b "${EMMC_DISK}" ]] || die "no internal eMMC (MMC) block device found."

EMUELEC_PART="$(find_emuelec_partition "${EMMC_DISK}" || true)"
[[ -n "${EMUELEC_PART}" && -b "${EMUELEC_PART}" ]] || die "no EMUELEC partition found on eMMC."

log "=== Sync eMMC Bootloader to TF ==="
log "TF card:       ${TF_DISK} (AURKNIX boot on ${FLASH_PART})"
log "eMMC:          ${EMMC_DISK}"
log "EmuELEC:       ${EMUELEC_PART} -> /flash"
log

log "[1/2] Copying eMMC idbloader -> ${TF_DISK} @ sector ${IDBLOADER_SKIP}..."
dd if="${EMMC_DISK}" of="${TF_DISK}" bs=${SECTOR_SIZE} \
  skip=${IDBLOADER_SKIP} seek=${IDBLOADER_SKIP} count=${IDBLOADER_COUNT} \
  conv=fsync,notrunc status=none

log "[2/2] Copying eMMC U-Boot FIT -> ${TF_DISK} @ sector ${FIT_SEEK}..."
dd if="${EMMC_DISK}" of="${TF_DISK}" bs=${SECTOR_SIZE} \
  skip=${FIT_SEEK} seek=${FIT_SEEK} count=${FIT_COUNT} \
  conv=fsync,notrunc status=none

MNT="$(mktemp -d)"
cleanup() {
  umount "${MNT}" 2>/dev/null || true
  rmdir "${MNT}" 2>/dev/null || true
  mount -o remount,ro /flash 2>/dev/null || true
}
trap cleanup EXIT

mount -o ro "${EMUELEC_PART}" "${MNT}"

if ! mount -o remount,rw /flash; then
  die "could not remount /flash read-write."
fi

copied=0
shopt -s nullglob
for src in "${MNT}"/*.dtb "${MNT}"/*.bmp "${MNT}"/*.png; do
  base="$(basename "${src}")"
  log "Copying ${base} -> /flash/${base}"
  cp -af "${src}" "/flash/${base}"
  copied=$((copied + 1))
done
shopt -u nullglob

if [[ ${copied} -eq 0 ]]; then
  log "Warning: no *.dtb, *.bmp, or *.png files found on ${EMUELEC_PART}."
else
  log "Copied ${copied} boot asset file(s) to /flash."
fi

mount -o remount,ro /flash
sync

log
log "Done. Power off completely, then cold boot from the TF card to test."
