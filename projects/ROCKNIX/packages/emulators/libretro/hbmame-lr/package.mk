# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="hbmame-lr"
PKG_VERSION="0.9"
PKG_ARCH="arm aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/AveyondFly/console_mod_res"
PKG_URL="https://github.com/AveyondFly/console_mod_res/releases/download/v${PKG_VERSION}/mod_cores.zip"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Homebrew MAME libretro cores - arcade emulator cores for 32-bit devices"
PKG_TOOLCHAIN="manual"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro

  # Download and extract cores
  curl -Lo ${PKG_BUILD}/mod_cores.zip ${PKG_URL}
  unzip -o ${PKG_BUILD}/mod_cores.zip -d ${PKG_BUILD}/cores

  # Install the cores we need
  for core in nebularm_32b nebularm_legacy_32b fbneo_32b fbalpha2012_32b mame2003_plus_32b; do
    if [ -f "${PKG_BUILD}/cores/${core}_libretro.so" ]; then
      cp -v ${PKG_BUILD}/cores/${core}_libretro.so ${INSTALL}/usr/lib/libretro/
    fi
  done

  cp -v ${PKG_BUILD}/cores/pcsx_rearmed_rumble_32b_libretro.so ${INSTALL}/usr/lib/libretro/

  curl -Lo ${PKG_BUILD}/mod_cores_genesis_plus_gx_EX_libretro.so.zip https://github.com/AveyondFly/console_mod_res/releases/download/v0.9/mod_cores_genesis_plus_gx_EX_libretro.so.zip
  unzip -o ${PKG_BUILD}/mod_cores_genesis_plus_gx_EX_libretro.so.zip -d ${PKG_BUILD}/cores
  cp -v ${PKG_BUILD}/cores/genesis_plus_gx_EX_libretro.so ${INSTALL}/usr/lib/libretro/
}
