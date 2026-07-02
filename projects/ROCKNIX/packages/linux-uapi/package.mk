# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Team ROCKNIX (https://github.com/ROCKNIX/distribution)

PKG_NAME="linux-uapi"
PKG_VERSION="6.18.21"
PKG_SHA256=""
PKG_LICENSE="GPL"
PKG_SITE="https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"
PKG_URL="${PKG_SITE}/snapshot/linux-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="ccache:host openssl:host"
PKG_LONGDESC="Linux UAPI headers for userspace (sysroot), independent of the target kernel version."
PKG_TOOLCHAIN="manual"

make_host() {
  :
}

makeinstall_host() {
  local headers_arch="${HEADERS_ARCH}"
  if [ -z "${headers_arch}" ]; then
    case "${TARGET_ARCH}" in
      aarch64)
        headers_arch="arm64"
        ;;
      x86_64)
        headers_arch="x86"
        ;;
      *)
        headers_arch="${TARGET_ARCH}"
        ;;
    esac
  fi

  make \
    ARCH=${headers_arch} \
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
