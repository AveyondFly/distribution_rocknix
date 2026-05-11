#!/bin/sh

. /etc/profile
set_kill set "commander"

sway_fullscreen "commander" &
gptokeyb -k commander --killsignal 15 &
export SDL_RENDER_DRIVER="${SDL_RENDER_DRIVER:-opengles2}"
cd /storage/.config/commander-baidupcs
exec ./commander --config ./commander.cfg
kill -9 "$(pidof gptokeyb)"
