# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="eka2l1-sa"
PKG_VERSION="0.9"
PKG_LICENSE="GPLv2"
PKG_ARCH="aarch64"
PKG_URL="https://github.com/AveyondFly/console_mod_res/releases/download/v${PKG_VERSION}/eka2l1_sdl2.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="eka2l1"
PKG_TAR_STRIP_COMPONENTS="no"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/eka2l1/scripts
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/config/eka2l1/scripts/
  chmod +x ${INSTALL}/usr/config/eka2l1/scripts/start_eka2l1.sh
  mkdir -p ${INSTALL}/usr/bin
  ln -sf /storage/.config/eka2l1/scripts/start_eka2l1.sh ${INSTALL}/usr/bin/start_eka2l1.sh

  cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/config/eka2l1/
  cp -rf ${PKG_BUILD}/eka2l1_sdl2 ${INSTALL}/usr/config/eka2l1/
}
