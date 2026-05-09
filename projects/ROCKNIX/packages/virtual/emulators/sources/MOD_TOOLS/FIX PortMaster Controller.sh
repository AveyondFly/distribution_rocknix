#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

# PortMaster control.txt invokes this path as an executable script; missing +x yields
# "Permission denied", then reads of /tmp/gamecontrollerdb.txt fail.
MAPPER_STORAGE="/storage/.config/PortMaster/mapper.txt"
MAPPER_PORTS="/roms/ports/PortMaster/mapper.txt"

if [[ ! -f "${MAPPER_STORAGE}" ]]; then
    echo "未找到 PortMaster mapper：${MAPPER_STORAGE}"
    exit 1
fi

chmod +x "${MAPPER_STORAGE}"

[[ -f "${MAPPER_PORTS}" ]] && chmod +x "${MAPPER_PORTS}"

echo "已为 PortMaster mapper 设置可执行权限。"
