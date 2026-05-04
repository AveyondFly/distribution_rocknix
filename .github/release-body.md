&nbsp;&nbsp;<img src="https://raw.githubusercontent.com/AveyondFly/distribution_rocknix/next/distributions/ROCKNIX/logos/rocknix-logo.png" width=192>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[![Latest Version](https://img.shields.io/github/release/AveyondFly/distribution_rocknix.svg?color=5998FF&label=latest%20version&style=flat-square)](https://github.com/AveyondFly/distribution_rocknix/releases/latest) [![Activity](https://img.shields.io/github/commit-activity/m/AveyondFly/distribution_rocknix?color=5998FF&style=flat-square)](https://github.com/AveyondFly/distribution_rocknix/commits) [![Pull Requests](https://img.shields.io/github/issues-pr-closed/AveyondFly/distribution_rocknix?color=5998FF&style=flat-square)](https://github.com/AveyondFly/distribution_rocknix/pulls) [![Discord Server](https://img.shields.io/discord/948029830325235753?color=5998FF&label=chat&style=flat-square)](https://discord.gg/seTxckZjJy)
#
ROCKNIX is a community developed Linux distribution for handheld gaming devices.  Our goal is to produce an operating system that has the features and capabilities that we need, and to have fun as we develop it.

## Licenses
ROCKNIX is a Linux distribution that is made up of many open-source components.  Components are provided under their respective licenses.  This distribution includes components licensed for non-commercial use only.

### ROCKNIX Branding
ROCKNIX branding and images are licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-nc-sa/4.0/).

#### You are free to
* Share — copy and redistribute the material in any medium or format
* Adapt — remix, transform, and build upon the material

#### Under the following terms
* Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
* NonCommercial — You may not use the material for commercial purposes.
* ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

### ROCKNIX Software
Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Installation
* Download the latest version of ROCKNIX.
* Decompress the image.
* Write the image to an SDCARD using an imaging tool.  Common imaging tools include [Balena Etcher](https://www.balena.io/etcher/), [Raspberry Pi Imager](https://www.raspberrypi.com/software/), and [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/).  If you're skilled with the command line, dd works fine too.

### Installation Package Downloads
| **Device/Platform** | **Download Package** | **Documentation** |
|---------------------|----------------------|---------------------|
| **RK3326** (unified image) | [AURKNIX-RK3326.aarch64-$DATE.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3326.aarch64-$DATE.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3326/) |
| **RK3566** | [AURKNIX-RK3566.aarch64-$DATE-Generic.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3566.aarch64-$DATE-Generic.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/RK3566/) |
| **S905L3A** | [AURKNIX-S905L3A.aarch64-$DATE.img.gz](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-S905L3A.aarch64-$DATE.img.gz) | [documentation](/documentation/PER_DEVICE_DOCUMENTATION/S905L3A/) |

## Upgrading
* Download and install the update online via the System Settings menu.
* If you are unable to update online
* Download the latest version of ROCKNIX from Github
* Copy the update to your device over the network to your device's update share.
* Reboot the device, and the update will begin automatically.

### Update Package Downloads
| **Device/Platform** | **Download Package** |
|---------------------|----------------------|
| **RK3326** | [AURKNIX-RK3326.aarch64-$DATE.tar](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3326.aarch64-$DATE.tar) |
| **RK3566** | [AURKNIX-RK3566.aarch64-$DATE.tar](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-RK3566.aarch64-$DATE.tar) |
| **S905L3A** | [AURKNIX-S905L3A.aarch64-$DATE.tar](https://github.com/AveyondFly/distribution_rocknix/releases/download/$DATE/AURKNIX-S905L3A.aarch64-$DATE.tar) |

## Documentation

### Contribute

* [Building ROCKNIX](https://rocknix.org/contribute/build/)
* [Code of Conduct](https://rocknix.org/contribute/code-of-conduct/)
* [Contributing to ROCKNIX](https://rocknix.org/contribute/)
* [Modifying ROCKNIX](https://rocknix.org/contribute/modify/)
* [Adding Hardware Quirks](https://rocknix.org/contribute/quirks/)
* [Creating Packages](https://rocknix.org/contribute/packages/)
* [Pull Request Template](/PULL_REQUEST_TEMPLATE.md)

### Play

* [Installing ROCKNIX](https://rocknix.org/play/install/)
* [Updating ROCKNIX](https://rocknix.org/play/update/)
* [Controls](https://rocknix.org/play/controls/)
* [Netplay](https://rocknix.org/play/netplay/)
* [Configuring Moonlight](https://rocknix.org/systems/moonlight/)
* [Device Specific Documentation](/documentation/PER_DEVICE_DOCUMENTATION)

### Configure

* [Optimizations](https://rocknix.org/configure/optimizations/)
* [Shaders](https://rocknix.org/configure/shaders/)
* [Cloud Sync](https://rocknix.org/configure/cloud-sync/)
* [VPN](https://rocknix.org/configure/vpn/)

### Other

* [Frequently Asked Questions](https://rocknix.org/faqs/)
* [Donating to ROCKNIX](https://rocknix.org/donations/)

## Change Log

### New Features
* Added...?

### Updates
* Updated...?

### Bug Fixes
* Fixed...?

**Full Changelog**: https://github.com/AveyondFly/distribution_rocknix/compare/$LAST_TAG...$DATE
