#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present AmberELEC (https://github.com/AmberELEC)

MODEL=$(cat /sys/firmware/devicetree/base/model | tr '\0' '\n')
DEVICE_FILE="/dev/input/by-path/platform-adc-keys-event"

if [[ "$MODEL" == *"Xifan NGP45H"* ]]; then
    # Keep the ADC keyboard visible to input_sense so volume and menu keys
    # retain their normal behavior.  Only mirror Back/ESC into the joypad.
    while true; do
        evtest "$DEVICE_FILE" | while read -r line; do
            if [[ $line == *"KEY_ESC"* ]]; then
                if [[ $line == *"value 1"* ]]; then
                    /usr/bin/adckeys_new.py startselect
                fi
            fi
        done
    done
elif [[ "$MODEL" == *"GameMT E"* ]] || [[ "$MODEL" == *"Diium D50Plus"* ]] || [[ "$MODEL" == *"Diium D007"* ]]; then
    while true; do
        evtest --grab "$DEVICE_FILE" | while read -r line; do
            if [[ $line == *"KEY_ESC"* ]]; then
                if [[ $line == *"value 1"* ]]; then
                    $(/usr/bin/adckeys.py startselect)
                fi
            elif [[ $line == *"KEY_RIGHTSHIFT"* ]]; then
                if [[ $line == *"value 1"* ]]; then
                    $(/usr/bin/adckeys.py select_press)
                elif [[ $line == *"value 0"* ]]; then
                    $(/usr/bin/adckeys.py select_release)
                fi
            elif [[ $line == *"KEY_ENTER"* ]]; then
                if [[ $line == *"value 1"* ]]; then
                    $(/usr/bin/adckeys.py start_press)
                elif [[ $line == *"value 0"* ]]; then
                    $(/usr/bin/adckeys.py start_release)
                fi
            elif [[ $line == *"KEY_VOLUMEUP"* ]]; then
                if [[ $line == *"value 1"* ]]; then
		    volume up
                fi
            elif [[ $line == *"KEY_VOLUMEDOWN"* ]]; then
                if [[ $line == *"value 1"* ]]; then
		    volume down
                fi
            fi
        done
    done
fi
