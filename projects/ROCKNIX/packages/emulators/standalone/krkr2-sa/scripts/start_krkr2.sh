#!/bin/bash

. /etc/profile

romfile="$1"
if [ -z "$romfile" ]; then
    echo "Usage: $0 <game.xp3>"
    exit 2
fi

prodir="/storage/.config/krkr2"
package_dir="/usr/config/krkr2"

if [ ! -d "$prodir" ]; then
    if [ -d "$package_dir" ]; then
        mkdir -p "/storage/.config"
        cp -rf "$package_dir" "/storage/.config/"
    else
        mkdir -p "$prodir"
    fi
    chmod -R 777 "$prodir"
fi

if [ ! -f "$prodir/krkr2.gptk" ] && [ -f "$package_dir/krkr2.gptk" ]; then
    cp -f "$package_dir/krkr2.gptk" "$prodir/krkr2.gptk"
fi

if [ -x "$prodir/krkr2_sdl2" ]; then
    krkr2_bin="$prodir/krkr2_sdl2"
elif [ -x "$package_dir/krkr2_sdl2" ]; then
    krkr2_bin="$package_dir/krkr2_sdl2"
else
    echo "KrKr2 executable not found"
    exit 1
fi

if command -v set_kill >/dev/null 2>&1; then
    set_kill set "-9 $(basename "$krkr2_bin")"
fi

chmod 666 /dev/uinput 2>/dev/null || true
cd "$prodir" || exit 1
rm -f ./log.txt

gptokeyb -k "krkr2_sdl2" -c "$prodir/krkr2.gptk" &
gptokeyb_pid=$!
cleanup() {
    kill -9 "$gptokeyb_pid" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

"$krkr2_bin" "$romfile" 2>&1 | tee -a ./log.txt
exit_code=${PIPESTATUS[0]}
exit "$exit_code"
