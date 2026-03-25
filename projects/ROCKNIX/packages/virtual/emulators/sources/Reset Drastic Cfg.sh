#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)  # 脚本绝对路径
SDL_DB_FILE="/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt" # 目标DB文件
JOYGUID_BIN="/usr/bin/joyguid"     # joyguid路径
DRASTIC_TEMPLATE="/usr/config/drastic/config//drastic.cfg"       # drastic.cfg模板
DRASTIC_CFG="/storage/.config/drastic/config/drastic.cfg"

# 定义配置文件路径
CONFIG_FILE="/storage/.config/joy_guid"

if [ -f /storage/.config/drastic/config/drastic.cf2 ]; then
    rm -rf /storage/.config/drastic/config/drastic.cf*
fi

cp "${DRASTIC_TEMPLATE}" "${DRASTIC_CFG}"

guid=$("$JOYGUID_BIN" 2>/dev/null | tr -d '\n')  # 移除换行符

# 查找匹配的配置行
mapping_line=$(grep -m1 "^${guid}," "$SDL_DB_FILE")

if [ -z "$mapping_line" ]; then
    echo "错误：未找到GUID $guid 对应的控制器配置"
    exit 1
fi

# 生成临时文件
tmp_file=$(mktemp)

awk -v mapping_str="$mapping_line" '
BEGIN {
    # Hat 方向掩码到值的映射 (Drastic 使用 0x440 | mask)
    hat_values["1"] = 1089  # up:    0x440 | 1 = 0x441
    hat_values["2"] = 1090  # right: 0x440 | 2 = 0x442
    hat_values["4"] = 1092  # down:  0x440 | 4 = 0x444
    hat_values["8"] = 1096  # left:  0x440 | 8 = 0x448

    # 初始化标志
    has_left_stick = 0
    has_right_stick = 0
    has_guide = 0

    # 初始化键值映射
    split(mapping_str, parts, /,/)
    delete key_map
    for (i in parts) {
        if (parts[i] ~ /:/) {
            split(parts[i], kv, /:/)
            key = kv[1]
            val = kv[2]

            # 检测是否有左摇杆
            if (key == "leftx" || key == "lefty") {
                has_left_stick = 1
            }

            # 检测是否有右摇杆
            if (key == "rightx" || key == "righty") {
                has_right_stick = 1
            }

            # 检测是否有 guide 键
            if (key == "guide") {
                has_guide = 1
            }

            if (val ~ /^b[0-9]+$/) {
                # 按钮: b0 -> 1024 + n
                key_map[key] = substr(val, 2) + 1024
            } else if (val ~ /^a[0-9]+\+$/) {
                # 轴正向: 0x480 + axis = 1152 + axis
                gsub(/^a|\+$/, "", val)
                key_map[key] = 1152 + val
                key_map[key "+"] = 1152 + val
            } else if (val ~ /^a[0-9]+-$/) {
                # 轴负向: 0x4C0 + axis = 1216 + axis
                gsub(/^a|-$/, "", val)
                key_map[key] = 1216 + val
                key_map[key "-"] = 1216 + val
            } else if (val ~ /^a[0-9]+$/) {
                # 轴（不带+/-后缀）: 直接存储正向和负向的最终值
                gsub(/^a/, "", val)
                # 标记此轴存在
                key_map[key] = "axis"
                # 正向最终值: 1152 + axis
                key_map[key "+"] = 1152 + val
                # 负向最终值: 1216 + axis
                key_map[key "-"] = 1216 + val
            } else if (val ~ /^h[0-9]+\.[0-9]+$/) {
                # Hat 方向: h0.1 -> 1088 (0x440 起始)
                gsub(/^h[0-9]+\./, "", val)
                if (val in hat_values) {
                    key_map[key] = hat_values[val]
                }
            }
        }
    }

    # 定义控件映射关系
    # 方向键
    control_mapping["CONTROL_INDEX_UP"] = "dpup"
    control_mapping["CONTROL_INDEX_DOWN"] = "dpdown"
    control_mapping["CONTROL_INDEX_LEFT"] = "dpleft"
    control_mapping["CONTROL_INDEX_RIGHT"] = "dpright"

    # 游戏按键
    control_mapping["CONTROL_INDEX_A"] = "a"
    control_mapping["CONTROL_INDEX_B"] = "b"
    control_mapping["CONTROL_INDEX_X"] = "x"
    control_mapping["CONTROL_INDEX_Y"] = "y"
    control_mapping["CONTROL_INDEX_L"] = "leftshoulder"
    control_mapping["CONTROL_INDEX_R"] = "rightshoulder"

    # 系统按键
    control_mapping["CONTROL_INDEX_START"] = "start"
    control_mapping["CONTROL_INDEX_SELECT"] = "back"

    # 特殊功能 - 默认映射（双摇杆手柄）
    control_mapping["CONTROL_INDEX_MENU"] = "leftstick"
    control_mapping["CONTROL_INDEX_SWAP_SCREENS"] = "guide"
    control_mapping["CONTROL_INDEX_SWAP_ORIENTATION_A"] = "lefttrigger"
    control_mapping["CONTROL_INDEX_SWAP_ORIENTATION_B"] = "righttrigger"

    # 触屏控制 - 默认使用右摇杆
    control_mapping["CONTROL_INDEX_TOUCH_CURSOR_PRESS"] = "rightstick"
    control_mapping["CONTROL_INDEX_TOUCH_CURSOR_UP"] = "righty-"
    control_mapping["CONTROL_INDEX_TOUCH_CURSOR_DOWN"] = "righty+"
    control_mapping["CONTROL_INDEX_TOUCH_CURSOR_LEFT"] = "rightx-"
    control_mapping["CONTROL_INDEX_TOUCH_CURSOR_RIGHT"] = "rightx+"

    # UI 导航
    control_mapping["CONTROL_INDEX_UI_UP"] = "dpup"
    control_mapping["CONTROL_INDEX_UI_DOWN"] = "dpdown"
    control_mapping["CONTROL_INDEX_UI_LEFT"] = "dpleft"
    control_mapping["CONTROL_INDEX_UI_RIGHT"] = "dpright"
    control_mapping["CONTROL_INDEX_UI_SELECT"] = "a"
    control_mapping["CONTROL_INDEX_UI_BACK"] = "x"
    control_mapping["CONTROL_INDEX_UI_EXIT"] = "b"
}

{
    current_line = $0
    if (index(current_line, "controls_b[") == 1) {
        split(current_line, arr1, "[")
        if (length(arr1) >= 2) {
            split(arr1[2], arr2, "]")
            control_index = arr2[1]
            
            # 单摇杆特殊处理：左摇杆作为触屏光标（需要有左摇杆）
            if (has_right_stick == 0 && has_left_stick == 1) {
                if (control_index == "CONTROL_INDEX_TOUCH_CURSOR_PRESS") {
                    # L3 作为 cursor press
                    if ("leftstick" in key_map) {
                        new_value = key_map["leftstick"]
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " new_value
                        }
                    }
                } else if (control_index == "CONTROL_INDEX_TOUCH_CURSOR_UP") {
                    # 左摇杆上 (Y轴负向): key_map["lefty-"] 已是最终值
                    if ("lefty-" in key_map) {
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " key_map["lefty-"]
                        }
                    }
                } else if (control_index == "CONTROL_INDEX_TOUCH_CURSOR_DOWN") {
                    # 左摇杆下 (Y轴正向): key_map["lefty+"] 已是最终值
                    if ("lefty+" in key_map) {
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " key_map["lefty+"]
                        }
                    }
                } else if (control_index == "CONTROL_INDEX_TOUCH_CURSOR_LEFT") {
                    # 左摇杆左 (X轴负向): key_map["leftx-"] 已是最终值
                    if ("leftx-" in key_map) {
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " key_map["leftx-"]
                        }
                    }
                } else if (control_index == "CONTROL_INDEX_TOUCH_CURSOR_RIGHT") {
                    # 左摇杆右 (X轴正向): key_map["leftx+"] 已是最终值
                    if ("leftx+" in key_map) {
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " key_map["leftx+"]
                        }
                    }
                } else if (control_index in control_mapping) {
                    # 其他控件使用默认映射
                    physical_key = control_mapping[control_index]
                    if (physical_key in key_map) {
                        new_value = key_map[physical_key]
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " new_value
                        }
                    }
                }
            } else {
                # 双摇杆手柄：使用默认映射
                if (control_index in control_mapping) {
                    physical_key = control_mapping[control_index]
                    if (physical_key in key_map) {
                        new_value = key_map[physical_key]
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " new_value
                        }
                    }
                }
            }
        }
    }
    # controls_a 处理
    else if (index(current_line, "controls_a[") == 1) {
        split(current_line, arr1, "[")
        if (length(arr1) >= 2) {
            split(arr1[2], arr2, "]")
            control_index = arr2[1]
            
            # MENU: 如果有 guide 键，设置 controls_a 的 MENU
            if (control_index == "CONTROL_INDEX_MENU" && has_guide == 1) {
                new_value = key_map["guide"]
                split(current_line, arr3, "=")
                if (length(arr3) >= 2) {
                    current_line = arr3[1] "= " new_value
                }
            }
            # 方向控件: 只有存在双摇杆时才设置（controls_a用左摇杆做方向）
            else if (has_right_stick == 1 && has_left_stick == 1) {
                if (control_index == "CONTROL_INDEX_UP" || control_index == "CONTROL_INDEX_UI_UP") {
                    # 上: lefty- (Y轴负向): 已是最终值
                    if ("lefty-" in key_map) {
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " key_map["lefty-"]
                        }
                    }
                } else if (control_index == "CONTROL_INDEX_DOWN" || control_index == "CONTROL_INDEX_UI_DOWN") {
                    # 下: lefty+ (Y轴正向): 已是最终值
                    if ("lefty+" in key_map) {
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " key_map["lefty+"]
                        }
                    }
                } else if (control_index == "CONTROL_INDEX_LEFT" || control_index == "CONTROL_INDEX_UI_LEFT") {
                    # 左: leftx- (X轴负向): 已是最终值
                    if ("leftx-" in key_map) {
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " key_map["leftx-"]
                        }
                    }
                } else if (control_index == "CONTROL_INDEX_RIGHT" || control_index == "CONTROL_INDEX_UI_RIGHT") {
                    # 右: leftx+ (X轴正向): 已是最终值
                    if ("leftx+" in key_map) {
                        split(current_line, arr3, "=")
                        if (length(arr3) >= 2) {
                            current_line = arr3[1] "= " key_map["leftx+"]
                        }
                    }
                }
            }
        }
    }
    print current_line
}
' "$DRASTIC_CFG" > "$tmp_file"

# 替换原文件
mv "$tmp_file" "$DRASTIC_CFG"

if [ -d /storage/.config/drastic_chn/config/ ]; then
    cp "$DRASTIC_CFG"  /storage/.config/drastic_chn/config/drastic.cfg
fi

echo "配置文件已更新：$config_file（使用GUID：$guid）"
