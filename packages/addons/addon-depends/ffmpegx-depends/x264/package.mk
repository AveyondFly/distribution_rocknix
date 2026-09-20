# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="x264"
PKG_VERSION="ff620d0c3c4f717ab393892983d43458d27e4bed"
PKG_SHA256="70b9ad4745c5422342187bb22fd7617818a3f5b483fd791d29d49087134158f8"
PKG_LICENSE="GPL"
PKG_SITE="http://www.videolan.org/developers/x264.html"
PKG_URL="https://github.com/mirror/x264/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="x264 codec"

if [ "${TARGET_ARCH}" = "x86_64" ]; then
  PKG_DEPENDS_TARGET+=" nasm:host"
fi

pre_configure_target() {
  cd ${PKG_BUILD}
  rm -rf .${TARGET_NAME}

  if [ "${TARGET_ARCH}" = "x86_64" ]; then
    export AS="${TOOLCHAIN}/bin/nasm"
  else
    PKG_X264_ASM="--disable-asm"
  fi
}

configure_target() {
  ./configure \
    --cross-prefix="${TARGET_PREFIX}" \
    --extra-cflags="${CFLAGS}" \
    --extra-ldflags="${LDFLAGS}" \
    --host="${TARGET_NAME}" \
    --prefix="/usr" \
    --sysroot="${SYSROOT_PREFIX}" \
    ${PKG_X264_ASM} \
    --disable-cli \
    --enable-lto \
    --enable-pic \
    --enable-static \
    --enable-strip
}
