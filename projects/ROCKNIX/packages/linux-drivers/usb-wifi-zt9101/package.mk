# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="usb-wifi-zt9101"
PKG_VERSION="8c99a897bc35402f50c3b3dd29df32efdebd639d"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/sudo-goblok/driver_usb_wireless_adapter_ZTopIncop"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="ZTOP ZT9101 USB WiFi driver"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make V=1 \
       ARCH=${TARGET_KERNEL_ARCH} \
       CROSS_COMPILE=${TARGET_KERNEL_PREFIX} \
       KSRC=$(kernel_path) \
       CONFIG_DEBUG_LEVEL=2 \
       CONFIG_MODULE_IMPORT_NS=y \
       CONFIG_HIF_PORT=usb
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/zt9101_ztopmac_usb.ko \
     ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}/

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/zt9101
  cp ${PKG_BUILD}/fw/ZT9101_fw_c1ab8ba.bin \
     ${PKG_BUILD}/fw/ZT9101V30_fw_8546b3a.bin \
     ${PKG_DIR}/firmware/wifi.cfg \
     ${INSTALL}/$(get_full_firmware_dir)/zt9101/

  mkdir -p ${INSTALL}/usr/lib/modprobe.d
  cp ${PKG_DIR}/modprobe.d/zt9101.conf \
     ${INSTALL}/usr/lib/modprobe.d/
}
