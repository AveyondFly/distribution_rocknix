# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-2024 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rkbin"
PKG_LICENSE="nonfree"
PKG_SITE="https://github.com/rockchip-linux/rkbin"
PKG_LONGDESC="rkbin: Rockchip Firmware and Tool Binaries"
PKG_TOOLCHAIN="manual"

case "${DEVICE}" in
  RK3588)
    # Pin rk3588 here until it hits mainline
    PKG_VERSION="7c35e21a8529b3758d1f051d1a5dc62aae934b2b"
    ;;
  *)
    PKG_VERSION="74213af1e952c4683d2e35952507133b61394862"
    ;;
esac

PKG_URL="https://github.com/rockchip-linux/rkbin/archive/${PKG_VERSION}.tar.gz"

post_unpack() {
 if [ "${DEVICE}" == "RK3326" ]; then
  # RK3326: the stock TPL blob initialises every DDR type at 333MHz and
  # mainline has no px30 dmc driver, so the memory stays at 333MHz for
  # the life of the system. That is far below what the BSP-based OSes on
  # the same boards run: dArkOS scales the DDR with dmc_ondemand up to
  # the 786MHz BSP ceiling and pins 528MHz even in its powersave mode.
  # Rewrite the frequency fields inside the TPL with Rockchip's own
  # ddrbin_tool (the long-standing ArkOS "DDR fix") so the memory comes
  # up at speed from boot.
  #
  # 786MHz failed a cold-init boot test once (2026-07-02, R36S) when a stale
  # partial flash was mistaken for a real failure; retry with a full 16MB
  # uboot.bin write before giving up. dArkOS reaches 786 through the BSP
  # dmc driver's runtime retraining; this TPL path sets the cold-init target.
  # Drop to 666 or 528 if a board genuinely fails at 786.
  RK3326_DDR_FREQ="${RK3326_DDR_FREQ:-786}"
  DDR_BIN="$(ls ${PKG_BUILD}/bin/rk33/rk3326_ddr_333MHz_*.bin)"
  ${PKG_BUILD}/tools/ddrbin_tool.py rk3326 -g ${PKG_BUILD}/rk3326_ddr_freq.txt ${DDR_BIN}
  sed -i -E "s#^(lp2_freq|ddr3_freq|lp3_freq|ddr4_freq|lp4_freq)=.*#\1=${RK3326_DDR_FREQ}#" ${PKG_BUILD}/rk3326_ddr_freq.txt
  ${PKG_BUILD}/tools/ddrbin_tool.py rk3326 ${PKG_BUILD}/rk3326_ddr_freq.txt ${DDR_BIN} >/dev/null
  echo "rkbin: RK3326 TPL DDR frequency set to ${RK3326_DDR_FREQ}MHz"

  # tune a second TPL copy for UART5 used on K36 clones (inherits the
  # DDR frequency edit above)
  cp -v ${DDR_BIN} ${PKG_BUILD}/rk3326_ddr_uart5.bin
  ${PKG_BUILD}/tools/ddrbin_tool.py rk3326 -g ${PKG_BUILD}/rk3326_ddr_uart5.txt ${PKG_BUILD}/rk3326_ddr_uart5.bin
  sed -i 's|uart id=.*$|uart id=5|' ${PKG_BUILD}/rk3326_ddr_uart5.txt
  ${PKG_BUILD}/tools/ddrbin_tool.py rk3326 ${PKG_BUILD}/rk3326_ddr_uart5.txt ${PKG_BUILD}/rk3326_ddr_uart5.bin >/dev/null
 fi
}
