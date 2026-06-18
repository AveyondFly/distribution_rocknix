# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="aislpc-rg52mini-stock"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/bmdhacks/aislpc-bootloader-tool"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/options ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"

# Stock RK3562 idbloader + U-Boot FIT dumps from EmuELEC on RG52 Mini (aislpc-bootloader-tool).
PKG_AISLPC_BOOTLOADER_BASE="https://github.com/bmdhacks/aislpc-bootloader-tool/raw/main/devices/rg52mini/stock"

unpack() {
  mkdir -p ${PKG_BUILD}
  curl -fsSL -o ${PKG_BUILD}/bootloader_area.img \
    ${PKG_AISLPC_BOOTLOADER_BASE}/bootloader_area.img
  curl -fsSL -o ${PKG_BUILD}/uboot_partition.img \
    ${PKG_AISLPC_BOOTLOADER_BASE}/uboot_partition.img
}

make_target() {
  : # nothing
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader

  cp ${PKG_BUILD}/bootloader_area.img ${INSTALL}/usr/share/bootloader/
  cp ${PKG_BUILD}/uboot_partition.img ${INSTALL}/usr/share/bootloader/

  # 16 MiB pre-partition blob for dd seek=64 (matches SYSTEM_PART_START=32768):
  #   blob sector 0      -> disk sector 64     (idbloader / SPL, 8 MiB)
  #   blob sector 16320  -> disk sector 16384  (U-Boot FIT, 4 MiB)
  # Tail is zero padding (reserved / resource gap before FAT @ sector 32768).
  truncate -s $((32768 * 512)) ${INSTALL}/usr/share/bootloader/Generic_uboot.bin
  dd if=${PKG_BUILD}/bootloader_area.img \
    of=${INSTALL}/usr/share/bootloader/Generic_uboot.bin \
    bs=512 conv=fsync,notrunc status=none
  dd if=${PKG_BUILD}/uboot_partition.img \
    of=${INSTALL}/usr/share/bootloader/Generic_uboot.bin \
    bs=512 seek=16320 conv=fsync,notrunc status=none

  cp -av ${INSTALL}/usr/share/bootloader/Generic_uboot.bin \
    ${INSTALL}/usr/share/bootloader/uboot.bin
}
