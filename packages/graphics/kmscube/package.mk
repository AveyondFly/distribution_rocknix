# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="kmscube"
PKG_VERSION="9f63f359fab1b5d8e862508e4e51c9dfe339ccb0"
PKG_SHA256="8af4c16f79b042c991ed1166d8d92e47f65a04b9b8ec7c3d3b72d1a17fa0e597"
PKG_LICENSE="GPL"
PKG_SITE="https://gitlab.freedesktop.org/mesa/kmscube"
PKG_URL="https://gitlab.freedesktop.org/mesa/kmscube/-/archive/${PKG_VERSION}/kmscube-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Example KMS/GBM/EGL application"

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
elif [ "${OPENGL_SUPPORT}" = "yes" ]; then
  echo "kmscube only supports OpenGLESv2"
  exit 0
fi
