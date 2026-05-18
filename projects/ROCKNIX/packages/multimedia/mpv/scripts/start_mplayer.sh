#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2020-present redwolftech
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "mpv"
systemctl start mpv

FBWIDTH="$(fbwidth)"
FBHEIGHT="$(fbheight)"

if [[ ${FBWIDTH} -ge ${FBHEIGHT} ]]; then
  RES="${FBWIDTH}x${FBHEIGHT}"
else
  RES="${FBHEIGHT}x${FBWIDTH}"
fi

VID=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}" | sed 's/^-P//')

HW=$(get_setting hwdec "${PLATFORM}" "${VID}")
if [ "${HW}" = true ]; then
   HW_DEC="--vo=dmabuf-wayland --drm-device=/dev/dri/card0"
fi
#--vo=dmabuf-wayland --drm-device=/dev/dri/card0
/usr/bin/mpv --fullscreen --geometry=${RES}  --hwdec=auto-safe $HW_DEC --input-gamepad=yes --input-ipc-server=/tmp/mpvsocket "${1}"
systemctl stop mpv
exit 0
