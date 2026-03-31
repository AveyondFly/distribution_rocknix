# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="e769657b0aff93eabd97fdc8f80f5808f3d58312"
PKG_SHA256="skip"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/AveyondFly/u-boot"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="next-dev"
GET_HANDLER_SUPPORT="git"
PKG_DEPENDS_TARGET="toolchain Python3:host swig:host pyelftools:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/options ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

pre_make_target() {
  PKG_UBOOT_CONFIG="evb-rk3326_defconfig"
  PKG_RKBIN="$(get_build_dir rkbin)"
  PKG_MINILOADER="${PKG_RKBIN}/bin/rk33/rk3326_miniloader_v1.40.bin"
  PKG_BL31="${PKG_RKBIN}/bin/rk33/rk3326_bl31_v1.34.elf"
  PKG_BL32="${PKG_RKBIN}/bin/rk33/rk3326_bl32_v2.18.bin"
  PKG_DDR_BIN="${PKG_RKBIN}/bin/rk33/rk3326_ddr_333MHz_v2.11.bin"
}

make_target() {
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
  setup_pkg_config_host

  find_file_path bootloader/rkhelper || exit 4
  RKHELPER=${FOUND_PATH}

  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make ${PKG_UBOOT_CONFIG}
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm \
        _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ \
        make HOSTCC="${HOST_CC}" HOSTLDFLAGS="-L${TOOLCHAIN}/lib" HOSTSTRIP="true" \
        -j$(nproc)
  . ${RKHELPER}
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader
  cp -av uboot.bin "${INSTALL}/usr/share/bootloader/uboot.bin"

  # Copy u-boot dtb for late initialization
  mkdir -p $INSTALL/usr/share/bootloader/device_trees
  cp -v ${PKG_DIR}/dtb/*.dtb ${INSTALL}/usr/share/bootloader/device_trees/
}
