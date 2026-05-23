# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="opengl-meson"
PKG_VERSION="51e81d36fccb1340b2dab9490da74ded29f849e1"
PKG_SHA256=""
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/aml-streambox/meson_mali"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain libdrm opentee_linuxdriver libmali"
PKG_LONGDESC="OpenGL ES headers and pkg-config stubs for Mali GPUs found in Amlogic Meson SoCs."
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  cd ${PKG_BUILD}

  BASE="${PKG_SITE}/raw/${PKG_VERSION}"

  # pkg-config stubs (~1KB total)
  mkdir -p lib/pkgconfig/gbm
  for f in lib/pkgconfig/egl.pc lib/pkgconfig/glesv2.pc lib/pkgconfig/wayland-egl.pc lib/pkgconfig/gbm/gbm.pc; do
    curl -fsSL -o ${f} ${BASE}/${f}
  done

  # EGL/GLES headers (~900KB)
  git clone --depth 1 --filter=blob:none --sparse ${PKG_SITE}.git ${PKG_BUILD}/.sparse
  cd ${PKG_BUILD}/.sparse
  git sparse-checkout set include
  cp -a include ${PKG_BUILD}/
  cd ${PKG_BUILD}
  rm -rf .sparse
}

makeinstall_target() {
  # install needed files for compiling
  mkdir -p ${SYSROOT_PREFIX}/usr/include
    cp -pr include/EGL_platform/platform_gbm/gbm/* ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/include/EGL
    cp -pr include/EGL ${SYSROOT_PREFIX}/usr/include
    cp -pr include/EGL_platform/platform_wayland/* ${SYSROOT_PREFIX}/usr/include/EGL 2>/dev/null || true
  mkdir -p ${SYSROOT_PREFIX}/usr/include/GLES2
    cp -pr include/GLES2 ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/include/GLES3
    cp -pr include/GLES3 ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/include/KHR
    cp -pr include/KHR ${SYSROOT_PREFIX}/usr/include
  mkdir -p ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp -pr lib/pkgconfig/gbm/gbm.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp -pr lib/pkgconfig/egl.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp -pr lib/pkgconfig/glesv2.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
}

post_install() {
  enable_service unbind-console.service
}
