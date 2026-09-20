# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)

PKG_NAME="libdvbpsi"
PKG_VERSION="1.3.3"
PKG_SHA256="02b5998bcf289cdfbd8757bedd5987e681309b0a25b3ffe6cebae599f7a00112"
PKG_LICENSE="GPL"
PKG_SITE="http://www.videolan.org/developers/libdvbpsi.html"
PKG_URL="https://deb.debian.org/debian/pool/main/libd/libdvbpsi/libdvbpsi_${PKG_VERSION}.orig.tar.bz2"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="library for MPEG TS and DVB PSI tables decoding and generating"

PKG_CONFIGURE_OPTS_TARGET="--enable-static --disable-shared"
