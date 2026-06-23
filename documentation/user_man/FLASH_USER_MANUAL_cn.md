# Flash 模拟器（Ruffle）— 玩家说明（中文）

英文版请参阅 [`FLASH_USER_MANUAL_en.md`](FLASH_USER_MANUAL_en.md)。

本说明介绍如何在 AURKNIX / 本改版 ROCKNIX 中运行 **Adobe Flash（`.swf`）** 游戏。当前由独立程序 **`ruffle-sa`**（前端 **`sdl2test-rocknix`**）提供，在 **RK3326** 机型镜像中可用。

---

## 游戏放哪里

将 `.swf` 文件放入 Flash 系统扫描目录：

```text
/storage/roms/flash/
```

EmulationStation 中系统名一般为 **Flash**。支持扩展名 **`.swf` / `.SWF`**。

---

## 运行时的文件位置

启动脚本 **`start_ruffle.sh`** 会从用户配置目录运行模拟器，并使用 **`gptokeyb`** 做手柄映射：

| 路径 | 说明 |
|------|------|
| `/storage/.config/ruffle/sdl2test-rocknix` | 实际运行的模拟器二进制 |
| `/storage/.config/ruffle/ruffle.gptk` | 系统级手柄映射（`gptokeyb`） |
| `/usr/config/ruffle/` | 镜像内置默认文件；升级后若需同步新版本，可将此目录内容复制到 `/storage/.config/ruffle/` |

若首次运行提示找不到程序或配置，请手动执行：

```bash
mkdir -p /storage/.config/ruffle
cp -a /usr/config/ruffle/* /storage/.config/ruffle/
```

---

## 系统级手柄映射（`ruffle.gptk`）

在模拟器接收输入之前，**`gptokeyb`** 会先把手柄信号转换成键盘或鼠标事件。

当前默认 **`ruffle.gptk`** 的策略是：

- **左摇杆** → 鼠标移动（`mouse_movement_*`）
- **其余按键** → 不映射（设为 `\`），避免误触

如需调整鼠标灵敏度，可编辑 **`/storage/.config/ruffle/ruffle.gptk`** 中的 **`mouse_scale`**、**`mouse_delay`**、**`deadzone_triggers`**。修改后重新启动游戏即可生效。

---

## 模拟器内按键（`sdl2test-rocknix`）

以下映射由模拟器自身处理（与 **`ruffle.gptk`** 叠加）。手柄键名以常见 Xbox 布局为准；**Select** 在部分设备上对应 **Back**。

### 默认键盘映射

| 手柄按键 | 键盘按键 |
|----------|----------|
| A | S |
| B | A |
| X | J |
| Y | U |
| L | A |
| R | D |
| L2 | W |
| R2 | S |
| L3 | O |
| R3 | L |
| Start | I |
| Select | K |

### 组合键

| 组合键 | 功能 |
|--------|------|
| Select + X | 切换 **鼠标模式** / **键盘模式** |
| Select + A | 切换十字键为 **WASD** 方向（仅 `sdl2test-rocknix`） |
| Guide | 退出游戏 |

### 鼠标模式

游戏启动后**默认进入鼠标模式**。

在鼠标模式下：

- **十字键**控制鼠标移动
- **Y** 键作为鼠标左键点击
- **L2 / R2** 仍按上表 keymap 映射为键盘按键

在键盘模式下，手柄按键按 keymap 映射为键盘输入。

> **提示**：系统级 **`ruffle.gptk`** 已把左摇杆映射为鼠标；模拟器内仍可用十字键移动指针。若感觉指针过快或过慢，可同时调整 **`ruffle.gptk`** 的 **`mouse_scale`** 与游戏内操作习惯。

---

## 按游戏自定义按键（`.cfg`）

可为单个 SWF 覆盖默认 keymap。以 SWF 文件名为 `{游戏名}`（不含扩展名），按以下顺序查找：

1. **与 SWF 同目录**：`{游戏名}.cfg`（优先）
2. **同目录下的 `keymap` 文件夹**：`keymap/{游戏名}.cfg`

示例：

```text
/storage/roms/flash/
├── game.swf
├── game.cfg          # 优先使用
└── keymap/
    └── game.cfg      # 同目录不存在时使用
```

### 映射文件格式

每行一条映射，格式为 `按钮名=键名`，`#` 开头为注释：

```ini
# 这是注释
A=S
B=A
X=J
Y=U
L=A
R=D
L2=W
R2=S
L3=O
R3=L
Start=I
Select=K
```

### 支持的按钮名

- `A`, `B`, `X`, `Y`
- `L`, `R`
- `L2`, `R2`
- `L3`, `R3`
- `Start`, `Select`

### 支持的键名

- 字母：`A` – `Z`
- 数字：`Num0` – `Num9`
- 方向键：`Up`, `Down`, `Left`, `Right`
- 功能键：`F1` – `F12`
- 特殊键：`Space`, `Return`, `Escape`, `Tab`, `Backspace`, `Delete`, `Insert`, `Home`, `End`, `PageUp`, `PageDown`

---

## 常见问题

| 现象 | 建议 |
|------|------|
| 前端没有 Flash 系统 | 确认使用的是含 **ruffle-sa** 的 **RK3326** 镜像，且 `/storage/roms/flash/` 下已有 `.swf` |
| 启动报错找不到二进制 | 按上文将 `/usr/config/ruffle/` 复制到 `/storage/.config/ruffle/` |
| 鼠标不好用 | 先试 **Select + X** 切换模式；再调整 **`ruffle.gptk`** 的 **`mouse_scale`** |
| 某款 Flash 游戏键位不对 | 在同目录添加 **`{游戏名}.cfg`** 覆盖映射 |

---

上游模拟器项目：[ruffle-aurknix](https://github.com/AveyondFly/ruffle-aurknix)
