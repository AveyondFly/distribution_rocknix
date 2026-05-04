# 本改版 ROCKNIX 用户手册（中文）

英文版请参阅 [`USER_MANUAL_en.md`](USER_MANUAL_en.md)。

本手册面向[**distribution_rocknix**](https://github.com/AveyondFly/distribution_rocknix) 用户撰写（[**Issues**](https://github.com/AveyondFly/distribution_rocknix/issues)、[**Pull requests**](https://github.com/AveyondFly/distribution_rocknix/pulls) 均在该仓库办理），说明其与 **ROCKNIX 主线**的主要差异：**额外模拟器**、**额外机型支持**、**独立模拟器增强说明**，以及**首次启动时对存储分区的可调布局（为 exFAT 游戏分区留出空间）**。

更通用的 ROCKNIX 使用方式（Wi‑Fi、蓝牙、更新、RetroArch、EmulationStation 等）仍以官方文档与社区为准；本文只补充本改版特有的内容。**刷写镜像请先对照 §3 机型表，并从 §1 所列地址获取最新构建（GitHub 或微信公众号分流）。**

---

## 1. 关于本改版与主线的关系

这是基于 ROCKNIX 的**非官方 Fork**，目标是：

- 在主线以外的更多掌机／盒子上提供可用镜像；
- 集成主线当前未附带的一批模拟器与工具；
- 对 **DraStic 增强版（drastic_adv-sa）** 与 **J2ME（free-j2me 独立前端）** 等组件做本地化说明与可调项说明。

如遇问题请先确认：**设备型号、镜像文件名、是否在首次启动前配置过分区保留文件**。刷机有风险，请先备份 SD 卡或 eMMC 上的重要数据。

**本改版工程（源码、Issue、Pull Request）：** [**https://github.com/AveyondFly/distribution_rocknix**](https://github.com/AveyondFly/distribution_rocknix)

- **反馈缺陷与功能请求**（Issue）：[**https://github.com/AveyondFly/distribution_rocknix/issues**](https://github.com/AveyondFly/distribution_rocknix/issues)
- **提交代码与文档改动**（Pull Request）：[**https://github.com/AveyondFly/distribution_rocknix/pulls**](https://github.com/AveyondFly/distribution_rocknix/pulls)

**最新镜像下载（GitHub Releases，Nightly）：** [**https://github.com/AveyondFly/distribution-nightly/releases**](https://github.com/AveyondFly/distribution-nightly/releases)

若你所在网络 **访问 GitHub 较慢或不稳定**，可关注微信公众号 **「k源机」**，按号内指引获取 **百度网盘等分流**下载地址（内容与发布节奏以公众号说明为准）。

与 **ROCKNIX 主线**相关且非本改版特有的问题，请通过你通常使用的 ROCKNIX 支持渠道或社区寻求说明。

---

## 2. 主线相比：额外自带的模拟器

下列组件在本改版中额外提供（RetroArch libretro **与**独立程序均有；前端里显示的名称以你镜像为准）。

| 组件 | 说明 |
|------|------|
| **gam4980-lr** | BBK 4980 等电子辞典游戏兼容（BBK 4980） |
| **hbmame-lr** | HBMAME，家用机类 MAME 向 libretro |
| **onscripter-lr** | ONScripter 脚本引擎（文字冒险等） |
| **PyMO / cpymo** | PyMO AVG 引擎的 C 实现相关支持 |
| **free-j2me** | J2ME SDL2 独立前端 |
| **OpenBOR-ff**（**sa**，独立程序） | 与主线自带 **OpenBOR**（同源独立引擎）并列；可执行文件一般为 `OpenBOR-ff`，**不走 RetroArch** |
| **drastic_adv-sa** | 增强版独立 NDS 模拟器（DraStic 衍生／定制） |
| **fbneoplus-lr** | FBNeo Plus libretro |

### 2.1 使用说明补充

**OpenBOR 与 OpenBOR-ff**

- **`OpenBOR-ff` 是独立的 OpenBOR 引擎（standalone / sa），由 EmulationStation 等前端直接拉起，并不像 `*-lr` 那样通过 RetroArch 加载。** 镜像里通常会同时带有默认的 **OpenBOR** 与本改版的 **OpenBOR-ff** 两个入口。
- 部分游戏或打包会标明需 **lns／LNS 版本**管线（或与默认 **OpenBOR** 引擎行为不兼容的变体）。**游玩这类资源时，请在前端的 OpenBOR 平台下选用 `OpenBOR-ff` 作为启动模拟器**（例如在 EmulationStation 的「游戏高级选项／高级系统设置」中为单款游戏或整平台指定 **OpenBOR-ff**，具体菜单措辞因主题而异）；**请勿在 RetroArch 里查找「OpenBOR-ff」核心**，本程序并非 libretro。
- ROM 打包方式、目录结构与版权仍须遵守上游与游戏作者要求。

**fbneoplus-lr 与 PGM2 插卡**

- **`fbneoplus-lr` 在 PGM2（PolyGame Master 2）类游戏中支持插卡／换卡相关功能**：可在运行时按核心或 RetroArch 说明操作卡带切换（具体热键以前端自带的 **Core 文档**／**快捷键说明**为准，不同主题可能显示的菜单名称略有差异）。
- 若某项插卡特性无响应，确认当前加载的核心为 **`FBNeo Plus`**（`fbneoplus-lr`），且 ROM 套装与 PGM2 BIOS 摆放路径符合该平台约定。

ROM、BIOS 与版权合规由用户自行负责；请将合法拥有的游戏文件放到系统约定的目录（通常为 `/storage/roms/bios/` 下对应文件夹，或通过 Samba/USB 挂载访问）。

---

## 3. 额外支持的设备（相对主线）

以下为本改版相对 **ROCKNIX 主线** **额外适配**的设备清单（随版本迭代可能与发布页微调，请以你下载镜像时的说明文件名为准）。刷写前务必确认：**SoC／品牌／具体型号／屏幕与功放硬件版本（若有）** 与镜像文档一致。

### 3.1 RK3326（统一镜像）

**RK3326 当前仅提供这一套统一镜像**，下列 **全部机型均由该镜像覆盖**——刷入后按设备 quirks／首次引导选择或自动识别机型即可；若你的机器外观名称在表中但与当前硬件改版不兼容，请到社区核对 PCB／屏幕批次。

| 品牌 | 型号 |
|------|------|
| Anbernic | RG351M, RG351V |
| BatleXP | G350 |
| Clone R36s | Type 2（有／无功放）, Type 3, Type 4, Sauce V03/V04 |
| Diium | D007, D-R28S |
| GameConsole | HG36, K36, K36S, R33S, R36S, R36S Plus, R36T, R36TMax, R36Ultra, R36XXProMax, R40XX, R40XX ProMax, R45H, R46H, R50S, RX6H, T16Max, U8, U8-V2, XGB36 |
| Gameforce | CHI |
| GameMT | E6 |
| Generic | EE Clone |
| MagicX | XU10, XU Mini M |
| ODROID-GO | Advance, Advance Black Edition, Super |
| PortableGame | A10Mini, A10Mini-V2 |
| Powkiddy | RGB10, RGB10X, RGB20S |
| XiFan | DC35V, DC40V, Mini40, MyMini, R36Max, R36Max2, R36Pro, XF28, XF35H, XF40H, XF40V |

### 3.2 RK3566（机型专用镜像，非与 3326 共用）

**RK3566 与 RK3326 镜像相互独立：** 表中每一类设备通常对应 **单独的镜像文件名／构建**，请在下发站点选择 **与你的具体型号完全一致** 的条目下载，不要用 RK3326 包刷 RK3566 机。

| 品牌 | 型号 |
|------|------|
| GameMT | E5P, E6P |
| MiniLong | Pocket1 |
| Powkiddy | x35H, x35S |

### 3.3 S905L3A Android 电视盒

| 品牌 | 型号 |
|------|------|
| CM311 | CM311 |
| E900V | E900V22C |
| M401 | M401A |

### 3.4 RK3562（WIP，预期与可用性以降低预期为准）

| 品牌 | 型号 |
|------|------|
| RO520C | LP3X-V10 |

### 3.5 RK3326S（Linux 6.6 BSP 内核支线）

该支线机型列表尚在扩展中；若发布页暂未列出具体商品名，请优先以 **SoC／设备代号** 与镜像说明核对。

### 3.6 「Test Gamepad」手柄测试程序（克隆机强烈推荐）

RK3326 等平台上**山寨／克隆机型批次多**，即便名称与 §3 列表接近，主板、摇杆霍尔／碳膜方案与功放电路也可能不同。若在 EmulationStation 里出现**键位错乱、无震动、线性扳机异常**等现象，可先排除硬件与/SDL 映射是否与当前固件期望一致：

- **机内入口**：系统在 **Portable／模块（Modules）等工具类菜单**中提供 **`Test Gamepad`**（脚本启动 **`gamepad-tester`**，可执行文件一般为 **`/usr/bin/gamepad-tester`**）；部分主题下名称或层级略有差别，可在前端搜索「Gamepad」相关条目。
- **作用**：基于 **SDL2 GameController**，可直观查看各键、十字键与双摇杆、扳机触发，并支持常见 **手柄震动／扳机马达**测试与热插拔，便于确认该机在内核与 SDL 层是否识别正常。
- **源码与 PC 交叉编译**：与镜像中程序同源的手柄测试源代码在仓库 **`tools/sdl2-controller-test/`**，开发者可在桌面端按需交叉编译调试；简明说明见同目录 **`README.md`**。

完成手柄测试后再进游戏／模拟器，可显著减少「误判为 ROM 问题」的情况；若测试结果与预期不符，请携带 **测试结果描述与机型改版信息** 向社区反馈。

若某机型在表中但启动异常，请到 [**distribution_rocknix Issues**](https://github.com/AveyondFly/distribution_rocknix/issues) 新开反馈，附带 **完整镜像文件名、哈希（如有）与硬件改版照片／铭牌信息**。

---

## 4. 首次启动：按需保留空间并自动创建 GAMES（exFAT）分区

本改版在首次扩容流程中支持一种可选布局：**把 Linux 使用的 ext4 `/storage` 分区只扩展到指定大小**，在 SD 卡／存储设备的**剩余连续空间**上再建一个 **`GAMES`** 分区，并格式化为 **exFAT**，便于 Windows / macOS 直接拷游戏或大文件。

该逻辑由启动时的 `fs-resize` 脚本完成，要点如下：

- 触发条件与普通 ROCKNIX 一致：存在 **`/storage/.please_resize_me`**（一般由全新刷写的镜像在首次引导前就绪；具体以镜像行为为准）。
- **若系统已经完成过初始化**（例如已存在 `/storage/.config`、`.cache`、`.kodi` 等目录），脚本会**拒绝再次分区扩容**并记入日志——因此本功能必须在**第一次正常进系统并完成初始化之前**按计划准备好标记文件。
- 在可被挂载为 **`/flash`** 的 FAT 分区**根目录**（与 ROCKNIX 常见做法一致，通常为刷机后电脑能看到的那个启动分区），新建一个**空文件**，文件名必须严格匹配模式：  
  **`resize_storage_<整数>G`**  
  例如：`resize_storage_16G` 表示希望 **ext4 `/storage` 分区在扩容后只占约 16GiB 末尾位置**，其后新建 `GAMES` exFAT 分区用尽剩余空间。  
  数字部分为大于 0 的整数；单位固定为后缀 **`G`**（GiB 量级语义，与脚本中 `parted` / 扩容参数一致）。
- **磁盘总容量必须大于**你设定的 `resize_storage_<N>G`**所要求的边界**，否则会记录日志并**回退为「storage 扩展到整盘剩余空间」**，且会删除无效的 `resize_storage_*G` 标记文件（**不再**创建单独的 GAMES 分区）。
- 成功执行 `resize_storage_*G` 路径时，脚本会：  
  1. 将原 storage 分区缩扩到指定大小上限；  
  2. `e2fsck` / `resize2fs` ext4；  
  3. 在空余空间 **`mkpart` + `mkfs.exfat -n GAMES`**；  
  4. 完成后删除 **`resize_storage_*G`** 标记文件并重启。

**操作建议（典型 SD 卡流程）：**

1. 将镜像写入 SD 卡。  
2. 在电脑上打开 FAT 分区，在根目录 **`touch`** 或新建空文件 **`resize_storage_32G`**（按需改数字）。  
3. 安全弹出后插入设备，**首次开机**插电等待扩容与重启完成。  
4. 之后可在宿主电脑上看到除原 ROCKNIX 分区外的 **exFAT GAMES** 分区，用于交换 ROM；设备内需依赖系统的自动挂载规则访问该分区（可与 `/storage/games-internal`、`games-external` 等政策配合，具体以镜像内 **automount**／前端路径说明为准）。

详细执行与日志可参考脚本：  
[`projects/ROCKNIX/packages/sysutils/busybox/scripts/fs-resize`](projects/ROCKNIX/packages/sysutils/busybox/scripts/fs-resize)

若未放置任何 `resize_storage_*G` 文件，行为与常规 ROCKNIX 一致：**单个 storage 分区扩展到最大并作 ext4 扩容**。

---

## 5. DraStic 增强版（drastic_adv-sa）：双屏布局与遮罩

本改版中的增强版独立 NDS 模拟器支持通过 **`layout.json`** 自定义上下屏位置、尺寸、叠加模式与背景图等。

- **配置文件路径**：`/storage/.config/drastic/resources/bg/<分辨率>/layout.json`  
  分辨率目录名形如 `1920x1080`、`1280x720`（与你的设备输出分辨率对应）。

完整字段说明、布局类型与示例见仓库内文档（当前文件名）：  
[**DRASTIC_USER_MANUAL_cn.md**](DRASTIC_USER_MANUAL_cn.md)（内容与「drastic_adv 自定义双屏尺寸和遮罩」一致）；英文版见 [**DRASTIC_USER_MANUAL_en.md**](DRASTIC_USER_MANUAL_en.md)。

---

## 6. J2ME 独立模拟器（free-j2me）

手柄映射、Hotkey 组合键、菜单操作、游戏旁路配置文件（`.conf`）与进阶修改 **`j2me.gptk`** 的说明单独成册，便于玩家查阅：

[**J2ME_USER_MANUAL_cn.md**](J2ME_USER_MANUAL_cn.md)；英文版见 [**J2ME_USER_MANUAL_en.md**](J2ME_USER_MANUAL_en.md)。

---

## 7. 电子书（KReader）与音乐（KPlayer）

本改版相较主线增加了面向掌机场景的 **EBOOK** 与增强款音乐播放器界面（与源码中的 **`kebook`**、**`kplayer`** 可执行名称对应）。

### 7.1 KReader 电子书（EBOOK / kebook）

- EmulationStation 中会出现 **EBOOK**（电子书）一类的系统条目，由独立程序 **`kebook`**（玩家侧常称 **KReader**）打开。
- **支持格式**：**EPUB、PDF、TXT**。
- **特色功能**：**背景音乐播放**（阅读时可同时播音轨）、**自动翻页**。具体按键与前端的 **`kebook`** 映射以实机手柄布局为准。
- 请将电子书文件放入 ES 为该 **EBOOK** 系统扫描到的目录（与 ROM 管理方式相同，通常为 **`/storage/roms/ebook`** 下对应电子书路径，或因主题而异的游戏库路径）。

### 7.2 KPlayer（较新的音乐播放器）

- 与经典 **Gmu Music Player** 并列提供；在 GMU 自带的播放列表中也有入口 **`Start KPlayer.sh`**，启动 **`kplayer`**。
- 定位相对 **界面与体验更现代化**，并额外支持 **在线下载歌词**（需联网，具体能力与站点可用性取决于程序实现与上游资源）。
- 音乐文件管理与 **Gmu** 相同：**`/storage/roms/music`、外置介质等**可被扫描到的音频目录即可播放。

电子书与音频版权由用户自备合法文件并遵守相关法律。

---

## 8. MOD_TOOLS 扩展脚本

本改版在 **`MOD_TOOLS`** 分类下附带若干便捷脚本（在 EmulationStation 等前端中与其他「工具／杂项」应用一起出现）。以下为与主线差异较大、建议使用前阅读说明的几项。**执行会改分区、覆盖配置或联网登录，请先备份 SD 卡与重要数据；刷写 eMMC 错误可能导致设备无法启动。**

源码目录（便于核对行为）：[`projects/ROCKNIX/packages/virtual/emulators/sources/MOD_TOOLS/`](projects/ROCKNIX/packages/virtual/emulators/sources/MOD_TOOLS/)

### 8.1 `Install AURKNIX to EMMC.sh`：TF 克隆到 eMMC，无卡启动

适用于 **RK3326** 等平台、**板载 eMMC 且当前从 TF（SD）启动**的克隆／寨机（例如 **GameConsole** 系列 **R36S** 等一批带 eMMC 的机型）。

- **作用**：从 **TF 卡**（脚本中假定块设备 **`/dev/mmcblk1`**）把 **引导与 AURKNIX FAT 分区**等内容克隆到 **eMMC**（**`/dev/mmcblk0`**），并处理分区 UUID 与签名以避免与 TF 冲突，在 eMMC 上生成可用的 **storage** 分区思路与主线「装到内置」一类流程一致（具体分区布局以脚本与日志为准）。
- **结果**：成功后通常可 **拔掉 TF 卡、仅从 eMMC 启动**。
- **注意**：必须先确认机器上 **`mmcblk0`／`mmcblk1` 与你的实际 TF、eMMC 对应关系**，错误选盘会破坏数据；操作时需 **接入电源**，过程中 **不要断电**。若你的硬件块设备命名不同，不要随意运行，需改用适配脚本或自制修改。

### 8.2 `Reset Drastic Cfg.sh`：恢复 DraStic 手柄配置

当 **Drastic／drastic_adv** 相关按键映射被改乱、无法进菜单或与手柄 GUID 不匹配时，可运行本脚本：

- **作用**：清除用户目录下的 `drastic.cf*` 异常文件（若存在），用系统自带的 **`drastic.cfg` 模板**重新写入 **`/storage/.config/drastic/config/drastic.cfg`**，并根据当前手柄在 **`SDL-GameControllerDB`**（`gamecontrollerdb.txt`）中的映射与 **`joyguid`** 输出重新生成与模板一致的绑定逻辑。
- **注意**：运行后自定义键位会丢失；若提示找不到当前手柄 GUID 对应条目，请先检查手柄识别或 **`gamecontrollerdb.txt`**。

### 8.3 `Start Baidu Sync.sh`：百度云与本机同步

- **作用**：启动基于 **commander** 的百度云客户端界面，配置与数据目录为 **`/storage/.config/commander-baidupcs`**（与脚本内 **`commander.cfg`** 等）。用于在设备与百度网盘之间浏览、上传、下载（具体能力以上游 **commander-baidupcs** 与用户配置为准）。
- **注意**：需在合法合规前提下使用；登录信息与 **`commander.cfg`** 安全请自行妥善保管。

### 8.4 `Toggle Power Button.sh`：电源键在「休眠」与「关机」之间切换

- **作用**：在 **`/storage/.config/logind.conf.d/logind.conf`** 中切换 **`systemd-logind`** 项 **`HandlePowerKey`**：**`suspend`（休眠）** 与 **`poweroff`（关机）**，运行一次即从当前策略切到另一种；界面会简要提示当前将切换到的含义。
- **注意**：仅在采用该 drop-in 配置的 ROCKNIX 环境下生效；部分机型休眠／唤醒表现因内核与 ACPI 而异，请以实机为准。

镜像中 **`MOD_TOOLS`** 下还可能包含 **Bezels 安装**、**SDL GameControllerDB 生成** 等脚本，使用前同样建议先了解是否会覆盖现有配置。

---

## 9. 其它实用提示

- **着色器与遮罩（边框）**：本改版镜像已附带一套**预设着色器方案**与**遮罩／Bezel 配置**（与 ROCKNIX 常见的分辨率、点对点或怀旧显示风格对齐）。若想更换或关闭，请到 **EmulationStation（ES）** 前端中调整：例如在**游戏高级选项／系统的高级设置**里为单机或整机平台选择不同的 **Shader set**、**Bezels**，以及是否启用遮罩等（具体菜单名称因 ES 主题略异）。不推荐在未理解路径含义时直接手写底层配置文件。
- **摇杆灯光（RGB 环／摇杆灯，视硬件而定）**：部分机型主板与固件开放了 **双侧摇杆灯** 或可编程 **LED**。可在 **系统设置** 中与 **LED 颜色／灯光**相关的选项里进行调整（仅在当前镜像针对该机种启用该功能时菜单才会生效；无灯或不支持的机型可能没有此项）。后续版本会陆续增加更多与摇杆灯光相关的控制能力，请以更新说明为准。
- **日志**：首次扩容可查看 **`/flash/fs-resize.log`**（在可挂载 boot 分区上），便于排查分区失败或容量不足导致的回退。  
- **法律与许可证**：本项目继承 ROCKNIX / JELOS 等上游许可证；请参阅根目录 README 中的 **Licenses** 与 **Credits** 章节。

---

## 10. 文档与仓库索引

| 文档／入口 | 内容 |
|------------|------|
| [**distribution_rocknix（本改版 GitHub）**](https://github.com/AveyondFly/distribution_rocknix) | 源码仓库；[**Issues**](https://github.com/AveyondFly/distribution_rocknix/issues) 报错与需求；[**Pull requests**](https://github.com/AveyondFly/distribution_rocknix/pulls) 贡献代码与文档 |
| [**distribution-nightly Releases**](https://github.com/AveyondFly/distribution-nightly/releases) | **最新预编译镜像**（GitHub）；若访问困难见下一行 |
| 微信公众号 **「k源机」** | **百度网盘等分流**下载指引（内容与更新以公众号说明为准） |
| [README.md](README.md) | Fork 简介、额外模拟器与机型表格、上游链接 |
| [USER_MANUAL_cn.md](USER_MANUAL_cn.md) | 本文（中文）：用户面向总览与本改版特有功能 |
| [USER_MANUAL_en.md](USER_MANUAL_en.md) | 英文手册（内容对应） |
| [J2ME_USER_MANUAL_cn.md](J2ME_USER_MANUAL_cn.md) | J2ME 手柄与设置说明（中文） |
| [J2ME_USER_MANUAL_en.md](J2ME_USER_MANUAL_en.md) | J2ME 玩家说明（英文） |
| [DRASTIC_USER_MANUAL_cn.md](DRASTIC_USER_MANUAL_cn.md) | drastic_adv 布局 JSON（中文） |
| [DRASTIC_USER_MANUAL_en.md](DRASTIC_USER_MANUAL_en.md) | drastic_adv layouts（English） |
| **`/roms/ebook/*.pdf`** | （若构建镜像时打包）`/usr/share/misc/doc/rocknix-user-man/` 下 PDF 可于首次开机复制到 **`/roms/ebook/`**便于 **EBOOK／kebook**；当前 Markdown 以 `*_cn.md`／`*_en.md` 成对维护（亦可通过独立手册仓库 Releases 分发 PDF）。 |

如对本文有增补建议（某一机型的实测 `resize_storage_XXG` 数值、GAMES 挂载路径、eMMC 刷写兼容性等），欢迎在 [**distribution_rocknix**](https://github.com/AveyondFly/distribution_rocknix) 开出 [**Issue**](https://github.com/AveyondFly/distribution_rocknix/issues) 或直接提交 [**Pull Request**](https://github.com/AveyondFly/distribution_rocknix/pulls)。
