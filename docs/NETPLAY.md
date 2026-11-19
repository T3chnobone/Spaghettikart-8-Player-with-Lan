# LAN Netplay

> **Note:** the 8-player Grand Prix has been removed. The main menu's 1P column
> is always 1 player and 2P is 2 players. For more players use **COUCH PARTY**
> (one PC) or **LAN GAME** (several PCs). The sections below on the Grand Prix
> describe the earlier build.


Play SpaghettiKart with up to **8 people on separate PCs** over a local network.

## LAN GAME (from the main menu)

The easy way: on the main menu go right to **LAN GAME** (the 4th column), pick
**VS** (and a class) or **BATTLE**, and the LAN setup screen opens. It's all
controller driven and drawn with the game's own font:

- **GAME:** HOST or JOIN (Left/Right).
- **YOUR ADDRESS** (host) / **HOST ADDRESS** (join, digit by digit with
  Up/Down, A to edit).
- **YOUR NAME:** A to edit, Up/Down letter, Left/Right move, B delete, START done.
- **PLAYERS ON THIS PC:** 1–4, each with their own controller (ports 1..n on
  that PC) and their own split-screen view. 8 players in all.
- **INPUT DELAY** (host): AUTO or 0–8 frames. **PORT:** 27064.
- Host: the panel lists who's in; **START RACE** (or START) when there are 2+.
- Join: the panel lists **games found on this network** (UDP broadcast on the
  same port); pick one and press A, or type the address and CONNECT. Z looks
  again. B leaves.

When the host starts, every PC goes to character select together; each player
moves their own numbered cursor. Races run like Couch Party (VS: no CPUs,
ends when all but one finish; Battle: last one with balloons wins), with each
PC showing only its own players' views, laid out by its own split-screen
setting. The results panel's Quit (or quitting from pause) ends the session
for everyone.

The netplay window below is still there for the 8-player Grand Prix.

## Netplay window

There are two match types:

- **Big race (default, 2–8 players).** A Grand Prix where every kart that has a
  player behind it is human, and each PC shows its own kart full-screen with
  its own HUD. Empty slots are filled with CPU drivers.
- **Split-screen (2–4 players).** The classic couch view, mirrored on every PC.
  Use this for Versus or Battle.

## How it works

Every PC runs the full game. Each frame, every player's controller input goes
to the host, the host bundles all inputs for that frame and sends the bundle
back out, and every PC runs the frame with the same inputs. This is
*deterministic lockstep*: as long as every PC starts in the same state and runs
the same build, the races stay identical everywhere. Only inputs cross the
network (a few KB/s per player).

- Transport: TCP on port **27064** (configurable), Nagle disabled. Finding
  games uses UDP on the same port number.
- Topology: star. Clients talk only to the host. Each PC can have several
  players (protocol version 2); players are numbered PC by PC.
- Input delay: inputs take effect N frames after they are pressed (default 2),
  which hides network latency. Raise it if play stutters over Wi-Fi.
- Desync detection: every 30 frames each PC hashes the RNG seed, menu state and
  every kart's position, velocity, type and item. The host compares them and
  everyone is warned if they differ.

### Big race internals

The stock game allows 4 human players, and its 1-player Grand Prix already
simulates 8 karts. A big race runs that 1-player Grand Prix on every PC and
switches karts 2..N from CPU to human control:

- Players 1–4 use the normal controller slots; players 5–8 get their own
  controller storage so the stock "any controller" and ghost-replay slots keep
  working (`get_player_controller()`).
- Per-human state that was sized for 4 (HUD, item windows, Lakitu) is sized for
  8, and the per-human updates (item roulette, laps, Lakitu, item use, pause,
  palm trees, Thwomps) run for every human driver.
- Every kart gets full physics. The stock game moves karts far from P1's camera
  on rails, which would otherwise apply to other PCs' players.
- The race waits for every human to finish (up to 45 seconds after the first
  finisher) before the results.
- Rendering is the only per-PC difference: the spare second race camera follows
  this PC's kart and the HUD reads that kart's data. The camera that game logic uses
  (the first race camera, following P1) stays identical on every PC.

## Playing

1. Every player opens **Port Menu → Enhancements → LAN Netplay → Open Netplay Window**
   and picks a character there.
2. The host enters a name and clicks **Host**. Find the host's LAN IP with
   `ipconfig` (Windows) or `ip addr` (Linux/macOS).
3. Everyone else enters the host's IP and clicks **Join**.
4. The host chooses **Big race** or **Split-screen** and clicks **Start match**.
   All PCs jump to the main menu on the same frame.
5. **Big race:** the host picks **1P → Mario GP**, their own character, the class
   and the cup. Everyone else drives the character they chose in the Netplay
   window.
   **Split-screen:** the host picks a 2/3/4-player mode and each player picks
   their character with their own controller.

Each PC uses its own controller 1 (or keyboard) as its player. The host (P1)
drives the menus and the post-race screens.

## Requirements and limits

- **Same build everywhere.** Floating-point results can differ between
  compilers/OSes, so mixed Windows/Linux/macOS matches are refused.
- **Same mods / custom tracks** and the same Extra (mirror) mode unlock state;
  mismatches are rejected at join with a reason.
- Gameplay settings from Enhancements (cheats, rulesets, traffic counts, custom
  CC, game speed...) are copied from the host for the match and restored
  afterwards. Changing them mid-match will desync.
- Pressing Reset, or any player quitting or stalling for 5 seconds, ends the
  match for everyone. The remaining PCs continue offline.
- LAN only: there is no NAT traversal, and lockstep with input delay is meant for
  low-latency links. Internet play would want rollback netcode.

Big race limits (first version, untested on real hardware):

- Grand Prix only. Versus/Battle with more than 4 players would need new menus.
- Track objects that the stock game only animates near P1's camera (some
  hazards and scenery) behave as they do for P1 on every PC.
- Sound is heard from P1's position; look-behind (C-down) only works for P1.
- The Grand Prix continue/retry decision after a race belongs to P1, and the
  results and points screens list players 2–8 by character name.
- If the desync warning appears, please report which track and what happened.

## Code map

| File | Role |
| --- | --- |
| `src/port/netplay/NetplayCore.{h,cpp}` | Sockets, protocol, lobby, lockstep, desync check. No game code. |
| `src/port/netplay/Netplay.{h,cpp}` | Game glue: start-state snapshot, CVar sync, compatibility check, state hash, C API. |
| `src/port/netplay/netrace.{h,c}` | Big race: human drivers 2–8, their controllers, grid, finish gate, view player. |
| `src/port/ui/NetplayWindow.{h,cpp}` | ImGui host/join window, match type, character pick. |
| `src/main.c` | Synced inputs after controller poll; renders this PC's kart in big races. |
| `src/port/Game.cpp` | Pumps the network, synced reset at match start, one Lakitu per human. |
| `src/code_80057C60.c`, `src/code_8006E9C0.c` | Per-human HUD, items, laps; HUD follows this PC's kart. |
| `src/player_controller.c`, `src/racing/*.c`, `src/spawn_players.c`, `src/update_objects.c`, `src/menu_items.c`, `src/actors/*`, `src/engine/objects/Thwomp.cpp` | 4-human limits lifted for big races. |
