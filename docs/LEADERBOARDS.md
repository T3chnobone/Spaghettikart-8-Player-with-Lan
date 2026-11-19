# Time Trial Leaderboards

The 10 best Time Trial times for every track, saved on this PC.

## Setting a time

Finish a Time Trial. If your time makes the top 10 for that track, the game
shows **NEW RECORD!** with your place, time, driver and where you land on the
board, drawn in the game's own font. Enter your name (up to 7 letters) with
the controller:

- **Up/Down** change the letter, **Left/Right** move, **A** next letter
  (A on the last letter saves), **B** delete.
- **Z** fills in your driver's name (e.g. LUIGI).
- **START** saves. **START+B** skips without saving.

Your last name is filled in for you. While the entry is up, player 1's
controller only types the name, so the results menu behind it waits.

Wherever the game shows a best race or best lap time (the course intro,
the Time Trial results and the DATA screen), it now shows the name of the
player who set it in place of the driver, if that time is on the board.

Replays ("watch replay" after a Time Trial) are never recorded. Name entry is
also off during LAN netplay, so it can't hold up the other PCs.

## Browsing

**On the DATA screen** (R on the main menu): open a track and its **TOP 10**
page comes up first: place, player name, driver and time, plus the best lap.
**Z** flips to the game's own records page and back; B goes back as usual.

**In the Port Menu:**
**Enhancements → Leaderboards → Open Leaderboards.** Pick a track
to see its board: place, name, time, best lap, driver and date. Custom tracks
get their own boards; tracks with times that are no longer installed are still
listed. Each track's times can be cleared, and the name prompt can be turned
off.

## Storage

`leaderboards.json` in the game folder (next to the saves). It's plain JSON,
keyed by each track's resource name (e.g. `mk:mario_raceway`), with times in
hundredths of a second. It's written atomically, so a crash mid-save can't
corrupt it, and a damaged file is ignored rather than crashing the game.

## Code map

| File | Role |
| --- | --- |
| `src/port/leaderboard/Leaderboard.{h,cpp}` | Boards, ranking, JSON load/save, time formatting. No game code. |
| `src/port/leaderboard/LeaderboardGame.{h,cpp}` | Detects a finished Time Trial, gamepad name entry, saving. |
| `src/port/ui/LeaderboardWindow.{h,cpp}` | Name entry window and the browse window. |
| `src/racing/race_logic.c`, `src/main.c`, `src/port/Game.cpp` | Hooks: race finished, controller input, per-frame tick. |
