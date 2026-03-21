# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="cpymo"
PKG_VERSION="main"
PKG_SITE="https://github.com/Strrationalism/CPyMO"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 ffmpeg"
PKG_LONGDESC="PyMO AVG Game Engine implementation in C."
PKG_TOOLCHAIN="make"

pre_configure_target() {
  cd ${PKG_BUILD}/cpymo-backends/sdl2
}

make_target() {
  make CC=${CC} \
       TARGET=cpymo \
       CFLAGS="${CFLAGS} -I${SYSROOT_PREFIX}/usr/include/SDL2 -D_REENTRANT" \
       LDFLAGS="${LDFLAGS} -lSDL2 -lswscale -lavformat -lavcodec -lavutil -lswresample -lm"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/cpymo-backends/sdl2/cpymo ${INSTALL}/usr/bin/
  cp ${PKG_DIR}/sources/start_cpymo.sh ${INSTALL}/usr/bin/
  chmod 0755 ${INSTALL}/usr/bin/start_cpymo.sh

  mkdir -p ${INSTALL}/usr/config/cpymo
  cp ${PKG_DIR}/sources/cpymo.gptk ${INSTALL}/usr/config/cpymo/
  cp ${PKG_DIR}/sources/default.ttf ${INSTALL}/usr/config/cpymo/
}
