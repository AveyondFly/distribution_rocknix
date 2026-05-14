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
    chmod 666 /dev/uinput
    cd $prodir
    rm -f ./log.txt
    gptokeyb -k "onscripter"&
    #sway_fullscreen "" &
    ./onscripter -r "$romdir" 2>&1 | tee -a ./log.txt
    kill -9 $(pidof gptokeyb)
fi
