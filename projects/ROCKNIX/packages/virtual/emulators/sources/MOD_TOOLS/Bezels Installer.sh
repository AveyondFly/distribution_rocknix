#!/bin/bash

. /etc/profile

ROM_DIR="/storage/roms"
TARGET_RES="1920x1080 1080x1920 1024x768 1280x720 720x1280 960x720 720x960 544x960 960x544 720x720 480x640 640x480 480x320 320x480"
FORCE_INSTALL=1
RESOLUTION_ARG=""

detect_resolution() {
  local detected_res

  detected_res="$1"

  if [ -z "${detected_res}" ]; then
    detected_res=$(
      grep -oE '(1920x1080|1080x1920|1280x720|1024x768|960x720|720x960|720x1280|960x544|544x960|720x720|640x480|480x640|480x320|320x480)' /sys/class/graphics/fb0/modes 2>/dev/null |
      grep -xE "$(echo "${TARGET_RES}" | tr ' ' '|')" |
      head -n1
    )

    if [[ -n "${detected_res}" ]]; then
      IFS='x' read -r width height <<< "${detected_res}"
      if (( width < height )); then
        detected_res="${height}x${width}"
      fi
    fi
  fi

  echo "${detected_res}"
}

ensure_bezel_archives() {
  mkdir -p /storage/bezels

  if ! compgen -G "/storage/bezels/bezels_*.zip" >/dev/null; then
    cp /usr/share/misc/bezels_*.zip /storage/bezels/ 2>/dev/null
  fi
}

for arg in "$@"; do
  case "${arg}" in
    --skip-existing)
      FORCE_INSTALL=0
      ;;
    --force)
      FORCE_INSTALL=1
      ;;
    *)
      RESOLUTION_ARG="${arg}"
      ;;
  esac
done

if [ "${FORCE_INSTALL}" -eq 0 ] && { [ -e "/roms/bezels/gba" ] || [ -e "${ROM_DIR}/bezels/gba" ]; }; then
  echo "Bezels already installed, skip" >/dev/tty0
  exit 0
fi

detected_res="$(detect_resolution "${RESOLUTION_ARG}")"

if [ -z "${detected_res}" ]; then
  echo "Unable to detect bezel resolution, skip" >/dev/tty0
  exit 1
fi

ensure_bezel_archives

target_zip="/storage/bezels/bezels_${detected_res}.zip"

if [ -f "${target_zip}" ]; then
  mkdir -p "${ROM_DIR}/bezels"
  unzip -oq "${target_zip}" -d "${ROM_DIR}/bezels/" || echo "Bezels file broken!" >/dev/tty0
else
  echo "Bezels not found for ${detected_res}, skip" >/dev/tty0
  exit 1
fi
