# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="free-j2me"
PKG_VERSION="master"
PKG_SITE="https://github.com/AveyondFly/freej2me-miyoomini"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain apache-ant:host SDL2 SDL2_mixer SDL2_ttf freeimage"
PKG_LONGDESC="J2ME emulator with SDL2 frontend for embedded devices."
PKG_TOOLCHAIN="make"

pre_configure_target() {
  # Build JAR with ant - natives/dist/linux-aarch64 already has libffaudio.so
  ${TOOLCHAIN}/bin/ant -Dvariant=linux-${ARCH}
}

make_target() {
  # Compile sdl2_interface frontend
  cd ${PKG_BUILD}/cpp/sdl2
  make clean
  make TOOLCHAIN=${TOOLCHAIN}/bin/${TARGET_NAME}-
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/java
  cp ${PKG_BUILD}/build/freej2me-sdl.jar ${INSTALL}/usr/config/java/
  
  # Copy sdl_interface frontend
  cp ${PKG_BUILD}/cpp/sdl2/sdl_interface ${INSTALL}/usr/config/java/

  mkdir -p ${INSTALL}/usr/config/java/lib
  cp ${PKG_BUILD}/cpp/native/lib/* ${INSTALL}/usr/config/java/lib/

  # Copy additional files if they exist
  if [ -f ${PKG_BUILD}/cpp/sdl2/keymap.cfg ]; then
    cp ${PKG_BUILD}/cpp/sdl2/keymap.cfg ${INSTALL}/usr/config/java/
  fi

  cp ${PKG_DIR}/sources/j2me.gptk ${INSTALL}/usr/config/java/
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_DIR}/sources/start_freej2me.sh ${INSTALL}/usr/bin/

  curl -Lo ${PKG_BUILD}/jdk.zip https://github.com/AveyondFly/console_mod_res/releases/download/v0.9/jdk.zip
  mkdir -p ${INSTALL}/usr/share/java/
  cp ${PKG_BUILD}/jdk.zip ${INSTALL}/usr/share/java/

}
