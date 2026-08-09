# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="4c7078cfdf7f014b89a38a1d5cb1f17dc9314489"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/radxa/u-boot"
PKG_URL=""
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="Radxa Cubie A5E (A527) prebuilt BSP boot chain (boot0 + boot_package)"
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/options ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"

make_target() {
  for f in boot0_sdcard_sun55iw3p1.bin boot_package.fex; do
    if [ ! -f "${PKG_DIR}/bin/${f}" ]; then
      die "A527 u-boot: missing ${PKG_DIR}/bin/${f} — run packages/u-boot/build-uboot.sh outside the build"
    fi
  done
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader

  cp -av ${PKG_DIR}/bin/boot0_sdcard_sun55iw3p1.bin ${INSTALL}/usr/share/bootloader/
  cp -av ${PKG_DIR}/bin/boot_package.fex ${INSTALL}/usr/share/bootloader/

  if [ -f ${PKG_DIR}/bin/u-boot-sun55iw3p1.bin ]; then
    cp -av ${PKG_DIR}/bin/u-boot-sun55iw3p1.bin ${INSTALL}/usr/share/bootloader/
  fi
}
