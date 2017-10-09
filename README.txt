[center][b][size=32pt]DockBuilder[/size][/b][/center]

This mod was originally developed by: [b][color=red]Theoman02[/color][/b] http://www.avorion.net/forum/index.php/topic,781.0.html

[b][color=red]Dirtyredz [/color][/b](myself), [b][color=red]Hammelpilaw[/color][/b], and [b][color=red]Laserzwei [/color][/b]all have worked to keep this mod alive and working.

This mod will allow you to build every station available in the game when founding a station.

Today I bring you the culmination  of all that work in a single mod with these features and bug fixes:

[quote]
--Added Resourcetrader (Hammelpilaw)
--Added Fighterfactory (Hammelpilaw)
--Added Sorted lists (Hammelpilaw)
--Fixed "The production line you chose doesn't exist" Error (Laserzwei, Dirtyredz)
--Added Alliance support (Dirtyredz)
--Ported mod to mods directory (Dirtyredz)
[/quote]

[b][size=24pt]Installation[/size][/b]
[hr]
Step 1:
Copy and paste the contents of the zip file into your avorion directory
There should now be a mods/ directory next to the data/ directory

Step 2:
Navigate to folder
[quote]
data/scripts/entity/stationfounder.lua
[/quote]
Open the file and place this line at the very bottom of the file

    [code]
    if not pcall(require, 'mods.DockBuilder.scripts.entity.stationfounder') then print('Mod: DockBuilder, failed to extend stationfounder.lua!') end
    [/code]

Thats it your done. start up your game or server and enjoy being able to build your own empire with every station available to you.

[b][size=24pt]Download[/size][/b]
[hr]
[url=https://github.com/dirtyredz/DockBuilder/releases/download/1.0.0/DockBuilder.v1.0.0.zip]DockBuilder v1.0.0[/url]

[b][size=24pt]Github[/size][/b]
[hr]
This project is on a public repo here:
https://github.com/dirtyredz/DockBuilder

I encourage anyone wanting to further advance thise project to please submit a pull request. Thxs.

[b][size=24pt]Notes[/size][/b]
[hr]
Again I want to make it explicitly clear that this is not my own work, but a culmination  of work from many modders.
