#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

CONFIG_DIR="/storage/.config/yabasanshiro"
ES_INPUT="/storage/.emulationstation/es_input.cfg"
DEVICES_DIR="/usr/config/yabasanshiro/devices"
JOYGUID_BIN="/usr/bin/joyguid"
FORCE=0
QUIET=0

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Generate YabaSanshiro input.cfg from the current controller via joyguid
and /storage/.emulationstation/es_input.cfg.

Options:
  -f, --force   Remove existing input.cfg and keymapv2.json before regenerating
  -q, --quiet   Suppress informational output
  -h, --help    Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    -f|--force) FORCE=1 ;;
    -q|--quiet) QUIET=1 ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

log() {
  [ "${QUIET}" -eq 1 ] || echo "$@"
}

err() {
  echo "$@" >&2
}

lookup_by_guid() {
  local guid="$1"

  [ "${#guid}" -eq 32 ] || return 1
  [ -f "${ES_INPUT}" ] || return 1

  GAMEPADCONFIG=$(xmlstarlet sel -t -c \
    "//inputList/inputConfig[@deviceGUID=\"${guid}\"]" -n "${ES_INPUT}")
  MAPPING_NAME=$(xmlstarlet sel -t -v \
    "//inputList/inputConfig[@deviceGUID=\"${guid}\"]/@deviceName" "${ES_INPUT}")

  [ -n "${GAMEPADCONFIG}" ] && [ -n "${MAPPING_NAME}" ]
}

lookup_by_device_name() {
  local gamepad="$1"

  [ -f "${ES_INPUT}" ] || return 1

  GAMEPADCONFIG=$(xmlstarlet sel -t -c \
    "//inputList/inputConfig[@deviceName=${gamepad}]" -n "${ES_INPUT}")
  MAPPING_NAME=$(eval echo "${gamepad}")

  [ -n "${GAMEPADCONFIG}" ] && [ -n "${MAPPING_NAME}" ]
}

detect_gamepad_config() {
  local guid=""

  GAMEPADCONFIG=""
  MAPPING_NAME=""

  if [ -x "${JOYGUID_BIN}" ]; then
    guid=$("${JOYGUID_BIN}" 2>/dev/null | tr -d '\n')
    if lookup_by_guid "${guid}"; then
      log "Matched controller by GUID: ${guid} (${MAPPING_NAME})"
      return 0
    fi
    log "No es_input.cfg entry for GUID: ${guid}"
  else
    log "joyguid not found, using fallback detection"
  fi

  if [[ "${HW_DEVICE}" =~ SM8550|SM8650 ]]; then
    lookup_by_device_name "'InputPlumber GameController'" && return 0
  elif grep -q "js0" /proc/bus/input/devices 2>/dev/null; then
    lookup_by_device_name "'$(grep -b4 js0 /proc/bus/input/devices | awk 'BEGIN {FS="\""}; /Name/ {printf $2}')'" && return 0
  elif grep -q "joypad" /proc/bus/input/devices 2>/dev/null; then
    lookup_by_device_name "'$(grep -b4 joypad /proc/bus/input/devices | awk 'BEGIN {FS="\""}; /Name/ {printf $2}')'" && return 0
  fi

  return 1
}

write_input_cfg() {
  cat <<EOF >"${CONFIG_DIR}/input.cfg"
<?xml version="1.0"?>
<inputList>
${GAMEPADCONFIG}
</inputList>
EOF
}

install_keymap() {
  local mapping_file="${DEVICES_DIR}/keymapv2_${MAPPING_NAME}.json"

  if [ -e "${mapping_file}" ]; then
    cp "${mapping_file}" "${CONFIG_DIR}/keymapv2.json"
    log "Installed preset keymap: ${mapping_file}"
  else
    rm -f "${CONFIG_DIR}/keymapv2.json"
    log "No preset keymap for ${MAPPING_NAME}; YabaSanshiro will build keymapv2.json from input.cfg"
  fi
}

if [ "${FORCE}" -eq 1 ]; then
  rm -f "${CONFIG_DIR}/input.cfg" "${CONFIG_DIR}/keymapv2.json"
  log "Removed existing YabaSanshiro input configuration"
elif [ -e "${CONFIG_DIR}/input.cfg" ]; then
  log "input.cfg already exists (${CONFIG_DIR}/input.cfg); use --force to regenerate"
  exit 0
else
  rm -f "${CONFIG_DIR}/keymapv2.json"
fi

mkdir -p "${CONFIG_DIR}"

if ! detect_gamepad_config; then
  err "Failed to detect controller or find a matching entry in ${ES_INPUT}"
  exit 1
fi

write_input_cfg
install_keymap

log "Wrote ${CONFIG_DIR}/input.cfg for ${MAPPING_NAME}"
