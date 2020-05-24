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
