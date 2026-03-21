# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="openbor-ff"
PKG_VERSION="5cac65237db9b1409a0b7ee4a1a64d6507834915"
PKG_SITE="https://github.com/AveyondFly/openbor-fflns"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 SDL2_gfx libogg libvorbisidec libvpx libpng"
PKG_LONGDESC="OpenBOR is the ultimate 2D side scrolling engine for beat em' ups, shooters, and more!"
PKG_TOOLCHAIN="make"
GET_HANDLER_SUPPORT="git"

pre_configure_target() {
  PKG_MAKE_OPTS_TARGET="BUILD_LINUX_${ARCH}=1 -C ${PKG_BUILD}/engine SDKPATH=${SYSROOT_PREFIX} PREFIX=${TARGET_NAME}"
  cd ${PKG_BUILD}
  #sed -i "s|device->mappings\[SDID_START\]      = SDL_CONTROLLER_BUTTON_START;|device->mappings\[SDID_START\]      = SDL_CONTROLLER_BUTTON_BACK;|g" engine/sdl/control.c
  #sed -i "s|device->mappings\[SDID_SCREENSHOT\] = SDL_CONTROLLER_BUTTON_BACK;|device->mappings\[SDID_SCREENSHOT\] = SDL_CONTROLLER_BUTTON_START;|g" engine/sdl/control.c
  sed -i "s|-Werror||g" engine/Makefile
}

pre_make_target() {
  cd ${PKG_BUILD}/engine
  chmod 775 ./version.sh
  ./version.sh
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp OpenBOR ${INSTALL}/usr/bin/OpenBOR-ff
  chmod 0777 ${INSTALL}/usr/bin/*
} 
