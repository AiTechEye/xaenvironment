minetest.register_node("exa2d:inactive_item", {
	pointable=false,
	drawtype="airlike",
	paramtype="light",
	paramtype2="facedir",
	groups = {not_in_creative_inventory=0,attached_node=1},
	drop = "",
	floodable = true,
	buildable_to = true,
	walkable = false,
	tiles = {"default_air.png"},
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

minetest.register_node("exa2d:block", {
	description = "?",
	pointable=false,
	drawtype="nodebox",
	paramtype="light",
	paramtype2="facedir",
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
		},
	
	}
})

minetest.register_node("exa2d:block_empty", {
	description = "?",
	pointable=false,
	drawtype="nodebox",
	paramtype="light",
	paramtype2="facedir",
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

exa2d.activate_item=function(pos)
	local p2 = minetest.get_node(pos).param2
	local m = minetest.get_meta(pos)
	local name = m:get_string("exa2d_item")
	if name ~= "" then
		minetest.swap_node(pos, {name=name, param2=p2})
		minetest.get_node_timer(pos):start(1)
	else
		minetest.remove_node(pos)
	end
end
	
exa2d.inactivate_item=function(pos)
	local n = minetest.get_node(pos)
	local p2 = n.param2
	for i,v in pairs(exa2d.user) do
		if v.object and v.fdir == p2 then
			local p = v.object:get_pos()
			if p and vector.distance(p,pos) <= 10 then
				return true
			end
		end
	end
	minetest.get_meta(pos):set_string("exa2d_item",n.name)
	minetest.swap_node(pos, {name="exa2d:inactive_item", param2=p2})
end



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
