#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

set_kill set "-9 cpymo"

progdir=`dirname "$1"`

if [ ! -f ${progdir}/system/default.ttf ]; then
  cp -r /usr/config/cpymo/default.ttf ${progdir}/system/
fi

cd ${progdir}

gptokeyb "cpymo" -c  &
/usr/bin/cpymo "${progdir}"
kill -9 $(pidof gptokeyb)
