exatec={
	tube_rules={{x=1,y=0,z=0},{x=-1,y=0,z=0},{x=0,y=0,z=1},{x=0,y=0,z=-1},{x=0,y=1,z=0},{x=0,y=-1,z=0}},
	wire_rules={{x=1,y=0,z=0},{x=-1,y=0,z=0},{x=0,y=0,z=1},{x=0,y=0,z=-1},{x=0,y=1,z=0},{x=0,y=-1,z=0}},
	wire_sends={last=os.time(),times=0},
	wire_signals={},
	wire_data_sends={last=os.time(),times=0},
	wire_data_signals={},
	temp = {},
}

dofile(minetest.get_modpath("exatec") .. "/functions.lua")
dofile(minetest.get_modpath("exatec") .. "/nodes.lua")
dofile(minetest.get_modpath("exatec") .. "/craft.lua")
dofile(minetest.get_modpath("exatec") .. "/entities.lua")

dofile(minetest.get_modpath("exatec") .. "/nodeswitch.lua")


player_style.register_manual_page({
	name = "exatec",
	itemstyle = "exatec:extraction",
	text = "The tech mod are made to in a effective way create mechanics from simple item transporting to advanced industry.The exatec list (paper) contains a list of items that works with the technology mod.\n\nThe most basic and needed items is:\nThe extraction that pushes items out of storages (eg chests) to next connected tube, technology or supported storage.\nThe button sends powerd signals to connected technology when someone presses it.\nThe autosender does same as the button but automatic each secund when it is toggled on.\n\nTubes: transport items between the machines or from them.\nFilter tubes: tubes that detects items and changing items direction where you want them.\nWires: sends powered signals between the machines.\nData wires: sends lua information between the machines.You can find all methods to use in a PCB.\n\nThe CMD Phone arent really working with the general technology but you can insead control mobs to do work with technology.You shoulden't trust this paralyed mobs too much because they gladly stucks in procceses or disapear when their lag level are too high.]item_image[1,0.5;1,1;exatec:list]",
	tags = {"xatec:extraction"},
})