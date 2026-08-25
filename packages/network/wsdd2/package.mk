# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="wsdd2"
PKG_VERSION="1.8.7"
PKG_SHA256="2b1e7720435a1e067388660ec3edb321a4c91b4f9d0928ba27d0a8d89b7ef3b9"
PKG_LICENSE="GPL 3.0"
PKG_SITE="https://tracker.debian.org/pkg/wsdd2"
PKG_URL="https://deb.debian.org/debian/pool/main/w/wsdd2/${PKG_NAME}_${PKG_VERSION}+dfsg.orig.tar.xz"
PKG_DEPENDS_TARGET="make:host gcc:host"
PKG_LONGDESC="WSD/LLMNR Discovery/Name Service Daemon"
PKG_BUILD_FLAGS="+size"

post_install() {
  enable_service wsdd2.service
}
