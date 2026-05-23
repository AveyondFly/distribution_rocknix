# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present Team CoreELEC (https://coreelec.org)

PKG_NAME="opentee_linuxdriver"
PKG_VERSION="0.1"
PKG_SHA256=""
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/CoreELEC/CoreELEC"
PKG_DEPENDS_TARGET="toolchain linux"
PKG_LONGDESC="OP-TEE SECPU FW Loader"
PKG_TOOLCHAIN="manual"

# Vendor OP-TEE userspace blobs tracked in CoreELEC, fetched at build time.
PKG_OPENTEE_FS_REF="coreelec-22"
PKG_OPENTEE_FS_BASE="projects/Amlogic-ce/packages/linux-drivers/amlogic/opentee_linuxdriver/filesystem"
PKG_OPENTEE_FS_URL="https://raw.githubusercontent.com/CoreELEC/CoreELEC/${PKG_OPENTEE_FS_REF}/${PKG_OPENTEE_FS_BASE}"

fetch_opentee_file() {
  local relpath="${1}"
  local out="${SOURCES}/opentee_linuxdriver/${PKG_OPENTEE_FS_REF}/${relpath}"

  mkdir -p "$(dirname "${out}")"

  if [ ! -f "${out}" ]; then
    echo "GET      opentee_linuxdriver ${relpath}" >&2
    if command -v wget >/dev/null 2>&1; then
      wget -q -O "${out}" "${PKG_OPENTEE_FS_URL}/${relpath}" || \
        die "ERROR: Failed to download opentee_linuxdriver ${relpath}"
    else
      curl -fsSL -o "${out}" "${PKG_OPENTEE_FS_URL}/${relpath}" || \
        die "ERROR: Failed to download opentee_linuxdriver ${relpath}"
    fi
  fi

  echo "${out}"
}

install_opentee_filesystem() {
  local dest="${PKG_BUILD}/filesystem/${ARCH}"
  local libdir="${dest}/usr/lib"
  local sbindir="${dest}/usr/sbin"

  mkdir -p "${libdir}" "${sbindir}"

  cp -a "$(fetch_opentee_file ${ARCH}/usr/lib/libteec.so.1.0.0)" "${libdir}/"
  cp -a "$(fetch_opentee_file ${ARCH}/usr/lib/libtee_preload_fw.so)" "${libdir}/"
  cp -a "$(fetch_opentee_file ${ARCH}/usr/sbin/tee-supplicant)" "${sbindir}/"
  cp -a "$(fetch_opentee_file ${ARCH}/usr/sbin/tee_preload_fw)" "${sbindir}/"
  cp -a "$(fetch_opentee_file ${ARCH}/usr/sbin/tee_stest)" "${sbindir}/"
  chmod 0755 "${sbindir}/"*

  ln -sfn libteec.so.1.0.0 "${libdir}/libteec.so.1.0"
  ln -sfn libteec.so.1.0 "${libdir}/libteec.so.1"
  ln -sfn libteec.so.1.0 "${libdir}/libteec.so"

  for soc in ${TEE_SOC}; do
    local ta_dir="${dest}/ta/v3.8/dev/${soc}"
    mkdir -p "${ta_dir}"
    cp -a "$(fetch_opentee_file ${ARCH}/ta/v3.8/dev/${soc}/526fc4fc-7ee6-4a12-96e3-83da9565bce8.ta)" "${ta_dir}/"
  done
}

post_unpack() {
  install_opentee_filesystem
}

make_target() {
  ${CC} -Wall -shared -fPIC -o tee-dummy-rpmb.so tee-dummy-rpmb.c
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/ta
    ln -sf /var/lib/optee_armtz ${INSTALL}/usr/lib/optee_armtz

    for soc in ${TEE_SOC}; do
      DIRSOC="${PKG_BUILD}/filesystem/${ARCH}/ta/v3.8/dev/${soc}"
      [ -d ${DIRSOC} ] && cp -rP ${DIRSOC} ${INSTALL}/usr/lib/ta
    done

  mkdir -p ${INSTALL}/usr/lib/coreelec
    install -m 0755 ${PKG_DIR}/scripts/tee-loader.sh ${INSTALL}/usr/lib/coreelec/tee-loader
    install -m 0755 ${PKG_DIR}/scripts/dovi-loader.sh ${INSTALL}/usr/lib/coreelec/dovi-loader
    install -m 0755 ${PKG_DIR}/scripts/read-firmware-version.sh ${INSTALL}/usr/lib/coreelec/read-firmware-version

  cp -rP ${PKG_BUILD}/filesystem/${ARCH}/usr ${INSTALL}

  cp tee-dummy-rpmb.so ${INSTALL}/usr/lib/coreelec
}

post_install() {
  enable_service opentee_linuxdriver.service

  # create mount points for Android partitions
  # must be /vendor because .ta file is used by absolute path
  mkdir -p ${INSTALL}/android/odm
  mkdir -p ${INSTALL}/android/oem
  mkdir -p ${INSTALL}/android/system
  mkdir -p ${INSTALL}/android/vendor
  ln -sf /android/system/system ${INSTALL}/system
  ln -sf /android/vendor ${INSTALL}/vendor
}
