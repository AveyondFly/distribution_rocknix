# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ws2812-common"
PKG_VERSION="b58ab2124f8aee796353ab414f964dd554c92864"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/lcdyk0517/JoyLed"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Common SPI WS2812 analogue-stick LED controller"
PKG_TOOLCHAIN="manual"

make_target() {
  ${CC} ${TARGET_CFLAGS} ${TARGET_LDFLAGS} \
    -o ws2812-common ws2812.c -lm
}

makeinstall_target() {
  install -Dm755 ws2812-common ${INSTALL}/usr/bin/ws2812-common
}
