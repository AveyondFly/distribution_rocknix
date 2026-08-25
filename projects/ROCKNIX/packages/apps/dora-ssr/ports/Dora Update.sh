#!/bin/bash
source /etc/profile
set -u

set_kill set "dora-update"

DORA_BASE=/storage/.local/share/dora-ssr

mkdir -p "$DORA_BASE/logs"

if pgrep -f "/usr/bin/dora-update-runner" >/dev/null; then
  exit 0
fi

exec foot \
  --fullscreen \
  --title="Dora Update" \
  --app-id=dora-update \
  --override=font=monospace:size=14 \
  /usr/bin/dora-update-runner
