#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Prepare offline OTA: user places *.tar under /storage/roms/.update/,
# this script writes /storage/.update/redirect_part for initramfs.

set -e

. /etc/profile

export XDG_RUNTIME_DIR=/var/run/0-runtime-dir
export WAYLAND_DISPLAY=wayland-1
export DISPLAY=:0.0

ASSET_DIR="/usr/share/misc/offline-update"
UPDATE_MARKER_DIR="/storage/.update"
UPDATE_ROMS_DIR="/storage/roms/.update"
REDIRECT_FILE="${UPDATE_MARKER_DIR}/redirect_part"
DISTRO_PREFIX="AURKNIX"

show_image() {
  local img="${1}"
  set +e
  killall -9 mpv 2>/dev/null
  set -e
  if [ -f "${ASSET_DIR}/${img}" ]; then
    mpv --loop-file=inf --fullscreen --no-terminal "${ASSET_DIR}/${img}" >/dev/null 2>&1 &
  fi
}

stop_mpv() {
  killall -9 mpv 2>/dev/null || true
}

show_failure() {
  show_image "deploy-failed.png"
  sleep 5
  stop_mpv
}

block_device_for_path() {
  df "$1" 2>/dev/null | awk 'NR==2 {print $1}'
}

find_update_tar() {
  local tar pkg_prefix

  if [ -z "${HW_DEVICE}" ] || [ -z "${HW_ARCH}" ]; then
    echo "Error: HW_DEVICE or HW_ARCH not set (source /etc/profile)." >&2
    return 1
  fi

  pkg_prefix="${DISTRO_PREFIX}-${HW_DEVICE}.${HW_ARCH}-"
  tar=$(ls -1 "${UPDATE_ROMS_DIR}/${pkg_prefix}"*.tar 2>/dev/null | sort -r | head -n 1)

  if [ -z "${tar}" ]; then
    echo "Error: no OTA package matching ${pkg_prefix}*.tar in ${UPDATE_ROMS_DIR}" >&2
    echo "Available packages:" >&2
    ls -1 "${UPDATE_ROMS_DIR}"/*.tar 2>/dev/null | sed 's/^/  /' >&2 || true
    return 1
  fi

  printf '%s\n' "${tar}"
}

verify_checksum() {
  local tar_file="${1}"
  local checksum_file="${tar_file}.sha256"

  [ -f "${checksum_file}" ] || return 0

  local expected actual
  expected=$(awk '{print $1}' "${checksum_file}")
  actual=$(sha256sum "${tar_file}" | awk '{print $1}')
  [ "${expected}" = "${actual}" ]
}

prepare_redirect() {
  local update_tar="${1}"
  local roms_dev storage_dev

  if ! mountpoint -q /storage/roms 2>/dev/null; then
    echo "Error: /storage/roms is not mounted."
    return 1
  fi

  roms_dev=$(block_device_for_path "/storage/roms")
  storage_dev=$(block_device_for_path "/storage")
  if [ -z "${roms_dev}" ]; then
    echo "Error: could not resolve block device for /storage/roms."
    return 1
  fi

  case "${roms_dev}" in
    /dev/*) ;;
    *)
      echo "Error: /storage/roms is not backed by a block device (${roms_dev})."
      echo "Use an external SD card partition or free space on /storage/.update instead."
      return 1
      ;;
  esac

  if [ "${roms_dev}" = "${storage_dev}" ]; then
    echo "Error: /storage/roms uses the same partition as /storage."
    echo "Place the update package in ${UPDATE_MARKER_DIR} instead, or use external storage."
    return 1
  fi

  mkdir -p "${UPDATE_MARKER_DIR}" "${UPDATE_ROMS_DIR}"
  echo "${roms_dev}" > "${REDIRECT_FILE}"
  sync

  echo "Update package: ${update_tar}"
  echo "Redirect device: ${roms_dev}"
  echo "Marker file: ${REDIRECT_FILE}"
  return 0
}

echo "=== AURKNIX Offline Upgrade ==="

show_image "preparing-upgrade.png"

update_tar=$(find_update_tar) || {
  show_failure
  exit 1
}

if ! verify_checksum "${update_tar}"; then
  echo "Error: checksum verification failed for ${update_tar}"
  rm -f "${REDIRECT_FILE}"
  show_failure
  exit 1
fi

if ! prepare_redirect "${update_tar}"; then
  rm -f "${REDIRECT_FILE}"
  show_failure
  exit 1
fi

echo "============================================="
echo "Offline upgrade is ready."
echo "Reboot the device to apply the update."
echo "============================================="

show_image "deploy-success.png"
sleep 5
stop_mpv
