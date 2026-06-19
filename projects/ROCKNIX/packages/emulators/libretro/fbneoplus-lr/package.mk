# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="fbneoplus-lr"
PKG_VERSION="ce0aae7135d83badf0be59f8babc55853d10b194"
PKG_LICENSE="Non-commercial"
PKG_SITE="https://github.com/lrf739146825/FBNeo"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Port of Final Burn Neo Plus to Libretro."
PKG_TOOLCHAIN="make"

pre_configure_target() {
  sed -i "s|LDFLAGS += -static-libgcc -static-libstdc++|LDFLAGS += -static-libgcc|" ./src/burner/libretro/Makefile

  PKG_MAKE_OPTS_TARGET=" -C ./src/burner/libretro USE_CYCLONE=0 profile=performance"

  if [[ "${TARGET_FPU}" =~ "neon" ]]; then
    PKG_MAKE_OPTS_TARGET+=" HAVE_NEON=1"
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/src/burner/libretro/fbneo_libretro.so ${INSTALL}/usr/lib/libretro/fbneoplus_libretro.so
}
