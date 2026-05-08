# EKA2L1 SDL2 User Guide

## First Launch: Installing Firmware

If no installed Symbian device firmware is detected on first launch, the program opens the firmware installation screen.

Two files are required:

- `ROM`: the device ROM file.
- `RPKG`: the device firmware package, usually ending with `.rpkg`.

Controls:

- `Arrow keys`: move between `ROM`, `RPKG`, `Install`, and `Exit`.
- `Enter`: open the selected item or confirm.
- In the file picker, `Enter` opens a folder or selects a file.
- In the file picker, `Left` or `Backspace` goes to the parent folder.
- `Esc`: go back or exit the current screen.

After selecting both `ROM` and `RPKG`, the `Install` button becomes available. Press `Enter` on `Install` to start installation. After installation finishes, the application launcher will open.

## Application Launcher

The launcher shows the installed applications as an icon grid.

Launcher controls:

- `Arrow keys`: move the selection.
- `2 / 4 / 6 / 8`: navigate up, left, right, and down. This only applies in the launcher.
- `Enter`: launch the selected application.
- `F1` or `F5`: open the SIS/SISX installer.
- `Space`: delete the selected application.
- `Esc`: exit the frontend.

## Installing Applications

Press `F1` or `F5` in the application launcher to open the application installer.

Controls:

- Select `SIS/SISX` and press `Enter` to open the file picker.
- Select a `.sis` or `.sisx` file.
- Back in the installer screen, select `Install` and press `Enter`.
- After installation finishes, select `Exit` or press `Esc` to return to the launcher.

The launcher refreshes automatically after returning, so newly installed applications should appear in the grid.

## Deleting Applications

In the application launcher, move the cursor to the application icon you want to delete and press `Space`.

Delete confirmation controls:

- `Cancel` is selected by default to prevent accidental deletion.
- `Left / Right`: switch between `Delete` and `Cancel`.
- `Enter` or `Space`: confirm the selected action.
- `Esc`: cancel deletion.

Choosing `Delete` uninstalls the application and removes its installed files. Applications built into the ROM cannot be deleted.

## In-Game Controls

While a game is running, launcher-only `2 / 4 / 6 / 8` navigation is disabled. These keys continue to work as numeric input.

Default in-game controls:

- `Arrow keys`: directional input.
- `Enter`: OK / middle key / select.
- `F1`: left softkey.
- `F2`: right softkey.
- `F3`: green call key.
- `F4`: red end key.
- `Esc`: red end / cancel.
- `Backspace`: backspace.
- `Space`: space.
- `0` to `9`: numeric keys.

When a game exits through its own in-game exit option, the frontend returns to the application launcher.

## Screen Rotation

Display rotation can be changed while a game is running:

- `R`: rotate clockwise by 90 degrees each time. The cycle is `0 -> 90 -> 180 -> 270 -> 0`.
- `F5`: open the rotation OSD menu.

OSD controls:

- `Left / Right`: change the rotation angle.
- `Enter`, `Esc`, or `F5`: close the OSD menu.

Directional input is automatically remapped to match the current screen rotation.
