# Orbit script (Matcha LuaVM + p UI)

Script for [Matcha LuaVM](https://matcha-latte.gitbook.io/matcha). Chaotic orbit camera around the selected player.

## How to run

In Matcha, run the loader only:

```lua
-- Paste contents of matcha_orbit_loader.lua or load the file
```

Or run `matcha_orbit_main.lua` directly (p library is loaded from URL inside it).

## Behavior

- **On start:** character is teleported to "space" `(123456789012, 123456789012, 123456789012)` and frozen (no falling).
- **GUI (p library):** Orbit tab → Players section → each player has an "Orbit: [name]" toggle. Turn on to orbit the camera around that player.
- **F1** — toggle menu open/close (p default).
- **Orbit:** camera moves around the target with varying radius and angles (chaotic, not a clean circle).
- **When target HP reaches 0:** orbit stops, character is teleported back to space and frozen.

## Files

- `matcha_orbit_main.lua` — main script (teleport, freeze, orbit, GUI, RunService).
- `matcha_orbit_chaos.lua` — chaos camera offset module (optional; main has inline fallback).
- `matcha_orbit_loader.lua` — loads chaos and main from URLs via loadstring.

## Dependencies

- Matcha LuaVM (RunService, game, Players, workspace, Camera).
- p library loaded from: `https://raw.githubusercontent.com/catowice/p/refs/heads/main/library.lua`

If Matcha does not provide `setrobloxinput`, `iskeypressed`, `isrbxactive` (used by p), the menu may not respond; stub them for your executor.
