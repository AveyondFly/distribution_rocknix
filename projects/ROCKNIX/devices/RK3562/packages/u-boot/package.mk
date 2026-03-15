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
  cp -av ${PKG_BUILD}/full_uboot.bin $INSTALL/usr/share/bootloader/uboot.bin
}
