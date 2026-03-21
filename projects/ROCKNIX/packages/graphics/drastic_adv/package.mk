# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

# Inherit nearly everything from SDL2
OPENGL_SUPPORT=no
. $(get_pkg_directory SDL2)/package.mk

PKG_NAME="drastic_adv"
PKG_DEPENDS_UNPACK+=" SDL2"
PKG_DEPENDS_TARGET="drastic-sa librga freeimage SDL2_ttf SDL2_image json-c"

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/config/drastic/lib"
  cp -a libSDL2-2.0.so.0.* "${INSTALL}/usr/config/drastic/lib/"
  ln -sf libSDL2-2.0.so.0.* "${INSTALL}/usr/config/drastic/lib/libSDL2-2.0.so.0"
  ln -sf libSDL2-2.0.so.0 "${INSTALL}/usr/config/drastic/lib/libSDL2.so"
}

post_makeinstall_target() {
  :
}
