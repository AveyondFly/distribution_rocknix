#!/bin/bash
#make by G.R.H

. /etc/profile

romfile=${1}
filename=$(basename "$romfile")
romdir=${romfile%/*}

#Check if onscripter exists in .config
if [ ! -d "/storage/.config/onscripter" ]; then
    mkdir -p "/storage/.config/onscripter"
    cp -rf "/usr/config/onscripter" "/storage/.config/"
    chmod -R 777 /storage/.config/onscripter
fi

if [ $filename == "Scan_for_new_games.ons" ]; then
    /usr/bin/bash "$romfile"
else
	set_kill set "-9 onscripter"
    prodir="/storage/.config/onscripter"
    export LD_LIBRARY_PATH="$prodir/lib32:/usr/lib32"
    export SPA_PLUGIN_DIR="/usr/lib32/spa-0.2"
    export PIPEWIRE_MODULE_DIR="/usr/lib32/pipewire-0.3/"
    export LIBGL_DRIVERS_PATH="/usr/lib32/dri"
    chmod 666 /dev/uinput
    cd $prodir
    rm -f ./log.txt
    gptokeyb "onscripter" -c "./onscripter.gptk" &
    ./onscripter -r "$romdir" 2>&1 | tee -a ./log.txt
    unset LD_LIBRARY_PATH
    kill -9 $(pidof gptokeyb)
    printf "\033c" >> /dev/tty1
fi
