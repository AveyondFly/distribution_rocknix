# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rk3326-dtb-select"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_SITE=""
PKG_URL=""
PKG_LONGDESC="Interactive RK3326 DTB / extlinux.conf selection for ROCKNIX"
PKG_TOOLCHAIN="manual"
PKG_DEPENDS_TARGET="toolchain Python3"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/rk3326-dtb-select
  cp -a ${PKG_DIR}/dtb_selector.py ${INSTALL}/usr/share/rk3326-dtb-select/
  cp -a ${PKG_DIR}/config ${INSTALL}/usr/share/rk3326-dtb-select/
  mkdir -p ${INSTALL}/usr/bin
  install -m 0755 ${PKG_DIR}/scripts/rk3326-dtb-select.in ${INSTALL}/usr/bin/rk3326-dtb-select

  # Shipped to FAT /flash root via bootloader release + mkimage (dtb_selector.py, config/, dtbselect)
  mkdir -p ${INSTALL}/usr/share/bootloader/dtb-select
  cp -a ${PKG_DIR}/dtb_selector.py ${INSTALL}/usr/share/bootloader/
  cp -a ${PKG_DIR}/config ${INSTALL}/usr/share/bootloader/config
  install -m 0755 ${PKG_DIR}/scripts/dtb-select-flash.in ${INSTALL}/usr/share/bootloader/dtbselect
  if [ -f ${PKG_DIR}/prebuilt/DtbselectWin64.exe ]; then
    install -m 644 ${PKG_DIR}/prebuilt/DtbselectWin64.exe ${INSTALL}/usr/share/bootloader/DtbselectWin64.exe
  fi
}
