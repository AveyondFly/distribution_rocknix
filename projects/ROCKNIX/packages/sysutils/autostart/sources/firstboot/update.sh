#!/bin/bash

. /etc/profile
. /usr/lib/rocknix/functions

hidecursor
ROM_DIR="/storage/roms"
RACFG="/storage/.config/retroarch/retroarch.cfg"

UPDATE_MODE="$1"

function Get_display_rotation() {
    local fbcon_rotate

    if [ -r /sys/class/graphics/fbcon/rotate ]; then
        read -r fbcon_rotate </sys/class/graphics/fbcon/rotate
        case "$fbcon_rotate" in
            1) echo 90; return ;;
            2) echo 180; return ;;
            3) echo 270; return ;;
        esac
    fi

    echo 0
}

function Test_Button_A(){
  evtest --query $event_dev $event_type $event_btn_a
}

function Test_Button_B(){
  evtest --query $event_dev $event_type $event_btn_b
}


function Set_system() {
    SYSCFG="/storage/.config/system/configs/system.cfg"
    sed -i -e '/system.hostname\=/c\system.hostname\='"${1}"'' ${SYSCFG}
    sed -i -e '/system\.display_mode_hdmi\=/d' ${SYSCFG}
    sed -i -e '/system\.display_mode\=/d' ${SYSCFG}

    if [ "$UPDATE_MODE" != "device_change" ]; then
        sed -i -e '/audio.volume\=/c\audio.volume\=60' ${SYSCFG}
        sed -i -e '/rotate.root.password\=/c\rotate.root.password\=0' ${SYSCFG}
        sed -i -e '/samba.enabled\=/c\samba.enabled\=0' ${SYSCFG}
        sed -i -e '/ssh.enabled\=/c\ssh.enabled\=0' ${SYSCFG}
        sed -i -e '/updates.enabled\=/c\updates.enabled\=0' ${SYSCFG}
        sed -i -e '/system.autohotkeys\=/c\system.autohotkeys\=0' ${SYSCFG}
        sed -i -e '/global.retroarch.menu_driver\=/c\global.retroarch.menu_driver\=ozone' ${SYSCFG}
    fi
}


function Set_system_cfg_entry() {
    local key="${1}"
    local value="${2}"
    local syscfg="/storage/.config/system/configs/system.cfg"
    local escaped_key="${key//./\.}"

    if grep -q "^${escaped_key}=" "${syscfg}"; then
        sed -i -e "/^${escaped_key}=/c\\${key}=${value}" "${syscfg}"
    else
        printf '%s=%s\n' "${key}" "${value}" >> "${syscfg}"
    fi
}

function Set_ra_ext() {
	gamecontrollerdb="/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt"

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

function Setup_drastic_cheat() {
  local drastic_dir="/storage/.config/drastic"
  local cheat_file="${drastic_dir}/usrcheat.dat"
  local chs_file="${drastic_dir}/usrcheat_chs.dat"
  local backup_file="${drastic_dir}/usrcheat.dat.bak"
  local language

  language="$(get_setting language 2>/dev/null)"
  case "${language}" in
    zh_*|zh-*)
      ;;
    *)
      return 0
      ;;
  esac

  mkdir -p "${drastic_dir}"

  if [ ! -e "${chs_file}" ] && [ -e "/usr/config/drastic/usrcheat_chs.dat" ]; then
    cp -f "/usr/config/drastic/usrcheat_chs.dat" "${chs_file}"
  fi

  if [ ! -e "${chs_file}" ]; then
    return 0
  fi

  if [ -L "${cheat_file}" ] && [ "$(readlink "${cheat_file}")" = "usrcheat_chs.dat" ]; then
    return 0
  fi

  if [ -f "${cheat_file}" ] && [ ! -L "${cheat_file}" ]; then
    mv -f "${cheat_file}" "${backup_file}"
  elif [ -e "${cheat_file}" ]; then
    rm -f "${cheat_file}"
  fi

  ln -sf usrcheat_chs.dat "${cheat_file}"
}


if [ "$UPDATE_MODE" != "device_change" ]; then
    TMP_IMG="/tmp/jdk_prompt.png"
    echo "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" | base64 -d > "$TMP_IMG"
    MPV_LOG="/var/log/mpv-firstboot.log"
    MPV_ROTATION="$(Get_display_rotation)"
    echo "$(date): firstboot: starting mpv drm prompt, rotate=${MPV_ROTATION}, log=${MPV_LOG}" >>/var/log/boot.log
    env -u WAYLAND_DISPLAY -u DISPLAY -u SDL_VIDEODRIVER \
        XDG_RUNTIME_DIR=/var/run/0-runtime-dir \
        mpv --no-config --osc=no --vo=drm --fullscreen --no-terminal --image-display-duration=10 \
            --video-rotate="${MPV_ROTATION}" --msg-level=all=info --log-file="${MPV_LOG}" "$TMP_IMG" >>/var/log/boot.log 2>&1 &
    MPV_PID=$!
    echo "$(date): firstboot: mpv pid=${MPV_PID}" >>/var/log/boot.log
fi

if [ ! -e "/roms/bios/jdk" ]; then
  echo "Installing JDK." >/dev/tty0
  unzip -oq /usr/share/java/jdk.zip -d /roms/bios &>/dev/null
  chmod +x /roms/bios/jdk/bin/*
fi
ln -sf /roms/bios/jdk /storage/jdk

# User manuals (PDF shipped in squashfs) -> persistent roms path for ebook reader
DOC_PDF_SRC="/usr/share/misc/doc/rocknix-user-man"
if [ -d "${DOC_PDF_SRC}" ] && compgen -G "${DOC_PDF_SRC}"/*.pdf >/dev/null 2>&1; then
  echo "Installing user manual PDFs to /roms/ebook." >/dev/tty0
  mkdir -p /roms/ebook
  cp -f "${DOC_PDF_SRC}"/*.pdf /roms/ebook/
fi

if [ ! -e "/storage/bezels" ]; then
  echo "Copy bezels." >/dev/tty0
  mkdir -p /storage/bezels
  cp /usr/share/misc/bezels_*.zip /storage/bezels/
fi

# 处理 ppsspp 字体软链接
PPSSPP_FONTS="/storage/.config/ppsspp/assets"
if [ -d "$PPSSPP_FONTS" ]; then
  for font in Roboto_Condensed-Bold.ttf Roboto_Condensed-Italic.ttf Roboto_Condensed-Light.ttf Roboto_Condensed-Regular.ttf; do
    rm -f "$PPSSPP_FONTS/$font"
    ln -s Roboto-Condensed.ttf "$PPSSPP_FONTS/$font"
  done
fi

unzip -oq /usr/share/misc/datas.zip -d /storage

if [ "$UPDATE_MODE" != "device_change" ] && { [ "$HW_DEVICE" = "RK3566" ] || [ "$HW_DEVICE" = "RK356X" ]; } && [ -f "/usr/config/modules/MOD_TOOLS/FixShutdown.sh" ]; then
  bash "/usr/config/modules/MOD_TOOLS/FixShutdown.sh"
fi

if [ -f "/usr/config/modules/MOD_TOOLS/Reset Drastic Cfg.sh" ]; then
  bash "/usr/config/modules/MOD_TOOLS/Reset Drastic Cfg.sh"
fi

if [ "$UPDATE_MODE" != "device_change" ]; then
    if [ -n "$MPV_PID" ]; then
        wait "$MPV_PID" 2>/dev/null
    fi
    rm -f "$TMP_IMG"
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

if [ "$UPDATE_MODE" != "device_change" ]; then
    if [ -z "$event_dev" ]; then
        if [ -e "/flash/zh_CN" ]; then
            echo -e "No input device. Default to \033[32mSimple Chinese\033[0m" >/dev/tty0
            sed -i -e '/system\.language\=/c system\.language\=zh_CN' /storage/.config/system/configs/system.cfg
            sed -i -e '/system\.timezone\=/c system\.timezone\=Asia/Shanghai' /storage/.config/system/configs/system.cfg
            sync
        else
            echo -e "No input device. Default to \033[32mEnglish\033[0m" >/dev/tty0
            sed -i -e '/system\.language\=/c system\.language\=en_US' /storage/.config/system/configs/system.cfg
            sync
            exit 0
        fi
    else
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
           if [ $time_time -ge 59 ]; then
             echo -e "Timeout $event_dev. Default to \033[32mEnglish\033[0m" >/dev/tty0
             sed -i -e '/system\.language\=/c system\.language\=en_US' /storage/.config/system/configs/system.cfg
             break
           fi
        done
    fi
fi

Setup_drastic_cheat

# 获取当前输出分辨率并交换宽高的功能
TARGET_RES="1920x1080 1080x1920 1024x768 1280x720 720x1280 960x720 720x960 854x480 480x854 544x960 960x544 720x720 480x640 640x480 480x320 320x480"
RESOLUTION_RE='(1920x1080|1080x1920|1280x720|1024x768|960x720|720x960|720x1280|854x480|480x854|960x544|544x960|720x720|640x480|480x640|480x320|320x480)'

normalize_resolution() {
    local res="$1"
    local width height

    [ -n "$res" ] || return 1

    case " $TARGET_RES " in
        *" $res "*) ;;
        *) return 1 ;;
    esac

    IFS='x' read -r width height <<< "$res"
    if (( width < height )); then
        res="${height}x${width}"
    fi

    echo "$res"
}

detect_current_resolution() {
    local width height res state candidate

    if [ -r /sys/class/display/vinfo ]; then
        width="$(sed -n 's/^[[:space:]]*width:[[:space:]]*//p' /sys/class/display/vinfo | head -n1)"
        height="$(sed -n 's/^[[:space:]]*height:[[:space:]]*//p' /sys/class/display/vinfo | head -n1)"
        if [[ "$width" =~ ^[0-9]+$ && "$height" =~ ^[0-9]+$ ]] &&
           res="$(normalize_resolution "${width}x${height}")"; then
            echo "$res"
            return
        fi
    fi

    for state in /sys/kernel/debug/dri/*/state; do
        [ -r "$state" ] || continue
        while read -r candidate; do
            if res="$(normalize_resolution "$candidate")"; then
                echo "$res"
                return
            fi
        done < <(sed -n 's/.*name:\[\([0-9]\+x[0-9]\+\)p[0-9].*/\1/p' "$state")
    done

    for candidate in $(grep -oE "$RESOLUTION_RE" /sys/class/graphics/fb0/modes 2>/dev/null); do
        if res="$(normalize_resolution "$candidate")"; then
            echo "$res"
            return
        fi
    done
}

detected_res="$(detect_current_resolution)"

# Default scale factors
MENU_SCALE_FACTOR="0.400000"
MENU_WIDGET_SCALE_FACTOR="0.300000"

case "$detected_res" in
    "1920x1080")
        echo "1920x1080"
        sed -i -e '/gba.shaderset\=/c\gba.shaderset\=zfast_lcd_standard.glslp' /storage/.config/system/configs/system.cfg
        sed -i -e '/gbah.shaderset\=/c\gbah.shaderset\=zfast_lcd_standard.glslp' /storage/.config/system/configs/system.cfg
        ;;
    "1280x720")
        echo "1280x720"
        sed -i -e '/gba.shaderset\=/c\gba.shaderset\=zfast_lcd_standard.glslp' /storage/.config/system/configs/system.cfg
        sed -i -e '/gbah.shaderset\=/c\gbah.shaderset\=zfast_lcd_standard.glslp' /storage/.config/system/configs/system.cfg
        ;;
    "1024x768")
        echo "1024x768"
        Set_system_cfg_entry "famicom.ratio" "8/7"
        Set_system_cfg_entry "famicom.integerscale" "1"
        Set_system_cfg_entry "fds.ratio" "8/7"
        Set_system_cfg_entry "fds.integerscale" "1"
        Set_system_cfg_entry "nes.ratio" "8/7"
        Set_system_cfg_entry "nes.integerscale" "1"
        Set_system_cfg_entry "nesh.ratio" "8/7"
        Set_system_cfg_entry "nesh.integerscale" "1"
        Set_system_cfg_entry "ngp.integerscale" "1"
        Set_system_cfg_entry "ngpc.integerscale" "1"
        Set_system_cfg_entry "sfc.ratio" "8/7"
        Set_system_cfg_entry "sfc.integerscale" "1"
        Set_system_cfg_entry "snes.ratio" "8/7"
        Set_system_cfg_entry "snes.integerscale" "1"
        Set_system_cfg_entry "snesh.ratio" "8/7"
        Set_system_cfg_entry "snesh.integerscale" "1"
        Set_system_cfg_entry "wonderswancolor.integerscale" "1"
        ;;
    "960x720")
        echo "960x720"
        MENU_SCALE_FACTOR="0.550000"
        MENU_WIDGET_SCALE_FACTOR="0.550000"
        Set_system_cfg_entry "famicom.ratio" "8/7"
        Set_system_cfg_entry "famicom.integerscale" "1"
        Set_system_cfg_entry "fds.ratio" "8/7"
        Set_system_cfg_entry "fds.integerscale" "1"
        Set_system_cfg_entry "nes.ratio" "8/7"
        Set_system_cfg_entry "nes.integerscale" "1"
        Set_system_cfg_entry "nesh.ratio" "8/7"
        Set_system_cfg_entry "nesh.integerscale" "1"
        Set_system_cfg_entry "ngp.integerscale" "1"
        Set_system_cfg_entry "ngpc.integerscale" "1"
        Set_system_cfg_entry "sfc.ratio" "8/7"
        Set_system_cfg_entry "sfc.integerscale" "1"
        Set_system_cfg_entry "snes.ratio" "8/7"
        Set_system_cfg_entry "snes.integerscale" "1"
        Set_system_cfg_entry "snesh.ratio" "8/7"
        Set_system_cfg_entry "snesh.integerscale" "1"
        Set_system_cfg_entry "wonderswancolor.integerscale" "1"
        ;;
    "854x480")
        echo "854x480"
        Set_system_cfg_entry "famicom.ratio" "8/7"
        Set_system_cfg_entry "famicom.integerscale" "1"
        Set_system_cfg_entry "fds.ratio" "8/7"
        Set_system_cfg_entry "fds.integerscale" "1"
        Set_system_cfg_entry "nes.ratio" "8/7"
        Set_system_cfg_entry "nes.integerscale" "1"
        Set_system_cfg_entry "nesh.ratio" "8/7"
        Set_system_cfg_entry "nesh.integerscale" "1"
        Set_system_cfg_entry "ngp.integerscale" "1"
        Set_system_cfg_entry "ngpc.integerscale" "1"
        Set_system_cfg_entry "sfc.ratio" "8/7"
        Set_system_cfg_entry "sfc.integerscale" "1"
        Set_system_cfg_entry "snes.ratio" "8/7"
        Set_system_cfg_entry "snes.integerscale" "1"
        Set_system_cfg_entry "snesh.ratio" "8/7"
        Set_system_cfg_entry "snesh.integerscale" "1"
        Set_system_cfg_entry "wonderswancolor.integerscale" "1"
        ;;
    "960x544")
        echo "960x544"
        ;;
    "720x720")
        echo "720x720"
        Set_system_cfg_entry "atarilynx.ratio" "custom"
        Set_system_cfg_entry "atarilynx.integerscale" "0"
        Set_system_cfg_entry "dreamcast.ratio" "custom"
        Set_system_cfg_entry "dreamcast.integerscale" "0"
        Set_system_cfg_entry "famicom.ratio" "custom"
        Set_system_cfg_entry "famicom.integerscale" "0"
        Set_system_cfg_entry "fds.ratio" "custom"
        Set_system_cfg_entry "fds.integerscale" "0"
        Set_system_cfg_entry "gb.ratio" "core"
        Set_system_cfg_entry "gb.integerscale" "1"
        Set_system_cfg_entry "gbc.ratio" "core"
        Set_system_cfg_entry "gbc.integerscale" "1"
        Set_system_cfg_entry "gbch.ratio" "core"
        Set_system_cfg_entry "gbch.integerscale" "1"
        Set_system_cfg_entry "gbh.ratio" "core"
        Set_system_cfg_entry "gbh.integerscale" "1"
        Set_system_cfg_entry "genesis.ratio" "custom"
        Set_system_cfg_entry "genesis.integerscale" "0"
        Set_system_cfg_entry "genh.ratio" "custom"
        Set_system_cfg_entry "genh.integerscale" "0"
        Set_system_cfg_entry "megadrive.ratio" "custom"
        Set_system_cfg_entry "megadrive.integerscale" "0"
        Set_system_cfg_entry "nes.ratio" "custom"
        Set_system_cfg_entry "nes.integerscale" "0"
        Set_system_cfg_entry "nesh.ratio" "custom"
        Set_system_cfg_entry "nesh.integerscale" "0"
        Set_system_cfg_entry "ngp.ratio" "core"
        Set_system_cfg_entry "ngp.integerscale" "1"
        Set_system_cfg_entry "ngpc.ratio" "core"
        Set_system_cfg_entry "ngpc.integerscale" "1"
        Set_system_cfg_entry "pc.ratio" "custom"
        Set_system_cfg_entry "pc.integerscale" "0"
        Set_system_cfg_entry "psx.ratio" "custom"
        Set_system_cfg_entry "psx.integerscale" "0"
        Set_system_cfg_entry "saturn.ratio" "custom"
        Set_system_cfg_entry "saturn.integerscale" "0"
        Set_system_cfg_entry "segacd.ratio" "custom"
        Set_system_cfg_entry "segacd.integerscale" "0"
        Set_system_cfg_entry "sfc.ratio" "custom"
        Set_system_cfg_entry "sfc.integerscale" "0"
        Set_system_cfg_entry "snes.ratio" "custom"
        Set_system_cfg_entry "snes.integerscale" "0"
        Set_system_cfg_entry "snesh.ratio" "custom"
        Set_system_cfg_entry "snesh.integerscale" "0"
        Set_system_cfg_entry "wonderswan.ratio" "custom"
        Set_system_cfg_entry "wonderswan.integerscale" "0"
        Set_system_cfg_entry "wonderswancolor.ratio" "custom"
        Set_system_cfg_entry "wonderswancolor.integerscale" "0"
        ;;
    "640x480")
        echo "640x480"
        Set_system_cfg_entry "msx.ratio" "custom"
        Set_system_cfg_entry "msx.integerscale" "0"
        Set_system_cfg_entry "pico-8.ratio" "custom"
        Set_system_cfg_entry "pico-8.integerscale" "0"
        Set_system_cfg_entry "pokemini.ratio" "custom"
        Set_system_cfg_entry "pokemini.integerscale" "0"
        Set_system_cfg_entry "psp.ratio" "custom"
        Set_system_cfg_entry "psp.integerscale" "0"
        Set_system_cfg_entry "virtualboy.ratio" "custom"
        Set_system_cfg_entry "virtualboy.integerscale" "0"
        Set_system_cfg_entry "gbc.integerscale" "1"
        Set_system_cfg_entry "gb.integerscale" "1"
        ;;
    "480x320")
        echo "480x320"
        ;;
    *)
        echo "$detected_res"
        ;;
esac

if [ -f "/usr/config/modules/MOD_TOOLS/Bezels Installer.sh" ]; then
    bash "/usr/config/modules/MOD_TOOLS/Bezels Installer.sh" --skip-existing "${detected_res}"
fi



if [ "$HW_DEVICE" = "RK3326" ] || [ "$HW_DEVICE" = "RK3326S" ] || [ "$HW_DEVICE" = "S905" ]; then
    sed -i -e '/gba.shaderset\=/c\gba.shaderset\=handheld/dot.glslp' /storage/.config/system/configs/system.cfg
    sed -i -e '/gbah.shaderset\=/c\gbah.shaderset\=handheld/dot.glslp' /storage/.config/system/configs/system.cfg
fi

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
    "MINILOONG Pocket1")
        echo "${QUIRK_DEVICE}"
        Set_system "MINILOONG"
	set_setting key.hotkey.b=BTN_MODE
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
    "XiFan DC45V")
        echo "${QUIRK_DEVICE}"
        Set_system "DC45V"
    ;;
    "XiFan R36Max2")
        echo "${QUIRK_DEVICE}"
        Set_system "R36Max2"
    ;;
    "XiFan RF35H")
        echo "${QUIRK_DEVICE}"
        Set_system "RF35H"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "XiFan RF40H")
        echo "${QUIRK_DEVICE}"
        Set_system "RF40H"
    ;;
    "XiFan RF45V")
        echo "${QUIRK_DEVICE}"
        Set_system "RF45V"
    ;;
    "XiFan XF45V")
        echo "${QUIRK_DEVICE}"
        Set_system "XF45V"
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
    "YMC A10Mini V4")
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
    "MagicX XU10")
        echo "${QUIRK_DEVICE}"
        Set_system "XU10"
    ;;
    "MagicX XU Mini M")
        echo "${QUIRK_DEVICE}"
        Set_system "XUMiniM"
    ;;
# 泡机堂
    "Powkiddy RGB10")
        echo "${QUIRK_DEVICE}"
        Set_system "RGB10"
        amixer -c 0 -M cset name="Playback Mux" HP
	set_setting key.dpad.events 1
    ;;
    "Powkiddy RGB20S")
        echo "${QUIRK_DEVICE}"
        amixer -c 0 -M cset name="Playback Mux" HP
        Set_system "RGB20S"
    ;;
    "Powkiddy RGB10X")
        echo "${QUIRK_DEVICE}"
        amixer -c 0 -M cset name="Playback Mux" HP
        Set_system "RGB10X"
    ;;
# 曼特科技
    "GameMT E6")
        echo "${QUIRK_DEVICE}"
        Set_system "E6"
        amixer -c 0 -M cset name="${DEVICE_PLAYBACK_PATH}" $DEVICE_PLAYBACK_PATH_SPK
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
# Game Console
    "Game Console R36S")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
    ;;
    "Game Console R36S Panel1")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
    ;;
    "Game Console R36S Panel2")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
    ;;
    "Game Console R36S Panel3")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
    ;;
    "Game Console R36S Panel4")
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
    "Game Console R36sPlus")
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
    "Clone R36s Type 3 Panel1")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "Clone R36s Type 3 Panel2")
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
    "Sauce R36s Panel1")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "Sauce R36s Panel2")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "Sauce R36s Panel3")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "Sauce R36s Panel4")
        echo "${QUIRK_DEVICE}"
        Set_system "R36S"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
# K36
    "Game Console K36")
        echo "${QUIRK_DEVICE}"
        Set_system "K36"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
# AISLPC
    "AISLPC K36S")
        echo "${QUIRK_DEVICE}"
        Set_system "K36S"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "AISLPC R36T")
        echo "${QUIRK_DEVICE}"
        Set_system "R36T"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "AISLPC R36TMax")
        echo "${QUIRK_DEVICE}"
        Set_system "R36TMax"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
# BatleXP
    "BatleXP G350")
        echo "${QUIRK_DEVICE}"
        Set_system "G350"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
# 其他无牌
    "Game Console XGB36")
        echo "${QUIRK_DEVICE}"
        Set_system "XGB36"
        amixer -c 0 -M cset name="Playback Mux" HP
    ;;
    "Game Console R36Ultra")
        echo "${QUIRK_DEVICE}"
        Set_system "R36Ultra"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "Game Console T16Max")
        echo "${QUIRK_DEVICE}"
        Set_system "T16Max"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "Game Console HG36")
        echo "${QUIRK_DEVICE}"
        Set_system "HG36"
        amixer -c 0 -M cset name="Playback Mux" SPK
    ;;
    "Game Console U8")
        echo "${QUIRK_DEVICE}"
        Set_system "U8"
    ;;
    "Game Console RX6H")
        echo "${QUIRK_DEVICE}"
        Set_system "RX6H"
    ;;
    "Game Console R40S")
        echo "${QUIRK_DEVICE}"
        Set_system "R40S"
    ;;
    "Game Console RG36")
        echo "${QUIRK_DEVICE}"
        Set_system "RG36"
    ;;
    "Game Console RG36PRO")
        echo "${QUIRK_DEVICE}"
        Set_system "RG36PRO"
    ;;
# 兜底
    *)
        echo "${QUIRK_DEVICE}"
        Set_system "Aurknix"
    ;;
esac

cp -f /usr/config/retroarch/retroarch.cfg ${RACFG}
Set_ra_ext "$MENU_SCALE_FACTOR" "$MENU_WIDGET_SCALE_FACTOR"

if [ "$(systemctl is-active input)" = "active" ]
then
  systemctl restart input
fi

# RK356X: sync stock eMMC bootloader and EmuELEC boot assets to the TF card.
if [ "${HW_DEVICE}" = "RK356X" ]; then
  _sync_uboot="/usr/config/modules/MOD_TOOLS/Sync eMMC Bootloader to TF.sh"
  [ -x "${_sync_uboot}" ] || _sync_uboot="/storage/.config/modules/MOD_TOOLS/Sync eMMC Bootloader to TF.sh"
  if [ -x "${_sync_uboot}" ]; then
    echo "Sync eMMC bootloader to TF..." >>/var/log/boot.log
    "${_sync_uboot}" >>/var/log/boot.log 2>&1 || true
  fi
fi

sync
