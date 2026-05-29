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
| **RK3566 (Generic)**<br>*Anbernic RG353P / RG353PS / RG353V / RG353VS / RG503, RG ARC-D / RG ARC-S; Powkiddy RGB10 Max 3, RGB20 Pro, RGB20 SX, RGB30, RK2023* | [AURKNIX-RK3566.aarch64-$DATE-Generic.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3566.aarch64-$DATE-Generic.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3566/) |
| **RK3566 (Specific)**<br>*Powkiddy X55, X35S, X35H; GameMT E5P / E6P; Diium D50 Plus; MiniLoong Pocket 1* | [AURKNIX-RK3566.aarch64-$DATE-Specific.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3566.aarch64-$DATE-Specific.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3566/) |
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
| **RK3566** (Generic & Specific) | [AURKNIX-RK3566.aarch64-$DATE.tar](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3566.aarch64-$DATE.tar) |
| **S905** | [AURKNIX-S905.aarch64-$DATE.tar](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-S905.aarch64-$DATE.tar) |

## Documentation

### This fork (AURKNIX)
* [Repository README](https://github.com/AveyondFly/distribution_rocknix/blob/next/README.md)
* [User manuals](https://github.com/AveyondFly/distribution_rocknix/tree/next/documentation/user_man)
* [Device-specific documentation](https://github.com/AveyondFly/distribution_rocknix/tree/next/documentation/PER_DEVICE_DOCUMENTATION)
* [Issues](https://github.com/AveyondFly/distribution_rocknix/issues) · [Pull requests](https://github.com/AveyondFly/distribution_rocknix/pulls)

## Change Log

### New Features
* Added...?

### Updates
* Updated...?

### Bug Fixes
* Fixed...?

**Full Changelog**: https://github.com/AveyondFly/distribution_rocknix/compare/$LAST_TAG...$DATE
