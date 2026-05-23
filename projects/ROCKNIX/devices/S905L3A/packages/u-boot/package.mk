# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="2025.04"
PKG_SHA256="439d3bef296effd54130be6a731c5b118be7fddd7fcc663ccbc5fb18294d8718"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="https://ftp.denx.de/pub/u-boot/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain u-boot-tools:host"
PKG_LONGDESC="Amlogic boot scripts for chain-booting from stock Android U-Boot."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"

make_target() {
  SCRIPTS_DIR="${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader/scripts"
  if [ -d "${SCRIPTS_DIR}" ]; then
    for src in ${SCRIPTS_DIR}/*.src; do
      base_src="$(basename ${src} .src)"
      mkimage -A ${TARGET_KERNEL_ARCH} -O linux -T script -C none -d "${src}" "${base_src}"
      if [ "${base_src}" = "Generic_cfgload" ]; then
        echo -n "ceboot=$(grep -v '^$' ${src} | sed '$!s/$/; \\/')" > Generic_cfgload_env
      fi
    done
  fi
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader

  [ -f aml_autoscript ] && cp -v aml_autoscript ${INSTALL}/usr/share/bootloader/
  [ -f Generic_cfgload ] && cp -v Generic_cfgload ${INSTALL}/usr/share/bootloader/
  [ -f Generic_cfgload_env ] && cp -v Generic_cfgload_env ${INSTALL}/usr/share/bootloader/

  CONFIG_INI="${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader/config.ini"
  [ -f "${CONFIG_INI}" ] && cp -v "${CONFIG_INI}" ${INSTALL}/usr/share/bootloader/
}
