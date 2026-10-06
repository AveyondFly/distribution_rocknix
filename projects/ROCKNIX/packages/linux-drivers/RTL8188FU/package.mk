# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present AURKNIX (https://github.com/AveyondFly)

PKG_NAME="RTL8188FU"
PKG_VERSION="c8c95708b3756c67139c456a2a6576c1e6491d82"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/kelebek333/rtl8188fu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_SHA256="c960a881de261aa8065ac1a4277664d2e9f31187c6050c2c75d386e7832bb2df"
PKG_LONGDESC="Realtek RTL8188FU out-of-tree USB WiFi driver"
PKG_TOOLCHAIN="make"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  make V=1 \
       ARCH=${TARGET_KERNEL_ARCH} \
       KSRC=$(kernel_path) \
       CROSS_COMPILE=${TARGET_KERNEL_PREFIX}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless
    cp rtl8188fu.ko ${INSTALL}/$(get_full_module_dir)/kernel/drivers/net/wireless

  mkdir -p ${INSTALL}/usr/lib/modprobe.d
    cp ${PKG_DIR}/modprobe.d/rtl8188fu.conf ${INSTALL}/usr/lib/modprobe.d/
}
