#!/bin/bash
# EKA2L1 SDL2 frontend launcher for ROCKNIX

EKA2L1_DIR="/storage/.config/eka2l1/"
cd "$EKA2L1_DIR"

# Data directory (config, devices, ROMs) lives alongside the binary
mkdir -p "$EKA2L1_DIR/data"

gptokeyb  -k "eka2l1_sdl2" -c ./eka2l1.gptk  --killsignal 15&

CUBEB_BACKEND=alsa ./eka2l1_sdl2

kill -9 `pidof gptokeyb`
