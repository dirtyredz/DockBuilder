# DockBuilder

This mod was originally developed by: Theoman02 http://www.avorion.net/forum/index.php/topic,781.0.html

Dirtyredz (myself), Hammelpilaw, and Laserzwei all have worked to keep this mod alive and working.

Today I bring you the culmanation of all that work in a single mod with these features and bug fixes:

Added Resourcetrader (Hammelpilaw)
Added Fighterfactory (Hammelpilaw)
Added Sorted lists (Hammelpilaw)
Fixed "The production line you chose doesn't exist" Error (Laserzwei, Dirtyredz)
Added Alliance support (Dirtyredz)
Ported mod to mods directory (Dirtyredz)


## Installation

Step 1:
Copy and paste the contents of the zip file into your avorion directory
There should now be a mods/ directory next to the data/ directory

Step 2:
Navigate to folder

data/scripts/entity/stationfounder.lua

Open the file and place this line at the very bottom of the file

    if not pcall(require, 'mods.DockBuilder.scripts.entity.stationfounder') then print('Mod: DockBuilder, failed to extend stationfounder.lua!') end


Thats it your done. start up your game or server and enjoy being able to build your own empire with every station available to you.

## Github
This project is on a public repo here:
https://github.com/dirtyredz/DockBuilder

I encourage anyone wanting to further advance thise project to please submit a pull request. Thxs.

## Notes
Again I want to make it explicitly clear that this is not my own work, but a culmanation of work from many modders.
