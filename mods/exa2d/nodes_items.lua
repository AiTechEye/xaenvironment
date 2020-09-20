minetest.register_node("exa2d:inactive_item", {
	pointable=false,
	drawtype="airlike",
	paramtype="light",
	paramtype2="facedir",
	groups = {not_in_creative_inventory=0,attached_node=1,on_load=1},
	drop = "",
	floodable = true,
	buildable_to = true,
	walkable = false,
	sunlight_propagates = true,
	tiles = {"default_air.png"},
	on_load=function(pos)
		local d = minetest.get_meta(pos):get_int("date")
		if default.date("d",d) > 1 then
			minetest.remove_node(pos)
		end
	end
})

minetest.register_node("exa2d:coin", {
	description = "Coin",
	pointable=false,
	drawtype="nodebox",
	paramtype="light",
	paramtype2="facedir",
	groups = {not_in_creative_inventory=1,attached_node=1,exa2d_item=1},
	drop = "",
	floodable = true,
	buildable_to = true,
	walkable = false,
	sunlight_propagates = true,
	tiles = {"default_air.png","default_air.png","default_air.png","default_air.png","default_air.png","player_style_coin.png"},
	node_box = {
		type="fixed",
		fixed={-0.5,-0.5,0.498,0.5,0.5,0.5}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function(pos, elapsed)
		exa2d.inactivate_item(pos)
		return true
	end,
})

minetest.register_node("exa2d:coin_effect", {
	description = "Coin effect",
	pointable=false,
	drawtype="nodebox",
	paramtype="light",
	paramtype2="facedir",
	groups = {not_in_creative_inventory=1,attached_node=1,exa2d_item=1},
	drop = "",
	floodable = true,
	buildable_to = true,
	walkable = false,
	sunlight_propagates = true,
	tiles = {"default_air.png","default_air.png","default_air.png","default_air.png","default_air.png","player_style_coin.png"},
	node_box = {
		type="fixed",
		fixed={-0.5,-0.5,0.498,0.5,0.5,0.5}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.25)
	end,
	on_timer = function(pos, elapsed)
		minetest.remove_node(pos)
	end,
})

minetest.register_node("exa2d:block", {
	description = "?",
	pointable=false,
	drawtype="nodebox",
	paramtype="light",
	paramtype2="facedir",
	sunlight_propagates = true,
	groups = {not_in_creative_inventory=1,attached_node=1,exa2d_item=1},
	drop = "",
	floodable = true,
	buildable_to = true,
	node_box = {
		type="fixed",
		fixed={-0.5,-0.5,0.45,0.5,0.5,0.5}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function(pos, elapsed)
		exa2d.inactivate_item(pos)
		return true
	end,
	tiles={
		{
			name = "exa2d_block.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 1,
			}
		}
	}
})

minetest.register_node("exa2d:block_empty", {
	description = "?",
	pointable=false,
	drawtype="nodebox",
	paramtype="light",
	paramtype2="facedir",
	sunlight_propagates = true,
	groups = {not_in_creative_inventory=1,attached_node=1,exa2d_item=1},
	drop = "",
	tiles={"exa2d_block_empty.png"},
	floodable = true,
	buildable_to = true,
	node_box = {
		type="fixed",
		fixed={-0.5,-0.5,0.45,0.5,0.5,0.5}
	},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function(pos, elapsed)
		exa2d.inactivate_item(pos)
		return true
	end
})

--[[
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local meta=minetest.get_meta(pos)
		local owner=meta:get_string("owner")
		if owner~="" and owner~=player:get_player_name() then
			return
		end
		minetest.swap_node(pos, {name="exa2d:door_" .. name .. "_b"})
		meta:set_int("p",meta:get_int("p"))
		meta:set_string("owner",owner)
		minetest.sound_play(sound_open,{pos=pos,gain=0.3,max_hear_distance=10})
	end,
	after_place_node = function(pos, placer)
		local pname=placer:get_player_name()
		local ob=exa2d.user[pname]
		local meta=minetest.get_meta(pos)

		if locked then
			meta:set_string("owner",pname)
		end

		if ob and ob.object and ob.object:get_pos().x<pos.x then
			minetest.swap_node(pos, {name="exa2d:door_" .. name .. "_a", param2=0})
		else
			minetest.swap_node(pos, {name="exa2d:door_" .. name .. "_a", param2=2})
			meta:set_int("p",2)
		end
	end,









	after_destruct = function(pos, oldnode)
		local m=minetest.get_meta(pos)
		if m:get_int("reset")==0 then
			minetest.after(1, function(pos)
				minetest.set_node(pos,{name="exa2d:blocking"})
				m:set_int("reset",1)
				minetest.get_node_timer(pos):start(1)
			end,pos)
		end
	end,
	on_timer = function (pos, elapsed)
		minetest.get_meta(pos):set_int("reset",0)
	end,

--]]
