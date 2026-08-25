# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="configtools"
PKG_VERSION="28ea239c53a2d5d8800c472bc2452eaa16e37af2"
PKG_SHA256="f78737b2a11e7b47dfacc0345c0ca2fbf538b7455efbaf7459ccc570a9cddf87"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/risqcapital/gnu-config-mirror"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST=""
PKG_LONGDESC="configtools"
PKG_TOOLCHAIN="manual"

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/configtools
  cp config.* ${TOOLCHAIN}/configtools
}
