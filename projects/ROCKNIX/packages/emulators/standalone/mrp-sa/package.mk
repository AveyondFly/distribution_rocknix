# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mrp-sa"
PKG_VERSION="0.9"
PKG_LICENSE="GPLv2"
PKG_ARCH="aarch64"
PKG_URL="https://github.com/AveyondFly/console_mod_res/releases/download/v${PKG_VERSION}/mrpoid-sdl2-arm.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="MRP emulator"
PKG_TAR_STRIP_COMPONENTS="no"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/start_mrp.sh
  cp -rf ${PKG_BUILD}/mrpoid-sdl2-arm ${INSTALL}/usr/bin/

  mkdir -p ${INSTALL}/usr/config/mrp
  cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/config/mrp/
}
