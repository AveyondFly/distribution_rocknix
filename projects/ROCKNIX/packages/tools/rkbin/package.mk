# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-2024 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rkbin"
case ${DEVICE} in
  RK3562)
    # RK3562 requires newer rkbin with rk3562 firmware
    PKG_VERSION="74213af1e952c4683d2e35952507133b61394862"
    ;;
  *)
    PKG_VERSION="7c35e21a8529b3758d1f051d1a5dc62aae934b2b"
    ;;
esac
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/rockchip-linux/rkbin"
PKG_URL="https://github.com/rockchip-linux/rkbin/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="rkbin: Rockchip Firmware and Tool Binaries"
PKG_TOOLCHAIN="manual"

post_unpack() {
  # RK3326: tune TPL for UART5 used on K36 clones
  # RK3562 uses newer rkbin and doesn't need this
  if [ "${DEVICE}" != "RK3562" ]; then
    cp -v ${PKG_BUILD}/bin/rk33/rk3326_ddr_333MHz_*.bin ${PKG_BUILD}/rk3326_ddr_uart5.bin
    ${PKG_BUILD}/tools/ddrbin_tool rk3326 -g ${PKG_BUILD}/rk3326_ddr_uart5.txt ${PKG_BUILD}/rk3326_ddr_uart5.bin
    sed -i 's|uart id=.*$|uart id=5|' ${PKG_BUILD}/rk3326_ddr_uart5.txt
    ${PKG_BUILD}/tools/ddrbin_tool rk3326 ${PKG_BUILD}/rk3326_ddr_uart5.txt ${PKG_BUILD}/rk3326_ddr_uart5.bin >/dev/null
  fi
}
