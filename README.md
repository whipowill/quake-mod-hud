# HUD for Quake

A Quake client-side mod for adding custom HUD layouts to the game.

![2021 HUD style](https://i.imgur.com/8vQaxJ7.jpg)
![Team Scores](https://i.imgur.com/kwuA8il.jpg)

Because this is a client-side mod, it means you can use it alongside other QuakeC mods (``progs.dat``) w/out issue.

## Install

Simply copy the ``csprogs.dat`` file into your ``id1`` or other mod folder.

## Usage

Use the following console commands:

- ``cl_sbar`` - change HUD layout
    - ``0`` - QuakeWorld style
    - ``1`` - Vanilla style
    - ``2`` - N64 / 2021 style :star:
- ``cl_teams 1`` - change scoreboard to team mode (not auto-detected from server atm)

## Issues

My understanding is this mod will work on both QS and FTE engines, but if there is an issue the solution would involve swapping out ``qsextensions.qc`` w/ ``fteextensions.qc`` and recompiling the code.

## Credits

- Original code by [ClanRing](https://github.com/quakeone/crmod-plus)