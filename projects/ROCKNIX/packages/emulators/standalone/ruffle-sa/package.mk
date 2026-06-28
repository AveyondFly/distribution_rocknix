# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 AURKNIX (https://github.com/AveyondFly/distribution_rocknix)

PKG_NAME="ruffle-sa"
PKG_VERSION="3bc39c5e0fdbc9fcde92681706395f6ef70f991b"
PKG_SITE="https://github.com/AveyondFly/ruffle-aurknix"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_BRANCH="main"
PKG_LICENSE="MIT OR Apache-2.0"
PKG_DEPENDS_TARGET="toolchain cargo:host rust:host SDL2 pulseaudio"
PKG_LONGDESC="Adobe Flash Player emulator (Ruffle SDL2 frontend for ROCKNIX)"
PKG_TOOLCHAIN="manual"

pre_configure_target() {
  export JAVA_HOME="${JAVA_HOME:-/usr}"
  export PKG_CONFIG_SYSROOT_DIR="${SYSROOT_PREFIX}"
  export PKG_CONFIG_PATH="${SYSROOT_PREFIX}/usr/lib/pkgconfig"
  export RUSTC_LINKER="${CC}"
  export RUSTFLAGS="-C link-arg=-Wl,-rpath-link,${SYSROOT_PREFIX}/usr/lib ${RUSTFLAGS}"
}

make_target() {
  cargo build \
    --release \
    --target ${TARGET_NAME} \
    -p sdl2test-rocknix
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/start_ruffle.sh ${INSTALL}/usr/bin/
  chmod 0755 ${INSTALL}/usr/bin/start_ruffle.sh

  mkdir -p ${INSTALL}/usr/config/ruffle
  cp ${PKG_BUILD}/.${TARGET_NAME}/target/${TARGET_NAME}/release/sdl2test-rocknix ${INSTALL}/usr/config/ruffle/
  ${STRIP} ${INSTALL}/usr/config/ruffle/sdl2test-rocknix
  cp ${PKG_DIR}/config/ruffle.gptk ${INSTALL}/usr/config/ruffle/
}
