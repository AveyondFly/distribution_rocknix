# Flash emulator (Ruffle) — Player guide

Chinese edition: **`FLASH_USER_MANUAL_cn.md`**.

This guide explains how to run **Adobe Flash (`.swf`)** games on the AURKNIX / this ROCKNIX fork. They are served by the standalone **`ruffle-sa`** package (binary **`sdl2test-rocknix`**) on **RK3326** images.

---

## Where to put games

Place `.swf` files in the Flash system folder:

```text
/storage/roms/flash/
```

EmulationStation usually lists the system as **Flash**. Extensions **`.swf` / `.SWF`** are accepted.

---

## Runtime file locations

The launcher **`start_ruffle.sh`** runs the emulator from the user config tree and attaches **`gptokeyb`** for controller mapping:

| Path | Role |
|------|------|
| `/storage/.config/ruffle/sdl2test-rocknix` | Emulator binary executed at launch |
| `/storage/.config/ruffle/ruffle.gptk` | System-wide controller map for **`gptokeyb`** |
| `/usr/config/ruffle/` | Factory defaults shipped in the image; after an update, copy here into `/storage/.config/ruffle/` if you want the newest binary or map |

If launch fails because files are missing, run once:

```bash
mkdir -p /storage/.config/ruffle
cp -a /usr/config/ruffle/* /storage/.config/ruffle/
```

---

## System controller map (`ruffle.gptk`)

Before the emulator sees input, **`gptokeyb`** translates controller events into keyboard or mouse signals.

The stock **`ruffle.gptk`** is intentionally minimal:

- **Left analog stick** → mouse movement (`mouse_movement_*`)
- **All other buttons** → unmapped (`\`) to avoid accidental keypresses

To tune pointer speed, edit **`mouse_scale`**, **`mouse_delay`**, and **`deadzone_triggers`** in **`/storage/.config/ruffle/ruffle.gptk`**, then relaunch the game.

---

## In-emulator controls (`sdl2test-rocknix`)

The mappings below are handled inside the emulator (on top of **`ruffle.gptk`**). Button names follow a typical Xbox layout; **Select** may appear as **Back** on some devices.

### Default keyboard map

| Controller | Keyboard |
|------------|----------|
| A | S |
| B | A |
| X | J |
| Y | U |
| L | A |
| R | D |
| L2 | W |
| R2 | S |
| L3 | O |
| R3 | L |
| Start | I |
| Select | K |

### Combos

| Combo | Action |
|-------|--------|
| Select + X | Toggle **mouse mode** / **keyboard mode** |
| Select + A | Toggle D-pad **WASD** mode (`sdl2test-rocknix` only) |
| Guide | Exit game |

### Mouse mode

Games start in **mouse mode** by default.

While in mouse mode:

- **D-pad** moves the pointer
- **Y** acts as **left mouse button**
- **L2 / R2** still follow the keymap table above

In keyboard mode, face buttons map to keyboard keys per the table.

> **Tip:** **`ruffle.gptk`** already maps the left stick to mouse movement; the D-pad also moves the pointer inside the emulator. Adjust **`mouse_scale`** in **`ruffle.gptk`** if the cursor feels too fast or slow.

---

## Per-game key overrides (`.cfg`)

You can override the built-in keymap for a single SWF. Let `{gamename}` be the file name without extension. Lookup order:

1. **Next to the SWF:** `{gamename}.cfg` (preferred)
2. **Under a `keymap` folder:** `keymap/{gamename}.cfg`

Example layout:

```text
/storage/roms/flash/
├── game.swf
├── game.cfg          # used first
└── keymap/
    └── game.cfg      # fallback
```

### File format

One mapping per line: `ButtonName=KeyName`. Lines starting with `#` are comments:

```ini
# comment
A=S
B=A
X=J
Y=U
L=A
R=D
L2=W
R2=S
L3=O
R3=L
Start=I
Select=K
```

### Supported button names

- `A`, `B`, `X`, `Y`
- `L`, `R`
- `L2`, `R2`
- `L3`, `R3`
- `Start`, `Select`

### Supported key names

- Letters: `A` – `Z`
- Numpad digits: `Num0` – `Num9`
- Arrows: `Up`, `Down`, `Left`, `Right`
- Function keys: `F1` – `F12`
- Special keys: `Space`, `Return`, `Escape`, `Tab`, `Backspace`, `Delete`, `Insert`, `Home`, `End`, `PageUp`, `PageDown`

---

## Troubleshooting

| Symptom | What to try |
|---------|-------------|
| No Flash system in ES | Use an **RK3326** image that includes **ruffle-sa**; add `.swf` files under `/storage/roms/flash/` |
| “Binary not found” on launch | Copy `/usr/config/ruffle/` → `/storage/.config/ruffle/` as shown above |
| Pointer hard to control | Press **Select + X** to switch modes; tweak **`mouse_scale`** in **`ruffle.gptk`** |
| One game needs different keys | Add **`{gamename}.cfg`** beside the SWF |

---

Upstream emulator: [ruffle-aurknix](https://github.com/AveyondFly/ruffle-aurknix)
