# HUD for Quake

A Quake client-side mod for adding a N64/2021 HUD layout to the game.  This layout isn't exactly the same as the 2021 rerelease, but it's close.  I used a little artistic license in this mod.

![2021 HUD style](https://i.imgur.com/T7e9LWg.jpg)

Because this is a client-side mod, it means you can use it alongside other QuakeC mods (``progs.dat``) w/out issue.  The features particular to the Quake Rogue expansion and Scarlet Mod should be autodetected and applied.

## Install

Simply copy the ``csprogs.dat`` file into your ``id1`` or other mod folder.

## Changelog

- October 2026
	- Tried to fix issues w/ Rogue expansion (untested)
	- Scarlet Mod
		- Scoreboard now detects team play and will show team scores
		- Scoreboard now shows deaths and assists
		- Teammates have icons that show above their heads
		- Nameplates show when aiming at a player

## Scarlet Mod

This HUD pairs with [Scarlet](https://github.com/whipowill/quake-mod-scarlet), my personal Quake perfection mod focused on gore, bots, weapons balancing, and multiplayer.  Scarlet tells the HUD what it supports, and the HUD turns each feature on by itself.  There is nothing to configure on your end, and on any other server these features stay hidden.

- **Deaths, assists and K/D** - extra scoreboard columns, shown when the server tracks them (assists only if ``scarlet_assist_window`` is above 0).  The scoreboard is centered on the screen, and the columns follow the longest player name.
- **Teamplay scoreboard** - ``cl_teams`` turns on by itself when ``teamplay`` is on, so teams are grouped and scored together.
- **Grenades** - ``cl_grenades`` turns on by itself when Scarlet has grenades enabled.
- **Teammate markers** - in teamplay, a marker in the teammate's color floats over each teammate, visible through walls, drawn using your ``fov``.  The server controls it with ``scarlet_team_markers``, ``scarlet_team_marker_names`` (show names over the markers) and ``scarlet_team_marker_scale`` (marker size).
- **Bot column** - when bots are playing, a far-left ``Bot`` column shows each bot's skill level (0-3) color-coded (3 dark orange, 2 orange, 1 yellow, 0 green).  Humans are left blank.
- **Nameplates** - when ``scarlet_nametags`` is on, the name of the player under your crosshair fades in just above it, stays for a moment after you look away, then fades out.

## Commands

In theory you would never need to use any of these commands bc the mod will autodetect what you're playing and turn them on.

- ``cl_teams 1`` - change scoreboard to teamplay mode (default ``0``, turns on automatically on a [Scarlet](https://github.com/whipowill/quake-mod-scarlet) server with ``teamplay`` on)
- ``cl_grenades 1`` - will show grenades you possess on the HUD (default ``0``, turns on automatically on a Scarlet server with grenades enabled)
- ``cl_weapons 1`` - will show weapons you possess on the HUD (default ``0``)
- ``cl_rogue -1`` - Rogue (Dissolution of Eternity) stores its ammo and armor differently, so the HUD reads them the Rogue way.  ``-1`` detects it from the game folder, ``1`` forces it on and ``0`` forces it off (default ``-1``)
- ``cl_hudtest 1`` - display all icons on the HUD for testing purposes (default ``0``)

## Issues

My understanding is this mod will work on both QS and FTE engines, but if there is an issue the solution would involve swapping out ``qsextensions.qc`` w/ ``fteextensions.qc`` and recompiling the code.

## Credits

- Original code by [ClanRing](https://github.com/quakeone/crmod-plus)

## External Links

- [CSQC Extension](https://quakewiki.org/wiki/EXT_CSQC)
- [CSQC Guide For Idiots](https://quakewiki.org/wiki/CSQC_guide_for_idiots)
- [Client-Side QuakeC](https://www.quakewiki.net/darkplaces-wiki/client-side-quakec/)