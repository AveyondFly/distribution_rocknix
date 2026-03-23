# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="drastic_adv-sa"
PKG_VERSION="0.9"
PKG_LICENSE="Proprietary:DRASTIC.pdf"
PKG_ARCH="aarch64"
PKG_URL="https://github.com/AveyondFly/console_mod_res/releases/download/v${PKG_VERSION}/drastic.tar.gz"
PKG_DEPENDS_TARGET="toolchain drastic-sa drastic_adv"
PKG_LONGDESC="Drastic NDS emulator with advanced display features - overlay package"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/drastic
  cp -rf ${PKG_BUILD}/config ${INSTALL}/usr/config/drastic/
  cp -rf ${PKG_BUILD}/lib ${INSTALL}/usr/config/drastic/
  cp -rf ${PKG_BUILD}/resources ${INSTALL}/usr/config/drastic/
  cp -f ${PKG_BUILD}/drastic ${INSTALL}/usr/config/drastic/
  cp -f ${PKG_BUILD}/usrcheat.dat ${INSTALL}/usr/config/drastic/usrcheat_chs.dat
  cp -f ${PKG_BUILD}/drastic.gptk ${INSTALL}/usr/config/drastic/

  # Download and install layout resources
  LAYOUT_URL="https://codeload.github.com/AveyondFly/drastic_layout/tar.gz/master"
  wget -O ${PKG_BUILD}/layout.tar.gz "${LAYOUT_URL}"
  tar -xzf ${PKG_BUILD}/layout.tar.gz -C ${PKG_BUILD}
  if [ -d "${PKG_BUILD}/drastic_layout-master/bg" ]; then
    mkdir -p ${INSTALL}/usr/config/drastic/resources
    cp -rf ${PKG_BUILD}/drastic_layout-master/bg ${INSTALL}/usr/config/drastic/resources/
  fi
}
