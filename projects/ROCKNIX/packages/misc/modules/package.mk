# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="modules"
PKG_VERSION=""
PKG_LICENSE="custom"
PKG_SITE=""
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain rclone"
PKG_LONGDESC="OS Modules Package"
PKG_TOOLCHAIN="manual"

case ${DEVICE} in
  RK3588|RK3399|SM8250|SM8550|SDM845|SM8650)
    PKG_DEPENDS_TARGET+=" gamepadtester qterminal"
  ;;
esac

# Fileman or Commander Filemanager
case ${DEVICE} in
  RK3326*|RK3399|RK3566|RK356X|RK3588|S905|S922X|SDM845|SM8250|SM8550|SM8650)
    PKG_DEPENDS_TARGET+=" commander"
    FILEMANAGER="commander"
  ;;
  *)
    PKG_DEPENDS_TARGET+=" fileman"
    FILEMANAGER="fileman"
  ;;
esac

make_target() {
  :
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/config/modules
  cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/config/modules
  chmod 0755 ${INSTALL}/usr/config/modules/*
}

post_makeinstall_target() {
  remove_gamelist_game() {
    python3 -c "
import re, sys
path = sys.argv[1]
with open(sys.argv[2]) as f:
    xml = f.read()
xml = re.sub(
    r'\s*<game>\s*<path>\./' + re.escape(path) + r'</path>.*?</game>',
    '',
    xml,
    flags=re.DOTALL,
)
open(sys.argv[2], 'w').write(xml)
" "${1}" "${INSTALL}/usr/config/modules/gamelist.xml"
  }

  case ${ARCH} in
    x86_64)
      rm -f ${INSTALL}/usr/config/modules/*Master*
    ;;
  esac

  case ${DEVICE} in
    SM8650)
      rm -f ${INSTALL}/usr/config/modules/*32bit*
    ;;
  esac

  if [ ! "${INSTALLER_SUPPORT}" = "yes" ] || \
     [ ! "${DISPLAYSERVER}" = "wl" ]
  then
    rm -f ${INSTALL}/usr/config/modules/Install*
  fi

# Set filemanger
  sed -e "s/@FILEMANAGER@/${FILEMANAGER}/g" -i ${INSTALL}/usr/config/modules/gamelist.xml
  if [ ${FILEMANAGER} == "commander" ]; then
    rm -rf ${INSTALL}/usr/config/modules/fileman.sh
  else
    rm -rf ${INSTALL}/usr/config/modules/commander.sh
  fi

  # MOD_TOOLS scripts are installed by emulators; drop gamelist entries when absent.
  if [ "${DEVICE}" = "S905" ]; then
    remove_gamelist_game "MOD_TOOLS/Install AURKNIX to EMMC.sh"
    remove_gamelist_game "MOD_TOOLS/Backup EMMC.sh"
    remove_gamelist_game "MOD_TOOLS/Restore EMMC.sh"
  fi

  case ${DEVICE} in
    RK3566|RK356X)
      ;;
    *)
      remove_gamelist_game "MOD_TOOLS/FixShutdown.sh"
      ;;
  esac
}

