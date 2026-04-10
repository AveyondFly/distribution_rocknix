# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="aic8800-usb"
PKG_VERSION="b6ba4cbacf9657caecce26c2426880c5bb485266"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/AveyondFly/aic8800-usb"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="AIC8800 USB WiFi/BT out-of-tree driver (aic_load_fw_usb + aic8800_fdrv_usb)"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD} modules
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/aic_load_fw/aic_load_fw_usb.ko \
     ${PKG_BUILD}/aic8800_fdrv/aic8800_fdrv_usb.ko \
     ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}

  mkdir -p ${INSTALL}/$(get_full_firmware_dir)/aic8800DC
  cp -a ${PKG_BUILD}/aic8800DC/. ${INSTALL}/$(get_full_firmware_dir)/aic8800DC/

  mkdir -p ${INSTALL}/usr/lib/modprobe.d
  cp ${PKG_DIR}/modprobe.d/aic8800-usb.conf ${INSTALL}/usr/lib/modprobe.d/
}
