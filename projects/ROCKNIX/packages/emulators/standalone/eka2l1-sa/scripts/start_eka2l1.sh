#!/bin/bash
# EKA2L1 SDL2 frontend launcher for ROCKNIX

EKA2L1_DIR="/storage/.config/eka2l1/"
cd "$EKA2L1_DIR"

gptokeyb  -k "eka2l1_sdl2" -c ./eka2l1.gptk  --killsignal 15&

if [ ! -e "/storage/.config/eka2l1/data" ]; then
    mkdir -p /roms/eka2l1/data
    ln -sf /roms/eka2l1/data  /storage/.config/eka2l1/
fi

CUBEB_BACKEND=alsa ./eka2l1_sdl2

kill -9 `pidof gptokeyb`
