#!/bin/bash
set -u

source /etc/profile

set_kill set "dora-ssr"

DORA_BASE=/storage/.local/share/dora-ssr
DORA_LOG="$DORA_BASE/logs/dora-ssr.log"
UNIT=dora-ssr-kmsdrm.service

mkdir -p "$DORA_BASE/logs"

if systemctl is-active --quiet "$UNIT"; then
  exit 0
fi

systemctl reset-failed "$UNIT" >/dev/null 2>&1 || true
systemd-run \
  --unit="${UNIT%.service}" \
  --collect \
  --property=TimeoutStopSec=15 \
  /usr/bin/dora-kmsdrm-runner >> "$DORA_LOG" 2>&1
