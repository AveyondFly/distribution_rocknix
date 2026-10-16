# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot-RK3562"
PKG_VERSION="ngp45h-20260711-tf-first"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/AveyondFly/distribution_rocknix"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Prebuilt RK3562 NGP45H DDR/SPL and U-Boot FIT with TF-first boot."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/options ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"

# Default boot chain for new images. First boot and system updates sync the
# device's own eMMC bootloader together with its hardcoded DTB and boot assets.
# Cross-model validation of this initial NGP45H boot chain is still pending;
# see bin/manifest.json for provenance and validation status.
# bootloader_area.img retains disk-relative offsets but contains no partition
# table or Vendor Storage; the FIT scans TF extlinux before the stock boot flow.

unpack() {
  (cd "${PKG_DIR}/bin" && sha256sum -c SHA256SUMS) || die "RK3562 bootloader checksum mismatch"
  mkdir -p "${PKG_BUILD}"
  cp "${PKG_DIR}/bin/bootloader_area.img" "${PKG_DIR}/bin/uboot_partition.img" "${PKG_BUILD}/"
}

make_target() {
  : # nothing
}

makeinstall_target() {
  # Pre-partition blob for the final dd seek=64:
  #   source sector 64   -> blob sector 0     -> disk sector 64 (idbloader / SPL)
  #   blob sector 16320  -> disk sector 16384 (U-Boot FIT, 4 MiB)
  # The source preserves disk sectors 0-16383, so skip its first 64 sectors.
  # Clear an existing blob as well, so repeated installs leave zero-filled gaps.
  truncate -s 0 "${PKG_BUILD}/uboot.bin"
  truncate -s $((32704 * 512)) "${PKG_BUILD}/uboot.bin"
  dd if="${PKG_BUILD}/bootloader_area.img" \
    of="${PKG_BUILD}/uboot.bin" \
    bs=512 skip=64 count=16320 conv=fsync,notrunc status=none
  dd if="${PKG_BUILD}/uboot_partition.img" \
    of="${PKG_BUILD}/uboot.bin" \
    bs=512 seek=16320 conv=fsync,notrunc status=none
}
