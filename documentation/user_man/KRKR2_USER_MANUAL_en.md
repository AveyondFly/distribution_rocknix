# Kirikiri2 (KrKr2) User Guide

Chinese edition: [`KRKR2_USER_MANUAL_cn.md`](KRKR2_USER_MANUAL_cn.md).

This guide is for users launching **Kirikiri2 / KrKr2** games from the frontend. The frontend calls `start_krkr2.sh` automatically, so you normally only need to care about **game folder layout, the font file, `.kr2` launch rules, and controller mapping**.

---

## Where to put games

Place games under:

```text
/storage/roms/krkr2/
```

In EmulationStation the system is typically named **Kirikiri2**. The frontend only scans **`.kr2` / `.KR2`** as launch entries (it does **not** scan `.xp3` directly).

Use one subdirectory per game when possible, for example:

```text
/storage/roms/krkr2/MyGame/
├── MyGame.kr2
├── data.xp3          # or MyGame.xp3 when using the implicit rule
├── plugin.xp3        # optional
├── default.ttf       # recommended game font
└── savedata/         # may be created at runtime
```

---

## `.kr2` launch rules

The frontend starts a **`.kr2` stub**. The engine resolves the real `.xp3` package as follows:

| Case | Behavior | Example |
| --- | --- | --- |
| `name.kr2` **specifies** an xp3 file name | Use that content and open the matching xp3 in the same folder | `MyGame.kr2` contains `data.xp3` → launches `MyGame/data.xp3` |
| `name.kr2` **does not specify** a valid xp3 | Fall back to the implicit `name.xp3` | Empty / unspecified `MyGame.kr2` → launches `MyGame/MyGame.xp3` |

Notes:

- A `.kr2` file is normally plain text with one relative path line, e.g. `data.xp3`.
- Specified paths are relative to the directory that contains the `.kr2`.
- Save data is usually written under `savedata/` in the game directory (exact behavior depends on the engine/game).

---

## Font file

The engine loads fonts from the **current game directory**:

| File | Recommended | Notes |
| --- | --- | --- |
| `<game dir>/default.ttf` | Yes | Place a TrueType font named `default.ttf` next to the `.kr2`. Recommended for Chinese text or games that need a specific typeface. |

If a suitable font is missing, on-screen text may show as blanks, tofu blocks, or missing glyphs. Put a working `default.ttf` in the same folder as the `.kr2`.

---

## Controller mapping

Controller buttons are mapped through `gptokeyb`. The active config file is:

```text
/storage/.config/krkr2/krkr2.gptk
```

Built-in defaults live in `/usr/config/krkr2/`. On first run, the start script tries to sync them into `/storage/.config/krkr2/`.

| Controller input | KrKr2 result |
| --- | --- |
| DPad / Left analog | Mouse movement |
| A | Mouse left click |
| B | Mouse right click |
| X | `Space` |
| Y | `Esc` |
| Start | `Enter` |
| Back (Select) | `Esc` |
| Guide | `Enter` |
| L1 | `Home` |
| R1 | `End` |
| L2 / R2 / L3 / R3 / Right analog | Unmapped |

Mouse-related tunables in `krkr2.gptk`:

| Setting | Purpose |
| --- | --- |
| `mouse_scale` | Mouse movement sensitivity (default `4096`) |
| `mouse_delay` | Mouse movement interval (default `16`) |
| `deadzone_x` / `deadzone_y` | Stick deadzones |
| `deadzone_triggers` | Trigger deadzone |

Restart the game after editing `krkr2.gptk` so the new mapping is loaded.

---

## Runtime paths

| Path | Notes |
| --- | --- |
| `/usr/bin/start_krkr2.sh` | Frontend launch script |
| `/usr/config/krkr2/` | Image-bundled binary and default `krkr2.gptk` |
| `/storage/.config/krkr2/` | User-side config and binary copy |
| `/storage/.config/krkr2/log.txt` | Last-run log (useful for path/font troubleshooting) |

---

## Notes

- **High memory usage:** Kirikiri2 games (especially large packages) can use a lot of RAM. On devices with **about 1GB of memory**, some titles may fail to start or crash at runtime due to insufficient memory. If that happens, close other background apps first, or try a device with more RAM.
- Frontend entry extensions are only **`.kr2` / `.KR2`**. `.xp3` packages are referenced by the `.kr2` rules and do not appear in the system game list.
- Most Kirikiri2 titles are mouse-driven, so the default mapping centers on mouse move and left/right click.
- If launch fails, check `/storage/.config/krkr2/log.txt` for path resolution and font-load messages.
