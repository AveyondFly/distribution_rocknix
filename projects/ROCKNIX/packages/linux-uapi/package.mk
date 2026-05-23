# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Team ROCKNIX (https://github.com/ROCKNIX/distribution)

PKG_NAME="linux-uapi"
PKG_VERSION="6.18.21"
PKG_SHA256=""
PKG_LICENSE="GPL"
PKG_SITE="http://www.kernel.org"
PKG_URL="https://www.kernel.org/pub/linux/kernel/v${PKG_VERSION/.*/}.x/linux-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="openssl:host"
PKG_LONGDESC="Linux UAPI headers for userspace (sysroot), independent of the target kernel version."

make_host() {
  :
}

makeinstall_host() {
  make \
    ARCH=${HEADERS_ARCH:-${TARGET_KERNEL_ARCH}} \
    HOSTCC="${TOOLCHAIN}/bin/host-gcc" \
    HOSTCXX="${TOOLCHAIN}/bin/host-g++" \
    HOSTCFLAGS="${HOST_CFLAGS}" \
    HOSTCXXFLAGS="${HOST_CXXFLAGS}" \
    HOSTLDFLAGS="${HOST_LDFLAGS}" \
    INSTALL_HDR_PATH=dest \
    headers_install
  mkdir -p ${SYSROOT_PREFIX}/usr/include
    cp -R dest/include/* ${SYSROOT_PREFIX}/usr/include
}
