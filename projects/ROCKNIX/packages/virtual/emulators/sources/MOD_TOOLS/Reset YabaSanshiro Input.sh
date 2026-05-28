#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

SETUP_BIN=""
for candidate in \
  /usr/bin/yabasanshiro-input-setup.sh \
  /storage/.local/bin/yabasanshiro-input-setup.sh \
  /storage/yabasanshiro-input-setup.sh
do
  if [ -x "${candidate}" ]; then
    SETUP_BIN="${candidate}"
    break
  fi
done

if [ -z "${SETUP_BIN}" ]; then
  echo "错误：未找到 ${SETUP_BIN}" >&2
  echo "请先安装 yabasanshiro-sa 包。" >&2
  exit 1
fi

echo "正在重置 YabaSanshiro 手柄配置..."
echo "将删除 /storage/.config/yabasanshiro/input.cfg 与 keymapv2.json，并根据当前手柄重新生成。"

"${SETUP_BIN}" --force
