#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)
#
# Detect image subdevice from extlinux.conf and /etc/os-release.
# Usage: . detect_subdevice.sh && detect_subdevice [BOOT_ROOT] [SYSTEM_ROOT]
# Sets: SUBDEVICE, HW_DEVICE

detect_subdevice() {
  local boot_root="${1:-/flash}"
  local system_root="${2:-}"
  local os_release="${system_root}/etc/os-release"
  local extlinux="${boot_root}/extlinux/extlinux.conf"
  local fdt

  SUBDEVICE=""
  HW_DEVICE=""

  if [ -f "${os_release}" ]; then
    HW_DEVICE=$(grep '^HW_DEVICE=' "${os_release}" | cut -d= -f2 | tr -d '"')
  fi

  [ -f "${extlinux}" ] || return 0

  if grep -q '^[^#]*FDTDIR ' "${extlinux}"; then
    case "${HW_DEVICE}" in
      RK356X) SUBDEVICE="RK3566-Generic" ;;
      RK3566) SUBDEVICE="Generic" ;;
    esac
    return 0
  fi

  fdt=$(grep '^[^#]*FDT ' "${extlinux}" | awk '{print $2}')
  [ -n "${fdt}" ] || return 0

  case "${fdt}" in
    *rk3562*)
      SUBDEVICE="RK3562"
      ;;
    *rk3566*)
      case "${HW_DEVICE}" in
        RK356X) SUBDEVICE="RK3566-Specific" ;;
        RK3566) SUBDEVICE="Specific" ;;
      esac
      ;;
  esac
}
