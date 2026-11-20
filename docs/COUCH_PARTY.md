# Couch Party (VS and Battle for up to 8 players)

(For players on several PCs, use **LAN GAME** next to it: see NETPLAY.md.)

VS races and Battles for 2 to 8 people on one PC, each with their own view.

## Playing

1. On the main menu, move right to the third column, **COUCH PARTY** (it
   replaces 3P and 4P). Choose **VS** (then a class) or **BATTLE** and OK.
2. The normal **character select** screen opens. Player 1 is already in:
   it's the controller that was driving the menus. Everyone else presses **A**
   on their own controller to join, up to 8. Each player's cursor is a box in
   their own colour with their number (1–8) in the corner.
   - Move the cursor and press **A** to pick, **B** to un-pick — exactly as in
     the original.
   - **B** before picking makes a joined player (2P–8P) leave again; player
     1's B goes back to the main menu, as usual.
   - When at least 2 players have joined and everyone has picked, **OK?**
     appears and each picked character moves to where that player's view
     will be on the split screen. A goes on.
3. Player 1 picks the cup and course, as usual.
4. Everyone gets their own view and HUD, arranged by the **Split screen**
   setting (Settings → Local Multiplayer, where the monitors are too). Each
   player keeps the controller they joined with.

**VS:** 3 laps, VS items, no CPU drivers. The race ends when all but one player
have finished.
**Battle:** 3 balloons each; the last player with balloons wins. Players 1–4
start on the usual 4-player spots and players 5–8 beside them.

After each race a results panel shows the places and each player's wins this
session. Any player picks **Race again**, **Change course**, **Change drivers**
(back to character select with everyone still joined) or **Quit to menu** with
Up/Down and A. For the first second and a half the options are greyed out
("Get ready...") so buttons still being pressed from the race can't pick one,
and a button held through that pause has to be let go and pressed again. The
pause menu works as in a normal VS race.

To get the stock 3P/4P columns back, untick **COUCH PARTY on the main menu**
in Settings → Local Multiplayer. Couch Party is off during LAN netplay.

## Controllers

Gamepads are given ports in connection order (Settings → Local Multiplayer →
"Give each gamepad its own player automatically"); the keyboard is port 1
unless remapped. Joining just picks which port each player is, so the order
people join in doesn't need to match.

## How it works

A couch race is the single-screen (1P) race in VS or Battle mode with every
joined player switched to human — the same machinery as the 8-player Grand
Prix (`netplay/netrace`, `localplay/`). The menus stay on the 3-player column
so the stock VS/Battle options, course select and pause menus are used; only
for the race itself is it switched to one screen and drawn as per-player
views.

## Limits (first version, untested on real hardware)

- The results are an overlay panel, not an N64-style screen.
- In Couch Party the cursors are drawn as numbered coloured boxes (the game
  only has cursor art for 1P–4P), for all players alike.
- The VS win counters on the stock results screens aren't updated.
- Battle start spots for players 5–8 are offsets from the stock ones; on custom
  battle arenas everyone uses Block Fort's spacing.

## Code map

| File | Role |
| --- | --- |
| `src/port/couch/CouchParty.{h,cpp}`, `couch.h` | Joining the character screen, controller order, race setup, results. |
| `src/port/ui/CouchWindow.{h,cpp}` | The results panel. |
| `src/menus.c`, `src/menu_items.c` | Third main menu column; 8 cursors on the character screen; hooks into the menu states. |
| `src/spawn_players.c` | 8-player VS grid and Battle spots. |
| `src/racing/race_logic.c` | VS finish, Battle eliminations, results instead of the stock zoom. |
| `src/player_controller.c`, `src/render_player.c`, `src/code_80057C60.c`, `src/render_objects.c`, `src/code_80005FD0.c`, `src/engine/RaceManager.cpp` | Every couch player drives, is drawn, ranked, on the minimap, and gets VS items. |
