#!/usr/bin/env bash
# Unpack S905 image, touch zh_CN on the AURKNIX (/flash) partition, recompress.
set -euo pipefail

src="${1:?usage: prepare-s905-zh-cn-img.sh input.img.gz}"

if [[ "${src}" != *S905* ]]; then
  echo "Not an S905 image: ${src}" >&2
  exit 1
fi

dest="${src%.img.gz}-zh_CN.img.gz"
workdir="$(mktemp -d)"
img="${workdir}/image.img"
mnt="${workdir}/mnt"
loop=""

cleanup() {
  sudo umount "${mnt}" 2>/dev/null || true
  if [[ -n "${loop}" ]]; then
    sudo losetup -d "${loop}" 2>/dev/null || true
  fi
  rm -rf "${workdir}"
}
trap cleanup EXIT

mkdir -p "${mnt}"
gunzip -c "${src}" > "${img}"

loop="$(sudo losetup -f --show -P "${img}")"
sudo mount "${loop}p1" "${mnt}"
sudo touch "${mnt}/zh_CN"
sudo umount "${mnt}"
sudo losetup -d "${loop}"
loop=""

gzip -c "${img}" > "${dest}"
echo "${dest}"
