#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

set_kill set "kebook"

gptokeyb -k "kebook" &
if [ "${1}" ]
then
    /usr/bin/kebook --book "$1"
else
    /usr/bin/kebook
fi
killall gptokeyb
