# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="dav1d"
PKG_VERSION="1.5.1"
PKG_SHA256="fa635e2bdb25147b1384007c83e15de44c589582bb3b9a53fc1579cb9d74b695"
PKG_LICENSE="BSD"
PKG_SITE="https://www.videolan.org/projects/dav1d.html"
PKG_URL="https://github.com/videolan/dav1d/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="dav1d is an AV1 decoder :)"

if [ "${TARGET_ARCH}" = "x86_64" ]; then
  PKG_DEPENDS_TARGET+=" nasm:host"
fi

PKG_MESON_OPTS_TARGET="-Denable_docs=false \
                       -Denable_examples=false \
                       -Denable_tests=false \
                       -Denable_tools=false \
                       -Dtestdata_tests=false"
