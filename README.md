# HUD for Quake

A Quake client-side mod for adding a N64/2021 HUD layout to the game.  This layout isn't exactly the same as the 2021 rerelease, but it's close.  I used a little artistic license in this mod.

![2021 HUD style](https://i.imgur.com/T7e9LWg.jpg)

## Install

Simply copy the ``csprogs.dat`` file into your ``id1`` or other mod folder.

## Scarlet Mod

This HUD pairs with [Scarlet](https://github.com/whipowill/quake-mod-scarlet), my personal Quake perfection mod focused on blood, balance, bots, and multiplayer arena.  Scarlet tells the HUD what it supports, and the HUD turns each feature on by itself.  There is nothing to configure on your end, and on any other server these features stay hidden.

- **Deaths & Assists** - extra scoreboard columns, shown when the server tracks them
- **Teamplay Scoreboard** - team players are grouped and scored together
- **Teammate Markers** - a marker in the teammate's color floats over each teammate
- **Bot Declarations** - when bots are playing, column shows each bot's skill level
- **Halo Nameplates** - the name of the player appears on the screen when aiming at them

|   |   |   |
|---|---|---|
| ![HUD screenshot](https://i.imgur.com/btgPBvc.jpeg) | ![HUD screenshot 3](https://i.imgur.com/zBtmhVk.png) | ![HUD screenshot 4](https://i.imgur.com/4lzaPkw.png) |

## Commands

- ``cl_weapons 1`` - will show weapons you possess on the HUD (default ``0``)
- ``cl_hudtest 1`` - display all icons on the HUD for testing purposes (default ``0``)

## Changelog

- October 2026
	- Tried to fix issues w/ Rogue expansion (untested)
	- Scarlet Mod
		- Scoreboard now detects team play and will show team scores
		- Scoreboard now shows deaths and assists
		- Teammates have icons that show above their heads
		- Nameplates show when aiming at a player

## Issues

My understanding is this mod will work on both QS and FTE engines, but if there is an issue the solution would involve swapping out ``qsextensions.qc`` w/ ``fteextensions.qc`` and recompiling the code.

## Credits

- Original code by [ClanRing](https://github.com/quakeone/crmod-plus)

## External Links

- [CSQC Extension](https://quakewiki.org/wiki/EXT_CSQC)
- [CSQC Guide For Idiots](https://quakewiki.org/wiki/CSQC_guide_for_idiots)
- [Client-Side QuakeC](https://www.quakewiki.net/darkplaces-wiki/client-side-quakec/)