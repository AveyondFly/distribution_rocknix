#!/bin/bash

. /etc/profile
. /usr/lib/rocknix/functions

hidecursor
ROM_DIR="/storage/roms"

function Test_Button_A(){
  evtest --query $event_dev $event_type $event_btn_a
}

function Test_Button_B(){
  evtest --query $event_dev $event_type $event_btn_b
}


function Set_system() {
    SYSCFG="/storage/.config/system/configs/system.cfg"
    sed -i -e '/system.hostname\=/c\system.hostname\='"${1}"'' ${SYSCFG}
    sed -i -e '/audio.volume\=/c\audio.volume\=60' ${SYSCFG}
    sed -i -e '/rotate.root.password\=/c\rotate.root.password\=0' ${SYSCFG}
    sed -i -e '/samba.enabled\=/c\samba.enabled\=0' ${SYSCFG}
    sed -i -e '/ssh.enabled\=/c\ssh.enabled\=0' ${SYSCFG}
    sed -i -e '/updates.enabled\=/c\updates.enabled\=0' ${SYSCFG}
    sed -i -e '/system.autohotkeys\=/c\system.autohotkeys\=0' ${SYSCFG}
    sed -i -e '/global.retroarch.menu_driver\=/c\global.retroarch.menu_driver\=ozone' ${SYSCFG}
}

function Set_ra_ext() {
	gamecontrollerdb="/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt"
	RACFG="/storage/.config/retroarch/retroarch.cfg"

	# 通过joyguid获取GUID
	guid=$(joyguid 2>/dev/null | tr -d '\n')

	# 异常处理
	if [ -z "$guid" ]; then
		echo "错误：无法获取Joystick GUID，请检查joyguid工具" >&2
		exit 1
	fi

	# 查找匹配行
	mapping_line=$(grep -m1 "^${guid}," "$gamecontrollerdb")
	if [ -z "$mapping_line" ]; then
		echo "错误：未找到GUID $guid 对应的控制器配置" >&2
		exit 1
	fi

	# 解析并生成带前缀的变量
	eval "$(
	echo "$mapping_line" | awk -F, '
	{
		for(i=1; i<=NF; i++) {
			if($i ~ /^[a-zA-Z]+:b[0-9]+$/) {
				split($i, pair, ":")
				key = pair[1]
				value = substr(pair[2],2)  # 去掉b前缀
				printf "declare -g mapped_%s=%d\n", key, value  # 添加前缀
			}
		}
	}'
	)"

	if [ "$HOTKEY" = "guide" ] && [ ! -z "${mapped_guide}" ]; then
		sed -i -e '/input_enable_hotkey_btn\ \=/c\input_enable_hotkey_btn\ \=\ \"'${mapped_guide}'\"' ${RACFG}
	else
		sed -i -e '/input_enable_hotkey_btn\ \=/c\input_enable_hotkey_btn\ \=\ \"'${mapped_back}'\"' ${RACFG}
	fi
	sed -i -e '/input_menu_toggle_btn\ \=/c\input_menu_toggle_btn\ \=\ \"'${mapped_x}'\"' ${RACFG}
	sed -i -e '/input_exit_emulator_btn\ \=/c\input_exit_emulator_btn\ \=\ \"'${mapped_start}'\"' ${RACFG}
	sed -i -e '/input_toggle_fast_forward_btn\ \=/c\input_toggle_fast_forward_btn\ \=\ \"'${mapped_righttrigger}'\"' ${RACFG}
	sed -i -e '/input_toggle_slowmotion_btn\ \=/c\input_toggle_slowmotion_btn\ \=\ \"'${mapped_lefttrigger}'\"' ${RACFG}
	if [ ! -z "${mapped_leftstick}" ]; then
		sed -i -e '/input_rewind_btn\ \=/c\input_rewind_btn\ \=\ \"'${mapped_leftstick}'\"' ${RACFG}
	else
		sed -i -e '/input_rewind_btn\ \=/c\input_rewind_btn\ =' ${RACFG}
	fi
	sed -i -e '/input_pause_toggle_btn\ \=/c\input_pause_toggle_btn\ \=\ \"'${mapped_a}'\"' ${RACFG}
	sed -i -e '/input_load_state_btn\ \=/c\input_load_state_btn\ \=\ \"'${mapped_rightshoulder}'\"' ${RACFG}
	sed -i -e '/input_save_state_btn\ \=/c\input_save_state_btn\ \=\ \"'${mapped_leftshoulder}'\"' ${RACFG}
	sed -i -e '/input_state_slot_increase_btn\ \=/c\input_state_slot_increase_btn\ \=\ \"'${mapped_dpup}'\"' ${RACFG}
	sed -i -e '/input_state_slot_decrease_btn\ \=/c\input_state_slot_decrease_btn\ \=\ \"'${mapped_dpdown}'\"' ${RACFG}
	sed -i -e '/input_screenshot_btn\ \=/c\input_screenshot_btn\ \=\ \"'${mapped_b}'\"' ${RACFG}
	sed -i -e '/input_fps_toggle_btn\ \=/c\input_fps_toggle_btn\ \=\ \"'${mapped_y}'\"' ${RACFG}
	sed -i -e '/menu_scale_factor\ \=/c\menu_scale_factor\ \=\ \"'${1}'\"' ${RACFG}
	sed -i -e '/menu_widget_scale_factor\ \=/c\menu_widget_scale_factor\ \=\ \"'${2}'\"' ${RACFG}
}

# 处理 ppsspp 字体软链接
PPSSPP_FONTS="/storage/.config/ppsspp/assets"
if [ -d "$PPSSPP_FONTS" ]; then
  for font in Roboto_Condensed-Bold.ttf Roboto_Condensed-Italic.ttf Roboto_Condensed-Light.ttf Roboto_Condensed-Regular.ttf; do
    rm -f "$PPSSPP_FONTS/$font"
    ln -s Roboto-Condensed.ttf "$PPSSPP_FONTS/$font"
  done
fi

if [ -f "/usr/config/modules/Reset Drastic Cfg.sh" ]; then
  bash "/usr/config/modules/Reset Drastic Cfg.sh"
fi

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
     sed -i -e '/system\.timezone\=/c system\.timezone\=Asia/Shanghai' /storage/.config/system/configs/system.cfg
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

# 获取分辨率并交换宽高的功能
TARGET_RES="1920x1080 1080x1920 1024x768 1280x720 720x1280 960x720 720x960 544x960 960x544 720x720 480x640 640x480 480x320 320x480"

detected_res=$(
    grep -oE '(1920x1080|1080x1920|1280x720|1024x768|960x720|720x960|720x1280|960x544|544x960|720x720|640x480|480x640|480x320|320x480)' /sys/class/graphics/fb0/modes |
    grep -xE "$(echo "$TARGET_RES" | tr ' ' '|')" |
    head -n1
)

if [[ -n "$detected_res" ]]; then
    IFS='x' read -r width height <<< "$detected_res"
    if (( width < height )); then
        detected_res="${height}x${width}"
    fi
fi

case "$detected_res" in
    "1920x1080")
        echo "1920x1080"
        ;;
    "1280x720")
        echo "1280x720"
        sed -i -e '/gba.shaderset\=/c\gba.shaderset\=zfast_lcd_standard.glslp' /storage/.config/system/configs/system.cfg
        sed -i -e '/gbah.shaderset\=/c\gbah.shaderset\=zfast_lcd_standard.glslp' /storage/.config/system/configs/system.cfg
        ;;
    "1024x768")
        echo "1024x768"
        ;;
    "960x720")
        echo "960x720"
        ;;
    "960x544")
        echo "960x544"
        ;;
    "720x720")
        echo "720x720"
        ;;
    "640x480")
        echo "640x480"
        ;;
    "480x320")
        echo "480x320"
        ;;
    *)
        echo "$detected_res"
        ;;
esac

# 获取 QUIRK_DEVICE
if [ -z "$QUIRK_DEVICE" ]; then
    QUIRK_DEVICE="$(tr -d '\0' </sys/firmware/devicetree/base/model 2>/dev/null)"
    if [ -z "$QUIRK_DEVICE" ]; then
        QUIRK_DEVICE="$(tr -d '\0' </sys/class/dmi/id/sys_vendor 2>/dev/null) $(tr -d '\0' </sys/class/dmi/id/product_name 2>/dev/null)"
    fi
    QUIRK_DEVICE="$(echo ${QUIRK_DEVICE} | sed -e "s#[/]#-#g")"
fi

case "${QUIRK_DEVICE}" in
    "Anbernic RG ARC-D")
        echo "${QUIRK_DEVICE}"
        Set_system "RGARC-D"
    ;;
    "Anbernic RG ARC-S")
        echo "${QUIRK_DEVICE}"
        Set_system "RGARC-S"
    ;;
    "Anbernic RG353P")
        echo "${QUIRK_DEVICE}"
        Set_system "RG353P"
    ;;
    "Anbernic RG353PS")
        echo "${QUIRK_DEVICE}"
        Set_system "RG353PS"
        Set_system "RG353M"
    ;;
    "Anbernic RG353M"|RG353Mm)
        echo "${QUIRK_DEVICE}"
    ;;
    "Anbernic RG353V")
        echo "${QUIRK_DEVICE}"
        Set_system "RG353V"
    ;;
    "Anbernic RG353VS")
        echo "${QUIRK_DEVICE}"
        Set_system "RG353VS"
    ;;
    "Anbernic RG503")
        echo "${QUIRK_DEVICE}"
        Set_system "RG503"
    ;;
    "Anbernic RG552")
        echo "${QUIRK_DEVICE}"
        Set_system "RG552"
    ;;
    "Anbernic Win600")
        echo "${QUIRK_DEVICE}"
        Set_system "Win600"
    ;;
    "Powkiddy RK2023")
        echo "${QUIRK_DEVICE}"
        Set_system "RK2023"
    ;;
    "Powkiddy RGB20P")
        echo "${QUIRK_DEVICE}"
        Set_system "RGB20PRO"
    ;;
    "Powkiddy RGB30")
        echo "${QUIRK_DEVICE}"
        Set_system "RGB30"
    ;;
    "Powkiddy RGB20SX")
        echo "${QUIRK_DEVICE}"
        Set_system "RGB20SX"
    ;;
    "Powkiddy RGB10 MAX 3 Pro")
        echo "${QUIRK_DEVICE}"
        Set_system "RGB10MAX3PRO"
    ;;
    "Powkiddy RGB10 Max 3")
        echo "${QUIRK_DEVICE}"
        Set_system "X55"
    ;;
    "Powkiddy x35s")
        echo "${QUIRK_DEVICE}"
        Set_system "X35H"
    ;;
    "RGBMAX4")
        echo "${QUIRK_DEVICE}"
        Set_system "RGBMAX4"
    ;;
#----------------------------------------以下已验证-------------------------------------#
# H700设备
    "Anbernic RG34XX")
        echo "${QUIRK_DEVICE}"
        Set_system "RG34XX"
    ;;
    "Anbernic RG CubeXX")
        echo "${QUIRK_DEVICE}"
        Set_system "RGCUBEXX"
    ;;
    "Anbernic RG40XX V")
        echo "${QUIRK_DEVICE}"
        Set_system "RG40XX-V"
    ;;
    "Anbernic RG40XX H")
        echo "${QUIRK_DEVICE}"
        Set_system "RG40XX-H"
    ;;
    "Anbernic RG28XX")
        echo "${QUIRK_DEVICE}"
        Set_system "RG28XX"
    ;;
    "Anbernic RG35XX 2024")
        echo "${QUIRK_DEVICE}"
        Set_system "RG35XX-2024"
    ;;
    "Anbernic RG35XX H")
        echo "${QUIRK_DEVICE}"
        Set_system "RG35XX-H"
    ;;
    "Anbernic RG35XX Plus")
        echo "${QUIRK_DEVICE}"
        Set_system "RG35XX-P"
    ;;
    "Anbernic RG35XX SP")
        echo "${QUIRK_DEVICE}"
        Set_system "RG35XX-SP"
    ;;
    "Anbernic RG34XX-SP")
        echo "${QUIRK_DEVICE}"
        Set_system "RG40XX-H"
    ;;
    "Anbernic RG35XX Pro")
        echo "${QUIRK_DEVICE}"
        Set_system "RG35XX-Pro"
    ;;
# 3326设备
# 稀范科技
    "XiFan MyMini")
        echo "${QUIRK_DEVICE}"
        Set_system "MyMini"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "XiFan Mini40")
        echo "${QUIRK_DEVICE}"
        Set_system "Mini40"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "XiFan XF35H")
        echo "${QUIRK_DEVICE}"
        Set_system "XF35H"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "XiFan R36Max")
        echo "${QUIRK_DEVICE}"
        Set_system "R36Max"
    ;;
    "XiFan R36Pro")
        echo "${QUIRK_DEVICE}"
        Set_system "R36Pro"
    ;;
    "XiFan XF40H")
        echo "${QUIRK_DEVICE}"
        Set_system "XF40H"
    ;;
    "XiFan XF40V")
        echo "${QUIRK_DEVICE}"
        Set_system "XF40V"
    ;;
    "XiFan XF28")
        echo "${QUIRK_DEVICE}"
        Set_system "XF28H"
    ;;
    "XiFan DC35V")
        echo "${QUIRK_DEVICE}"
        Set_system "DC35V"
    ;;
    "XiFan DC40V")
        echo "${QUIRK_DEVICE}"
        Set_system "DC40V"
    ;;
    "XiFan R36Max2")
        echo "${QUIRK_DEVICE}"
        Set_system "R36Max2"
    ;;
# BatleXP
    "BatleXP G350")
        echo "${QUIRK_DEVICE}"
        Set_system "G350"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
# 安伯尼克
    "Anbernic RG351M")
        echo "${QUIRK_DEVICE}"
        Set_system "RG351M"
    ;;
    "Anbernic RG351V")
        echo "${QUIRK_DEVICE}"
        Set_system "RG351V"
    ;;
# 亿米创
    "YMC A10Mini")
        echo "${QUIRK_DEVICE}"
        Set_system "A10mini"
    ;;
    "YMC A10Mini V2")
        echo "${QUIRK_DEVICE}"
        Set_system "A10miniv2"
    ;;
# 迪优米
    "Diium D-R28S")
        echo "${QUIRK_DEVICE}"
        Set_system "DR28S"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "Diium D007")
        echo "${QUIRK_DEVICE}"
        Set_system "D007"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
# Magicx
    "MINILOONG Pocket1")
        echo "${QUIRK_DEVICE}"
        Set_system "MINILOONG"
	set_setting key.hotkey.b=BTN_MODE
    ;;
# 泡机堂
    "Powkiddy RGB10")
        echo "${QUIRK_DEVICE}"
        Set_system "RGB10"
	set_setting key.dpad.events 1
    ;;
    "Powkiddy RGB20S")
        echo "${QUIRK_DEVICE}"
        Set_system "RGB20S"
    ;;
    "Powkiddy RGB10X")
        echo "${QUIRK_DEVICE}"
        Set_system "RGB10X"
    ;;
# 曼特科技
    "GameMT E6")
        echo "${QUIRK_DEVICE}"
        Set_system "E6"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "GameMT E6Plus")
        echo "${QUIRK_DEVICE}"
        Set_system "E6Plus"
    ;;
    "GameMT E5Plus")
        echo "${QUIRK_DEVICE}"
        Set_system "e5plus"
    ;;
# Odroid
    "ODROID-GO Super")
        echo "${QUIRK_DEVICE}"
        Set_system "OGS"
    ;;
# GameConsole
    "Game Console R36S")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
    ;;
    "Game Console R50S")
        echo "${QUIRK_DEVICE}"
        Set_system "R50S"
    ;;
    "Game Console R33S")
        echo "${QUIRK_DEVICE}"
        Set_system "R33S"
    ;;
    "GameConsole R36sPlus")
        echo "${QUIRK_DEVICE}"
        Set_system "R36sPlus"
    ;;
    "Game Console R45H")
        echo "${QUIRK_DEVICE}"
        Set_system "R45H"
    ;;
    "Game Console R46H")
        echo "${QUIRK_DEVICE}"
        Set_system "R46H"
    ;;
    "Game Console R40XX")
        echo "${QUIRK_DEVICE}"
        Set_system "R40XX"
    ;;
    "Game Console R40XX ProMax")
        echo "${QUIRK_DEVICE}"
        Set_system "R40xxProMax"
    ;;
# R36s克隆机
    "Clone R36s Type 2 With Amplifier")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "Clone R36s Type 2 Without Amplifier")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "Clone R36s Type 3")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "Clone R36s Type 4")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
# R36s酱油机
    "Sauce R36s V04")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "Sauce R36s V03")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
# K36
    "GameConsole K36")
        echo "${QUIRK_DEVICE}"
        Set_system "K36"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
# AISLPC
    "GameConsole K36S")
        echo "${QUIRK_DEVICE}"
        Set_system "K36S"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "GameConsole R36T")
        echo "${QUIRK_DEVICE}"
        Set_system "R36T"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "GameConsole R36TMax")
        echo "${QUIRK_DEVICE}"
        Set_system "R36TMax"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
# 其他无牌
    "GameConsole XGB36")
        echo "${QUIRK_DEVICE}"
        Set_system "XGB36"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "GameConsole R36Ultra")
        echo "${QUIRK_DEVICE}"
        Set_system "R36Ultra"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "GameConsole T16Max")
        echo "${QUIRK_DEVICE}"
        Set_system "T16Max"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "GameConsole HG36")
        echo "${QUIRK_DEVICE}"
        Set_system "HG36"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
# 兜底
    *)
        echo "${QUIRK_DEVICE}"
        Set_system "Rockchip"
    ;;
esac

Set_ra_ext "0.400000" "0.300000"

if [ "$(systemctl is-active input)" = "active" ]
then
  systemctl restart input
fi

sync
