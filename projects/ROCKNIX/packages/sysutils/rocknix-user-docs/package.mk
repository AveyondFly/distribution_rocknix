# SPDX-License-Identifier: GPL-2.0-or-later

PKG_NAME="rocknix-user-docs"
PKG_VERSION="1.0"
PKG_LICENSE="GPLv2"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain"
PKG_SECTION="misc"
PKG_LONGDESC="User manuals as PDF under /usr/share/misc/doc/rocknix-user-man (CI: documentation/user_man/prebuilt-pdf from rocknix-user-manuals-pdfs artifact; else pandoc/host or tools/manual-pdf bootstrap)"
PKG_TOOLCHAIN="manual"

make_target() {
  :
}

makeinstall_target() {
  local DEST_DOC="${INSTALL}/usr/share/misc/doc/rocknix-user-man"
  local PRE="${ROOT}/documentation/user_man/prebuilt-pdf"
  mkdir -p "${DEST_DOC}"
  if [[ -d "${PRE}" ]] && ls "${PRE}"/*.pdf >/dev/null 2>&1; then
    cp -a "${PRE}"/*.pdf "${DEST_DOC}/"
    return 0
  fi
  chmod +x "${ROOT}/documentation/user_man/build-pdfs.sh"
  "${ROOT}/documentation/user_man/build-pdfs.sh" "${DEST_DOC}"
}
