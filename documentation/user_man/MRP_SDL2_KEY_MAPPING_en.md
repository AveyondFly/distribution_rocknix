# MRP SDL2 User Guide

This guide is for users running MRP files from the frontend. The frontend handles launch and conversion automatically, so users normally only need to care about the required font files and the controller mapping.

## Runtime Resource Files

The MRP runtime work directory is:

```text
/storage/roms/mrp/mythroad/
```

The emulator needs the following font files for Chinese text rendering:

| File | Required | Notes |
| --- | --- | --- |
| `/storage/roms/mrp/mythroad/system/gb16_mrpoid.uc2` | Yes | Main Chinese bitmap font. Missing this file can cause blank text or font load failure. |
| `/storage/roms/mrp/mythroad/system/fonts/font16.tsf` | Recommended | Compatibility font from the Android package. Keep this file if available. |

Other compatibility resources may also exist under `/storage/roms/mrp/mythroad/`:

| Directory or file | Notes |
| --- | --- |
| `system/` | System resource directory. It should contain at least `gb16_mrpoid.uc2`. |
| `system/fonts/` | Compatibility font directory. It can contain `font16.tsf`. |
| `plugins/` | Compatibility plugin directory. Some MRPs or older runtime packages may depend on extension files here. If the resource package includes this directory, keep it as-is. |
| Other game-created directories or files | Some MRPs write config, cache, or save data under `mythroad`. Do not delete them unless you know what they are used for. |

## Controller Mapping

Controller buttons are mapped through `gptokeyb`. The active config file is:

```text
/storage/.config/mrp/mrp.gptk
```

| Controller input | MRP result |
| --- | --- |
| DPad Up | Phone keypad `2` |
| DPad Down | Phone keypad `8` |
| DPad Left | Phone keypad `4` |
| DPad Right | Phone keypad `6` |
| Left analog Up | Phone keypad `2` |
| Left analog Down | Phone keypad `8` |
| Left analog Left | Phone keypad `4` |
| Left analog Right | Phone keypad `6` |
| Right analog Up | Phone keypad `2` |
| Right analog Down | Phone keypad `8` |
| Right analog Left | Phone keypad `4` |
| Right analog Right | Phone keypad `6` |
| A | Phone keypad `5` |
| B | Phone keypad `0` |
| X | `*` |
| Y | `#` |
| L1 | Phone keypad `1` |
| R1 | Phone keypad `3` |
| L2 | Phone keypad `7` |
| R2 | Phone keypad `9` |
| L3 | Power/end |
| R3 | Send |
| Start | Left soft key |
| Back | Right soft key |
| Guide | Power/end |

## Hotkey Combos

| Controller hotkey input | MRP result |
| --- | --- |
| Hotkey + A | Power/end |
| Hotkey + B | Send |
| Hotkey + X | Volume up |
| Hotkey + Y | Volume down |
| Hotkey + L1 | Volume up |
| Hotkey + R1 | Volume down |
| Hotkey + L2 | Select/confirm |
| Hotkey + R2 | Right soft key/back |
| Hotkey + DPad Up | MRP directional up |
| Hotkey + DPad Down | MRP directional down |
| Hotkey + DPad Left | MRP directional left |
| Hotkey + DPad Right | MRP directional right |

## Changing Keys

To change controller keys, edit:

```text
/storage/.config/mrp/mrp.gptk
```

Map each controller button to the keyboard key that represents the desired MRP key. Common keyboard outputs are:

| Keyboard output | MRP result |
| --- | --- |
| `0`-`9` | Phone keypad `0`-`9` |
| `s`, also compatible with `shift+8` | `*` |
| `d`, also compatible with `shift+3` | `#` |
| `f1` | Left soft key |
| `f2` or `backspace` | Right soft key/back |
| `f3` | Send |
| `f4` or `escape` | Power/end |
| `enter` or `space` | Select/confirm |
| `pageup` | Volume up |
| `pagedown` | Volume down |
| `m` | Toggle the SDL OSD menu |

After changing `mrp.gptk`, restart the frontend/emulator session so the new mapping is loaded.

## Notes

- The normal DPad and analog directions intentionally use phone keypad `2/4/6/8`, because many MRP games use numeric keypad directions directly.
- The OSD menu supports host-side rotation and a `2468 -> DPad` mode. Use Up/Down to select a row, Left/Right to change it, and `m`/Enter/Escape to close.
- When `2468 -> DPad` is enabled, keyboard `2/4/6/8` are converted to `MR_KEY_UP/LEFT/RIGHT/DOWN`.
- A/B are mapped to `5/0`; X/Y provide direct `* / #` input.
- The previous A/B functions (`enter/backspace`) are kept on Hotkey + L2/R2.
