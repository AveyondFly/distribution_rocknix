#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2021-present 351ELEC (https://github.com/351ELEC)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

# OpenBOR only works with Pak files, if you have an extracted game you will need to create a pak first.

arguments="$@"

if [ -n "$3" ]; then
  OB="$3"
else
  CORE="${arguments##*--core=}"  # read from --core= onwards
  OB="${CORE%% *}"  # until a space is found
fi

if [ -n "$4" ]; then
  EMU="$4"
else
  EMU="${arguments##*--emulator=}"
  EMU="${EMU%% *}"
fi

pakname=$(basename "$1")
pakname="${pakname%.*}"

CONFIGDIR="/storage/openbor"
PAKS="${CONFIGDIR}/Paks"
SAVES="${CONFIGDIR}/Saves"
SCREENSHOTS="${CONFIGDIR}/ScreenShots"

ln -s /roms/screenshots $SCREENSHOTS

# Make sure the folders exists
  mkdir -p "${CONFIGDIR}"
  mkdir -p "${PAKS}"
  mkdir -p "${SAVES}"

# Clear PAKS folder to avoid getting the launcher on next run
  rm -rf ${PAKS}/*

# make a symlink to the pak
ln -sf "$1" "${PAKS}"
for f in "$1".0*; do
  if [ -e "$f" ]; then
    ln -sf "$f" "${PAKS}"
  fi
done

# only create symlink to master.cfg if its the first time running the pak
if [ ! -f "${SAVES}/${pakname}.cfg" ]; then
	if [ ${OB} = "OpenBOR-ff" ]; then
		ln -sf "${CONFIGDIR}/masterff.cfg" "${SAVES}/${pakname}.cfg"
	else
		ln -sf "${CONFIGDIR}/master.cfg" "${SAVES}/${pakname}.cfg"
	fi
fi

# We start the fake keyboard
if [ "$EMU" != "OpenBOR-nogptk" ]; then
  gptokeyb -k ${OB} --killsignal 15 &
fi

# Run OpenBOR in the config folder
  cd "${CONFIGDIR}"
  ${OB}

# We stop the fake keyboard
  killall gptokeyb &
