&nbsp;&nbsp;<img src="https://raw.githubusercontent.com/AveyondFly/distribution_rocknix/next/distributions/ROCKNIX/logos/rocknix-logo.png" width=192>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[![Latest Version](https://img.shields.io/github/release/AveyondFly/distribution_rocknix.svg?color=5998FF&label=latest%20version&style=flat-square)](https://github.com/AveyondFly/distribution_rocknix/releases/latest) [![Activity](https://img.shields.io/github/commit-activity/m/AveyondFly/distribution_rocknix?color=5998FF&style=flat-square)](https://github.com/AveyondFly/distribution_rocknix/commits) [![Pull Requests](https://img.shields.io/github/issues-pr-closed/AveyondFly/distribution_rocknix?color=5998FF&style=flat-square)](https://github.com/AveyondFly/distribution_rocknix/pulls)
#
**AURKNIX** is a community Linux distribution for handheld gaming devices, maintained as a fork of **ROCKNIX**. Images and updates for this project are published from this repository’s [Releases](https://github.com/AveyondFly/distribution_rocknix/releases).

## Licenses
AURKNIX is made up of many open-source components. Components are provided under their respective licenses. This distribution includes components licensed for non-commercial use only. See the [**Licenses** section of the repository README](https://github.com/AveyondFly/distribution_rocknix/blob/next/README.md#licenses).

## Installation
* Download the latest **AURKNIX** image from this project on GitHub.
* Decompress the image.
* Write the image to an SDCARD using an imaging tool. Common imaging tools include [Balena Etcher](https://www.balena.io/etcher/), [Raspberry Pi Imager](https://www.raspberrypi.com/software/), and [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/). If you're skilled with the command line, dd works fine too.

### Installation Package Downloads
| **Device/Platform** | **Download Package** | **Documentation** |
|---------------------|----------------------|---------------------|
| **RK3326** (unified image) | [AURKNIX-RK3326.aarch64-$DATE.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3326.aarch64-$DATE.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3326/) |
| **RK3326S** (unified image)<br>*GameMT E6; GameKiddy GKD Pixel 2 (P2)*<br>*Use `/flash/dtbselect` or `DtbselectWin64.exe` on the boot partition to pick the device tree* | [AURKNIX-RK3326S.aarch64-$DATE.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3326S.aarch64-$DATE.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3326S/) |
| **RK3566 (Generic)**<br>*Powkiddy RGB10 Max 3, RGB20 Pro, RGB20 SX, RGB30, RK2023* | [AURKNIX-RK3566.aarch64-$DATE-Generic.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3566.aarch64-$DATE-Generic.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3566/) |
| **RK3566 (Specific)**<br>*Powkiddy X55, X35S, X35H; GameMT E5P / E6P; Diium D50 Plus; MiniLoong Pocket1; Miyoo Flip; Radxa ZERO 3W* | [AURKNIX-RK3566.aarch64-$DATE-Specific.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3566.aarch64-$DATE-Specific.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3566/) |
| **RK356X (RK3562, 5.10 BSP)**<br>*AISLPC RG52 Mini, RG43H Pro, RG43V Pro*<br>*Use `/flash/dtbselect` or `DtbselectWin64.exe`: default entries for AIC8800 WiFi; **v1** entries (**RG52 Mini v1**, **RG43H Pro v1**, **RG43V Pro v1**) for **RK915 WiFi*** | [AURKNIX-RK356X.aarch64-$DATE-RK3562.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK356X.aarch64-$DATE-RK3562.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK356X/) |
| **RK356X (RK3566-Generic, 5.10 BSP)**<br>*Powkiddy RGB10 Max 3, RGB20 Pro, RGB20 SX, RGB30, RK2023*<br>*Boots via multi-DTB `FDTDIR`; not interchangeable with standalone **RK3566 Generic** (mainline 6.x)* | [AURKNIX-RK356X.aarch64-$DATE-RK3566-Generic.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK356X.aarch64-$DATE-RK3566-Generic.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK356X/) |
| **RK356X (RK3566-Specific, 5.10 BSP)**<br>*Powkiddy X55, X35S, X35H; GameMT E5P / E6P; Diium D50 Plus; MiniLoong Pocket1; Coolboy / Kuhai H9*<br>*Use `/flash/dtbselect` or `DtbselectWin64.exe`; **Coolboy H9** (also sold as **Kuhai H9**) is **RK356X only** — not in standalone **RK3566 Specific**. **Miyoo Flip** and **Radxa ZERO 3W** use standalone **RK3566 Specific** (mainline 6.x), not RK356X.* | [AURKNIX-RK356X.aarch64-$DATE-RK3566-Specific.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK356X.aarch64-$DATE-RK3566-Specific.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK356X/) |
| **S905** | [AURKNIX-S905.aarch64-$DATE.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-S905.aarch64-$DATE.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/S905/) |

## Upgrading
* Download and install the update online via the System Settings menu.
* If you are unable to update online
* Download the latest **AURKNIX** update from GitHub
* Copy the update to your device over the network to your device's update share.
* Reboot the device, and the update will begin automatically.

### Update Package Downloads
| **Device/Platform** | **Download Package** |
|---------------------|----------------------|
| **RK3326** | [AURKNIX-RK3326.aarch64-$DATE.tar](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3326.aarch64-$DATE.tar) |
| **RK3326S** | [AURKNIX-RK3326S.aarch64-$DATE.tar](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3326S.aarch64-$DATE.tar) |
| **RK3566** (Generic & Specific) | [AURKNIX-RK3566.aarch64-$DATE.tar](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3566.aarch64-$DATE.tar) |
| **RK356X** (RK3562, RK3566-Generic & RK3566-Specific) | [AURKNIX-RK356X.aarch64-$DATE.tar](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK356X.aarch64-$DATE.tar) |
| **S905** | [AURKNIX-S905.aarch64-$DATE.tar](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-S905.aarch64-$DATE.tar) |

## Documentation

### This fork (AURKNIX)
* [Repository README](https://github.com/AveyondFly/distribution_rocknix/blob/next/README.md)
* [User manuals](https://github.com/AveyondFly/distribution_rocknix/tree/next/documentation/user_man)
* [Device-specific documentation](https://github.com/AveyondFly/distribution_rocknix/tree/next/documentation/PER_DEVICE_DOCUMENTATION)
* [Issues](https://github.com/AveyondFly/distribution_rocknix/issues) · [Pull requests](https://github.com/AveyondFly/distribution_rocknix/pulls)

## Change Log

### New Features
* **RK3326S** unified image: initial support for **GameMT E6** and **GameKiddy GKD Pixel 2 (P2)** (PX30S). Select the device tree with `/flash/dtbselect` (Linux) or `DtbselectWin64.exe` (Windows) on the boot partition.
* **RK356X** now ships **three install images** (5.10 BSP kernel): **RK3562**, **RK3566-Generic**, and **RK3566-Specific**. Pick the subimage that matches your hardware; do not use standalone **RK3566** packages (mainline 6.x) on RK356X targets.

### Updates
* Updated...?

### Bug Fixes
* Fixed...?

**Full Changelog**: https://github.com/AveyondFly/distribution_rocknix/compare/$LAST_TAG...$DATE
