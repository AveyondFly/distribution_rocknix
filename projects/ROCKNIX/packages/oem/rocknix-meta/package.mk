# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rocknix-meta"
PKG_VERSION="0.9"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/AveyondFly/console_mod_res"
PKG_URL="https://github.com/AveyondFly/console_mod_res/releases/download/v${PKG_VERSION}/rocknix_meta.tar.gz"
PKG_DEPENDS_TARGET="toolchain ppsspp-sa drastic_adv-sa"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="Meta package for ROCKNIX custom resources."

makeinstall_target() {
  mkdir -p ${INSTALL}
  tar -xzf ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.tar.gz -C ${INSTALL} --strip-components=1
}
