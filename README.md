<img src="https://github.com/AveyondFly/distribution_rocknix/blob/next/distributions/ROCKNIX/logos/rocknix-logo.png?raw=yes" width=192>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[![Latest Version](https://img.shields.io/github/release/AveyondFly/distribution_rocknix.svg?color=3b82f6&label=latest%20version&style=flat-square)](https://github.com/AveyondFly/distribution_rocknix/releases/latest) [![Activity](https://img.shields.io/github/commit-activity/m/AveyondFly/distribution_rocknix?color=3b82f6&style=flat-square)](https://github.com/AveyondFly/distribution_rocknix/commits) [![Pull Requests](https://img.shields.io/github/issues-pr-closed/AveyondFly/distribution_rocknix?color=3b82f6&style=flat-square)](https://github.com/AveyondFly/distribution_rocknix/pulls)

---

ROCKNIX is an immutable Linux distribution for handheld gaming devices developed by a small community of enthusiasts.  Our goal is to produce an operating system that has the features and capabilities that we need, and to have fun as we develop it.

## About This Fork

This is an **unofficial** fork of ROCKNIX that provides support for additional devices and emulators not included in the official distribution.

### Additional Emulators

- **BBK 4980** (gam4980-lr): Electronic dictionary game emulator
- **EKA2L1** (eka2l1-sa): Symbian / N-Gage emulator
- **flycast2022-sa**: Flycast 2022 standalone (default for Dreamcast / Atomiswave / Naomi)
- **gpsp_ezode** (gpsp_ezode-lr): gpSP EZODE GBA emulator (default for GBA / GBA Hacks)
- **HBMAME** (hbmame-lr): Homebrew MAME libretro core
- **mkxp-z**: RPG Maker XP
- **mrp** (mrp-sa): MRP Games (feature phone game format)
- **krkr2** (krkr2-sa): Kirikiri2 visual novel engine
- **ONScripter** (onscripter-lr / onscripter-sa): Visual novel engine (libretro + standalone)
- **ppsspp2021-sa**: PPSSPP 2021 standalone (default PSP on RK3326 / RK3566 / RK356X)
- **PyMO/cpymo**: PyMO AVG game engine in C
- **free-j2me**: J2ME SDL2 frontend standalone
- **OpenBOR-ff**: OpenBOR-ff variant
- **drastic_adv-sa**: Advanced Drastic NDS emulator
- **fbneoplus-lr**: FBNeo Plus libretro core
- **ruffle-sa**: Flash emulator

### Additional Apps & Tools

- **gamepadtester**: Gamepad tester utility
- **KPlayer** (kplayer): Enhanced music player with modern UI and online lyric download
- **KReader** (kebook): E-book reader

### Ports

Independent ports apps:

- [**Kodi**](https://github.com/AveyondFly/console_mod_res/releases/download/v0.9/kodi.zip): Media player and entertainment hub

### Additional Supported Devices

#### RK3326 Devices (unified image)
| Brand | Models |
|-------|--------|
| BatleXP | G350 |
| Clone R36s | Type 2 (with/without amplifier), Type 3, Type 4, Sauce Panel 1/2/3/4 |
| Diium | D007, D-R28S |
| GameConsole | HG36, K36, K36S, R33S, R36S, R36S Plus, R36T, R36TMax, R36Ultra,R36UltraX, R36XXProMax, R40S, R40XX, R40XX ProMax, R45H, R46H, R50S, R50H, RX6H, T16Max, U8, U8-V2, XGB36 |
| Gameforce | CHI |
| GameMT | E6 |
| Generic | EE Clone |
| Lenovo | Go2 |
| MagicX | XU10, XU Mini M |
| ODROID-GO | Advance, Advance Black Edition, Super |
| PortableGame | A10Mini, A10Mini-V4 |
| Powkiddy | RGB10, RGB10X, RGB20S |
| XiFan | DC35V, DC40V, DC45V, Mini40, MyMini, R36Max, R36Max2, R36Pro, RF35H, RF40H, RF45V, XF28, XF35H, XF40H, XF40V, XF45V |

#### RK3566 Devices — Generic image
| Brand | Models |
|-------|--------|
| Powkiddy | RGB10 Max 3, RGB20 Pro, RGB20 SX, RGB30, RK2023 |

#### RK3566 Devices — Specific image
| Brand | Models |
|-------|--------|
| Diium | D50 Plus |
| GameMT | E5P, E6P |
| MiniLoong | Pocket1 |
| Miyoo | Flip |
| Powkiddy | X55, X35S, X35H |
| Radxa | ZERO 3W |

#### S905 Android TV Boxes
| Brand | Models |
|-------|--------|
| Skyworth | E900V22C(S905L3A) |
| GameBox | X10(S905X4) |

#### RK356X Devices (unified image, 5.10 BSP kernel)

The **RK356X** image is a single unified build that bundles **RK3562**, **RK3566-Generic**, and **RK3566-Specific** subimages. It uses the **Rockchip 5.10 BSP kernel**, unlike standalone **RK3566** images which use the **mainline 6.x** kernel — do not mix RK356X and RK3566 install packages.

Use `/flash/dtbselect` (Linux) or `DtbselectWin64.exe` (Windows) on the boot partition to pick the device tree for **RK3562** and **RK3566-Specific** targets. **RK3566-Generic** subimage boots via `FDTDIR` (multi-DTB folder) and does not use dtbselect.

##### RK3562 subimage
| Brand | Models | Notes |
|-------|--------|-------|
| AISLPC | RG52 Mini, RG43H Pro, RG43V Pro | **v1** entries (**RG52 Mini v1**, **RG43H Pro v1**, **RG43V Pro v1**) are for the **RK915 WiFi** hardware revision; the default entries are for other WiFi variants (AIC8800D80). |

##### RK3566-Generic subimage
| Brand | Models | Notes |
|-------|--------|-------|
| Powkiddy | RGB10 Max 3, RGB20 Pro, RGB20 SX, RGB30, RK2023 | Powkiddy handhelds only — **does not include** Anbernic models from standalone **RK3566 Generic**. |

##### RK3566-Specific subimage
| Brand | Models | Notes |
|-------|--------|-------|
| Coolboy | H9 | **RK356X only** — not included in standalone **RK3566 Specific**. |
| Diium | D50 Plus | |
| GameMT | E5P, E6P | |
| MiniLoong | Pocket1 | |
| Powkiddy | X55, X35S, X35H | |

#### RK3326S Devices (unified image, PX30S, 5.10 BSP Kernel)
| Brand | Models | Notes |
|-------|--------|-------|
| GameMT | E6 | RK3326S / PX30S variant. |
| GameKiddy | GKD Pixel 2 (P2) | |

Use `/flash/dtbselect` (Linux) or `DtbselectWin64.exe` (Windows) on the boot partition to select the correct device tree.

## Features

* ROCKNIX has a very active community of developers and users.
* Integrated cross-device local and remote network play.
* In-game touch support on supported devices.
* Fine grain control for battery life or performance.
* Includes support for playing Music and Video.
* Bluetooth audio and controller support.
* Support for HDMI audio and video out, and USB audio.
* Device to device and device to cloud sync with Syncthing and rclone.
* VPN support with Wireguard, Tailscale, and ZeroTier.
* Includes built-in support for scraping and retroachievements.
* Screen color adjustment (brightness / contrast / saturation / hue) on RK3326, RK3326S, RK3566, and RK356X devices.

## User manuals

Guides for this fork live in [`documentation/user_man/`](documentation/user_man/) as paired Chinese and English Markdown files (`*_cn.md` / `*_en.md`): general fork usage, drastic_adv `layout.json`, and J2ME controls. PDFs shipped in release images are built in CI from those sources.

## Contributing

Pull requests can request **automatic image builds** in GitHub Actions. Add a `build:` line to the PR description (the [PR template](.github/PULL_REQUEST_TEMPLATE.md) includes this section by default):

```
build:RK3326/RK3566
```

- **Supported devices:** `RK3326`, `RK3326S`, `RK3566`, `S905`, `RK356X`
- **Multiple devices:** separate with `/`, `,`, `;`, or spaces (e.g. `build:RK3326/RK3566`)
- **All devices:** `build:ALL`
- **Skip builds:** leave `build:` empty or omit the line

CI runs when the PR is opened, updated, or when you edit the description. After a successful build, download `AURKNIX-image-*` and `AURKNIX-update-*` artifacts from the workflow run on the **Checks** tab. PR builds are for testing only and are not published as releases.

## Screenshots

<table>
  <tr>
    <td><img src="snapshots/nds.png"/></td>
    <td><img src="snapshots/music_player.png"/></td>
  </tr>
  <tr>
    <td><img src="snapshots/ebook.png"/></td>
    <td><img src="snapshots/aveyond3c3.png"/></td>
  </tr>
</table>

## Licenses

**AURKNIX** is a fork of **ROCKNIX**; ROCKNIX derives from [JELOS](https://github.com/JustEnoughLinuxOS/distribution/). All applicable licenses apply and credit to the JELOS and ROCKNIX teams. 

You are free to:

- Share: copy and redistribute the material in any medium or format
- Adapt: remix, transform, and build upon the material

Under the following terms:

- Attribution: You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
- NonCommercial: You may not use the material for commercial purposes.
- ShareAlike: If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

### Bundled Works
All other software is provided under each component's respective license. These licenses can be found in the software sources or in this project's licenses folder. Modifications to bundled software and scripts by the JELOS and ROCKNIX teams are licensed under the terms of the software being modified.

## Credits

Like any Linux distribution, this project is not the work of one person. It is the work of many persons all over the world who have developed the open source bits without which this project could not exist. Special thanks to CoreELEC, LibreELEC, JELOS, ROCKNIX, and to developers and contributors across the open source community.

## Support

If you would like to support maintainer **lcdyk**, you can use Ko-fi: [https://ko-fi.com/lcdyk](https://ko-fi.com/lcdyk).
