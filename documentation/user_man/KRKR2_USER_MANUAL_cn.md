# Kirikiri2（KrKr2）用户指南

英文版请参阅 [`KRKR2_USER_MANUAL_en.md`](KRKR2_USER_MANUAL_en.md)。

本文面向通过前端直接启动 **Kirikiri2 / KrKr2** 游戏的用户。前端会自动调用 `start_krkr2.sh`，用户通常只需关注 **游戏目录组织、字体文件、`.kr2` 启动规则与手柄键位**。

---

## 游戏放哪里

将游戏放入：

```text
/storage/roms/krkr2/
```

EmulationStation 中系统名一般为 **Kirikiri2**。前端只扫描 **`.kr2` / `.KR2`** 作为启动入口（不直接扫描 `.xp3`）。

推荐每个游戏使用独立子目录，例如：

```text
/storage/roms/krkr2/MyGame/
├── MyGame.kr2
├── data.xp3          # 或与 .kr2 同名的 MyGame.xp3
├── plugin.xp3        # 可选
├── default.ttf       # 推荐：游戏字体
└── savedata/         # 运行后可能自动生成
```

---

## `.kr2` 启动规则

前端启动的是 **`.kr2` 启动桩**。引擎按以下规则解析实际要打开的 `.xp3`：

| 情况 | 行为 | 示例 |
| --- | --- | --- |
| `name.kr2` **内指定了** xp3 文件名 | 读取该内容，启动同目录下对应的 xp3 | `MyGame.kr2` 内容为 `data.xp3` → 启动 `MyGame/data.xp3` |
| `name.kr2` **未指定**（空文件或未写有效 xp3） | 隐式使用同名 `name.xp3` | `MyGame.kr2` 未指定 → 启动 `MyGame/MyGame.xp3` |

说明：

- `.kr2` 一般是纯文本，内容写一行相对路径即可，例如：`data.xp3`。
- 指定的路径相对于 **该 `.kr2` 所在目录**。
- 存档等数据通常写在游戏目录下的 `savedata/`（以引擎实际行为为准）。

---

## 字体文件

引擎会从**当前游戏目录**加载字体：

| 文件 | 是否推荐 | 说明 |
| --- | --- | --- |
| `<游戏目录>/default.ttf` | 推荐 | 游戏自带 / 自行放置的 TrueType 字体。中文或特殊字形游戏建议放一份兼容字体，命名为 `default.ttf`。 |

若缺少合适字体，界面文字可能显示异常、方块或缺字。请把可用的 `default.ttf` 放到与 `.kr2` 相同的游戏目录中。

---

## 手柄映射

手柄按键通过 `gptokeyb` 映射。当前使用的配置文件是：

```text
/storage/.config/krkr2/krkr2.gptk
```

镜像内置默认文件位于 `/usr/config/krkr2/`；首次运行时，启动脚本会尽量同步到 `/storage/.config/krkr2/`。

| 手柄输入 | KrKr2 效果 |
| --- | --- |
| 十字键 / 左摇杆 | 鼠标移动 |
| A | 鼠标左键 |
| B | 鼠标右键 |
| X | `Space`（空格） |
| Y | `Esc` |
| Start | `Enter` |
| Back（Select） | `Esc` |
| Guide | `Enter` |
| L1 | `Home` |
| R1 | `End` |
| L2 / R2 / L3 / R3 / 右摇杆 | 未映射 |

鼠标相关可调参数（编辑 `krkr2.gptk`）：

| 参数 | 作用 |
| --- | --- |
| `mouse_scale` | 鼠标移动灵敏度（默认 `4096`） |
| `mouse_delay` | 鼠标移动间隔（默认 `16`） |
| `deadzone_x` / `deadzone_y` | 摇杆死区 |
| `deadzone_triggers` | 扳机死区 |

修改 `krkr2.gptk` 后，重新启动游戏即可生效。

---

## 运行时配置位置

| 路径 | 说明 |
| --- | --- |
| `/usr/bin/start_krkr2.sh` | 前端调用的启动脚本 |
| `/usr/config/krkr2/` | 镜像内置二进制与默认 `krkr2.gptk` |
| `/storage/.config/krkr2/` | 用户侧配置与可执行文件副本 |
| `/storage/.config/krkr2/log.txt` | 最近一次运行日志（便于排查启动路径、字体加载等问题） |

---

## 说明

- **内存要求较高**：Kirikiri2 游戏（尤其是较大资源包）占用内存偏多。在 **约 1GB 内存** 的设备上，部分游戏可能因内存不足而无法启动或运行中崩溃。若出现异常退出，可先关闭其他后台程序，或换用内存更大的设备再试。
- 前端入口扩展名仅为 **`.kr2` / `.KR2`**；`.xp3` 作为资源包由 `.kr2` 规则引用，不会出现在系统游戏列表中。
- 多数 Kirikiri2 游戏以鼠标操作为主，因此默认映射以鼠标移动与左右键为核心。
- 若启动失败，可先查看 `/storage/.config/krkr2/log.txt` 中的路径解析与字体加载信息。
