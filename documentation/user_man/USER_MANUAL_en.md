# ROCKNIX fork — User manual (English)

This manual is for users of [**distribution_rocknix**](https://github.com/AveyondFly/distribution_rocknix) ([**Issues**](https://github.com/AveyondFly/distribution_rocknix/issues), [**Pull requests**](https://github.com/AveyondFly/distribution_rocknix/pulls) are handled there). It explains how this fork differs from upstream **ROCKNIX**: **additional emulators**, **extra supported devices**, **standalone emulator tweaks**, and the **optional first-boot storage layout that reserves space for a later exFAT “GAMES” partition**.

General ROCKNIX usage (Wi‑Fi, Bluetooth, updates, RetroArch, EmulationStation, etc.) is still documented by the upstream project and community; this document only covers **fork-specific** topics.**Before flashing**, check the device list in **§3** and obtain the latest build from the sources listed in **§1** (GitHub Releases or mirror via WeChat).

A **Chinese edition** with the same structure is **`USER_MANUAL_cn.md`**.

---

## 1. Relationship to upstream ROCKNIX

This is an **unofficial fork** whose goals are:

- Ship images on more handhelds/TV boxes beyond what upstream prioritises;
- Bundle emulators/tools not present upstream;
- Document forks of **drastic_adv-sa** and **free-j2me** bindings and tweak paths.

Always verify **exact device model**, **image file name**, and whether you configured **partition reservation flags before first boot**. Flashing firmware is risky: back up SD card or eMMC data first.

**This fork — source code, Issues, Pull requests:** [**https://github.com/AveyondFly/distribution_rocknix**](https://github.com/AveyondFly/distribution_rocknix)

- **Bug reports / feature requests:** [**https://github.com/AveyondFly/distribution_rocknix/issues**](https://github.com/AveyondFly/distribution_rocknix/issues)
- **Code & documentation patches:** [**https://github.com/AveyondFly/distribution_rocknix/pulls**](https://github.com/AveyondFly/distribution_rocknix/pulls)

**Latest nightly image downloads:** [**https://github.com/AveyondFly/distribution-nightly/releases**](https://github.com/AveyondFly/distribution-nightly/releases)

If GitHub is slow or unreliable, follow the official WeChat public account **「k源机」** for mirror links (**Baidu Pan**, etc.); wording and cadence follow that account.

For bugs that obviously belong to **upstream ROCKNIX only**, use the support channels you normally use for that project, or seek guidance from the broader ROCKNIX community.

---

## 2. Emulators bundled on top of upstream

Additional components in this fork (both libretro **`*-lr`** and **standalone binaries** exist; launcher names vary by theme):

| Component | Purpose |
|-----------|---------|
| **gam4980-lr** | BBK 4980–style dictionary games |
| **hbmame-lr** | HBMAME (homebrew MAME‑style cores) via libretro |
| **onscripter-lr** | Visual novel runner (ONScripter) |
| **PyMO / cpymo** | PyMO AVG engine tooling |
| **free-j2me** | SDL2 J2ME front-end (standalone) |
| **OpenBOR-ff** (**sa**) | Ships beside stock **OpenBOR**; **`OpenBOR-ff`** is **standalone**, not RetroArch |
| **drastic_adv-sa** | Enhanced standalone NDS (DraStic derivative/custom build) |
| **fbneoplus-lr** | FBNeo “Plus” libretro |

### 2.1 Extra usage notes

**OpenBOR vs OpenBOR-ff**

- **`OpenBOR-ff` is standalone**: EmulationStation (or equivalent) launches the binary directly; it is **not** a RetroArch core.
- Some mods require the **lns / LNS** engine line or behave badly on stock OpenBOR. For those packs, assign **`OpenBOR-ff`** as the launcher for that game/platform (advanced game/system options wording depends on theme). **Do not** look inside RetroArch cores for OpenBOR‑ff—it is not libretro.
- Honour OpenBOR/community packaging rules and copyright.

**fbneoplus-lr & PGM2 “cartridge swap”**

- **`fbneoplus-lr`** exposes **PGM2 (Polygame Master 2)** hot‑swap/card features where implemented. Use RetroArch/Core documentation for each build’s shortcuts.
- If swap does nothing, confirm **`FBNeo Plus`** (`fbneoplus-lr`) is selected and PGM2 ROM/BIOs paths satisfy the launcher.

You alone are responsible for BIOS/ROM legality (`/storage/roms`, Samba/USB, etc.).

---

## 3. Extra supported hardware (beyond upstream ROCKNIX)

This list tracks **fork-specific** additions. Details may drift vs a download page — **trust the README/filename bundled with your image**. Flash only after verifying **SoC, brand, model, and any amplifier/screen PCB revision quirks**.

### 3.1 RK3326 — single unified image

**RK3326 ships a single unified image.** **All rows below use that image**; device quirks/auto selection happen after flash. PCB/screen swaps may break expectations even when marketing names match—ask maintainers before filing bugs.

| Brand | Models |
|-------|--------|
| Anbernic | RG351M, RG351V |
| BatleXP | G350 |
| Clone R36s | Type 2 (with/without amplifier), Type 3, Type 4, Sauce V03/V04 |
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

### 3.2 RK3566 — per-device images only

RK3566 **does not reuse** RK3326 images. Download **the build whose filename matches your exact hardware**.

| Brand | Models |
|-------|--------|
| GameMT | E5P, E6P |
| MiniLong | Pocket1 |
| Powkiddy | x35H, x35S |

### 3.3 S905L3A Android TV boxes

| Brand | Models |
|-------|--------|
| CM311 | CM311 |
| E900V | E900V22C |
| M401 | M401A |

### 3.4 RK3562 (WIP)

| Brand | Models |
|-------|--------|
| RO520C | LP3X-V10 |

Expect rough edges until maintainers declare the branch stable.

### 3.5 RK3326S (Linux 6.6 BSP branch)

SKU list growing; reconcile SoC/marketing names vs release notes.

### 3.6 “Test Gamepad” utility (recommended for clones)

Clone boards often differ subtly. Mis-mapped hats, absent rumble, or odd analogue triggers merit running **`gamepad-tester`** first:

- **Launcher:** **Portable / Modules → Test Gamepad** (may differ per theme).
- Shows SDL2 controller state plus rumble/trigger‑motor probes; confirms kernel/SDL mapping assumptions.
- Source tree: **`tools/sdl2-controller-test/`** (`README.md` explains host builds).

File issues only after collecting evidence (photo of PCB/revision plus description). Open them at [**distribution_rocknix Issues**](https://github.com/AveyondFly/distribution_rocknix/issues) with image filename/checksum whenever possible.

---

## 4. First boot: shrink `/storage`, auto-create exFAT `GAMES`

Optional flow (script `fs-resize`):

- Trigger matches stock ROCKNIX: marker **`/storage/.please_resize_me`** on virgin installs.
- If `.config`/`.cache` already exist resizing aborts ⇒ configure **before** first successful boot finishes.
- On the FAT **`/flash` root**, drop an empty sentinel named **`resize_storage_<integer>G`** (GiB‑style wording used by `parted`). Example **`resize_storage_16G`** leaves free space afterward for **`mkfs.exfat -n GAMES`** on the slack tail.
- If the disk smaller than sentinel demands, sentinel is erased and **`/storage`** simply grows to 100 %.
- See repository path `projects/ROCKNIX/packages/sysutils/busybox/scripts/fs-resize` for exact behaviour/logs.

Absent any sentinel ⇒ stock full‑grow **`/storage`**.

Typical workflow: flash → mount FAT on PC → `touch resize_storage_32G` → eject → first boots expand & reboot → the host OS should show an **`exFAT`** volume labelled **`GAMES`** next to ROCKNIX storage partitions.

---

## 5. drastic_adv-sa overlays & bezel JSON

Standalone NDS build reads **`layout.json`** per output mode:

`/storage/.config/drastic/resources/bg/<WxH>/layout.json` (folders like `1920x1080`).

Detailed schema & presets: **`DRASTIC_USER_MANUAL_en.md`** (Chinese counterpart: **`DRASTIC_USER_MANUAL_cn.md`**).

---

## 6. J2ME (free‑j2me standalone)

Gameplay / hotkeys / `.conf` sidecars / editing **`j2me.gptk`**: **`J2ME_USER_MANUAL_en.md`** (**`J2ME_USER_MANUAL_cn.md`** in Chinese).

---

## 7. EBOOK (**kebook**/KReader) & music (**kplayer**/KPlayer)

### 7.1 EBOOK (“KReader”) — **`kebook`**

- ES lists an **EBOOK** system launching **`kebook`**.
- **Formats:** EPUB, PDF, TXT.
- **Extras:** ambient music while reading, optional auto page turns (final bindings depend on `kebook`/theme).
- Place books wherever ES indexing expects (commonly **`/storage/roms/ebook`** or theme-specific dirs).

### 7.2 KPlayer

Bundled playlist entry **`Start KPlayer.sh`** → **`kplayer`**, a more modern UI than classic GMU; includes **online lyric download** where supported (requires connectivity).

Treat audio/ebook licensing like ROMs—you must supply legal files.

---

## 8. MOD_TOOLS helper scripts

These live under **`MOD_TOOLS`** in ES along with miscellaneous utilities.**They repartition, overwrite configs, or hit cloud APIs—snapshot SD/eMMC backups first.**

Source mirror: [`projects/ROCKNIX/packages/virtual/emulators/sources/MOD_TOOLS/`](projects/ROCKNIX/packages/virtual/emulators/sources/MOD_TOOLS/)

### 8.1 `Install AURKNIX to EMMC.sh` — clone TF ⇒ eMMC (often RK3326 clones)

Copies AURKNIX FAT/boot stack from presumed **`/dev/mmcblk1`** (microSD) to **`/dev/mmcblk0`** (eMMC) with UUID juggling so you may **remove µSD afterward**. Absolutely confirm block nodes on your SKU; unplugging mid-run bricks storage.

### 8.2 `Reset Drastic Cfg.sh`

Rebuilds **`/storage/.config/drastic/config/drastic.cfg`** from bundled template plus current **`joyguid` + SDL gamecontroller DB** mappings; clears stray `drastic.cf*`. Custom binds vanish until re-edited.

### 8.3 `Start Baidu Sync.sh`

Launches **`commander-baidupcs`** rooted at **`/storage/.config/commander-baidupcs`**.

### 8.4 `Toggle Power Button.sh`

Cycles **`systemd-logind`** `HandlePowerKey` between **`suspend`** and **`poweroff`** inside **`/storage/.config/logind.conf.d/logind.conf`**.

Other MOD entries (bezels unzip, SDL DB generator…) remain—read prompts before approving.

---

## 9. Misc tips

- **Shaders & bezels**: Fork ships tuned defaults. Change shader sets / bezel toggles inside **EmulationStation advanced menus** rather than blindly editing plaintext unless you understand each key.
- **Analog stick LEDs / RGB rims** (SKU dependent): tweak **LED colour** sliders in **System settings** where exposed; roadmap adds richer lighting controls across revisions.
- **Logs**: **`/flash/fs-resize.log`** captures partition attempts (mount FAT on PC).
- **License**: JELOS / ROCKNIX heritage — see distro **Licenses** & **Credits** files.

---

## 10. Document map

| Item | Notes |
|------|-------|
| [**distribution_rocknix**](https://github.com/AveyondFly/distribution_rocknix) | Source + [**Issues**](https://github.com/AveyondFly/distribution_rocknix/issues)/[**PRs**](https://github.com/AveyondFly/distribution_rocknix/pulls) |
| [**distribution-nightly releases**](https://github.com/AveyondFly/distribution-nightly/releases) | Firmware downloads |
| WeChat **`k源机`** | Mirror links |
| Repo root **`README.md`** | High-level changelog |
| **`USER_MANUAL_cn.md`** / **`USER_MANUAL_en.md`** | This handbook (Zh / EN) |
| **`J2ME_USER_MANUAL_*.md`** | J2ME hotkeys/bindings |
| **`DRASTIC_USER_MANUAL_*.md`** | `layout.json` geometry guide |
| **`/roms/ebook/*.pdf`** | Bundled **`/usr/share/misc/doc/rocknix-user-man`** PDF snapshots may be copied here on first-boot (`documentation/user_man/` Markdown remains canonical for developers) |

Contribution welcome via Issues/PR against **distribution_rocknix**.
