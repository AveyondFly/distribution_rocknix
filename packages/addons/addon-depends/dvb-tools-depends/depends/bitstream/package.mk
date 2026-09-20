# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bitstream"
PKG_VERSION="1.5"
PKG_SHA256="600c0342fd2403dd9fe711baf176f234ed5f15c692738cfbe904ec5cd56fe362"
PKG_LICENSE="GPL"
PKG_SITE="http://www.videolan.org"
PKG_URL="https://github.com/videolan/bitstream/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="biTStream is a set of C headers allowing a simpler access to binary structures such as specified by MPEG, DVB, IETF."

PKG_MAKEINSTALL_OPTS_TARGET="PREFIX=/usr"
