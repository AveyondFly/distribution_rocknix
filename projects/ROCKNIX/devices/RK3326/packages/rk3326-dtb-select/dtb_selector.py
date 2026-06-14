#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
RK3326 掌机 DTB 选择器
========================
功能：
  - 交互式菜单选择设备厂商和型号
  - 自动生成 extlinux.conf 配置文件
  - 部署设备所需的 overlays（如有）
  - 支持中英文界面切换

支持设备：
  R36S系列、安伯尼克、稀范科技、PowKiddy、Odroid 等 RK3326 掌机

用法：
  python dtb_selector.py

环境变量：
  RK3326_DTB_SELECT_CONFIG  - 自定义 config 目录路径
  RK3326_DTB_SELECT_NO_REMOUNT - 跳过 /flash 分区重挂载
  ROCKNIX_BOOT - 启动分区挂载点（默认 /flash）

新增设备：
    1. ALL_DEVICES 中添加
    2. DEVICE_TRANSLATIONS 中添加
    3. 如果有新厂家则需要CATEGORIES
"""

import os, sys, re, shutil, subprocess, tempfile
from typing import Optional, List, Dict
from dataclasses import dataclass

# Windows 终端 ANSI
if os.name == "nt":
    try:
        os.system("")
    except Exception:
        pass

try:
    from wcwidth import wcswidth as _wlen
except Exception:
    _wlen = lambda s: len(s)

ANSI_RE = re.compile(r'\x1b\[[0-9;]*m')

# ==== 多语言支持 ====
LANG = "zh"  # 默认中文，启动时可选

TRANSLATIONS = {
    "zh": {
        "title_lang_select": "请选择语言 / Please select language",
        "lang_zh": "中文",
        "lang_en": "English",
        "title_select_vendor": "请选择厂商 / 机型分类",
        "devices_count": "{} 台设备",
        "exit": "退出程序",
        "back": "返回上一级",
        "input_number": "输入编号：",
        "invalid_number": "无效编号，请重试。",
        "applying_config": "正在应用配置",
        "model": "机型",
        "serial": "SERIAL",
        "vt": "VT",
        "debug": "DEBUG",
        "overlay": "OVERLAY",
        "no_change": "（不改）",
        "generated_extlinux": "已生成 extlinux.conf",
        "deployed_overlays": "已部署 overlays",
        "deleted_overlays": "已删除 overlays（当前机型无需 overlays）",
        "config_complete": "配置完成！",
        "config_failed": "配置失败，请检查 config 文件夹",
        "press_any_key": "按任意键返回厂商列表...",
        "press_any_key_exit": "按任意键退出...",
        "thank_you": "感谢使用，再见！",
        "error_missing_config": "错误：缺少 config 目录",
        "error_missing_template": "错误：缺少模板",
        "error_missing_overlays": "错误：缺少 overlays 源目录",
    },
    "en": {
        "title_lang_select": "Please select language / 请选择语言",
        "lang_zh": "中文",
        "lang_en": "English",
        "title_select_vendor": "Select Manufacturer / Device Category",
        "devices_count": "{} devices",
        "exit": "Exit",
        "back": "Back",
        "input_number": "Enter number: ",
        "invalid_number": "Invalid number, please try again.",
        "applying_config": "Applying Configuration",
        "model": "Model",
        "serial": "SERIAL",
        "vt": "VT",
        "debug": "DEBUG",
        "overlay": "OVERLAY",
        "no_change": "(no change)",
        "generated_extlinux": "Generated extlinux.conf",
        "deployed_overlays": "Deployed overlays",
        "deleted_overlays": "Deleted overlays (not required for this device)",
        "config_complete": "Configuration complete!",
        "config_failed": "Configuration failed, please check config folder",
        "press_any_key": "Press any key to return to vendor list...",
        "press_any_key_exit": "Press any key to exit...",
        "thank_you": "Thank you, goodbye!",
        "error_missing_config": "Error: Missing config directory",
        "error_missing_template": "Error: Missing template",
        "error_missing_overlays": "Error: Missing overlays source directory",
    },
}

def t(key: str, *args) -> str:
    """获取翻译文本，支持格式化参数"""
    text = TRANSLATIONS[LANG].get(key, key)
    if args:
        return text.format(*args)
    return text

# ==== 路径 ====
if getattr(sys, 'frozen', False):
    ROOT_DIR = os.path.dirname(sys.executable)
else:
    ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

CONFIG_DIR = os.environ.get("RK3326_DTB_SELECT_CONFIG", os.path.join(ROOT_DIR, "config"))


def _boot_write_root() -> str:
    """ROCKNIX: 启动 FAT 挂载在 /flash；无则回退到脚本目录（本地测试）。"""
    b = os.environ.get("ROCKNIX_BOOT", "/flash")
    if os.path.isdir(b):
        return b
    return ROOT_DIR


def _remount_flash(rw: bool) -> None:
    if os.environ.get("RK3326_DTB_SELECT_NO_REMOUNT"):
        return
    if _boot_write_root() != "/flash":
        return
    mount = "/usr/bin/mount"
    if not os.path.isfile(mount):
        return
    mode = "rw" if rw else "ro"
    subprocess.run(
        [mount, "-o", f"remount,{mode}", "/flash"],
        check=False,
        capture_output=True,
    )

# ==== 工具 ====
def clear_screen():
    os.system("cls" if os.name == "nt" else "clear")

def wait_anykey(msg=None):
    if msg is None:
        msg = t("press_any_key_exit")
    print(msg, end="", flush=True)
    if os.name == "nt":
        try:
            import msvcrt
            _ = msvcrt.getwch()
            print("")
            return
        except Exception:
            pass
    try:
        input()
    except EOFError:
        pass

# ==== 数据结构 ====
@dataclass
class DtbEntry:
    dtb: str
    tty: object
    overlay: Optional[str] = None

# ==== 设备映射 ====
ALL_DEVICES: Dict[str, DtbEntry] = {
    # R36s克隆
    "R36S克隆 种类1带功放": DtbEntry("rk3326-xifan-r36pro.dtb", 101),
    "R36S克隆 种类1不带功放": DtbEntry("rk3326-gameconsole-hg36.dtb", 101),
    "R36S克隆 种类1不带功放并反转右摇杆": DtbEntry("rk3326-gameconsole-k36.dtb", 101),
    "R36S克隆 种类2带功放": DtbEntry("rk3326-r36s-type2-with-amplifier.dtb", 101),
    "R36S克隆 种类2不带功放": DtbEntry("rk3326-r36s-type2-without-amplifier.dtb", 101),
    "R36S克隆 种类3屏幕1": DtbEntry("rk3326-r36s-type3-panel1.dtb", 101),
    "R36S克隆 种类3屏幕2": DtbEntry("rk3326-r36s-type3-panel2.dtb", 101),
    "R36S克隆 种类4": DtbEntry("rk3326-r36s-type4.dtb", 101),

    # R36s酱油
    "R36S酱油 屏幕1": DtbEntry("rk3326-r36s-sauce-panel1.dtb", 202),
    "R36S酱油 屏幕2": DtbEntry("rk3326-r36s-sauce-panel2.dtb", 202),
    "R36S酱油 屏幕3": DtbEntry("rk3326-r36s-sauce-panel3.dtb", 202),
    "R36S酱油 屏幕4": DtbEntry("rk3326-r36s-sauce-panel4.dtb", 202),

    # K36系列
    "K36 原始版本": DtbEntry("rk3326-gameconsole-k36.dtb", 202),

    # BatleXP
    "BatleXP G350": DtbEntry("rk3326-batlexp-g350.dtb", 101),

    # AISLPC
    "AISLPC K36s": DtbEntry("rk3326-aislpc-k36s.dtb", 101),
    "AISLPC R36T": DtbEntry("rk3326-aislpc-r36t.dtb", 101),
    "AISLPC R36TMax": DtbEntry("rk3326-aislpc-r36tmax.dtb", 101),

    # 其他
    "T16Max": DtbEntry("rk3326-gameconsole-t16max.dtb", 101),
    "U8": DtbEntry("rk3326-gameconsole-u8.dtb", 101),
    "U8 P2屏幕": DtbEntry("rk3326-gameconsole-u8-v2.dtb", 101),
    "RX6H": DtbEntry("rk3326-gameconsole-rx6h.dtb", 101),
    "HG36/HG3506": DtbEntry("rk3326-gameconsole-hg36.dtb", 202),
    "R36 Ultra": DtbEntry("rk3326-gameconsole-r36ultra.dtb", 101),
    "R36 Ultra v2": DtbEntry("rk3326-gameconsole-r36ultra-v2.dtb", 101),
    "XGB36": DtbEntry("rk3326-gameconsole-xgb36.dtb", 202),
    "RG36": DtbEntry("rk3326-gameconsole-rg36.dtb", 202),
    "R40S": DtbEntry("rk3326-gameconsole-r40s.dtb", 202,),
    "R39S": DtbEntry("rk3326-gameconsole-r40s.dtb", 202,),

    # GameConsole
    "Game Console R33s": DtbEntry("rk3326-gameconsole-r33s.dtb", 202),
    "Game Console R36s P1屏幕": DtbEntry("rk3326-gameconsole-r36s.dtb", 202),
    "Game Console R36s P2屏幕": DtbEntry("rk3326-gameconsole-r36s-panel2.dtb", 202),
    "Game Console R36s P3屏幕": DtbEntry("rk3326-gameconsole-r36s-panel3.dtb", 202),
    "Game Console R36s P4屏幕": DtbEntry("rk3326-gameconsole-r36s-panel4.dtb", 202),
    "Game Console R36xx": DtbEntry("rk3326-gameconsole-r36s-panel4.dtb", 202),
    "Game Console R36H": DtbEntry("rk3326-gameconsole-r36s-panel4.dtb", 202),
    "Game Console O30S": DtbEntry("rk3326-gameconsole-r36s-panel4.dtb", 202),
    "Game Console R50S": DtbEntry("rk3326-gameconsole-r50s.dtb", 202,),
    "Game Console R36sPlus": DtbEntry("rk3326-gameconsole-r36splus.dtb", 202),
    "Game Console R36H ProMax": DtbEntry("rk3326-gameconsole-r45h.dtb", 202,),
    "Game Console R40XX": DtbEntry("rk3326-gameconsole-r40xx.dtb", 202,),
    "Game Console R40XX ProMax": DtbEntry("rk3326-gameconsole-r40xxpromax.dtb", 202,),
    "Game Console R45H": DtbEntry("rk3326-gameconsole-r45h.dtb", 202,),
    "Game Console R46H": DtbEntry("rk3326-gameconsole-r46h.dtb", 202,),

    # 稀范科技
    "稀范科技 MyMini": DtbEntry("rk3326-xifan-mymini.dtb", 101),
    "稀范科技 Mini40": DtbEntry("rk3326-xifan-mini40.dtb", 101),
    "稀范科技 XF35H": DtbEntry("rk3326-xifan-xf35h.dtb", 101),
    "稀范科技 R36Max": DtbEntry("rk3326-xifan-r36max.dtb", 101),
    "稀范科技 R36Pro": DtbEntry("rk3326-xifan-r36pro.dtb", 101),
    "稀范科技 XF40H": DtbEntry("rk3326-xifan-xf40h.dtb", 101),
    "稀范科技 XF40V": DtbEntry("rk3326-xifan-xf40v.dtb", 101),
    "稀范科技 XF28": DtbEntry("rk3326-xifan-xf28.dtb", 101),
    "稀范科技 DC35V": DtbEntry("rk3326-xifan-dc35v.dtb", 101),
    "稀范科技 DC40V": DtbEntry("rk3326-xifan-dc40v.dtb", 101),
    "稀范科技 R36Max2": DtbEntry("rk3326-xifan-r36max2.dtb", 202),

    # 安伯尼克
    "安伯尼克 RG351M": DtbEntry("rk3326-anbernic-rg351m.dtb", 101),
    "安伯尼克 RG351V": DtbEntry("rk3326-anbernic-rg351v.dtb", 101),
    "安伯尼克 RG351V P2屏幕": DtbEntry("rk3326-anbernic-rg351v.dtb", 101, "overlays-rg351v-p2"),
    "安伯尼克 RG351MP": DtbEntry("rk3326-gameconsole-r36s.dtb", 202, "overlays-rg351mp-p2"),

    # 亿米创
    "YMC A10mini": DtbEntry("rk3326-portablegame-a10mini.dtb", 202),
    "YMC A10mini V4": DtbEntry("rk3326-portablegame-a10mini-v4.dtb", 202),

    # 迪优米
    "Diium D-R28S": DtbEntry("rk3326-diium-dr28s.dtb", 101),
    "Diium D007(Plus)": DtbEntry("rk3326-diium-d007.dtb", 101),

    # Magicx
    "Magicx Xu10": DtbEntry("rk3326-magicx-xu10.dtb", 202),
    "Magicx Xu Mini M": DtbEntry("rk3326-magicx-xu-mini-m.dtb", 101),

    # 泡机堂
    "PowKiddy RGB10": DtbEntry("rk3326-powkiddy-rgb10.dtb", 101),
    "PowKiddy RGB10X": DtbEntry("rk3326-powkiddy-rgb10x.dtb", 101),
    "PowKiddy RGB10S": DtbEntry("rk3326-powkiddy-rgb10s.dtb", 101),
    "PowKiddy RGB2OS": DtbEntry("rk3326-powkiddy-rgb20s.dtb", 202),
    "PowKiddy RGB10Max1": DtbEntry("rk3326-powkiddy-rgb10max1.dtb", 101),

    # GAMEMT
    "GAMEMT E6": DtbEntry("rk3326-gamemt-e6.dtb", 101),

    # Odroid
    "ODROID-GO Advance": DtbEntry("rk3326-odroid-go2.dtb", 101),
    "ODROID-GO Advance 1.1": DtbEntry("rk3326-odroid-go2-v11.dtb", 101),
    "Odroid Go Super": DtbEntry("rk3326-odroid-go3.dtb", 101),

    # Batlexp
    "Batlexp G350": DtbEntry("rk3326-batlexp-g350.dtb", 202),
}

# ==== 分组 ====
CATEGORIES: Dict[str, Dict[str, DtbEntry]] = {
    "稀范科技": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("稀范科技 ")},
    "安伯尼克": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("安伯尼克 ")},
    "亿米创": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("YMC ")},
    "迪优米": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("Diium ")},
    "Magicx": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("Magicx ")},
    "泡机堂": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("PowKiddy ")},
    "漫特科技": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("GAMEMT ")},
    "Odroid": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("Odroid ")},
    "Game Console": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("Game Console ")},
    "R36S克隆": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("R36S克隆 ")},
    "R36S酱油": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("R36S酱油 ")},
    "K36系列": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("K36 ")},
    "AISLPC": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("AISLPC ")},
    "Batlexp": {k: ALL_DEVICES[k] for k in ALL_DEVICES if k.startswith("Batlexp ")},
    "其他": {
        "GameConsole T16Max|S6000": ALL_DEVICES["T16Max"],
        "GameConsole U8": ALL_DEVICES["U8"],
        "GameConsole U8 P2屏幕": ALL_DEVICES["U8 P2屏幕"],
        "GameConsole HG36|HG3506": ALL_DEVICES["HG36/HG3506"],
        "GameConsole R36Ultra": ALL_DEVICES["R36 Ultra"],
        "GameConsole R36 Ultra v2": ALL_DEVICES["R36 Ultra v2"],
        "GameConsole G26|XGB36": ALL_DEVICES["XGB36"],
        "GameConsole R40S": ALL_DEVICES["R40S"],
        "GameConsole R39S": ALL_DEVICES["R39S"],
    },
}

# ==== 厂商名称英文翻译 ====
CATEGORY_TRANSLATIONS = {
    "稀范科技": "Xifan Tech",
    "安伯尼克": "Anbernic",
    "亿米创": "YMC",
    "迪优米": "Diium",
    "Magicx": "Magicx",
    "泡机堂": "PowKiddy",
    "漫特科技": "GAMEMT",
    "Odroid": "Odroid",
    "Game Console": "Game Console",
    "R36S克隆": "R36S Clone",
    "R36S酱油": "R36S Sauce",
    "K36系列": "K36 Series",
    "AISLPC": "AISLPC",
    "Batlexp": "Batlexp",
    "其他": "Others",
}

# ==== 设备名称英文翻译 ====
DEVICE_TRANSLATIONS = {
    # R36s克隆
    "R36S克隆 种类1带功放": "R36S Clone Type1 with Amp",
    "R36S克隆 种类1不带功放": "R36S Clone Type1 without Amp",
    "R36S克隆 种类1不带功放并反转右摇杆": "R36S Clone Type1 without Amp (Inverted R-Stick)",
    "R36S克隆 种类2带功放": "R36S Clone Type2 with Amp",
    "R36S克隆 种类2不带功放": "R36S Clone Type2 without Amp",
    "R36S克隆 种类3屏幕1": "R36S Clone Type3 Panel1",
    "R36S克隆 种类3屏幕2": "R36S Clone Type3 Panel2",
    "R36S克隆 种类4": "R36S Clone Type4",

    # R36s酱油
    "R36S酱油 屏幕1": "R36S Sauce Panel1",
    "R36S酱油 屏幕2": "R36S Sauce Panel2",
    "R36S酱油 屏幕3": "R36S Sauce Panel3",
    "R36S酱油 屏幕4": "R36S Sauce Panel4",

    # K36系列
    "K36 原始版本": "K36 Original",

    # AISLPC
    "AISLPC K36s": "AISLPC K36s",
    "AISLPC R36T": "AISLPC R36T",
    "AISLPC R36TMax": "AISLPC R36TMax",

    # 其他
    "T16Max": "T16Max",
    "U8": "U8",
    "U8 P2屏幕": "U8 P2 Screen",
    "RX6H": "RX6H",
    "HG36/HG3506": "HG36/HG3506",
    "R36 Ultra": "R36 Ultra",
    "R36 Ultra V2": "R36 Ultra V2",
    "XGB36": "XGB36",
    "R40S": "R40S",
    "R39S": "R39S",

    # GameConsole
    "Game Console R33s": "Game Console R33s",
    "Game Console R36s P1屏幕": "Game Console R36s P1 Screen",
    "Game Console R36s P2屏幕": "Game Console R36s P2 Screen",
    "Game Console R36s P3屏幕": "Game Console R36s P3 Screen",
    "Game Console R36s P4屏幕": "Game Console R36s P4 Screen",
    "Game Console R36xx": "Game Console R36xx",
    "Game Console R36H": "Game Console R36H",
    "Game Console O30S": "Game Console O30S",
    "Game Console R50S": "Game Console R50S",
    "Game Console R36sPlus": "Game Console R36sPlus",
    "Game Console R36H ProMax": "Game Console R36H ProMax",
    "Game Console R40XX": "Game Console R40XX",
    "Game Console R40XX ProMax": "Game Console R40XX ProMax",
    "Game Console R45H": "Game Console R45H",
    "Game Console R46H": "Game Console R46H",

    # 稀范科技
    "稀范科技 MyMini": "Xifan MyMini",
    "稀范科技 Mini40": "Xifan Mini40",
    "稀范科技 XF35H": "Xifan XF35H",
    "稀范科技 R36Max": "Xifan R36Max",
    "稀范科技 R36Pro": "Xifan R36Pro",
    "稀范科技 XF40H": "Xifan XF40H",
    "稀范科技 XF40V": "Xifan XF40V",
    "稀范科技 XF28": "Xifan XF28",
    "稀范科技 DC35V": "Xifan DC35V",
    "稀范科技 DC40V": "Xifan DC40V",
    "稀范科技 R36Max2": "Xifan R36Max2",

    # 安伯尼克
    "安伯尼克 RG351M": "Anbernic RG351M",
    "安伯尼克 RG351V": "Anbernic RG351V",
    "安伯尼克 RG351V P2屏幕": "Anbernic RG351V P2 Screen",
    "安伯尼克 RG351MP": "Anbernic RG351MP",

    # 亿米创
    "YMC A10mini": "YMC A10mini",
    "YMC A10mini V4": "YMC A10mini V4",

    # 迪优米
    "Diium D-R28S": "Diium D-R28S",

    # Magicx
    "Magicx Xu10": "Magicx Xu10",
    "Magicx Xu Mini M": "Magicx Xu Mini M",

    # 泡机堂
    "PowKiddy RGB10": "PowKiddy RGB10",
    "PowKiddy RGB10X": "PowKiddy RGB10X",
    "PowKiddy RGB10S": "PowKiddy RGB10S",
    "PowKiddy RGB2OS": "PowKiddy RGB2OS",
    "PowKiddy RGB10Max1": "PowKiddy RGB10Max1",

    # GAMEMT
    "GAMEMT E6": "GAMEMT E6",

    # Odroid
    "ODROID-GO Advance": "ODROID-GO Advance",
    "ODROID-GO Advance 1.1": "ODROID-GO Advance Black Edition",
    "Odroid Go Super": "Odroid Go Super",

    # Batlexp
    "Batlexp G350": "Batlexp G350",
}

def get_device_name(zh_name: str) -> str:
    """根据当前语言获取设备名称"""
    if LANG == "en":
        return DEVICE_TRANSLATIONS.get(zh_name, zh_name)
    return zh_name

def get_category_name(zh_name: str) -> str:
    """根据当前语言获取厂商分类名称"""
    if LANG == "en":
        return CATEGORY_TRANSLATIONS.get(zh_name, zh_name)
    return zh_name

# ==== 可见宽度 & UI ====
def visible_width(s: str) -> int:
    return _wlen(ANSI_RE.sub('', s))

def pad_disp(s: str, width: int) -> str:
    pad = max(width - visible_width(s), 0)
    return s + ' ' * pad

def center_disp(s: str, width: int) -> str:
    w = visible_width(s)
    if w >= width:
        return s
    left = (width - w) // 2
    right = width - w - left
    return ' ' * left + s + ' ' * right

def color(s, bg=False, bright=True, enable=True):
    if not enable:
        return s
    c = '44' if bg else '97'
    if bright and not bg:
        c = '97'
    if bg and bright:
        c = '44'
    return f'\033[{c}m{s}\033[0m'

def term_width():
    try:
        return shutil.get_terminal_size((80, 20)).columns
    except Exception:
        return 80

def print_header(title: str, *, no_color=False, ascii_border=False):
    tw = term_width()
    border_char = '#' if ascii_border else '█'
    bar = border_char * tw
    print(color(pad_disp(bar, tw), bg=True, enable=not no_color))
    print(color(center_disp(title, tw), bg=True, enable=not no_color))
    print(color(pad_disp(bar, tw), bg=True, enable=not no_color))

def render_single_column_menu(items: List[str], *, prompt=None, no_color=False, ascii_border=False):
    if prompt is None:
        prompt = t("input_number")
    for i, name in enumerate(items, 1):
        print(f"{i:>2}. {name}")
    tw = term_width()
    sep_char = '-' if ascii_border else '─'
    print(sep_char * tw)
    print(prompt)

def choose_index(count: int) -> int:
    while True:
        s = input(t("input_number")).strip()
        if s.isdigit():
            n = int(s)
            if 1 <= n <= count:
                return n - 1
        print(t("invalid_number"))

# ==== TTY 解析 ====
def _to_tty_name(v):
    if v is None:
        return None
    if isinstance(v, int):
        return f"ttyS{v % 100}"
    s = str(v).strip()
    if s.startswith("tty"):
        return s
    if s.isdigit():
        return f"ttyS{int(s) % 100}"
    return s

def _to_vt_name(v):
    if v is None:
        return None
    s = str(v).strip()
    if s.startswith("tty"):
        return s
    if s.isdigit():
        return f"tty{s}"
    return s

def _parse_tty_spec(tty_value):
    serial = vt = debug = None
    if isinstance(tty_value, dict):
        serial = _to_tty_name(tty_value.get("serial"))
        vt     = _to_vt_name(tty_value.get("vt"))
        debug  = _to_tty_name(tty_value.get("debug", tty_value.get("serial")))
    elif isinstance(tty_value, (list, tuple)):
        if len(tty_value) == 3:
            serial = _to_tty_name(tty_value[0])
            vt     = _to_vt_name(tty_value[1])
            debug  = _to_tty_name(tty_value[2])
        elif len(tty_value) == 2:
            serial = _to_tty_name(tty_value[0])
            vt     = _to_vt_name(tty_value[1])
            debug  = serial
        elif len(tty_value) == 1:
            serial = _to_tty_name(tty_value[0])
            debug  = serial
    else:
        serial = _to_tty_name(tty_value)
        debug  = serial
    return serial, vt, debug

# ==== APPEND / console 替换 ====
def _apply_tty_in_bootargs_str(bootargs: str, tty_value):
    serial_tty, vt_tty, debug_tty = _parse_tty_spec(tty_value)

    idx = 0
    console_re = re.compile(r'console=(?:/dev/)?tty[^\s,"]+(?P<speed>,\d+)?')

    def repl_console(m):
        nonlocal idx
        idx += 1
        speed = m.group("speed") or ""
        if idx == 1 and serial_tty:
            return f"console={serial_tty}{speed}"
        if idx == 2 and vt_tty:
            return f"console={vt_tty}"
        return m.group(0)

    bootargs = console_re.sub(repl_console, bootargs)

    if debug_tty:
        bootargs = re.sub(
            r'systemd\.debug_shell=(?:/dev/)?tty[^\s,"]+',
            f'systemd.debug_shell={debug_tty}',
            bootargs
        )

    return bootargs

def _apply_tty_in_append(content: str, tty_value):
    """
    在 extlinux.conf 里找到 APPEND 行，替换其中的 console= / systemd.debug_shell=
    """
    def _repl(m):
        prefix = m.group(1)  # "APPEND "
        args   = m.group(2)  # 原始参数串
        new_args = _apply_tty_in_bootargs_str(args, tty_value)
        return prefix + new_args

    return re.sub(r'^(\s*APPEND\s+)(.*)$', _repl, content, flags=re.MULTILINE)

# ==== 原子文件/目录操作 ====
def atomic_write_text(path: str, text: str):
    d = os.path.dirname(path)
    os.makedirs(d, exist_ok=True)
    with tempfile.NamedTemporaryFile('w', encoding='utf-8', newline='\n', dir=d, delete=False) as tf:
        tf.write(text)
        tmp = tf.name
    os.replace(tmp, path)

def atomic_replace_dir(src_dir: str, dst_dir: str):
    if os.path.exists(dst_dir):
        bak = dst_dir + ".bak"
        try:
            if os.path.exists(bak):
                shutil.rmtree(bak)
            os.replace(dst_dir, bak)
        except Exception:
            pass
    os.replace(src_dir, dst_dir)
    bak = dst_dir + ".bak"
    if os.path.exists(bak):
        shutil.rmtree(bak, ignore_errors=True)

# ==== 生成 extlinux.conf / overlays ====
def build_extlinux_conf(dtb_file: str, tty_value, overlay_dir: Optional[str], *, no_color=False):
    if not os.path.isdir(CONFIG_DIR):
        print(t("error_missing_config"), "→", CONFIG_DIR)
        return False

    tpath = os.path.join(CONFIG_DIR, "extlinux.conf")
    if not os.path.isfile(tpath):
        print(t("error_missing_template"), "→", tpath)
        return False

    base = _boot_write_root()
    remount = base == "/flash" and not os.environ.get("RK3326_DTB_SELECT_NO_REMOUNT")
    if remount:
        _remount_flash(True)

    ok = True
    try:
        with open(tpath, 'r', encoding='utf-8') as f:
            content = f.read()

        content = content.replace("my.dtb", dtb_file)
        content = _apply_tty_in_append(content, tty_value)

        out_path = os.path.join(base, "extlinux", "extlinux.conf")
        atomic_write_text(out_path, content)
        print(color(t("generated_extlinux"), bg=True, enable=not no_color), f"（DTB={dtb_file}）\n  → {out_path}")

        overlays_path = os.path.join(base, "overlays")

        if overlay_dir:
            src = os.path.join(CONFIG_DIR, overlay_dir)
            if not os.path.isdir(src):
                print(t("error_missing_overlays"), "→", src)
                ok = False
            else:
                tmp = os.path.join(tempfile.gettempdir(), "rk3326-dtb-select-overlays.tmp")
                if os.path.exists(tmp):
                    shutil.rmtree(tmp, ignore_errors=True)

                shutil.copytree(src, tmp)
                atomic_replace_dir(tmp, overlays_path)
                print(t("deployed_overlays"), "→", overlay_dir)
        else:
            if os.path.exists(overlays_path):
                shutil.rmtree(overlays_path, ignore_errors=True)
                print(t("deleted_overlays"), "\n  →", overlays_path)
    finally:
        if remount:
            sbin_sync = "/usr/bin/sync"
            if os.path.isfile(sbin_sync):
                subprocess.run([sbin_sync], check=False, capture_output=True)
            _remount_flash(False)

    return ok

# ==== 主逻辑 ====
def main():
    global LANG
    clear_screen()

    # 语言选择菜单
    print_header(t("title_lang_select"), no_color=False)
    print(f"1. {t('lang_zh')}")
    print(f"2. {t('lang_en')}")
    print("────────────────────────────────────────────")
    lang_choice = input(t("input_number")).strip()

    if lang_choice == "2":
        LANG = "en"

    while True:
        clear_screen()
        print_header(t("title_select_vendor"), no_color=False)
        categories = list(CATEGORIES.keys())
        for i, cat in enumerate(categories, 1):
            count = len(CATEGORIES[cat])
            display_cat = get_category_name(cat)
            print(f"{i:2}. {display_cat}（{t('devices_count', count)}）")
        print(f"{len(categories) + 1:2}. {t('exit')}")
        print("────────────────────────────────────────────")
        choice = input(t("input_number")).strip()

        if not choice.isdigit():
            continue
        choice = int(choice)
        if choice == len(categories) + 1:
            clear_screen()
            print_header(t("thank_you"), no_color=False)
            break
        if not (1 <= choice <= len(categories)):
            continue

        selected_cat = categories[choice - 1]

        # 二级菜单
        while True:
            clear_screen()
            display_cat = get_category_name(selected_cat)
            print_header(f"{display_cat}", no_color=False)
            models = list(CATEGORIES[selected_cat].keys())

            for i, name in enumerate(models, 1):
                display_name = get_device_name(name)
                print(f"{i:2}. {display_name}")
            print(f"{len(models) + 1:2}. {t('back')}")
            print("────────────────────────────────────────────")
            sub_choice = input(t("input_number")).strip()

            if not sub_choice.isdigit():
                continue
            sub_choice = int(sub_choice)
            if sub_choice == len(models) + 1:
                break
            if not (1 <= sub_choice <= len(models)):
                continue

            selected_name = models[sub_choice - 1]
            entry = CATEGORIES[selected_cat][selected_name]
            tty_value = entry.tty

            clear_screen()
            print_header(t("applying_config"), no_color=False)
            display_name = get_device_name(selected_name)
            print(f"{t('model')}：{display_name}\n")
            s, v, d = _parse_tty_spec(tty_value)
            print(f"  DTB     = {entry.dtb}")
            print(f"  {t('serial')}  = {s or t('no_change')}")
            print(f"  {t('vt')}      = {v or t('no_change')}")
            print(f"  {t('debug')}   = {d or t('no_change')}")
            if entry.overlay:
                print(f"  {t('overlay')} = {entry.overlay}")

            ok = build_extlinux_conf(entry.dtb, tty_value, entry.overlay)
            print("\n" + (t("config_complete") if ok else t("config_failed")))

            wait_anykey(t("press_any_key"))
            break

if __name__ == "__main__":
    main()
