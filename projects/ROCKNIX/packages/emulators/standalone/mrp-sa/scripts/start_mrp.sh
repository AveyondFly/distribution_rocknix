#!/bin/bash

gptokeyb -c /storage/.config/mrp/mrp.gptk -k mrpoid-sdl2-arm &
mkdir -p /storage/roms/mrp/mythroad/
mrpoid-sdl2-arm --sdpath /storage/roms/mrp --workpath mythroad "$1"
kill -9 `pidof gptokeyb`
