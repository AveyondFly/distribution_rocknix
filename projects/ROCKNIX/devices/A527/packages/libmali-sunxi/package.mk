# SPDX-License-Identifier: GPL-2.0
# Allwinner Tina AIOT V1.4.6 Mali-G57 DDK userspace (wayland + gbm + vulkan)

PKG_NAME="libmali-sunxi"
PKG_VERSION="5aca0243fa630708d01a4b97c4513aed4fe014f0"
PKG_SITE="https://github.com/AveyondFly/a527-bsp-sdk"
PKG_LICENSE="nonfree"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="Allwinner sun55i Mali-G57 DDK userspace from a527-bsp-sdk monorepo"
PKG_DEPENDS_TARGET="toolchain libdrm gpudriver"

# Tina ships per-toolchain trees; gcc-10.3 matches the AIOT SDK buildroot toolchain generation.
PKG_LIBGPU_SUBDIR="mali-g57/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/wayland/aarch64-none-linux-gnu/lib64"

unpack() {
  [ -d "${PKG_BUILD}" ] && rm -rf "${PKG_BUILD}"
  echo "GET      a527-bsp-sdk libgpu/mali-g57 (sparse @${PKG_VERSION:0:12})" >&2
  git clone --depth 1 --filter=blob:none --sparse \
    "${PKG_SITE}.git" "${PKG_BUILD}" || \
    die "libmali-sunxi: failed to clone ${PKG_SITE}"
  ( cd "${PKG_BUILD}"
    git fetch --depth 1 origin "${PKG_VERSION}"
    git checkout "${PKG_VERSION}"
    git sparse-checkout set libgpu/mali-g57
  ) || die "libmali-sunxi: failed to checkout ${PKG_VERSION}"
}

make_target() {
  :
}

makeinstall_target() {
  local libroot="${PKG_BUILD}/libgpu/${PKG_LIBGPU_SUBDIR}"
  local libdir="${INSTALL}/usr/lib"

  if [ ! -d "${libroot}" ]; then
    die "libmali-sunxi: missing ${PKG_LIBGPU_SUBDIR} in a527-bsp-sdk checkout"
  fi

  mkdir -p "${libdir}/mali" "${INSTALL}/usr/share/vulkan/icd.d" \
           "${INSTALL}/usr/share/vulkan/implicit_layer.d"

  install -Dm755 "${libroot}/mali/libmali.so.0.32.0" "${libdir}/mali/libmali.so.0.32.0"
  ln -sf mali/libmali.so.0.32.0 "${libdir}/libmali.so.0"
  ln -sf libmali.so.0 "${libdir}/libmali.so"

  for lib in egl/libEGL.so.1.4.0 gbm/libgbm.so.1.0.0 \
             gles1/libGLESv1_CM.so.1.1.0 gles2/libGLESv2.so.2.1.0 \
             wayland-egl/libwayland-egl.so.1.0.0; do
    install -Dm755 "${libroot}/${lib}" "${libdir}/$(basename "${lib}")"
  done

  ln -sf libEGL.so.1.4.0 "${libdir}/libEGL.so.1"
  ln -sf libEGL.so.1 "${libdir}/libEGL.so"
  ln -sf libgbm.so.1.0.0 "${libdir}/libgbm.so.1"
  ln -sf libgbm.so.1 "${libdir}/libgbm.so"
  ln -sf libGLESv1_CM.so.1.1.0 "${libdir}/libGLESv1_CM.so.1"
  ln -sf libGLESv1_CM.so.1 "${libdir}/libGLESv1_CM.so"
  ln -sf libGLESv2.so.2.1.0 "${libdir}/libGLESv2.so.2"
  ln -sf libGLESv2.so.2 "${libdir}/libGLESv2.so"
  ln -sf libwayland-egl.so.1.0.0 "${libdir}/libwayland-egl.so.1"
  ln -sf libwayland-egl.so.1 "${libdir}/libwayland-egl.so"

  if [ "${VULKAN_SUPPORT}" = "yes" ]; then
    install -Dm755 "${libroot}/vulkan/libvulkan.so.1.3.296" "${libdir}/libvulkan.so.1.3.296"
    ln -sf libvulkan.so.1.3.296 "${libdir}/libvulkan.so.1"
    ln -sf libvulkan.so.1 "${libdir}/libvulkan.so"
    install -Dm755 "${libroot}/vulkan_wsi/libVkLayer_window_system_integration.so" \
      "${libdir}/libVkLayer_window_system_integration.so"

    cat > "${INSTALL}/usr/share/vulkan/icd.d/mali_icd.json" <<'EOF'
{
  "file_format_version": "1.0.0",
  "ICD": {
    "library_path": "/usr/lib/libmali.so",
    "api_version": "1.2.0",
    "device_type": "VK_DEVICE_TYPE_PHYSICAL_DEVICE"
  }
}
EOF

    install -Dm644 "${PKG_BUILD}/libgpu/mali-g57/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/wayland/VkLayer_window_system_integration.json" \
      "${INSTALL}/usr/share/vulkan/implicit_layer.d/VkLayer_window_system_integration.json"
  fi
}
