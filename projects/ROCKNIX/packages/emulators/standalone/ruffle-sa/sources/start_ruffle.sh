#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 AURKNIX (https://github.com/AveyondFly/distribution_rocknix)

. /etc/profile

CONF_DIR="/storage/.config/ruffle"
RUFFLE_BIN="${CONF_DIR}/sdl2test-rocknix"

set_kill set "-9 sdl2test-rocknix"

gptokeyb "sdl2test-rocknix" -c "${CONF_DIR}/ruffle.gptk" &
"${RUFFLE_BIN}" "$1" --fullscreen
kill -9 "$(pidof gptokeyb)"
