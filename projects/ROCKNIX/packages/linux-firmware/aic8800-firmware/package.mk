# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="aic8800-firmware"
PKG_VERSION="faf08007fb25ed0372245e710b3577516d20dc17"
PKG_LICENSE="Proprietary"
PKG_SITE="https://github.com/AveyondFly/aic8800-fw"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_SOURCE_DIR="aic8800-fw-${PKG_VERSION}"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="AIC8800D80 SDIO WiFi/BT firmware for RG52 Mini"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/aic8800
  cp -av ${PKG_BUILD}/*.bin ${PKG_BUILD}/*.txt \
        ${INSTALL}/$(get_full_firmware_dir)/aic8800/
}
