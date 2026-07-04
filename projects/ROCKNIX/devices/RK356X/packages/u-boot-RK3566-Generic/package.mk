# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)
#
# Based on JELOS Rockchip u-boot package.mk (RK3566-BSP path).

PKG_NAME="u-boot-RK3566-Generic"
PKG_VERSION="97c658238f7ccd436fbdede451bfd7488514a5c8"
PKG_SHA256="skip"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/JustEnoughLinuxOS/rk356x-uboot"
PKG_URL="${PKG_SITE}.git"
GET_HANDLER_SUPPORT="git"
PKG_DEPENDS_TARGET="toolchain Python3 swig:host pyelftools:host linux"
PKG_LONGDESC="Rockchip RK3566 U-Boot for Powkiddy handhelds (rk356x-uboot)."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

pre_make_target() {
  PKG_RKBIN="$(get_build_dir rkbin)"
  PKG_BL31="${PKG_RKBIN}/bin/rk35/rk3568_bl31_v1.45.elf"
  PKG_DDR_BIN="${PKG_RKBIN}/bin/rk35/rk3568_ddr_1056MHz_v1.23.bin"
  PKG_LOADER="${PKG_RKBIN}/bin/rk35/rk356x_spl_v1.14.bin"
  PKG_DTB_DIR="$(get_build_dir linux)/arch/arm64/boot/dts/rockchip"
}

make_target() {
  setup_pkg_config_host

  export BL31="${PKG_BL31}"
  export ROCKCHIP_TPL="${PKG_DDR_BIN}"

  cd "${PKG_BUILD}"
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0

  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm64 make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm64 \
    make rk3568_defconfig rk3566.config BL31="${PKG_BL31}" \
    u-boot.dtb u-boot.itb CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm64 \
    _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ \
    make HOSTCC="${HOST_CC}" HOSTLDFLAGS="-L${TOOLCHAIN}/lib" HOSTSTRIP="true" \
    CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"

  ${PKG_RKBIN}/tools/mkimage -n rk3568 -T rksd \
    -d "${PKG_DDR_BIN}:${PKG_LOADER}" -C bzip2 idbloader.img

  chmod +x "${PKG_DIR}/pack-resource.sh"
  DTB_DIR="${PKG_DTB_DIR}" OUT="${PKG_BUILD}/resource.img" \
    PKG_BUILD="${PKG_BUILD}" "${PKG_DIR}/pack-resource.sh"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader
  cp -av ${PKG_BUILD}/idbloader.img ${INSTALL}/usr/share/bootloader/RK3566-Generic_idbloader.img
  cp -av ${PKG_BUILD}/u-boot.itb ${INSTALL}/usr/share/bootloader/RK3566-Generic_u-boot.itb
  cp -av ${PKG_BUILD}/resource.img ${INSTALL}/usr/share/bootloader/RK3566-Generic_resource.img
}
