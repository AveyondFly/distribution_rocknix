#!/usr/bin/env bash
# Build Radxa BSP u-boot for Cubie A5E and refresh bin/ (run outside ROCKNIX build).
# Requires: arm-linux-gnueabi-gcc, curl, tar, busybox, git (optional)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${SCRIPT_DIR}/bin"
WORK="${TMPDIR:-/tmp}/a527-uboot-build-$$"
PACK_WORK="${WORK}/pack"

UBOOT_REV="${UBOOT_REV:-4c7078cfdf7f014b89a38a1d5cb1f17dc9314489}"
DEVICE_REPO_REV="${DEVICE_REPO_REV:-device-a527-v1.4.6}"
OPI_BUILD_REF="${OPI_BUILD_REF:-next}"

mkdir -p "${BIN_DIR}" "${WORK}" "${PACK_WORK}"

echo "==> Fetch Radxa u-boot @ ${UBOOT_REV}"
curl -fsSL "https://github.com/radxa/u-boot/archive/${UBOOT_REV}.tar.gz" \
  | tar xz -C "${WORK}" --strip-components=1

echo "==> Fetch board files"
curl -fsSL "https://github.com/radxa/allwinner-device/archive/refs/heads/${DEVICE_REPO_REV}.tar.gz" \
  | tar xz -C "${WORK}" --strip-components=1 \
    "allwinner-device-${DEVICE_REPO_REV}/configs/cubie_a5e/uboot-board.dts" \
    "allwinner-device-${DEVICE_REPO_REV}/configs/cubie_a5e/sys_config.fex" 2>/dev/null \
  || curl -fsSL "https://github.com/radxa/allwinner-device/archive/refs/heads/${DEVICE_REPO_REV}.tar.gz" \
  | tar xz -C "${WORK}" --strip-components=1 \
    configs/cubie_a5e/uboot-board.dts \
    configs/cubie_a5e/sys_config.fex
mkdir -p "${WORK}/device-a527/configs/cubie_a5e"
cp "${WORK}/configs/cubie_a5e/uboot-board.dts" "${WORK}/device-a527/configs/cubie_a5e/"
cp "${WORK}/configs/cubie_a5e/sys_config.fex" "${WORK}/device-a527/configs/cubie_a5e/"
cp "${WORK}/configs/cubie_a5e/uboot-board.dts" "${SCRIPT_DIR}/dts/uboot-board.dts"

echo "==> Fetch Orange Pi pack-uboot tools (dragonsecboot, update_uboot, ...)"
curl -fsSL "https://github.com/orangepi-xunlong/orangepi-build/archive/refs/heads/${OPI_BUILD_REF}.tar.gz" \
  | tar xz -C "${WORK}" \
    "orangepi-build-${OPI_BUILD_REF}/external/packages/pack-uboot/tools" \
    "orangepi-build-${OPI_BUILD_REF}/external/packages/pack-uboot/sun55iw3/bin"
mv "${WORK}/orangepi-build-${OPI_BUILD_REF}/external/packages/pack-uboot/tools" "${WORK}/tools"
mv "${WORK}/orangepi-build-${OPI_BUILD_REF}/external/packages/pack-uboot/sun55iw3/bin" "${WORK}/opi-bin"
rm -rf "${WORK}/orangepi-build-${OPI_BUILD_REF}"
TOOLS="${WORK}/tools"
OPI_BIN="${WORK}/opi-bin"

echo "==> Toolchain layout (Radxa Makefile expects ../tools/toolchain/...)"
mkdir -p "${WORK}/../tools/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi/bin"
for t in gcc g++ as ld ld.bfd ar nm objcopy objdump strip cpp readelf; do
  ln -sf "$(command -v arm-linux-gnueabi-${t})" \
    "${WORK}/../tools/toolchain/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi/bin/arm-linux-gnueabi-${t}"
done

cat > "${WORK}/../.buildconfig" <<EOF
LICHEE_BUSSINESS=linux
LICHEE_CHIP_CONFIG_DIR=${WORK}/device-a527/configs
LICHEE_ARCH=arm64
LICHEE_IC=sun55iw3p1
LICHEE_CHIP=sun55iw3p1
LICHEE_BOARD=cubie_a5e
LICHEE_PLAT_OUT=${WORK}/out
LICHEE_BOARD_CONFIG_DIR=${WORK}/device-a527/configs/cubie_a5e
LICHEE_BRANDY_DEFCONF=sun55iw3p1_defconfig
EOF

cd "${WORK}"
if ! grep -q 'Wno-error=attributes' Makefile; then
  sed -i 's/-Werror/-Werror -Wno-error=attributes/' Makefile
fi

echo "==> Configure radxa-cubie-a5e_defconfig (CONFIG_DISTRO_DEFAULTS / extlinux)"
make mrproper >/dev/null 2>&1 || true
make radxa-cubie-a5e_defconfig
make -j"$(nproc)"

echo "==> Download Radxa boot0"
curl -fsSL "https://raw.githubusercontent.com/radxa/allwinner-device/${DEVICE_REPO_REV}/bin/boot0_sdcard_sun55iw3p1.bin" \
  -o "${PACK_WORK}/boot0_sdcard.fex"

echo "==> Pack boot_package.fex"
cd "${PACK_WORK}"
cp "${WORK}/u-boot.bin" u-boot.fex
cp "${WORK}/arch/arm/dts/sun55i-a527-cubie-a5e.dtb" sunxi.fex
cp "${OPI_BIN}/monitor.fex-linux5.15" monitor.fex
cp "${OPI_BIN}/scp.fex" scp.fex
cp "${WORK}/configs/cubie_a5e/sys_config.fex" sys_config.bin

cat > boot_package.cfg <<'EOF'
[package]
item=u-boot,                 u-boot.fex
item=monitor,                monitor.fex
item=scp,                    scp.fex
item=dtb,                    sunxi.fex
EOF

export PATH="${TOOLS}:${PATH}"
"${TOOLS}/update_uboot" -no_merge u-boot.fex sys_config.bin
busybox unix2dos boot_package.cfg 2>/dev/null || true
"${TOOLS}/dragonsecboot" -pack boot_package.cfg

cp boot0_sdcard.fex "${BIN_DIR}/boot0_sdcard_sun55iw3p1.bin"
cp boot_package.fex "${BIN_DIR}/boot_package.fex"
arm-linux-gnueabi-objcopy -O binary "${WORK}/u-boot" "${BIN_DIR}/u-boot-sun55iw3p1.bin"

echo "==> Installed:"
ls -la "${BIN_DIR}/"
sha256sum "${BIN_DIR}"/*
echo "Done. u-boot rev ${UBOOT_REV}, defconfig radxa-cubie-a5e_defconfig"
