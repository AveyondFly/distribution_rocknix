# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2026 ROCKNIX — PPSSPP v1.12.3 (ArkOS rk3326_core_builds workflow)

PKG_NAME="ppsspp2021-sa"
PKG_SITE="https://github.com/hrydgard/ppsspp"
PKG_URL="${PKG_SITE}.git"
PKG_VERSION="5310e411b4856949344020ebfcc5c6d3f22a6ff7" # v1.12.3
CHEAT_DB_VERSION="7c9fe1ae71155626cea767aed53f968de9f4051f"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain ffmpeg libzip SDL2 zlib zip"
PKG_LONGDESC="PPSSPP v1.12.3 standalone (legacy GLES build)"
GET_HANDLER_SUPPORT="git"

PKG_CMAKE_OPTS_TARGET=" -DUSE_SYSTEM_FFMPEG=OFF \
                        -DCMAKE_BUILD_TYPE=Release \
                        -DCMAKE_SYSTEM_NAME=Linux \
                        -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
                        -DBUILD_SHARED_LIBS=OFF \
                        -DUSE_SYSTEM_LIBPNG=OFF \
                        -DANDROID=OFF \
                        -DWIN32=OFF \
                        -DAPPLE=OFF \
                        -DCMAKE_CROSSCOMPILING=ON \
                        -DUSING_QT_UI=OFF \
                        -DUNITTEST=OFF \
                        -DSIMULATOR=OFF \
                        -DHEADLESS=OFF \
                        -DUSE_DISCORD=OFF"

if [ "${OPENGL_SUPPORT}" = "yes" ] && [ ! "${PREFER_GLES}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd glew"
  PKG_CMAKE_OPTS_TARGET+=" -DUSING_FBDEV=OFF \
			   -DUSING_GLES2=OFF"

elif [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSING_FBDEV=ON \
                           -DUSING_EGL=OFF \
                           -DUSING_GLES2=ON"
fi

PKG_CMAKE_OPTS_TARGET+=" -DVULKAN=OFF \
                         -DUSE_VULKAN_DISPLAY_KHR=OFF \
                         -DUSING_X11_VULKAN=OFF"
GRENDERER="0 (OPENGL)"

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER}"
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_WAYLAND_WSI=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DUSE_WAYLAND_WSI=OFF"
fi

case ${TARGET_ARCH} in
  aarch64)
    PKG_CMAKE_OPTS_TARGET+=" -DFORCED_CPU=aarch64"
  ;;
esac

pre_configure_target() {
  echo '#include <cstdint>' > ${PKG_BUILD}/ppsspp_stdint_force.h
  sed -i 's/\-O[23]//g' ${PKG_BUILD}/CMakeLists.txt
  sed -i "s|include_directories(/usr/include/drm)|include_directories(${SYSROOT_PREFIX}/usr/include/drm)|" ${PKG_BUILD}/CMakeLists.txt

  export CFLAGS="${CFLAGS} -fPIC -Wno-error"
  export CXXFLAGS="${CXXFLAGS} -fpermissive -fPIC -Wno-error"
  export CPPFLAGS="${CPPFLAGS} -Wno-error"
}

pre_make_target() {
  if [ "${TARGET_ARCH}" = "aarch64" ]; then
    FFSH="${PKG_BUILD}/ffmpeg/linux_arm64.sh"
    if [ -f "${FFSH}" ]; then
      sed -i '/--disable-everything \\/s//--disable-everything \\\n --disable-iconv \\/g' "${FFSH}"
      sed -i '/-finline-limit\=300/s//-finline-limit\=300 -fPIC /g' "${FFSH}"
      sed -i '/make clean/s//sed -i \"s\/^#define HAVE_ARC4RANDOM 1\/#define HAVE_ARC4RANDOM 0\/\" config.h\nmake clean/' "${FFSH}"
      sed -i "s|aarch64-linux-gnu-|${TARGET_PREFIX}|g" "${FFSH}"
      (cd ${PKG_BUILD}/ffmpeg && ./linux_arm64.sh)
    fi
  fi

  find ${PKG_BUILD} -name flags.make -exec sed -i "s:isystem :I:g" \{} \;
  find ${PKG_BUILD} -name build.ninja -exec sed -i "s:isystem :I:g" \{} \;
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/ppsspp2021
  mkdir -p ${INSTALL}/usr/bin
  cp PPSSPPSDL ${INSTALL}/usr/lib/ppsspp2021/

  ln -sf /storage/.config/ppsspp2021/assets ${INSTALL}/usr/lib/ppsspp2021/assets

  mkdir -p ${INSTALL}/usr/config/ppsspp2021/PSP/SYSTEM
  mkdir -p ${INSTALL}/usr/config/ppsspp2021/PSP/Cheats
  cp -r `find . -name "assets" | xargs echo` ${INSTALL}/usr/config/ppsspp2021/

  if [ -d "${PKG_DIR}/../ppsspp-sa/config" ]; then
    cp -rf ${PKG_DIR}/../ppsspp-sa/config/* ${INSTALL}/usr/config/ppsspp2021/
  fi

  if [ -d "${PKG_DIR}/../ppsspp-sa/sources/${DEVICE}" ]; then
    cp ${PKG_DIR}/../ppsspp-sa/sources/${DEVICE}/* ${INSTALL}/usr/config/ppsspp2021/PSP/SYSTEM
  fi

  rm -f ${INSTALL}/usr/config/ppsspp2021/assets/gamecontrollerdb.txt
  ln -sf NotoSansJP-Regular.ttf ${INSTALL}/usr/config/ppsspp2021/assets/Roboto-Condensed.ttf
  curl -Lo ${INSTALL}/usr/config/ppsspp2021/PSP/Cheats/cheat.db https://raw.githubusercontent.com/Saramagrean/CWCheat-Database-Plus-/${CHEAT_DB_VERSION}/cheat.db

  cat >${INSTALL}/usr/bin/ppsspp2021 <<'EOF'
#!/bin/sh
exec /usr/lib/ppsspp2021/PPSSPPSDL "$@"
EOF
  chmod 0755 ${INSTALL}/usr/bin/ppsspp2021

  cp ${PKG_DIR}/scripts/start_ppsspp2021.sh ${INSTALL}/usr/bin
  cp ${PKG_DIR}/scripts/cheevos_ppsspp2021.sh ${INSTALL}/usr/bin
  chmod 0755 ${INSTALL}/usr/bin/start_ppsspp2021.sh ${INSTALL}/usr/bin/cheevos_ppsspp2021.sh
}

post_install() {
  sed -e "s/@GRENDERER@/${GRENDERER}/g" -i ${INSTALL}/usr/bin/start_ppsspp2021.sh
}
