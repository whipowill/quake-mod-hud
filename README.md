# HUD for Quake

A Quake client-side mod for adding custom HUD layouts and team scores to the game.

![QSS-M with HUD mod](https://i.imgur.com/uPsTKCv.jpg)

This mod only works on QuakeSpasm engines.  If the game is ``deathmatch`` and ``teamplay`` it will add the team scores to the top of the screen.  Because this is a client-side mod, it means you can use it alongside other QuakeC mods (``progs.dat``) w/out issue.

## Install

- Simply copy the ``csprogs.dat`` file into your ``id1`` or other mod folder.

## Usage

Use the console commands to change the HUD layout.

- ``cl_sbar`` - change HUD layout
    - ``0`` - QuakeWorld
    - ``1`` - Vanilla
    - ``2`` - N64
    - ``3`` - N64 with meshes instead of models, where supported
- ``cl_hudswap`` - swap ammo/weapons locations
    - ``0`` - right
    - ``1`` - left

## Issues

- My understanding is this mod will only work on QS engines, but could be made to work on FTE engines by swapping out ``qsextensions.qc`` w/ ``fteextensions.qc``.

## Credits

- Original code by [ClanRing](https://github.com/quakeone/crmod-plus)