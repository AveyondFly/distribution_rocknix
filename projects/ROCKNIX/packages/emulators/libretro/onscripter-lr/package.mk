# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="onscripter-lr"
PKG_VERSION="ec954a3475c3bf41517d0bdb84f48cd28c0f4f72"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/YuriSizuku/OnscripterYuri"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ONScripter Yuri - Visual novel game engine libretro core"
PKG_TOOLCHAIN="manual"

configure_target() {
  cd ${PKG_BUILD}/src/onsyuri_libretro

  cmake -B build -G Ninja \
    -DCMAKE_TOOLCHAIN_FILE=${CMAKE_CONF} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr
}

make_target() {
  cd ${PKG_BUILD}/src/onsyuri_libretro
  ninja -C build
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp -v ${PKG_BUILD}/src/onsyuri_libretro/build/onsyuri_libretro.so ${INSTALL}/usr/lib/libretro/
}