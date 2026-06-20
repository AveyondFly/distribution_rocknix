#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile
set_kill set "-9 flycast"

#load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

# Conf files vars
SOURCE_DIR="/usr/config/flycast"
CONF_DIR="/storage/.config/flycast"
FLYCAST_INI="emu.cfg"

#Check if flycast exists in .config
if [ ! -d "/storage/.config/flycast" ]; then
  cp -r "${SOURCE_DIR}" "${CONF_DIR}"
fi

#Move save file storage/roms
if [ -d "${CONF_DIR}/data" ]; then
  mv "${CONF_DIR}/data" "/storage/roms/dreamcast/"
fi

#Make flycast bios folder
if [ ! -d "/storage/roms/bios/dc" ]; then
  mkdir -p "/storage/roms/bios/dc"
fi

#Link  .config/flycast to .local
ln -sf "/storage/roms/bios/dc" "/storage/roms/dreamcast/data"


#Make sure flycast gptk config exists
if [ ! -f "${CONF_DIR}/flycast.gptk" ]; then
  cp -r "/usr/config/flycast/flycast.gptk" "${CONF_DIR}/flycast.gptk"
fi

#Make sure flycast gptk SDL_Keyboard.cfg exists
if [ ! -f "${CONF_DIR}/mappings/SDL_Keyboard.cfg" ]; then
  cp -r "/usr/config/flycast/mappings/SDL_Keyboard.cfg" "${CONF_DIR}/mappings/SDL_Keyboard.cfg"
fi

#Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
GRENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")

#Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
if [ "${CORES}" = "little" ]
then
  EMUPERF="${SLOW_CORES}"
elif [ "${CORES}" = "big" ]
then
  EMUPERF="${FAST_CORES}"
else
  ### All..
  unset EMUPERF
fi

  #Graphics Renderer
        if [ "$GRENDERER" = "vulkan" ]; then
                sed -i '/^pvr.rend =/c\pvr.rend = 4' "${CONF_DIR}/${FLYCAST_INI}"
        else
                sed -i '/^pvr.rend =/c\pvr.rend = 0' "${CONF_DIR}/${FLYCAST_INI}"
	fi

#Retroachievements
/usr/bin/cheevos_flycast.sh

# Debugging info:
  echo "GAME set to: ${GAME}"
  echo "PLATFORM set to: ${PLATFORM}"
  echo "CONF DIR: ${CONF_DIR}/${FLYCAST_INI}"
  echo "CPU CORES set to: ${EMUPERF}"
  echo "GRAPHICS RENDERER set to: ${GRENDERER}"
  echo "Launching /usr/bin/flycast ${1}"

CORE=${3%-*}
#Run flycast emulator
$GPTOKEYB $CORE -c "${CONF_DIR}/flycast.gptk" &
${EMUPERF} /usr/bin/$CORE "${1}"
kill -9 "$(pidof gptokeyb)"
