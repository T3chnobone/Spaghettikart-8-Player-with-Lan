# Replaceable menu pictures (textures folder)

Three menu pictures can be swapped for your own PNG files. They live in the
`textures` folder next to `Spaghettify.exe`:

| File | What it is | Size in the game | Tinted? |
|---|---|---|---|
| `couch_party_button.png` | Top of the 3rd main-menu column (COUCH PARTY) | 64 x 54 | no |
| `lan_game_button.png` | Top of the 4th main-menu column (LAN GAME) | 64 x 54 | no |
| `character_highlight.png` | Frame around the portrait a player is on, Couch Party character select | 64 x 76 | yes, in each player's colour |
| `character_highlight_p1.png` ... `_p8.png` | Optional: a frame of its own for one player | 64 x 76 | no |

## Rules

- **Format:** PNG with transparency (RGBA). 8-bit, palette and grey PNGs work too;
  JPG, BMP and TGA also load, but they have no transparency.
- **Size:** draw at the size above, or any multiple of it (2x = 128 x 108, 4x =
  256 x 216, ...) for a sharper picture. Any other size is stretched to fit. The
  largest accepted is 512 x 512.
- **Transparent pixels** show what is behind the picture (the menu background,
  or the character portrait for the highlight).
- **character_highlight.png** is multiplied by each player's colour (red, blue,
  yellow, green, orange, purple, cyan, pink for players 1 to 8). Draw it in white
  and grey to keep the colours; a coloured picture is mixed with them. The middle
  should be transparent so the portrait shows through. The player-number tag in
  the corner is still drawn by the game on top.
- A `character_highlight_pN.png` is used for player N as drawn, without the
  tint, and wins over `character_highlight.png` for that player.
- **Picked** characters still pulse, and the buttons still fade in and out with
  the menu, using the picture's own transparency.

## Going back to the built-in pictures

Delete (or rename) the file. If a file is missing, can't be read, or is bigger
than 512 x 512, the game draws its built-in picture instead and writes the reason
in the log (`logs/` folder).

The files are read once, when the menus first need them. Restart the game after
changing them.

## About the files that come with the game

The COUCH PARTY and LAN GAME buttons and the coloured frames are not textures in
the original game: they are drawn from boxes and text by the code. The files in
the package are images of them: the boxes are exact, the lettering is close but
uses a different font from the game's. Delete the two button files to get the
game's own lettering back.

The other menu textures that come from the ROM (the 1P/2P pictures, the stock
1P-4P cursors and so on) can already be replaced with SpaghettiKart's mod
folders: a folder or .zip/.o2r in `mods` holding `<resource path>.png`, for
example `textures/texture_tkmk00/texture_menu_3p_game.png`.
