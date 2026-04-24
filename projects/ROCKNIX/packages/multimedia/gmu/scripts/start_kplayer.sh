#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

set_kill set "kplayer"

gptokeyb -k "kplayer" &
/usr/bin/kplayer
killall gptokeyb
