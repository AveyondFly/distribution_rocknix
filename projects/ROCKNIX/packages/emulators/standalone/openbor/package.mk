# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="openbor"
PKG_VERSION="f903011ccbd22c475a1fc2895d3ce4c69d6c6e1e"
PKG_SITE="https://github.com/DCurrent/openbor"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 libogg libvorbisidec libvpx libpng"
PKG_LONGDESC="OpenBOR is the ultimate 2D side scrolling engine for beat em' ups, shooters, and more!"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

pre_configure_target() {
  PKG_MAKE_OPTS_TARGET="BUILD_LINUX_${ARCH}=1 -C ${PKG_BUILD}/engine SDKPATH=${SYSROOT_PREFIX} PREFIX=${TARGET_NAME}"
  cd ${PKG_BUILD}
  sed -i "s|-Werror||g" engine/Makefile
  sed -i "s|\$(LNXDEV)/\$(PREFIX)strip \$(TARGET) -o \$(TARGET_FINAL)|${TARGET_NAME}-strip \$(TARGET) -o \$(TARGET_FINAL)|g" engine/Makefile
}

pre_make_target() {
  cd ${PKG_BUILD}/engine
  ./version.sh
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp OpenBOR ${INSTALL}/usr/bin/OpenBOR
  cp ${PKG_DIR}/sources/start_OpenBOR.sh ${INSTALL}/usr/bin
  chmod 0777 ${INSTALL}/usr/bin/*
  mkdir -p ${INSTALL}/usr/config/openbor  
} 
