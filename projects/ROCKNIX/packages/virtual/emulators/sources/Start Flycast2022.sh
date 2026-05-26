#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

set_kill set "flycast2022"

sway_fullscreen "flycast" &

/usr/bin/flycast2022 >/dev/null 2>&1
