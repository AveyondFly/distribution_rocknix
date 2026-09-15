#!/usr/bin/python3

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present AmberELEC (https://github.com/AmberELEC)
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

import os
import struct
import sys
import time


JOYPAD_DEVICES = (
    "/dev/input/by-path/platform-rocknix-joypad-event-joystick",
    "/dev/input/by-path/platform-rocknix-singleadc-joypad-event-joystick",
)

BTN_SELECT = 0x13A
BTN_START = 0x13B


def find_joypad_device():
    for path in JOYPAD_DEVICES:
        if os.path.exists(path):
            return path
    raise FileNotFoundError("ROCKNIX joypad event device not found")


def write_key(device, code, value):
    event = struct.pack("llHHI", 0, 0, 1, code, value)
    with open(device, "wb", buffering=0) as event_device:
        event_device.write(event)


def tap(device, *codes):
    for code in codes:
        write_key(device, code, 1)
    time.sleep(0.1)
    for code in codes:
        write_key(device, code, 0)


def main(arguments):
    device = find_joypad_device()

    if len(arguments) == 1:
        command = arguments[0]
        if command == "select":
            tap(device, BTN_SELECT)
        elif command == "start":
            tap(device, BTN_START)
        elif command == "startselect":
            tap(device, BTN_SELECT, BTN_START)
        elif command == "select_press":
            write_key(device, BTN_SELECT, 1)
        elif command == "select_release":
            write_key(device, BTN_SELECT, 0)
        elif command == "start_press":
            write_key(device, BTN_START, 1)
        elif command == "start_release":
            write_key(device, BTN_START, 0)
        else:
            raise ValueError(f"unknown command: {command}")
    elif len(arguments) == 2:
        code = int(arguments[0], 16)
        if arguments[1] == "press":
            write_key(device, code, 1)
        elif arguments[1] == "release":
            write_key(device, code, 0)
        else:
            raise ValueError(f"unknown action: {arguments[1]}")
    else:
        raise ValueError("expected one command or a hexadecimal keycode and action")


if __name__ == "__main__":
    main(sys.argv[1:])
