beds={}

beds.update_waypoint=function(user,pos)
	local name = user:get_player_name()
	local p = player_style.players[name]
	p.bed = p.bed or {}
	if not user then
		return
	elseif not pos then
		if p.bed.waypoint then
			user:hud_remove(p.bed.waypoint)
		end
		p.bed.waypoint = nil
	elseif not p.bed.waypoint then
		p.bed.waypoint = user:hud_add({
			hud_elem_type="image_waypoint",
			scale = {x=1.5, y=1.5},
			name="aim",
			text="beds_icon.png",
			world_pos = pos
		})
	else
		user:hud_change(p.bed.waypoint, "world_pos", pos)
	end
end

minetest.register_on_joinplayer(function(player)
	local s = player:get_meta():get_string("beds_position")
	if s ~="" then
		local pos = minetest.string_to_pos(s)
		beds.update_waypoint(player,pos)
	end
end)


player_style.register_button({
	name="Bed",
	type="image",
	image="beds_icon.png",
	info="Go to bed",
	low_priority = true,
	action=function(player)
		if player:get_meta():get_int("respawn_disallowed") == 1 then
			minetest.chat_send_player(player:get_player_name(),"Beds is disallowed in this case")
		elseif not beds.respawn(player) then
			minetest.chat_send_player(player:get_player_name(),"You have to sleep in a bed first")
		end
	end
})

minetest.register_on_respawnplayer(function(player)
	return beds.respawn(player)
end)

beds.respawn=function(player)
	local pos = player:get_meta():get_string("beds_position")
	if pos ~= "" and player:get_meta():get_int("respawn_disallowed") == 0 then
		player:set_pos(minetest.string_to_pos(pos))
		return true
	end
end

beds.lay_and_stand=function(pos,player)
	local pname = player:get_player_name()
	if default.player_attached[pname] then
		player:set_physics_override({speed=1, jump=1})
		minetest.after(0.3, function(player,pname)
			player:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
			default.player_attached[pname]=nil
			default.player_set_animation(player, "stand")
		end,player,pname)
	else
		local v = player:get_velocity()
		if math.abs(v.x)+math.abs(v.z) > 0 then
			return
		end
		player:set_pos(pos)
		player:set_physics_override({speed=0, jump=0})
		minetest.after(0.3, function(player,pname)
			player:set_eye_offset({x=0,y=-14,z=2}, {x=0,y=0,z=0})
			default.player_attached[pname]=true
			default.player_set_animation(player, "lay")
		end,player,pname)
	end
end

beds.sleeping=function(pos,player)
	local tim = minetest.get_timeofday()
	if tim >= 0.77 or tim < 0.21 then
		local players = {}
		for _, p in pairs(minetest.get_connected_players()) do
			if p and minetest.get_item_group(minetest.get_node(p:get_pos()).name,"bed") == 0 then
				return
			end
		end
		for _, p in pairs(minetest.get_connected_players()) do
			local m = p:get_meta()
			if minetest.get_item_group(minetest.get_node(p:get_pos()).name,"tent") == 0 and m:get_int("respawn_disallowed") == 0 then
				m:set_string("beds_position",minetest.pos_to_string(p:get_pos()))
				beds.update_waypoint(p,p:get_pos())
			end
		end
		minetest.set_timeofday(0.21)
	end
end

minetest.register_node("beds:bed", {
	description = "Bed",
	stack_max=1,
	tiles = {"beds_bed.png","default_wood.png","default_wood.png^beds_bed_side.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 1,bed=1,used_by_npc=1,store=300,fall_damage_add_percent=-50,bouncy=99},
	drawtype="nodebox",
	paramtype="light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = { 
			{-0.5, -0.5, -0.5, 0.5, 0.06, 1.5},
		}
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local p1 = player:get_player_name()
		if not default.player_attached[p1] then
			for _, p2 in ipairs(minetest.get_objects_inside_radius(pos,1)) do
				if p2:is_player() and p2:get_player_name() ~=p1 then
					return
				end
			end
		end
		beds.lay_and_stand(pos,player)
		minetest.get_node_timer(pos):start(5)
	end,
	on_timer =  function (pos, elapsed)
		for _, player in ipairs(minetest.get_objects_inside_radius(pos,1)) do
			if player:is_player() then
				beds.sleeping(pos,player)
				return true
			end
		end
		return false
	end,
	on_place=function(itemstack, placer, pointed_thing)
		local p = pointed_thing.under
		if not default.defpos(p,"buildable_to") then
			p = pointed_thing.above
		end
		local f=minetest.dir_to_facedir(placer:get_look_dir())
		if (f==2 and default.defpos({x=p.x,y=p.y,z=p.z-1},"buildable_to")) or
		(f==0 and default.defpos({x=p.x,y=p.y,z=p.z+1},"buildable_to")) or
		(f==1 and default.defpos({x=p.x+1,y=p.y,z=p.z},"buildable_to")) or
		(f==3 and default.defpos({x=p.x-1,y=p.y,z=p.z},"buildable_to")) then
			minetest.set_node(p,{name="beds:bed",param2=f})
			itemstack:take_item()
			return itemstack
		end
	end
})

minetest.register_node("beds:blocking", {
	drawtype="airlike",
	paramtype="light",
	sunlight_propagetes = true,
	pointable = false,
	walkable = false,
	groups={not_in_creative_inventory=1},
})

minetest.register_node("beds:tent", {
	description = "Tent",
	stack_max=1,
	tiles = {"beds_tent.png"},
	groups = {dig_immediate = 3, flammable = 1,bed=1,tent=1,store=500},
	drawtype="mesh",
	paramtype="light",
	paramtype2 = "facedir",
	mesh = "tent.obj",
	selection_box = {
		type = "fixed",
		fixed = { 
			{-0.5, -0.5, -0.5, 0.5, 0.5, 1.5},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = { 
			{-0.5, -0.5, -0.5, 0.5, 0.5, 1.5},
		}
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local p1 = player:get_player_name()
		if not default.player_attached[p1] then
			for _, p2 in ipairs(minetest.get_objects_inside_radius(pos,1)) do
				if p2:is_player() and p2:get_player_name() ~=p1 then
					return
				end
			end
		end
		beds.lay_and_stand(pos,player)
		minetest.get_node_timer(pos):start(5)
	end,
	on_timer =  function (pos, elapsed)
		for _, player in ipairs(minetest.get_objects_inside_radius(pos,1)) do
			if player:is_player() then
				beds.sleeping(pos,player)
				return true
			end
		end
		return false
	end,
	on_place=function(itemstack, placer, pointed_thing)
		local p = pointed_thing.under
		if not default.defpos(p,"buildable_to") then
			p = pointed_thing.above
		end
		local name = placer:get_player_name()
		for y = 0,1 do
		for x = -1,1 do
		for z = -1,1 do
			local np = {x=p.x+x,y=p.y+y,z=p.z+z}
			if not default.defpos(np,"buildable_to") or minetest.is_protected(np,name) then
				return
			end
		end
		end
		end
		for y = 0,1 do
		for x = -1,1 do
		for z = -1,1 do
			minetest.set_node({x=p.x+x,y=p.y+y,z=p.z+z},{name="beds:blocking"})
		end
		end
		end
		local f=minetest.dir_to_facedir(placer:get_look_dir())
		minetest.set_node(p,{name="beds:tent",param2=f})
		itemstack:take_item()
		return itemstack
	end,
	after_destruct=function(pos)
		for y = 0,1 do
		for x = -1,1 do
		for z = -1,1 do
			minetest.remove_node({x=pos.x+x,y=pos.y+y,z=pos.z+z})
		end
		end
		end
	end
})

minetest.register_craft({
	output="beds:bed",
	recipe={
		{"materials:piece_of_cloth","materials:piece_of_cloth","materials:piece_of_cloth"},
		{"group:wood","group:wood","group:wood"},
	},
})

minetest.register_craft({
	output="beds:tent",
	recipe={
		{"group:stick","materials:piece_of_cloth","group:stick"},
		{"materials:piece_of_cloth","materials:piece_of_cloth","materials:piece_of_cloth"},
	},
})