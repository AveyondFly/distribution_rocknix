# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mcu-led"
PKG_VERSION="1.0"
PKG_LICENSE="GPL-2.0"
PKG_SITE="https://github.com/bmdhacks/dArkOS_rg52mini"
PKG_URL=""
PKG_LONGDESC="AISLPC analog-stick RGB MCU UART control (mcu_led CLI)"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  install -Dm755 ${PKG_DIR}/sources/mcu_led ${INSTALL}/usr/bin/mcu_led
  install -Dm644 ${PKG_DIR}/sources/ledctl.reference.sh \
    ${INSTALL}/usr/share/mcu-led/ledctl.reference.sh
}
