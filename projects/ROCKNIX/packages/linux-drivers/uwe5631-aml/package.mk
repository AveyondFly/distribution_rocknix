# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="uwe5631-aml"
PKG_VERSION="df31fe79d3a5875a23e1d7e25852e35de1c25e43"
PKG_SHA256=""
PKG_ARCH="aarch64"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/uwe5631-aml"
PKG_URL="https://github.com/CoreELEC/uwe5631-aml/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_NEED_UNPACK="${LINUX_DEPENDS}"
PKG_LONGDESC="uwe5631-aml: Unisoc UWE5621 WIFI/BT driver"
PKG_IS_KERNEL_PKG="yes"
PKG_TOOLCHAIN="manual"

make_target() {
  echo "making WIFI"
  kernel_make -C ${PKG_BUILD} \
    M=${PKG_BUILD} \
    KERNEL_SRC=$(kernel_path) \
    UNISOC_WIFI_CUS_CONFIG="/lib/firmware/unisoc" \
    modules

  echo "making BT"
  kernel_make -C ${PKG_BUILD}/BT/tty-sdio \
    M=${PKG_BUILD}/BT/tty-sdio \
    KERNEL_SRC=$(kernel_path) \
    CURFOLDER=${PKG_BUILD}/BSP \
    modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}

  find $PKG_BUILD/ -name \*.ko -not -path '*/\.*' \
    -exec cp {} ${INSTALL}/$(get_full_module_dir)/${PKG_NAME} \;

  mkdir -p ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/unisoc

  cp -av ${PKG_DIR}/firmware/*.ini \
         ${PKG_BUILD}/BT/libbt/conf/sprd/runtime/*.ini \
         ${PKG_BUILD}/BSP/fw/wcnmodem.bin \
    ${INSTALL}/$(get_kernel_overlay_dir)/lib/firmware/unisoc

  mkdir -p ${INSTALL}/usr/lib/systemd/system
  cp ${PKG_DIR}/system.d/*.service ${INSTALL}/usr/lib/systemd/system

  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/sprd_sdio-firmware-aml ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/sprd_sdio-firmware-aml
}

post_install() {
  enable_service sprd_sdio-firmware-aml.service
}
