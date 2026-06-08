# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="libretro-database"
PKG_VERSION="fbcc8c1c24d8b20b6aaca95b4da6a2f39ad85f05"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/libretro/libretro-database"
PKG_URL="https://github.com/libretro/libretro-database/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET=""
PKG_LONGDESC="Repository containing cheatcode files, content data files, etc."
PKG_TOOLCHAIN="manual"

PKG_CHEATS_VERSION="v0.9"
PKG_CHEATS_SOURCE_NAME="console_mod_res-cheats-${PKG_CHEATS_VERSION}.tar.gz"
PKG_CHEATS_URL="https://github.com/AveyondFly/console_mod_res/releases/download/${PKG_CHEATS_VERSION}/cheats.tar.gz"
PKG_CHEATS_SHA256="8169cca4c7b8b7b75bdebd6ffb0bd7f2d84d1968477f6c6acccb934de72bd132"

fetch_cheats_archive() {
  local tarball="${SOURCES}/${PKG_NAME}/${PKG_CHEATS_SOURCE_NAME}"

  mkdir -p "${SOURCES}/${PKG_NAME}"

  if [ ! -f "${tarball}" ]; then
    echo "GET      ${PKG_NAME} cheats (archive)" >&2
    if command -v wget >/dev/null 2>&1; then
      wget -q -O "${tarball}" "${PKG_CHEATS_URL}" || \
        die "ERROR: Failed to download ${PKG_NAME} cheats from ${PKG_CHEATS_URL}"
    else
      curl -fsSL -o "${tarball}" "${PKG_CHEATS_URL}" || \
        die "ERROR: Failed to download ${PKG_NAME} cheats from ${PKG_CHEATS_URL}"
    fi
  fi

  echo "${PKG_CHEATS_SHA256}  ${tarball}" | sha256sum -c - >&2 || \
    die "ERROR: ${PKG_NAME} cheats checksum mismatch for ${tarball}"

  echo "${tarball}"
}

post_unpack() {
  sed -i '/cp -ar -t .* cht cursors/s/ rdb//' ${PKG_BUILD}/Makefile
}

makeinstall_target() {
  make install INSTALLDIR="${INSTALL}/usr/share/libretro-database" -C "${PKG_BUILD}"

  mkdir -p "${INSTALL}/usr/share/libretro-database/cht"
  tar --strip-components=1 -xf "$(fetch_cheats_archive)" -C "${INSTALL}/usr/share/libretro-database/cht"
}
