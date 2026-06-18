# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rk915-firmware"
PKG_VERSION=""
PKG_LICENSE="Proprietary"
PKG_SITE="https://rocknix.org"
PKG_LONGDESC="Rockchip RK915 SDIO WiFi firmware"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_firmware_dir)
  cp -v ${PKG_DIR}/firmware/rk915_fw.bin ${INSTALL}/$(get_full_firmware_dir)/
  cp -v ${PKG_DIR}/firmware/rk915_patch.bin ${INSTALL}/$(get_full_firmware_dir)/
}
