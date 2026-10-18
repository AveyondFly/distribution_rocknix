# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="openbor_latest"
PKG_ARCH="aarch64 x86_64"
PKG_VERSION="787b6770409935137579715febf80cf7a529b748"
PKG_SITE="https://github.com/DCurrent/openbor"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain SDL2 libogg libvorbis libvpx libpng"
PKG_LONGDESC="Latest OpenBOR engine with ROCKNIX controller mappings, installed alongside the existing OpenBOR."
PKG_TOOLCHAIN="cmake"
GET_HANDLER_SUPPORT="git"

pre_configure_target() {
  # Use the target sysroot instead of CMake's default /usr include path.
  PKG_CMAKE_OPTS_TARGET="-DBUILD_LINUX=ON
                         -DCMAKE_PREFIX_PATH=${SYSROOT_PREFIX}/usr
                         -DCMAKE_LIBRARY_PATH=${SYSROOT_PREFIX}/usr/lib"
  if [ "${ARCH}" = "aarch64" ]; then
    # Match the existing ARM build: SDL renderer, without desktop OpenGL.
    PKG_CMAKE_OPTS_TARGET+=" -DTARGET_ARCH=ARM64 -DUSE_OPENGL=OFF -DUSE_LOADGL=OFF"
  elif [ "${ARCH}" = "x86_64" ]; then
    PKG_CMAKE_OPTS_TARGET+=" -DTARGET_ARCH=AMD64"
  fi
}

makeinstall_target() {
  install -Dm755 OpenBOR ${INSTALL}/usr/bin/OpenBOR-latest
}
