#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)
import os
import re
import shutil
import subprocess
import sys
import tempfile
from typing import List, Tuple

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

ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")

if getattr(sys, "frozen", False):
    ROOT_DIR = os.path.dirname(sys.executable)
else:
    ROOT_DIR = os.path.dirname(os.path.abspath(__file__))


def _boot_write_root() -> str:
    """ROCKNIX: 启动 FAT 挂载在 /flash；无则回退到脚本目录（本地测试）。"""
    b = os.environ.get("ROCKNIX_BOOT", "/flash")
    if os.path.isdir(b):
        return b
    return ROOT_DIR


def _remount_flash(rw: bool) -> None:
    if os.environ.get("RK356X_DTB_SELECT_NO_REMOUNT"):
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


def clear_screen():
    os.system("cls" if os.name == "nt" else "clear")


def wait_anykey(msg="按任意键继续..."):
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


def visible_width(s: str) -> int:
    return _wlen(ANSI_RE.sub("", s))


def pad_disp(s: str, width: int) -> str:
    pad = max(width - visible_width(s), 0)
    return s + " " * pad


def center_disp(s: str, width: int) -> str:
    w = visible_width(s)
    if w >= width:
        return s
    left = (width - w) // 2
    right = width - w - left
    return " " * left + s + " " * right


def color(s, bg=False, bright=True, enable=True):
    if not enable:
        return s
    c = "44" if bg else "97"
    if bright and not bg:
        c = "97"
    if bg and bright:
        c = "44"
    return f"\033[{c}m{s}\033[0m"


def term_width():
    try:
        return shutil.get_terminal_size((80, 20)).columns
    except Exception:
        return 80


def print_header(title: str, *, no_color=False, ascii_border=False):
    tw = term_width()
    border_char = "#" if ascii_border else "█"
    bar = border_char * tw
    print(color(pad_disp(bar, tw), bg=True, enable=not no_color))
    print(color(center_disp(title, tw), bg=True, enable=not no_color))
    print(color(pad_disp(bar, tw), bg=True, enable=not no_color))


# RK356X：与 config.xml 中 <file> 条目一致
ALL_DEVICES: List[Tuple[str, str]] = [
    ("AISLPC RG52 Mini", "device_trees/rk3562-rg52mini.dtb"),
    ("AISLPC RG52 Mini v1 (RK915 WiFi)", "device_trees/rk3562-rg52mini-v1.dtb"),
    ("AISLPC RG43H Pro", "device_trees/rk3562-rg43h.dtb"),
    ("AISLPC RG43H Pro v1 (RK915 WiFi)", "device_trees/rk3562-rg43h-v1.dtb"),
    ("AISLPC RG43V Pro", "device_trees/rk3562-rg43v.dtb"),
    ("AISLPC RG43V Pro v1 (RK915 WiFi)", "device_trees/rk3562-rg43v-v1.dtb"),
]


def atomic_write_text(path: str, text: str):
    d = os.path.dirname(path)
    os.makedirs(d, exist_ok=True)
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", newline="\n", dir=d, delete=False
    ) as tf:
        tf.write(text)
        tmp = tf.name
    os.replace(tmp, path)


def normalize_fdt_path(dtb_rel: str) -> str:
    p = dtb_rel.strip()
    if not p.startswith("/"):
        p = "/" + p
    return p


def patch_fdt_line(content: str, dtb_rel: str) -> str:
    """将首条未注释的 `FDT …` 行替换为新的设备树路径（保留行首缩进）。"""
    path = normalize_fdt_path(dtb_rel)
    patched = False
    out: List[str] = []
    for line in content.splitlines(True):
        nl = "\n" if line.endswith("\n") else ""
        core = line[:-1] if line.endswith("\n") else line
        if not patched and not re.match(r"^\s*#", core):
            m = re.match(r"^(\s*)FDT\s+\S", core)
            if m:
                out.append(f"{m.group(1)}FDT {path}{nl}")
                patched = True
                continue
        out.append(line)
    if not patched:
        raise ValueError("未找到可用的 FDT 行。")
    return "".join(out)


def apply_fdt_to_extlinux(dtb_rel: str, *, no_color=False) -> bool:
    base = _boot_write_root()
    remount = base == "/flash" and not os.environ.get("RK356X_DTB_SELECT_NO_REMOUNT")
    if remount:
        _remount_flash(True)
    path = os.path.join(base, "extlinux", "extlinux.conf")
    try:
        if not os.path.isfile(path):
            print(
                color("错误：找不到 extlinux.conf", bg=True, enable=not no_color),
                f"→ {path}",
            )
            return False
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        try:
            new_content = patch_fdt_line(content, dtb_rel)
        except ValueError as e:
            print(color(str(e), bg=True, enable=not no_color))
            return False
        atomic_write_text(path, new_content)
        print(
            color("已更新 extlinux.conf", bg=True, enable=not no_color),
            f"（FDT={normalize_fdt_path(dtb_rel)}）\n  → {path}",
        )
    finally:
        if remount:
            sbin_sync = "/usr/bin/sync"
            if os.path.isfile(sbin_sync):
                subprocess.run([sbin_sync], check=False, capture_output=True)
            _remount_flash(False)
    return True


def main():
    clear_screen()
    items = ALL_DEVICES
    while True:
        clear_screen()
        print_header("RK356X — 请选择机型", no_color=False)
        for i, (name, _) in enumerate(items, 1):
            print(f"{i:>2}. {name}")
        print(f"{len(items) + 1:>2}. 退出程序")
        print("────────────────────────────────────────────")
        choice = input("输入编号：").strip()
        if not choice.isdigit():
            continue
        n = int(choice)
        if n == len(items) + 1:
            clear_screen()
            print_header("感谢使用，再见！", no_color=False)
            break
        if not (1 <= n <= len(items)):
            continue

        name, dtb = items[n - 1]
        clear_screen()
        print_header("正在应用配置", no_color=False)
        print(f"机型：{name}\n")
        print(f"  DTB = {dtb}")

        ok = apply_fdt_to_extlinux(dtb)
        print("\n" + ("配置完成！" if ok else "配置失败。"))
        wait_anykey("\n按任意键返回机型列表...")


if __name__ == "__main__":
    main()
