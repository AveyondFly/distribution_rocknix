# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/options ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"

for PKG_SUBDEVICE in ${SUBDEVICES}; do
  PKG_DEPENDS_TARGET+=" u-boot-${PKG_SUBDEVICE}"
  PKG_NEED_UNPACK+=" $(get_pkg_directory u-boot-${PKG_SUBDEVICE})"
done

make_target() {
  : # nothing
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader

  for PKG_SUBDEVICE in ${SUBDEVICES}; do
    PKG_UBOOTDIR="$(get_build_dir u-boot-${PKG_SUBDEVICE})"
    if [ -f "${PKG_UBOOTDIR}/bootloader_area.img" ] && \
       [ -f "${PKG_UBOOTDIR}/uboot_partition.img" ]; then
      cp -av "${PKG_UBOOTDIR}/bootloader_area.img" $INSTALL/usr/share/bootloader/
      cp -av "${PKG_UBOOTDIR}/uboot_partition.img" $INSTALL/usr/share/bootloader/
    fi
    if [ -f "${PKG_UBOOTDIR}/uboot.bin" ]; then
      cp -av "${PKG_UBOOTDIR}/uboot.bin" $INSTALL/usr/share/bootloader/${PKG_SUBDEVICE}_uboot.bin
    fi
  done
}
