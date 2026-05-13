# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="onscripter-sa"
PKG_VERSION="0.9"
PKG_LICENSE="GPLv2"
PKG_ARCH="aarch64"
PKG_URL="https://github.com/AveyondFly/console_mod_res/releases/download/v${PKG_VERSION}/onscripter.zip"
PKG_SOURCE_DIR="onscripter"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="onscripter emulator"
PKG_ZIP_STRIP_COMPONENTS="no"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/start_onscripter.sh

  mkdir -p ${INSTALL}/usr/config/onscripter
  cp -rf ${PKG_BUILD}/* ${INSTALL}/usr/config/onscripter/
  chmod +x ${INSTALL}/usr/config/onscripter/onscripter
}
