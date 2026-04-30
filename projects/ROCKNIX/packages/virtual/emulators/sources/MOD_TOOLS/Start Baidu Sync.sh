#!/bin/sh

. /etc/profile
set_kill set "commander"

sway_fullscreen "commander" &

cd /storage/.config/commander-baidupcs
exec ./commander --config ./commander.cfg
