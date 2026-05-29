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
- **ONScripter** (onscripter-lr / onscripter-sa): Visual novel engine (libretro + standalone)
- **ppsspp2021-sa**: PPSSPP 2021 standalone (default PSP on RK3326 / RK3566)
- **PyMO/cpymo**: PyMO AVG game engine in C
- **free-j2me**: J2ME SDL2 frontend standalone
- **OpenBOR-ff**: OpenBOR-ff variant
- **drastic_adv-sa**: Advanced Drastic NDS emulator
- **fbneoplus-lr**: FBNeo Plus libretro core

### Additional Apps & Tools

- **gamepadtester**: Gamepad tester utility
- **KPlayer** (kplayer): Enhanced music player with modern UI and online lyric download
- **KReader** (kebook): E-book reader

### Additional Supported Devices

#### RK3326 Devices (unified image)
| Brand | Models |
|-------|--------|
| Anbernic | RG351M, RG351V |
| BatleXP | G350 |
| Clone R36s | Type 2 (with/without amplifier), Type 3, Type 4, Sauce V03/V04 |
| Diium | D007, D-R28S |
| GameConsole | HG36, K36, K36S, R33S, R36S, R36S Plus, R36T, R36TMax, R36Ultra, R36XXProMax, R40S, R40XX, R40XX ProMax, R45H, R46H, R50S, RX6H, T16Max, U8, U8-V2, XGB36 |
| Gameforce | CHI |
| GameMT | E6 |
| Generic | EE Clone |
| MagicX | XU10, XU Mini M |
| ODROID-GO | Advance, Advance Black Edition, Super |
| PortableGame | A10Mini, A10Mini-V2 |
| Powkiddy | RGB10, RGB10X, RGB20S |
| XiFan | DC35V, DC40V, Mini40, MyMini, R36Max, R36Max2, R36Pro, XF28, XF35H, XF40H, XF40V |

#### RK3566 Devices — Generic image
| Brand | Models |
|-------|--------|
| Anbernic | RG353P / RG353PS / RG353V / RG353VS, RG503, RG ARC-D / RG ARC-S |
| Powkiddy | RGB10 Max 3, RGB20 Pro, RGB20 SX, RGB30, RK2023 |

#### RK3566 Devices — Specific image
| Brand | Models |
|-------|--------|
| Diium | D50 Plus |
| GameMT | E5P, E6P |
| MiniLoong | Pocket1 |
| Powkiddy | X55, X35S, X35H |

#### S905 Android TV Boxes
| Brand | Models |
|-------|--------|
| Skyworth | E900V22C(S905L3A) |
| GameBox | X10(S905X4) |

#### RK356X Devices (WIP)
| Brand | Models |
|-------|--------|
| RO520C | LP3X-V10 |

#### RK3326S Devices (6.6 BSP Kernel)
| Brand | Models |
|-------|--------|
| TBD | TBD |

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
* Screen color adjustment (brightness / contrast / saturation / hue) on RK3326 and RK3566 devices.

## User manuals

Guides for this fork live in [`documentation/user_man/`](documentation/user_man/) as paired Chinese and English Markdown files (`*_cn.md` / `*_en.md`): general fork usage, drastic_adv `layout.json`, and J2ME controls. PDFs shipped in release images are built in CI from those sources.

## Screenshots

<table>
  <tr>
    <td><img src="https://rocknix.org/_inc/images/screenshots/system-view.png"/></td>
    <td><img src="https://rocknix.org/_inc/images/screenshots/menu.png"/></td>
  </tr>
  <tr>
    <td><img src="https://rocknix.org/_inc/images/screenshots/gamelist-view-metadata-immersive.png"/></td>
    <td><img src="https://rocknix.org/_inc/images/screenshots/gamelist-view-no-metadata-immersive.png"/></td>
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
