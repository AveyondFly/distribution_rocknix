# drastic_adv dual-screen layouts & bezel guide (English)

Simplified-Chinese counterpart: **`DRASTIC_USER_MANUAL_cn.md`**.

## Table of contents

1. [Introduction](#introduction)
2. [File locations](#file-locations)
3. [`layout.json` schema](#layoutjson-schema)
4. [Layout modes (`type`)](#layout-modes-type)
5. [Authoring a custom layout](#authoring-a-custom-layout)
6. [Themes & background art](#themes--background-art)
7. [Worked examples](#worked-examples)
8. [FAQ](#faq)

---

## Introduction

drastic_adv loads `layout.json` to anchor the DS **top (`screen0`)** and **touch (`screen1`)** outputs anywhere on the framebuffer, optionally with transparency, bezel art, rotations, and instant switching between presets.**Capabilities:**

- Reposition both screens arbitrarily
- Use transparent/stacked HUD mode
- Decorate with fullscreen backdrop PNG/JPEG
- Store multiple presets and flip between them instantly

---

## File locations

```
/storage/.config/drastic/resources/bg/[WxH]/layout.json
```

`[WxH]` matches framebuffer mode, examples:

| Native mode | Folder |
|-------------|--------|
| 1920×1080 | `1920x1080` |
| 1280×720 | `1280x720` |
| 640×480 | `640x480` |

1080p sample path:

```
/storage/.config/drastic/resources/bg/1920x1080/layout.json
```

---

## `layout.json` schema

### Outer object

```json
{
  "name": "My pack",
  "layout": [
    { "...": "..." }
  ]
}
```

| Field | Type | Req. | Meaning |
|-------|------|------|---------|
| `name` | string | no | Human label for toolkit/debug |
| `layout` | array | **yes** | Ordered list of mode entries |

Per-entry fields:

| Field | Type | Req. | Meaning |
|-------|------|------|---------|
| `index` | int | yes | Increasing slot id (0,1,…) |
| `type` | int | yes | `0‑4`, see modes below |
| `name` | string | no | In-game picker label |
| `bg` | string | no | Background filename co-located with JSON |
| `rotate` | int | no | `0` upright, `90` CW, `270` CCW semantics per build |
| `screen0_*` | int | yes | Bounding box for **top screen** (`x`,`y`,`w`,`h`) |
| `screen1_*` | int | yes | Bounding box for **touch screen** |

Coordinate system origin is **upper-left**. +X heads right, +Y heads down:

```
(0,0) ─────────────► X
  │
  │   ┌──────────┐
  │   │ screen0 │  (DS top LCD)
  │   └──────────┘
  │           ┌────┐
  │           │ s1 │
  └───────────┘    ▼ Y
```

---

## Layout modes (`type`)

### `type: 0` — NORMAL classic side‑by‑side

```
{
  "index": 0,
  "type": 0,
  "name": "Side layout",
  "screen0_x": 64,
  "screen0_y": 60,
  "screen0_w": 1280,
  "screen0_h": 960,
  "screen1_x": 1408,
  "screen1_y": 372,
  "screen1_w": 448,
  "screen1_h": 336
}
```

### `type: 1` — TRANSPARENT HUD

Fullscreen top LCD; bottom LCD rendered translucent overlay (alpha tweaks live in emu menu Position/Alpha binds). Great for RPG where map dominates HUD.

Example skeleton:

```
{
  "index": 1,
  "type": 1,
  "name": "Transparent HUD",
  "screen0_x": 0,
  "screen0_y": 60,
  "screen0_w": 1280,
  "screen0_h": 960,
  "screen1_x": 1280,
  "screen1_y": 300,
  "screen1_w": 640,
  "screen1_h": 480
}
```

> Note: XY here seed scale; realtime corner snapping uses in-emulator Position toggles (**Select+R1**, etc.—see FAQ).

### `type: 2` — VERT stacked

Upper LCD above touch LCD.

```
{
  "index": 2,
  "type": 2,
  "name": "Vertical stack",
  "screen0_x": 600,
  "screen0_y": 0,
  "screen0_w": 720,
  "screen0_h": 540,
  "screen1_x": 600,
  "screen1_y": 540,
  "screen1_w": 720,
  "screen1_h": 540
}
```

### `type: 3` — HIGH‑RES emphasize top

Max top screen with secondary panel docked sideways.

```
{
  "index": 3,
  "type": 3,
  "name": "Top priority",
  "screen0_x": 0,
  "screen0_y": 0,
  "screen0_w": 1440,
  "screen0_h": 1080,
  "screen1_x": 1440,
  "screen1_y": 360,
  "screen1_w": 480,
  "screen1_h": 360
}
```

### `type: 4` — SINGLE (hide partner)

Keeps roughly 4:3 host mapping for surviving LCD; counterpart sizes may be zeros.

```
{
  "index": 4,
  "type": 4,
  "name": "Single LCD",
  "screen0_x": 240,
  "screen0_y": 0,
  "screen0_w": 1440,
  "screen0_h": 1080,
  "screen1_x": 0,
  "screen1_y": 0,
  "screen1_w": 0,
  "screen1_h": 0
}
```

Keep **multiple of 256×192**, ideally **maintain ~4:3** to dodge stretch.

---

## Authoring a custom layout

### 1) Measure framebuffer

Identify exact width×height ROCKNIX reports for your SKU (retroarch overlays + `weston-debug`/`modetest` clues).

### 2) Decide integer scale factors

Native DS buffers = **256×192** each.**Common embiggen**:

| Factor | WxH |
|--------|-----|
| 1× | 256×192 |
| 2× | 512×384 |
| 3× | 768×576 |
| 4× | 1024×768 |
| 5× | **1280×960** handy for tops |
| 5.625× | **1440×1080** fills 1080p height |

Centre formula:

```
x = (panel_w - lcd_w)//2
y = (panel_h - lcd_h)//2
```

### 3) Author JSON UTF‑8 lowercase filename `layout.json`

Validate commas/brackets.**Tip:** run through `jq` or vscode JSON schema.

### 4) Deploy into proper `bg/<WxH>/` tree

Ownership should be whoever runs drastic (usually writable under `/storage`).

### 5) Relaunch drastic

Cold start ensures shaders rebuild around new rects.

---

## Themes & background art

- **`bg`** field references PNG/JPEG sharing folder with JSON, ideally identical resolution as host mode.
- You may fan out numbered subfolders (`1/`,`2/`…) swapping themes from UI.
- Emulator resolves relative paths vs active theme bundle.

Minimal sample:

```
{
  "index": 0,
  "type": 0,
  "name": "Wallpaper BG",
  "bg": "my_background.png",
  ...
}
```

---

## Worked examples

### 1080p all‑in‑one presets

Exact clone of Chinese appendix sample (modes 0,2,3,1,4):

```json
{
  "name": "1080p presets",
  "layout": [
    {
      "index": 0,
      "type": 0,
      "name": "Side layout",
      "bg": "bg_normal.png",
      "rotate": 0,
      "screen0_x": 64,
      "screen0_y": 60,
      "screen0_w": 1280,
      "screen0_h": 960,
      "screen1_x": 1408,
      "screen1_y": 372,
      "screen1_w": 448,
      "screen1_h": 336
    },
    {
      "index": 1,
      "type": 2,
      "name": "Stacked vertical",
      "bg": "bg_vertical.png",
      "rotate": 0,
      "screen0_x": 600,
      "screen0_y": 0,
      "screen0_w": 720,
      "screen0_h": 540,
      "screen1_x": 600,
      "screen1_y": 540,
      "screen1_w": 720,
      "screen1_h": 540
    },
    {
      "index": 2,
      "type": 3,
      "name": "Top dominates",
      "bg": "bg_fullscreen.png",
      "rotate": 0,
      "screen0_x": 0,
      "screen0_y": 0,
      "screen0_w": 1440,
      "screen0_h": 1080,
      "screen1_x": 1440,
      "screen1_y": 360,
      "screen1_w": 480,
      "screen1_h": 360
    },
    {
      "index": 3,
      "type": 1,
      "name": "Transparent HUD",
      "bg": "",
      "rotate": 0,
      "screen0_x": 0,
      "screen0_y": 60,
      "screen0_w": 1280,
      "screen0_h": 960,
      "screen1_x": 1280,
      "screen1_y": 300,
      "screen1_w": 640,
      "screen1_h": 480
    },
    {
      "index": 4,
      "type": 4,
      "name": "Single screen",
      "bg": "",
      "rotate": 0,
      "screen0_x": 240,
      "screen0_y": 0,
      "screen0_w": 1440,
      "screen0_h": 1080,
      "screen1_x": 0,
      "screen1_y": 0,
      "screen1_w": 0,
      "screen1_h": 0
    }
  ]
}
```

### 720p compact pair

```json
{
  "name": "720p minimal",
  "layout": [
    {
      "index": 0,
      "type": 0,
      "name": "Standard",
      "bg": "",
      "rotate": 0,
      "screen0_x": 0,
      "screen0_y": 0,
      "screen0_w": 960,
      "screen0_h": 720,
      "screen1_x": 960,
      "screen1_y": 240,
      "screen1_w": 320,
      "screen1_h": 240
    },
    {
      "index": 1,
      "type": 1,
      "name": "Transparent",
      "bg": "",
      "rotate": 0,
      "screen0_x": 0,
      "screen0_y": 0,
      "screen0_w": 960,
      "screen0_h": 720,
      "screen1_x": 960,
      "screen1_y": 240,
      "screen1_w": 320,
      "screen1_h": 240
    }
  ]
}
```

---

## FAQ

### Q1 Changes ignored?

Validate filename `layout.json` (lowercase), directory matches live video mode JSON syntax (JSONLint).

### Q2 Weird stretch?

Maintain ~`256:192` ratio when resizing each screen pair.

### Q3 Transparency corner?

Use **Settings (Select+B) → Position** or **Select+R1** carousel (top-right/top-left/etc.)—not raw JSON alone.

### Q4 Transparency strength?

Settings → **Alpha** or **Select+L1** increments.

### Q5 Cycling authored modes?

Hold **Select+B**, pick **Layout**, or mash **L2** quick cycle.

### Q6 Theme swap?

**Select+B → Theme**, or **Select+L2**.

### Q7 Missing wallpaper?

Ensure asset path & extension match **`bg`** case-sensitively & lives under theme folder.

---

## Shortcut cheat sheet

| Combo | Behaviour |
|-------|-----------|
| Select + B | Open/close quick menu |
| ↑ / ↓ | Menu cursor |
| ← / → | Tweaks value |
| B | Abort menu |
| L2 | Next `layout.json` preset |
| Select + L2 | Next wallpaper pack |
| Select + L1 | Alpha +/- |
| Select + R1 | HUD corner carousel |

Advanced pixel filter knobs stay inside same overlay (`Pixel…` submenu).

---

## Appendix — suggested widths

### 1080p

| Role | WxH | Scale note |
|------|-----|------------|
| Top LCD | 1280×960 | ~5× |
| Tall top | 1440×1080 | 5.625× |
| Compact bottom | 640×480 | 2.5× |
| Micro HUD | 448×336 | 1.75× |

### 720p

| Role | WxH |
|------|-----|
| Full height LCD | 960×720 |
| Large top | 768×576 |
| Tiny HUD | 320×240 |

### 480p

| WxH |
|-----|
| 640×480 (panel fill) |
| 512×384 |
| 256×192 (1× pristine) |

---

*Document revision 1.0 — drastic_adv ROCK fork branch.*
