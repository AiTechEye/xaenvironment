default.register_door=function(def)
	local uname = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
	local mod = minetest.get_current_modname() ..":"
	local name = mod .. def.name
	local groups = def.groups or {choppy = 2, oddly_breakable_by_hand = 2,door=1}

	groups.flammable = def.burnable and 1 or nil

	minetest.register_node(name,{
		description = def.description or uname,
		groups = groups,
		drawtype="nodebox",
		paramtype="light",
		paramtype2 = "facedir",
		tiles = {def.texture},
		paramtype = "light",
		sounds = def.sounds or default.node_sound_wood_defaults(),
		selection_box={
			type="fixed",
			fixed={-0.5, -0.5, 0.375, 0.5, 1.5, 0.5}
		},
		collision_box={
			type="fixed",
			fixed={-0.5, -0.5, 0.375, 0.5, 1.5, 0.5}
		},
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, 0.375, 0.5, -0.4, 0.5},
				{-0.5, 1.4, 0.375, 0.5, 1.5, 0.5},
				{0.375, -0.4, 0.375, 0.5, 1.4, 0.5},
				{-0.5, -0.5, 0.375, -0.4, 1.4, 0.5},
				{-0.5, -0.5, 0.4, 0.5, 1.4, 0.475},
			}
		},
		on_rightclick = function(pos)
			local pp=minetest.get_node(pos).param2
			local meta=minetest.get_meta(pos)
			if meta:get_int("locked")==1 then return end
			local p=meta:get_int("p")
			if pp==2 and p==2 then
				minetest.swap_node(pos, {name=name, param2=3})
				minetest.sound_play("doors_door_open",{pos=pos,gain=0.3,max_hear_distance=10})
			elseif pp==3 and p==2 then
				minetest.swap_node(pos, {name=name, param2=2})
				minetest.sound_play("doors_door_close",{pos=pos,gain=0.3,max_hear_distance=10})
			elseif pp==0 and p==0 then
				minetest.swap_node(pos, {name=name, param2=1})
				minetest.sound_play("doors_door_open",{pos=pos,gain=0.3,max_hear_distance=10})
			elseif pp==1 and p==0 then
				minetest.swap_node(pos, {name=name, param2=0})
				minetest.sound_play("doors_door_close",{pos=pos,gain=0.3,max_hear_distance=10})	
			elseif pp==3 and p==3 then
				minetest.swap_node(pos, {name=name, param2=0})
				minetest.sound_play("doors_door_open",{pos=pos,gain=0.3,max_hear_distance=10})
			elseif pp==0 and p==3 then
				minetest.swap_node(pos, {name=name, param2=3})
				minetest.sound_play("doors_door_close",{pos=pos,gain=0.3,max_hear_distance=10})
			elseif pp==1 and p==1 then
				minetest.swap_node(pos, {name=name, param2=2})
				minetest.sound_play("doors_door_open",{pos=pos,gain=0.3,max_hear_distance=10})
			elseif pp==2 and p==1 then
				minetest.swap_node(pos, {name=name, param2=1})
				minetest.sound_play("doors_door_close",{pos=pos,gain=0.3,max_hear_distance=10})
			else
				meta:set_int("autoopen",1)
				minetest.get_node_timer(pos):start(0.2)
			end
		end,
		on_construct=function(pos)
			local meta=minetest.get_meta(pos)
			meta:set_int("p",minetest.get_node(pos).param2)
			minetest.get_node_timer(pos):start(1)
			meta:set_int("n",1)
		end,
		after_place_node = function(pos, placer)
			minetest.get_node_timer(pos):stop()
		end,
		mesecons = {
			receptor = {state = "off"},
			effector = {
			action_on = function (pos, node)
				minetest.get_meta(pos):set_int("locked",1)
			end,
			action_off = function (pos, node)
				minetest.get_meta(pos):set_int("locked",0)
			end,
		}}
	})
	minetest.register_craft({
		output = name,
		recipe = def.craft
	})
	if def.burnable then
		minetest.register_craft({
			type = "fuel",
			recipe = name,
			burntime = 10,
		})
	end
end

default.register_chair=function(def)
	local uname = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
	local mod = minetest.get_current_modname() ..":"
	local name = mod .. def.name .. "_chair"
	local groups = def.groups or {choppy = 2, oddly_breakable_by_hand = 2,chair=1}

	groups.flammable = def.burnable and 1 or nil

	minetest.register_node(name,{
		description = def.description or uname .. " chair",
		groups = groups,
		drawtype="nodebox",
		paramtype="light",
		paramtype2 = "facedir",
		tiles = {def.texture},
		paramtype = "light",
		sounds = def.sounds or default.node_sound_wood_defaults(),
		selection_box={
			type="fixed",
			fixed={-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125}
		},
		collision_box={
			type="fixed",
			fixed={
				{-0.3125, -0.5, -0.3125, 0.3125, -0.0625, 0.3125},
				{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125}
			}
		},
		node_box = {
			type = "fixed",
			fixed = {
				{-0.3125, -0.5, 0.1875, -0.1875, 0.5, 0.3125},
				{0.1875, -0.5, 0.1875, 0.3125, 0.5, 0.3125},
				{0.1875, -0.5, -0.3125, 0.3125, -0.0625, -0.1875},
				{-0.3125, -0.5, -0.3125, -0.1875, -0.0625, -0.1875},
				{-0.3125, -0.125, -0.3125, 0.3125, 0, 0.3125},
				{-0.1875, 0.3125, 0.1875, 0.1875, 0.4375, 0.3125},
				{-0.3125, 0.125, 0.1875, 0.3125, 0.1875, 0.3125},
				{0.23, -0.4375, -0.3125, 0.29, -0.375, 0.3125},
				{-0.29, -0.4375, -0.3125, -0.23, -0.375, 0.3125},
				{-0.29, -0.4375, -0.0315, 0.29, -0.375, 0.031},
			}
		},
		on_rightclick = function(pos, node, player, itemstack, pointed_thing)
			local v=player:get_player_velocity()
			if v.x~=0 or v.y~=0 or v.z~=0 then return end
			player:set_pos({x=pos.x,y=pos.y,z=pos.z})
			local pname=player:get_player_name()
			if default.player_attached[pname] then
				player:set_physics_override(1, 1, 1)
				minetest.after(0.3, function(player,pname)
					player:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
					default.player_attached[pname]=nil
					default.player_set_animation(player, "stand")
				end,player,pname)
			else
				player:set_physics_override(0, 0, 0)
				minetest.after(0.3, function(player,pname)
					player:set_eye_offset({x=0,y=-7,z=2}, {x=0,y=0,z=0})
					default.player_attached[pname]=true
					default.player_set_animation(player, "sit")
				end,player,pname)
				minetest.after(0.3, function(player,pname)
					player:set_eye_offset({x=0,y=-7,z=2}, {x=0,y=0,z=0})
					default.player_attached[pname]=true
					default.player_set_animation(player, "sit")
				end,player,pname)
			end
		end,
		can_dig = function(pos, player)
			for _, ob in ipairs(minetest.get_objects_inside_radius(pos,1)) do
				return false
			end
			return true
		end,
		on_construct=function(pos)
			local meta=minetest.get_meta(pos)
			minetest.get_node_timer(pos):start(1)
			meta:set_int("n",20)
			meta:set_int("y",0)
		end,
		on_blast=function(pos)
			for _, player in ipairs(minetest.get_objects_inside_radius(pos,1)) do
				if player:is_player() then
					local pname=player:get_player_name()
					player:set_physics_override(1, 1, 1)
					minetest.after(0.3, function(player,pname)
						player:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
						default.player_attached[pname]=nil
						default.player_set_animation(player, "stand")
					end,player,pname)
				end
			end
		end,
		after_place_node = function(pos, placer)
			minetest.get_meta(pos):set_int("placed",1)
		end
	})

	minetest.register_craft({
		output = name,
		recipe = {{"group:stick","",""},
			{"group:wood","",""},
			{"group:stick","",""},
		}
	})
	if def.burnable then
		minetest.register_craft({
			type = "fuel",
			recipe = name,
			burntime = 10,
		})
	end
end