# J2ME emulator — Player guide

This guide explains **how to play games with the gamepad**, **how to open settings**, **where per‑game tweaks are saved**, and **which file advanced users remap**. New players should read everything once.

Chinese edition: **`J2ME_USER_MANUAL_cn.md`**.

---

## How input works

- The emulator runs the game Java layer; SDL passes **virtual keyboard** events produced from `gptokeyb`.
- Buttons named **A, B, L1…** follow an Xbox-style layout in documentation, yet the **`j2me.gptk`** shipped with your image is authoritative.

---

## Hotkey combos

Some actions require **holding the Hotkey**, then tapping another face button. The physical Hotkey (**Select**, **Back**, etc.) varies per handheld—see your vendor readme.

“**Hotkey + A**” means *hold Hotkey, tap A once*.

| Combo | Effect |
|-------|--------|
| Hotkey + A | Quit game / kill emulator |
| Hotkey + B | Cycle keypad layout presets (many OEM skins) |
| Hotkey + X | Toggle overlay **settings menu** |
| Hotkey + Y | Toggle pointer mode (cursor with D‑pad or analogue; **A** confirms) |

---

## In-game mappings (without Hotkey)

| Phone UI | Pad |
|-----------|-----|
| Left soft key | Back |
| Right soft key | Start |
| OK | A |
| Digit 0 | Y |
| `*` | B |
| `#` | X |
| Digits **1 / 3** | L1 / R1 |
| Digits **7 / 9** | L2 / R2 |
| D-pad | D-pad **or** left stick |

If axes feel swapped, tap **Hotkey + B**, or reopen **settings → Phone**.

---

## While the overlay menu is open

Press **Hotkey + X** first; keys then drive widgets, **not** the MIDlet UI.

| Action | Input |
|--------|-------|
| Move highlight | ↑/↓ (pad or analogue) |
| Change value | ←/→ |
| Close menu | **Hotkey + X** again or tap **Y** |

Menus adjust resolution, virtual handset skin, rotation, … Settings persist next to ROM (below).

---

## Extra shortcuts

| Pad | Role |
|-----|------|
| L3 (click left stick—when present) | Force quit title |
| R3 | Screenshot |

If firmware omitted rotate hardware keys, invoke **Rotate** inside the menu.

---

## Per-title configuration files

- Adjacent to each `.jar`, expect `<Game>.conf`.
- Overrides from the overlay (resolution/skin/orientation); presence **beats** heuristics.
- Folder/filenames mentioning `320x240` hints may bootstrap defaults on first boot.

---

## Editing `j2me.gptk` manually

1. Locate **`j2me.gptk`** beside the launcher / runtime (path differs by SKU).
2. **Backup** before editing—restore snapshots if binds break.
3. Lines resemble `button = keystroke`; suffix **`_hk`** marks Hotkey combos.
4. Right-hand identifiers must obey **`gptokeyb`** rules—consult vendor/community docs when unsure.
5. Relaunch MIDlet afterward.

Otherwise share or download a **`j2me.gptk`** tuned for identical hardware.

---

## FAQ

**Q:** Hotkeys ignore me.  
**A:** Identify the Hotkey wiring (`Select`, `Guide`, …) for your SKU.

**Q:** Buttons clash with tables here.  
**A:** Overrides in `j2me.gptk` win—inspect the on-device copy.

**Q:** Silence in-game.  
**A:** Raise system volume first; remaining issues may stem from the MIDlet or firmware audio stack—ask maintainers.

---

*Respect game copyrights and local laws.*
