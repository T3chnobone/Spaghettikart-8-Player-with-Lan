# Local Multiplayer (up to 8 players) and Multiple Screens

> **Note:** the 8-player Grand Prix has been removed. The main menu's 1P column
> is always 1 player and 2P is 2 players. For more players use **COUCH PARTY**
> (one PC) or **LAN GAME** (several PCs). The sections below on the Grand Prix
> describe the earlier build.


Up to 8 people on one PC, each with their own view, on one screen or spread
over several monitors.

Open it from **Port Menu → Settings → Local Multiplayer → Open Local Multiplayer & Screens**.

For VS races and Battles, use **COUCH PARTY** on the main menu instead (see
[COUCH_PARTY.md](COUCH_PARTY.md)); it uses the same split-screen and monitor
settings. This page's "Playing" section is the 8-player Grand Prix.

## Playing

1. Tick **Local multiplayer**, set the number of **Players** (2–8) and pick a
   character for players 2–8.
2. Plug in the gamepads. With **Give each gamepad its own player automatically**
   on, gamepad 1 drives player 1, gamepad 2 player 2, and so on (in connection
   order). Tick **Player 1 uses the keyboard** to shift every gamepad up one
   player. **Open bindings** shows all 8 ports if you want to remap.
3. In the game, choose **1P → Mario GP**. Player 1 picks their character, class
   and cup as usual.
4. Every player gets their own view with their own HUD (item, laps, place).
   Empty grid slots are CPU drivers.

## Screens and resolution

- **Split screen:** how the views are arranged on each screen.
  *Automatic* picks the grid whose views are closest to 4:3; *Side by side*
  puts everyone in one row; *Stacked* puts everyone in one column; *Two rows*
  gives 2x2 for 3-4 players and 4x2 for 7-8. Also on the Couch Party lobby.

- **Monitors:** every monitor is listed with its resolution and position. Tick
  the ones to use and turn on **Span the game window across the ticked
  monitors**: the window becomes borderless and covers them. Views are shared
  out over the ticked monitors (earlier monitors take any extra) and arranged
  in a grid on each, so each monitor keeps its own resolution. The preview in
  the window shows where every player will be.
- **View render scale (25–200%):** resolution each view is drawn at, relative to
  its size on screen. Lower it if 8 views run slowly.
- **Window size:** preset sizes (and each monitor's own size) when not spanning.
- Full screen is in Settings → General; the game's internal resolution is in
  Settings → Graphics.

## How it works

- **Race:** the same "big race" used by LAN netplay: the stock 1-player Grand
  Prix, which already simulates 8 karts, with karts 2..N switched to human
  control. See `docs/NETPLAY.md` for what that changes in the race code.
- **Inputs:** libultraship now has 8 controller ports (it had 4). Players 1–4
  use the normal controller slots; players 5–8 use their own storage so the
  game's "any controller" and ghost-replay slots keep working.
- **Cameras:** P1 and P2 use the 1P race's existing cameras; players 3–8 get one
  each.
- **Rendering:** each view is drawn as a normal full-screen 1-player frame into
  its own off-screen framebuffer, sized to its place on screen, then the
  views are composed onto the window. The renderer gained framebuffers with
  their own aspect ratio so a tall or wide view gets the right field of view
  instead of being stretched. Per-screen state that the game sized for 4 split
  screens (kart animation frames, palettes, kart matrices, screen contexts) is
  sized for 8.
- **Spanning:** libultraship's window backends gained a monitor list and a
  borderless mode; spanning sets the window to the bounding box of the ticked
  monitors.

## Limits (first version, untested on real hardware)

- Grand Prix only (as for netplay big races).
- Sound is heard from P1's position; look-behind works for P1 only.
- The speedometer needle and the finish-screen HUD layout follow P1.
- The HUD is laid out for a 4:3 area; in very narrow views (e.g. 8 players on
  one 16:9 screen) elements near the edges may be cut off.
- Drawing 8 full views is roughly 8 times the rendering work of one; use the
  render scale on slower PCs.
- Monitors that don't line up into a rectangle leave parts of the spanning
  window off-screen; views are only placed on ticked monitors.
- Spanning has been written for both the SDL (OpenGL/Metal) and DXGI
  (DirectX 11) window backends but not tried on real multi-monitor setups.

## Code map

| File | Role |
| --- | --- |
| `src/port/localplay/localplay.cpp` | Settings, applying them to the race, gamepad assignment, spanning, window size. |
| `src/port/localplay/localplay_render.c` | Per-player cameras, drawing each view to its framebuffer, composing. |
| `src/port/localplay/ViewLayout.{h,cpp}` | Pure layout math: views over monitors, grid choice. |
| `src/port/ui/LocalPlayWindow.{h,cpp}` | The settings window and layout preview. |
| `libultraship` | 8 controller ports; own-aspect framebuffers; monitor list and borderless window. |
