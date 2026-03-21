# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="gam4980-lr"
PKG_VERSION="main"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ThisBoringWorld/gam4980"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro core for BBK Longman 4980 electronic dictionary game emulator."
PKG_TOOLCHAIN="manual"

make_target() {
  cd ${PKG_BUILD}/src
  ${CC} -std=c11 -Wall -Ofast -shared -o gam4980_libretro.so libretro.c ${LDFLAGS}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/src/gam4980_libretro.so ${INSTALL}/usr/lib/libretro/
}