# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rtl8733bs"
PKG_VERSION="5862f27a6310dccfd5dbd262f9aac7126c678330"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/AveyondFly/RTL8733BS_WiFi_linux_v5.14.1.1-46"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="Realtek RTL8733BS SDIO WiFi out-of-tree driver (8733bs.ko)"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C "$(kernel_path)" M="${PKG_BUILD}" \
    USER_WIFIMAC_PATH="/storage/.config/wifimac.txt" \
    modules
}

makeinstall_target() {
  mkdir -p "${INSTALL}/$(get_full_module_dir)/${PKG_NAME}"
  cp "${PKG_BUILD}/8733bs.ko" "${INSTALL}/$(get_full_module_dir)/${PKG_NAME}/"

  mkdir -p "${INSTALL}/$(get_full_firmware_dir)/rtl8733b"
  cp "${PKG_BUILD}/fwbin/rtl8733bs_fw.bin" "${INSTALL}/$(get_full_firmware_dir)/rtl8733b/FW_NIC.bin"
  cp "${PKG_BUILD}/fwbin/rtl8733bs_config.bin" "${INSTALL}/$(get_full_firmware_dir)/rtl8733b/wifi_efuse_8733bs.map"
}
