# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="aic8800-sdio"
PKG_VERSION="fda6713f1eebdc83ce23d9f35b6dec1abae2b2c9"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/radxa-pkg/aic8800"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="AIC8800 SDIO WiFi/BT out-of-tree driver (aic8800_bsp + aic8800_btlpm + aic8800_fdrv)"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) \
    M=${PKG_BUILD}/src/SDIO/driver_fw/driver/aic8800 \
    CONFIG_PLATFORM_UBUNTU=n \
    CONFIG_AIC_FW_PATH=/lib/firmware/aic8800 \
    modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/src/SDIO/driver_fw/driver/aic8800/aic8800_bsp/aic8800_bsp.ko \
     ${PKG_BUILD}/src/SDIO/driver_fw/driver/aic8800/aic8800_btlpm/aic8800_btlpm.ko \
     ${PKG_BUILD}/src/SDIO/driver_fw/driver/aic8800/aic8800_fdrv/aic8800_fdrv.ko \
     ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/aic8800
  cp ${PKG_BUILD}/src/SDIO/driver_fw/fw/aic8800*/* \
     ${INSTALL}/$(get_full_firmware_dir)/aic8800/

  mkdir -p ${INSTALL}/usr/lib/systemd/system
  cp ${PKG_DIR}/system.d/*.service ${INSTALL}/usr/lib/systemd/system

  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/aic8800-sdio-bt ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/aic8800-sdio-bt
}

post_install() {
  enable_service aic8800-sdio.service
}
