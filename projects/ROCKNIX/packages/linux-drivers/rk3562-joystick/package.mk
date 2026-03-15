# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rk3562-joystick"
PKG_VERSION="1.0"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/bmdhacks/kernel_rk3562"
PKG_URL=""
PKG_LONGDESC="rk3562-joystick: RK3562 handheld gamepad driver"
PKG_TOOLCHAIN="manual"
PKG_IS_KERNEL_PKG="yes"

unpack() {
  mkdir -p ${PKG_BUILD}
  cp ${PKG_DIR}/*.c ${PKG_DIR}/Makefile ${PKG_BUILD}/
}

pre_make_target() {
  unset LDFLAGS
}

make_target() {
  kernel_make -C $(kernel_path) M=${PKG_BUILD}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
  cp ${PKG_BUILD}/*.ko ${INSTALL}/$(get_full_module_dir)/${PKG_NAME}
}
