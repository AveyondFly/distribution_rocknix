# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="wifi_dummy-aml"
PKG_VERSION="1.0"
PKG_SHA256=""
PKG_LICENSE="GPL"
PKG_SITE="https://coreelec.org"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="${PKG_NAME}: Amlogic SDIO/PCIe WiFi power-on and bus rescan"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/wifi_dummy.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}

  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/wifi_dummy-aml ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/wifi_dummy-aml

  mkdir -p ${INSTALL}/usr/lib/wifi_dummy-aml/profiles
  cp ${PKG_DIR}/profiles/*.conf ${INSTALL}/usr/lib/wifi_dummy-aml/profiles

  mkdir -p ${INSTALL}/usr/lib/systemd/system
  cp ${PKG_DIR}/system.d/*.service ${INSTALL}/usr/lib/systemd/system
}

post_install() {
  enable_service wifi_dummy-aml.service
}
