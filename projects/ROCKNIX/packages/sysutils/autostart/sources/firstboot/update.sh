#!/bin/bash

. /etc/profile
. /usr/lib/rocknix/functions

hidecursor
ROM_DIR="/storage/roms"
DONE_FLAG="/storage/data/mod.done"

if [ -e "$DONE_FLAG" ]; then
  exit 0
fi

function Test_Button_A(){
  evtest --query $event_dev $event_type $event_btn_a
}

function Test_Button_B(){
  evtest --query $event_dev $event_type $event_btn_b
}

event_type="EV_KEY"
event_btn_a="BTN_EAST"
event_btn_b="BTN_SOUTH"

event_dev=""

if [ -e /dev/input/by-path/platform-*event-joystick ]; then
    joystick_dev=$(eval echo /dev/input/by-path/platform-*event-joystick)
    if [ -e "$joystick_dev" ]; then
        event_dev=$(readlink -f "$joystick_dev")
    fi
elif [ -e /dev/input/by-path/platform-*-event-mouse ]; then
    mouse_dev=$(eval echo /dev/input/by-path/platform-*-event-mouse)
    if [ -e "$mouse_dev" ]; then
        event_dev=$(readlink -f "$mouse_dev")
    fi
else
    echo "No suitable input device found." >/dev/tty0
fi

# 如果没有输入设备，直接默认 English
if [ -z "$event_dev" ]; then
    echo -e "No input device. Default to \033[32mEnglish\033[0m" >/dev/tty0
    sed -i -e '/system\.language\=/c system\.language\=en_US' /storage/.config/system/configs/system.cfg
    touch "$DONE_FLAG"
    sync
    exit 0
fi

printf "\n " >/dev/tty0
printf "\n==> Please set the system default language:" >/dev/tty0
printf "\n " >/dev/tty0
echo -e "\nPress \033[31mA\033[0m to \033[32mSimple Chinese\033[0m. \033[33mB\033[0m to \033[32mEnglish\033[0m.\n" >/dev/tty0
time_start=$(date --date=`date +'%H:%M:%S'` +%s)
while true
do
   Test_Button_A
   if [ "$?" -eq "10" ]; then
     sed -i -e '/system\.language\=/c system\.language\=zh_CN' /storage/.config/system/configs/system.cfg
     echo -e "\033[31mA\033[0m - \033[32mSimple Chinese\033[0m" >/dev/tty0
     break
   fi
   Test_Button_B
   if [ "$?" -eq "10" ]; then
     sed -i -e '/system\.language\=zh_CN/c system\.language\=en_US' /storage/.config/system/configs/system.cfg
     echo -e "\033[33mB\033[0m - \033[32mEnglish\033[0m" >/dev/tty0
     break
   fi
   time_end=$(date --date=`date +'%H:%M:%S'` +%s) && let "time_time=${time_end} - ${time_start}"
   if [ $time_time -ge 9 ]; then
     echo -e "Timeout $event_dev. Default to \033[32mEnglish\033[0m" >/dev/tty0
     sed -i -e '/system\.language\=/c system\.language\=en_US' /storage/.config/system/configs/system.cfg
     break
   fi
done

touch "$DONE_FLAG"

sync