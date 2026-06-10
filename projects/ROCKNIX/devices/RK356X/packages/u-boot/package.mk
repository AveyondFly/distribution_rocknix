# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="0.1"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/AveyondFly/build_rocknix"
PKG_URL="https://github.com/AveyondFly/build_rocknix/releases/download/${PKG_VERSION}/full_uboot.tar.xz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/options ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"

unpack() {
  mkdir -p ${PKG_BUILD}
  tar -xf ${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME} -C ${PKG_BUILD}
}

make_target() {
  : # nothing
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader

  # full_uboot.bin is a Rockchip full-disk style loader: RKNS metadata starts at
  # sector 0, while the BootROM idbloader entry is at sector 64. The common
  # image writer writes uboot.bin to disk sector 64, so normalize the loader
  # layout here before packaging it.
  rm -f $INSTALL/usr/share/bootloader/uboot.bin
  dd if=${PKG_BUILD}/full_uboot.bin of=$INSTALL/usr/share/bootloader/uboot.bin bs=512 skip=64 count=16256 conv=fsync,notrunc status=none
  dd if=${PKG_BUILD}/full_uboot.bin of=$INSTALL/usr/share/bootloader/uboot.bin bs=512 skip=16320 seek=16320 conv=fsync,notrunc status=none
}
