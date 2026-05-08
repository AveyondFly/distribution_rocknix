# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="quirks"
PKG_VERSION=""
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain autostart"
PKG_LONGDESC="Quirks is a simple package that provides device quirks."
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/autostart/quirks/{bin,platforms,devices}

  cp ${PKG_DIR}/bin/* ${INSTALL}/usr/lib/autostart/quirks/bin

  # Copy all device quirks (QUIRK_DEVICE is determined at runtime from device tree)
  cp -r ${PKG_DIR}/devices/* ${INSTALL}/usr/lib/autostart/quirks/devices

  # Copy only the current platform's quirks (DEVICE is known at build time)
  if [ -d "${PKG_DIR}/platforms/${DEVICE}" ]
  then
    mkdir -p ${INSTALL}/usr/lib/autostart/quirks/platforms/${DEVICE}
    cp -r ${PKG_DIR}/platforms/${DEVICE}/* ${INSTALL}/usr/lib/autostart/quirks/platforms/${DEVICE}/
  fi

  chmod -R 0755 ${INSTALL}/usr/lib/autostart/quirks
}

post_install() {
  enable_service led-poweroff.service
  if [ "${DEVICE}" = "RK3326" -o "${DEVICE}" = "RK3566" ]; then
    enable_service volume-fixup.service
  fi
  if [ "${DEVICE}" = "S905L3A" ]; then
    enable_service persist-mac.service
    enable_service s905l3a-audio.service
  fi
}
