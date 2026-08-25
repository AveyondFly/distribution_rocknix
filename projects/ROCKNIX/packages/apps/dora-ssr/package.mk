# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present AURKNIX (https://github.com/AveyondFly)

PKG_NAME="dora-ssr"
PKG_VERSION="1.9.2-10"
PKG_ARCH="aarch64"
PKG_LICENSE="MIT"
PKG_SITE="https://dora-ssr.net"
PKG_URL="https://ppa.launchpadcontent.net/ippclub/dora-ssr/ubuntu/pool/main/d/dora-ssr/dora-ssr_${PKG_VERSION}_arm64.deb"
PKG_SHA256="e201f0b4c54fb2dcecec994db2f290ed0e70ccd1ab32d4e84a30d099f45b89c4"
PKG_DEPENDS_HOST="zstd:host"
PKG_DEPENDS_TARGET="toolchain alsa-lib binutils curl dbus foot gzip libdrm mesa util-linux xmlstarlet zstd"
PKG_LONGDESC="Dora SSR game engine with KMSDRM launch and PPA update support"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p ${PKG_BUILD}
  (
    cd ${PKG_BUILD}
    ar x ${SOURCES}/${PKG_NAME}/${PKG_NAME}-${PKG_VERSION}.deb
    zstd -dc data.tar.zst | tar -x
  )
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/usr/bin/dora-ssr ${INSTALL}/usr/bin/
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin/
  chmod 0755 ${INSTALL}/usr/bin/dora-ssr \
             ${INSTALL}/usr/bin/dora-kmsdrm-runner \
             ${INSTALL}/usr/bin/dora-update-runner

  mkdir -p ${INSTALL}/usr/share/dora-ssr
  cp -a ${PKG_BUILD}/usr/share/dora-ssr/. ${INSTALL}/usr/share/dora-ssr/
  mkdir -p ${INSTALL}/usr/share/dora-ssr/ports
  cp ${PKG_DIR}/ports/* ${INSTALL}/usr/share/dora-ssr/ports/
  chmod 0755 ${INSTALL}/usr/share/dora-ssr/ports/*
  echo "${PKG_VERSION}" > ${INSTALL}/usr/share/dora-ssr/version

  mkdir -p ${INSTALL}/usr/lib/autostart/common
  cp ${PKG_DIR}/autostart/012-dora-ssr ${INSTALL}/usr/lib/autostart/common/
  chmod 0755 ${INSTALL}/usr/lib/autostart/common/012-dora-ssr
}
