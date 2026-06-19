#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

set -euo pipefail

log() {
  echo "$*"
}

dt_compatible() {
  tr '\0' ' ' < /proc/device-tree/compatible 2>/dev/null || true
}

dt_model() {
  tr '\0' '\n' < /proc/device-tree/model 2>/dev/null | head -n1 || true
}

find_rk817() {
  local dev base bus addr_hex compatible name

  for dev in /sys/bus/i2c/devices/*-*; do
    [ -d "${dev}" ] || continue

    name="$(cat "${dev}/name" 2>/dev/null || true)"
    compatible=""
    if [ -e "${dev}/of_node/compatible" ]; then
      compatible="$(tr '\0' ' ' < "${dev}/of_node/compatible" 2>/dev/null || true)"
    fi

    case "${name} ${compatible}" in
      *rk817*|*"rockchip,rk817"*) ;;
      *) continue ;;
    esac

    base="${dev##*/}"
    bus="${base%%-*}"
    addr_hex="${base#*-}"
    printf '%s %s\n' "${bus}" "$((16#${addr_hex}))"
    return 0
  done

  return 1
}

if ! dt_compatible | grep -qE 'rockchip,rk3566|rockchip,rk3562'; then
  log "This shutdown fix is only intended for RK3566/RK356X devices."
  log "Model: $(dt_model)"
  exit 1
fi

if ! command -v i2cget >/dev/null 2>&1 || ! command -v i2cset >/dev/null 2>&1; then
  log "i2c-tools are required but were not found."
  exit 1
fi

if ! read -r bus addr < <(find_rk817); then
  log "No RK817 PMIC was found."
  log "Model: $(dt_model)"
  exit 1
fi

log "Model: $(dt_model)"
log "RK817 detected on I2C bus ${bus}, address $(printf '0x%02x' "${addr}")"

old_save0="$(i2cget -f -y "${bus}" "${addr}" 0x99)"
old_save1="$(i2cget -f -y "${bus}" "${addr}" 0xa4)"

log "Before: POWER_EN_SAVE0(0x99)=${old_save0}, POWER_EN_SAVE1(0xa4)=${old_save1}"

i2cset -f -y "${bus}" "${addr}" 0x99 0x00
i2cset -f -y "${bus}" "${addr}" 0xa4 0x00

new_save0="$(i2cget -f -y "${bus}" "${addr}" 0x99)"
new_save1="$(i2cget -f -y "${bus}" "${addr}" 0xa4)"

log "After:  POWER_EN_SAVE0(0x99)=${new_save0}, POWER_EN_SAVE1(0xa4)=${new_save1}"
log "RK817 shutdown state has been reset. Please test shutdown again."
