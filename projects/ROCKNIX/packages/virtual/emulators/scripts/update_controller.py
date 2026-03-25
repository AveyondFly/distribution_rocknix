#!/usr/bin/env python3
"""
控制器配置更新脚本
将 es_input.cfg 中的控制器配置转换为 SDL GameControllerDB 格式
"""

import os
import sys
import stat
import shutil
import subprocess
import tempfile
import xml.etree.ElementTree as ET
from datetime import datetime
from pathlib import Path

# ======================== 配置区 ========================
SCRIPT_DIR = Path(__file__).parent.resolve()
XML_FILE = Path("/storage/.config/emulationstation/es_input.cfg")
SDL_DB_FILE = Path("/storage/.config/SDL-GameControllerDB/gamecontrollerdb.txt")
JOYGUID_BIN = Path("/usr/bin/joyguid")

# ===================== 日志函数 =====================
class Color:
    SUCCESS = "\033[32m"
    ERROR = "\033[31m"
    WARNING = "\033[33m"
    INFO = "\033[34m"
    RESET = "\033[0m"

def log(level: str, message: str) -> None:
    """带颜色输出的日志函数"""
    color = getattr(Color, level, Color.RESET)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"{color}[{timestamp}] {level}: {message}{Color.RESET}")

# ===================== XML 转 SDL 转换 =====================
XML_TO_SDL_MAPPING = {
    # 基础按键
    "a": "a",
    "b": "b",
    "x": "x",
    "y": "y",
    "start": "start",
    "select": "back",
    # 肩键
    "leftshoulder": "leftshoulder",
    "rightshoulder": "rightshoulder",
    "pageup": "leftshoulder",
    "pagedown": "rightshoulder",
    # 扳机
    "lefttrigger": "lefttrigger",
    "righttrigger": "righttrigger",
    "l2": "lefttrigger",
    "r2": "righttrigger",
    # 摇杆按下
    "leftstick": "leftstick",
    "rightstick": "rightstick",
    "leftthumb": "leftstick",
    "rightthumb": "rightstick",
    "l3": "leftstick",
    "r3": "rightstick",
    # 方向键
    "up": "dpup",
    "down": "dpdown",
    "left": "dpleft",
    "right": "dpright",
    # 热键 - 特殊处理
    "hotkeyenable": "guide",
    "hotkey": "guide",
}

AXIS_MAPPING = {
    "leftanalogleft": "leftx",
    "leftanalogright": "leftx",
    "leftanalogup": "lefty",
    "leftanalogdown": "lefty",
    "rightanalogleft": "rightx",
    "rightanalogright": "rightx",
    "rightanalogup": "righty",
    "rightanalogdown": "righty",
    "joystick1left": "leftx",
    "joystick1up": "lefty",
    "joystick2left": "rightx",
    "joystick2up": "righty",
}

TRIGGER_AXIS_MAPPING = {
    "lefttrigger": "lefttrigger",
    "righttrigger": "righttrigger",
    "l2": "lefttrigger",
    "r2": "righttrigger",
}

def convert_xml_to_sdl(xml_file: Path, target_guid: str) -> str:
    """将 XML 配置转换为 SDL 格式"""
    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
    except Exception as e:
        log("ERROR", f"解析 XML 文件失败: {e}")
        sys.exit(1)

    target_config = None
    for config in root.findall("inputConfig"):
        if config.get("deviceGUID") == target_guid:
            target_config = config
            break

    if not target_config:
        log("ERROR", f"未找到 GUID {target_guid} 的配置")
        sys.exit(1)

    sdl_entries = []
    axis_map = {}
    used_button_ids = set()
    hotkey_inputs = []

    # 第一遍：处理所有非 hotkey 的输入
    for input_elem in target_config.findall("input"):
        xml_name = input_elem.get("name")
        input_type = input_elem.get("type")
        input_id = input_elem.get("id")
        sdl_name = XML_TO_SDL_MAPPING.get(xml_name)

        # 跳过 hotkey，稍后处理
        if xml_name in ("hotkeyenable", "hotkey"):
            hotkey_inputs.append(input_elem)
            continue

        if input_type == "axis":
            value = input_elem.get("value")
            invert = False
            if value is not None:
                value = int(value)
                invert_conditions = {
                    "leftanalogup": value > 0,
                    "leftanalogdown": value < 0,
                    "leftanalogleft": value > 0,
                    "leftanalogright": value < 0,
                    "rightanalogup": value > 0,
                    "rightanalogdown": value < 0,
                    "rightanalogleft": value > 0,
                    "rightanalogright": value < 0,
                    "joystick1up": value > 0,
                    "joystick1left": value > 0,
                    "joystick2up": value > 0,
                    "joystick2left": value > 0,
                }
                invert = invert_conditions.get(xml_name, False)

            # 处理扳机轴
            if xml_name in TRIGGER_AXIS_MAPPING:
                trigger_name = TRIGGER_AXIS_MAPPING[xml_name]
                if trigger_name not in axis_map:
                    entry = f"{trigger_name}:a{input_id}+"
                    sdl_entries.append(entry)
                    axis_map[trigger_name] = True
                continue

            # 处理摇杆轴
            axis_name = AXIS_MAPPING.get(xml_name)
            if axis_name and axis_name not in axis_map:
                entry = f"{axis_name}:a{input_id}"
                if invert:
                    entry += "~"
                sdl_entries.append(entry)
                axis_map[axis_name] = True
            continue

        if input_type == "button":
            if sdl_name and input_id not in used_button_ids:
                entry = f"{sdl_name}:b{input_id}"
                sdl_entries.append(entry)
                used_button_ids.add(input_id)
            continue

        if input_type == "hat" and sdl_name:
            hat_value = input_elem.get("value")
            if hat_value:
                entry = f"{sdl_name}:h{input_id}.{hat_value}"
                sdl_entries.append(entry)
            continue

    # 第二遍：处理 hotkey（只有按钮 ID 不冲突时才添加 guide）
    for input_elem in hotkey_inputs:
        input_type = input_elem.get("type")
        input_id = input_elem.get("id")

        if input_type == "button" and input_id not in used_button_ids:
            entry = f"guide:b{input_id}"
            sdl_entries.append(entry)
            used_button_ids.add(input_id)

    device_name = target_config.get("deviceName", "Unknown Controller")
    return f"{target_guid},{device_name},platform:Linux,{','.join(sdl_entries)},"

# ===================== 工具函数 =====================
def check_joyguid() -> None:
    """检查 joyguid 可执行文件"""
    log("INFO", "检查 joyguid 可执行文件")

    if not JOYGUID_BIN.exists():
        log("ERROR", f"找不到 joyguid 可执行文件: {JOYGUID_BIN}")
        log("ERROR", "请确认 joyguid 文件是否存在于脚本同级目录")
        sys.exit(1)

    if not os.access(JOYGUID_BIN, os.X_OK):
        log("WARNING", "缺少执行权限，尝试修复...")
        try:
            JOYGUID_BIN.chmod(0o755)
            log("SUCCESS", "权限修复成功")
        except Exception:
            log("ERROR", "权限修复失败，请手动执行: chmod +x joyguid")
            sys.exit(1)

def get_guid() -> str:
    """获取控制器 GUID（带重试机制）"""
    max_retries = 3
    for retry in range(1, max_retries + 1):
        log("INFO", f"尝试获取 GUID (第{retry}次)")
        try:
            result = subprocess.run(
                [str(JOYGUID_BIN)],
                capture_output=True,
                text=True,
                timeout=5
            )
            guid = result.stdout.strip()
            if len(guid) == 32:
                log("SUCCESS", f"GUID 获取成功: {guid[:8]}****")
                return guid
        except subprocess.TimeoutExpired:
            log("WARNING", "获取 GUID 超时")
        except Exception as e:
            log("WARNING", f"获取 GUID 失败: {e}")

        if retry < max_retries:
            import time
            time.sleep(1)

    log("ERROR", "GUID 获取失败，请检查控制器连接")
    sys.exit(1)

def handle_symlink(file_path: Path) -> None:
    """处理符号链接"""
    log("INFO", f"检查文件链接状态: {file_path}")

    if file_path.is_symlink():
        log("WARNING", f"检测到符号链接: {file_path}")
        target_file = file_path.resolve()

        # 检查目标文件是否只读
        if not os.access(target_file, os.W_OK):
            log("WARNING", f"检测到只读文件: {target_file}")

            # 备份原始链接
            bak_file = Path(f"{file_path}_bak_{datetime.now().strftime('%Y%m%d%H%M%S')}")
            log("INFO", f"创建备份: {bak_file}")
            shutil.copy2(file_path, bak_file)

            # 替换为可写副本
            log("INFO", "创建可写副本...")
            tmp_file = Path(f"{file_path}.tmp")
            shutil.copy2(target_file, tmp_file)
            tmp_file.chmod(0o644)
            tmp_file.replace(file_path)

            if file_path.is_symlink():
                log("ERROR", "符号链接未成功替换")
                sys.exit(1)
            log("SUCCESS", "已转换为可写普通文件")
        else:
            log("INFO", "目标文件可写，保持链接状态")
    elif not file_path.exists():
        log("WARNING", "文件不存在，创建初始配置")
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.touch()

def update_sdl_db(sdl_file: Path, guid: str, new_entry: str) -> None:
    """更新 SDL 数据库文件"""
    log("INFO", "更新数据库条目...")

    lines = []
    found = False

    if sdl_file.exists():
        with open(sdl_file, 'r') as f:
            for line in f:
                if line.startswith(f"{guid},"):
                    lines.append(new_entry + '\n')
                    found = True
                else:
                    lines.append(line)

    if not found:
        lines.insert(0, new_entry + '\n')
        log("INFO", "GUID 不存在，添加新条目到文件开头")
    else:
        log("INFO", "GUID 已存在，更新条目")

    with open(sdl_file, 'w') as f:
        f.writelines(lines)

    # 设置权限
    sdl_file.chmod(0o777)

# ===================== 主函数 =====================
def main() -> None:
    log("INFO", "====== 开始控制器配置更新流程 ======")

    # 初始化检查
    check_joyguid()
    handle_symlink(SDL_DB_FILE)

    # 获取 GUID
    guid = get_guid()

    # 生成 SDL 条目
    log("INFO", "生成 SDL 配置条目...")
    if not XML_FILE.exists():
        log("ERROR", f"XML 文件不存在: {XML_FILE}")
        sys.exit(1)

    new_entry = convert_xml_to_sdl(XML_FILE, guid)
    log("INFO", f"生成条目: {new_entry}")

    # 更新数据库
    update_sdl_db(SDL_DB_FILE, guid, new_entry)

    log("SUCCESS", "====== 更新成功完成 ======")
    log("INFO", "修改后条目预览:")

    # 显示更新后的条目
    with open(SDL_DB_FILE, 'r') as f:
        for line in f:
            if line.startswith(f"{guid},"):
                print(line.strip())
                break

if __name__ == "__main__":
    main()
