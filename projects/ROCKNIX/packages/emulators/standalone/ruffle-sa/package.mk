# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 AURKNIX (https://github.com/AveyondFly/distribution_rocknix)

PKG_NAME="ruffle-sa"
PKG_VERSION="0.9"
PKG_LICENSE="MIT OR Apache-2.0"
PKG_ARCH="aarch64"
PKG_URL="https://github.com/AveyondFly/console_mod_res/releases/download/v${PKG_VERSION}/sdl2test-rocknix.tar.gz"
PKG_SHA256="8050c475908da141efae66214027045af491cdfe72593879bf1bc9a0345405f6"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Adobe Flash Player emulator (Ruffle SDL2 frontend for ROCKNIX)"
PKG_TAR_STRIP_COMPONENTS="no"
PKG_SKIP_PATCHES="yes"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/start_ruffle.sh ${INSTALL}/usr/bin/
  chmod 0755 ${INSTALL}/usr/bin/start_ruffle.sh

  mkdir -p ${INSTALL}/usr/config/ruffle
  cp ${PKG_BUILD}/sdl2test-rocknix ${INSTALL}/usr/config/ruffle/
  chmod 0755 ${INSTALL}/usr/config/ruffle/sdl2test-rocknix
  cp ${PKG_DIR}/config/ruffle.gptk ${INSTALL}/usr/config/ruffle/
}
