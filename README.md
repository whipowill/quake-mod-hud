# HUD for Quake

A Quake client-side mod for adding a N64/2021 HUD layout to the game.  This layout isn't exactly the same as the 2021 rerelease, but it's close.  I used a little artistic license in this mod.

![2021 HUD style](https://i.imgur.com/Y6CRpck.jpg)
![Team Scores](https://i.imgur.com/kwuA8il.jpg)

Because this is a client-side mod, it means you can use it alongside other QuakeC mods (``progs.dat``) w/out issue.

## Install

Simply copy the ``csprogs.dat`` file into your ``id1`` or other mod folder.

## Usage

- ``cl_teams 1`` - change scoreboard to team mode (not auto-detected from server atm)

### Testing

- ``cl_hudtest 1`` - display all powerups
- ``cl_hudtest2 1`` - display all runes

## Issues

My understanding is this mod will work on both QS and FTE engines, but if there is an issue the solution would involve swapping out ``qsextensions.qc`` w/ ``fteextensions.qc`` and recompiling the code.

## Credits

- Original code by [ClanRing](https://github.com/quakeone/crmod-plus)

## External Links

- [CSQC For Idiots](https://quakewiki.org/wiki/CSQC_guide_for_idiots) - Introduction to client side QC scripting
- [CSQC Extension](https://quakewiki.org/wiki/EXT_CSQC#CSQC_ConsoleCommand) - Maybe a clue on how to autodetect teamplay games?? Still can't figure out how to do this.