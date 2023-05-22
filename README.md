# HUD for Quake

A Quake client-side mod for adding a N64/2021 HUD layout to the game.  This layout isn't exactly the same as the 2021 rerelease, but it's close.  I used a little artistic license in this mod.

![2021 HUD style](https://i.imgur.com/T7e9LWg.jpg)
![Team Scores](https://i.imgur.com/Ia2e3ZM.jpg)

Because this is a client-side mod, it means you can use it alongside other QuakeC mods (``progs.dat``) w/out issue.

## Install

Simply copy the ``csprogs.dat`` file into your ``id1`` or other mod folder.

## Changelog

- May 2023
	- Autodetect ``teamplay`` from [Scarlet](https://github.com/whipowill/quake-mod-scarlet) mod
	- Display hand grenades count from [Scarlet](https://github.com/whipowill/quake-mod-scarlet) mod

## Usage

- ``cl_teams 1`` - change scoreboard to teamplay mode (default ``0``)
- ``cl_weapons 1`` - will show weapons you possess on the HUD (default ``0``)
- ``cl_hudtest 1`` - display all icons on the HUD for testing purposes (default ``0``)

## Issues

My understanding is this mod will work on both QS and FTE engines, but if there is an issue the solution would involve swapping out ``qsextensions.qc`` w/ ``fteextensions.qc`` and recompiling the code.

## Credits

- Original code by [ClanRing](https://github.com/quakeone/crmod-plus)

## External Links

- [CSQC Extension](https://quakewiki.org/wiki/EXT_CSQC)
- [CSQC Guide For Idiots](https://quakewiki.org/wiki/CSQC_guide_for_idiots)
- [Client-Side QuakeC](https://www.quakewiki.net/darkplaces-wiki/client-side-quakec/)