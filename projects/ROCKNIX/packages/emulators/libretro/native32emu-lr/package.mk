################################################################################
#      This file is part of OpenELEC - http://www.openelec.tv
#      Copyright (C) 2009-2012 Stephan Raue (stephan@openelec.tv)
#
#  This Program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This Program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with OpenELEC.tv; see the file COPYING.  If not, write to
#  the Free Software Foundation, 51 Franklin Street, Suite 500, Boston, MA 02110, USA.
#  http://www.gnu.org/copyleft/gpl.html
################################################################################

PKG_NAME="native32emu-lr"
PKG_VERSION="d6fb25ec330fcec36b74135bac36e19fbdc16338"
PKG_LICENSE="MPLv2.0"
PKG_SITE="https://github.com/jiangxincode/Native32Emu"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain cargo:host"
PKG_LONGDESC="Native32 Emulator"
PKG_PATCH_DIRS+="${DEVICE}"

PKG_TOOLCHAIN="manual"

make_target() {
  cd ${PKG_BUILD}
  cargo build \
    --target ${TARGET_NAME} \
    --release \
    --locked \
    -p native32emu-libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${CARGO_TARGET_DIR}/${TARGET_NAME}/release/libnative32emu.so ${INSTALL}/usr/lib/libretro/native32emu_libretro.so
}
