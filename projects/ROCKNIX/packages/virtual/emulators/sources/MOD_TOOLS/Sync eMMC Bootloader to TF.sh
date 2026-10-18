#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)
#
# Copy the factory eMMC bootloader and boot assets to the AURKNIX TF card.
# Supports EmuELEC (EMUELEC) and AIS (AISROCK, partition name aisos).
# Keep the distribution's selected DTBs and extlinux configuration intact.
# --dry-run checks the real disks and lists assets without writing to them.

set -euo pipefail

SECTOR_SIZE=512
IDBLOADER_SKIP=64
IDBLOADER_COUNT=16320
FIT_SEEK=16384
FIT_COUNT=8192
BOOTLOADER_COUNT=$((FIT_SEEK + FIT_COUNT - IDBLOADER_SKIP))

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

factory_system() {
  case "$1" in
    EMUELEC) echo EmuELEC ;;
    AISROCK) echo AIS ;;
    *) return 1 ;;
  esac
}

find_factory_partition() {
  local emmc_disk="$1"
  local part label

  for part in "${emmc_disk}"p*; do
    [[ -b "${part}" ]] || continue
    label="$(blkid -s LABEL -o value "${part}" 2>/dev/null || true)"
    if factory_system "${label}" >/dev/null; then echo "${part}"; return 0; fi
  done

  return 1
}

first_partition_sector() {
  local disk="${1#/dev/}" start_file start first=0
  for start_file in /sys/class/block/"${disk}"p*/start; do
    [[ -r "${start_file}" ]] || continue
    start="$(cat "${start_file}")"
    if (( first == 0 || start < first )); then first=${start}; fi
  done
  (( first > 0 )) || return 1
  echo "${first}"
}

validate_tf_layout() {
  local first="$1"
  [[ "${first}" =~ ^[0-9]+$ ]] || die "invalid TF partition start."
  (( first >= FIT_SEEK + FIT_COUNT )) || die "TF partitions overlap the bootloader write range."
}

validate_ais_layout() {
  [[ "$1" = aisos && "$2" = "${FIT_SEEK}" &&
     "$3" = "${FIT_COUNT}" && "$4" = uboot ]] || die "unsupported AIS U-Boot partition layout."
}

selected_dtbs() {
  # Protect every extlinux entry, including alternate/fallback boot entries.
  awk 'toupper($1)=="FDT" {sub(/^\//, "", $2); print $2}' "$1"
}

sync_assets() {
  local source="$1" target="$2" backup="$3" dry_run="$4"
  local src rel selected protected manifest copied=0
  manifest="$(mktemp "${WORK:-/tmp}/boot-assets.XXXXXXXX")"
  find "${source}" -type f \( -iname '*.dtb' -o -iname '*.bmp' -o -iname '*.png' \) -print0 >"${manifest}"
  while IFS= read -r -d '' src; do
    rel="${src#"${source}/"}"
    protected=no
    for selected in "${SELECTED_DTBS[@]}"; do
      if [[ "${rel,,}" = "${selected,,}" ]]; then protected=yes; break; fi
    done
    if [[ "${protected}" = yes ]]; then
      log "Keeping selected DTB: ${rel}"
      continue
    fi
    log "Copying ${rel} -> ${target}/${rel}"
    if [[ "${dry_run}" = no ]]; then
      if [[ -f "${target}/${rel}" ]]; then
        mkdir -p "${backup}/$(dirname "${rel}")"
        cp -f "${target}/${rel}" "${backup}/${rel}"
      fi
      mkdir -p "${target}/$(dirname "${rel}")"
      cp -f "${src}" "${target}/${rel}.sync-bootloader.tmp"
      mv -f "${target}/${rel}.sync-bootloader.tmp" "${target}/${rel}"
    fi
    copied=$((copied + 1))
  done < "${manifest}"
  rm -f "${manifest}"
  log "Boot assets: ${copied} file(s)."
}

read_bootloader() {
  dd if="$1" of="$2" bs=${SECTOR_SIZE} skip=${IDBLOADER_SKIP} \
    count=${BOOTLOADER_COUNT} status=none
  [[ "$(wc -c < "$2")" -eq $((BOOTLOADER_COUNT * SECTOR_SIZE)) ]] || die "short bootloader read."
}

write_bootloader() {
  local image="$1" disk="$2" expected actual
  [[ "$(wc -c < "${image}")" -eq $((BOOTLOADER_COUNT * SECTOR_SIZE)) ]] || die "invalid staged bootloader size."
  expected="$(sha256sum "${image}" | awk '{print $1}')"
  dd if="${image}" of="${disk}" bs=${SECTOR_SIZE} seek=${IDBLOADER_SKIP} \
    count=${BOOTLOADER_COUNT} conv=fsync,notrunc status=none
  actual="$(dd if="${disk}" bs=${SECTOR_SIZE} skip=${IDBLOADER_SKIP} \
    count=${BOOTLOADER_COUNT} status=none | sha256sum | awk '{print $1}')"
  [[ "${actual}" = "${expected}" ]] || die "TF bootloader readback verification failed; backup: ${BACKUP_DIR}."
  log "Verified TF bootloader SHA256: ${actual}"
}

cleanup() {
  if [[ "${FLASH_REMOUNTED:-no}" = yes ]]; then mount -o remount,ro /flash || true; fi
  if [[ "${FACTORY_MOUNTED:-no}" = yes ]]; then
    # Do not remove the temporary directory if the filesystem is still mounted.
    umount "${WORK}/factory" || return
  fi
  [[ -z "${WORK:-}" ]] || rm -rf "${WORK}"
}

main() {
  local dry_run=no dev label factory_name first selected
  local -a factory_dtbs
  case "${1:-}" in
    --dry-run) dry_run=yes ;;
    --help|-h) echo "Usage: $0 [--dry-run]"; return ;;
    '') ;;
    *) die "unknown option: $1" ;;
  esac
  (( $# <= 1 )) || die "too many arguments."
  require_root
  if ! tr '\0' ' ' < /proc/device-tree/compatible 2>/dev/null | grep -q 'rockchip,rk3562'; then
    die "this tool is only for RK3562 devices (rockchip,rk3562)."
  fi

  FLASH_PART="$(awk '$2=="/flash"{print $1; exit}' /proc/mounts)"
  [[ -n "${FLASH_PART}" && -b "${FLASH_PART}" ]] || die "/flash is not mounted from a block device."
  TF_DISK="$(partition_disk "${FLASH_PART}")" || die "could not resolve TF card disk."
  [[ "$(mmc_type "${TF_DISK}")" = SD ]] || die "${TF_DISK} is not an SD card."
  EMMC_DISK=""
  for dev in /dev/mmcblk*; do
    [[ -b "${dev}" ]] || continue
    [[ "${dev}" =~ p[0-9]+$ ]] && continue
    if [[ "$(mmc_type "${dev}")" = MMC ]]; then EMMC_DISK="${dev}"; break; fi
  done
  [[ -n "${EMMC_DISK}" && "${EMMC_DISK}" != "${TF_DISK}" ]] || die "no separate internal eMMC found."
  for dev in "${TF_DISK}" "${EMMC_DISK}"; do
    [[ "$(blockdev --getss "${dev}")" = "${SECTOR_SIZE}" ]] || die "${dev} does not use 512-byte sectors."
  done
  first="$(first_partition_sector "${TF_DISK}")" || die "could not read TF partition boundaries."
  validate_tf_layout "${first}"

  FACTORY_PART="$(find_factory_partition "${EMMC_DISK}" || true)"
  [[ -n "${FACTORY_PART}" ]] || die "no EMUELEC or AISROCK partition found on eMMC."
  label="$(blkid -s LABEL -o value "${FACTORY_PART}")"
  factory_name="$(factory_system "${label}")"
  if [[ "${label}" = AISROCK ]]; then
    validate_ais_layout "$(blkid -s PARTLABEL -o value "${FACTORY_PART}")" \
      "$(cat "/sys/class/block/${EMMC_DISK#/dev/}p1/start")" \
      "$(cat "/sys/class/block/${EMMC_DISK#/dev/}p1/size")" \
      "$(blkid -s PARTLABEL -o value "${EMMC_DISK}p1")"
  fi

  log "=== Sync eMMC Bootloader to TF (${factory_name}) ==="
  log "TF card: ${TF_DISK}; /flash: ${FLASH_PART}; first partition: ${first}"
  log "Factory: ${EMMC_DISK}; ${FACTORY_PART} (LABEL=${label})"
  log "Write range: sectors ${IDBLOADER_SKIP}..$((FIT_SEEK + FIT_COUNT - 1))"
  WORK="$(mktemp -d)"
  FACTORY_MOUNTED=no
  FLASH_REMOUNTED=no
  trap cleanup EXIT
  mkdir "${WORK}/factory"
  mount -o ro "${FACTORY_PART}" "${WORK}/factory"
  FACTORY_MOUNTED=yes

  SELECTED_DTBS=()
  if [[ -f /flash/extlinux/extlinux.conf ]]; then
    mapfile -t SELECTED_DTBS < <(selected_dtbs /flash/extlinux/extlinux.conf)
  fi
  if [[ "${factory_name}" = AIS ]]; then
    (( ${#SELECTED_DTBS[@]} > 0 )) || die "AIS sync requires an extlinux FDT entry."
    [[ -s "${WORK}/factory/extlinux/extlinux.conf" ]] || die "AIS factory extlinux configuration is missing."
    mapfile -t factory_dtbs < <(selected_dtbs "${WORK}/factory/extlinux/extlinux.conf")
    (( ${#factory_dtbs[@]} > 0 )) || die "AIS factory extlinux has no FDT entry."
    for selected in "${factory_dtbs[@]}"; do
      [[ -s "${WORK}/factory/${selected}" ]] || die "AIS factory DTB is missing: ${selected}"
    done
  fi
  for selected in "${SELECTED_DTBS[@]}"; do
    [[ -s "/flash/${selected}" ]] || die "selected DTB is missing: ${selected}"
    log "Keeping extlinux FDT: ${selected}"
  done
  # Read both source ranges before changing any boot files or the TF bootloader.
  read_bootloader "${EMMC_DISK}" "${WORK}/factory-bootloader.bin"
  log "Factory bootloader SHA256: $(sha256sum "${WORK}/factory-bootloader.bin" | awk '{print $1}')"
  if [[ "${dry_run}" = yes ]]; then
    sync_assets "${WORK}/factory" /flash "" yes
    log "Dry run complete; no boot assets or raw devices were written."
    return
  fi

  BACKUP_DIR="$(mktemp -d /storage/.config/bootloader-sync.XXXXXXXX)"
  read_bootloader "${TF_DISK}" "${BACKUP_DIR}/tf-bootloader.bin"
  log "TF backup: ${BACKUP_DIR} (starts at sector ${IDBLOADER_SKIP})"
  printf 'TF_DISK=%s\nFLASH_PART=%s\nEMMC_DISK=%s\nFACTORY_PART=%s\nSECTOR_SIZE=%s\nSTART=%s\nCOUNT=%s\n' \
    "${TF_DISK}" "${FLASH_PART}" "${EMMC_DISK}" "${FACTORY_PART}" \
    "${SECTOR_SIZE}" "${IDBLOADER_SKIP}" "${BOOTLOADER_COUNT}" >"${BACKUP_DIR}/layout.txt"
  sha256sum "${BACKUP_DIR}/tf-bootloader.bin" >"${BACKUP_DIR}/SHA256SUMS"

  if awk '$2=="/flash"{print $4}' /proc/mounts | grep -Eq '(^|,)ro(,|$)'; then
    mount -o remount,rw /flash || die "could not remount /flash read-write."
    FLASH_REMOUNTED=yes
  fi
  # Prepare the factory U-Boot's DTB/images before installing its boot code.
  sync_assets "${WORK}/factory" /flash "${BACKUP_DIR}/assets" no
  sync
  write_bootloader "${WORK}/factory-bootloader.bin" "${TF_DISK}"
  sync
  log "Done. Power off completely, then cold boot from the TF card to test."
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then main "$@"; fi
