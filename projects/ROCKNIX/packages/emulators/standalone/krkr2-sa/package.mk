# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="krkr2-sa"
PKG_VERSION="0.9"
PKG_LICENSE="GPLv2"
PKG_ARCH="aarch64"
PKG_URL="https://github.com/AveyondFly/console_mod_res/releases/download/v${PKG_VERSION}/krkr2_sdl2.tar.gz"
PKG_SHA256="a146b08f2cbe959ad02f2ba7ca8c806b142361600714a85b8e9315d4d578f996"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Kirikiri2 (KrKr2) visual novel engine"
PKG_TAR_STRIP_COMPONENTS="no"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/start_krkr2.sh

  mkdir -p ${INSTALL}/usr/config/krkr2
  cp -rf ${PKG_BUILD}/krkr2_sdl2 ${INSTALL}/usr/config/krkr2/
  chmod +x ${INSTALL}/usr/config/krkr2/krkr2_sdl2
  cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/config/krkr2/
}
