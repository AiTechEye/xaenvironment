default.register_fence=function(def)
	local uname = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
	local mod = minetest.get_current_modname() ..":"
	local name = mod .. def.name

	def.groups =  def.groups or			{}
	def.groups.choppy = def.groups.choppy or	2
	def.groups.fence = def.groups.fence or		1
	def.groups.flammable = def.groups.flammable or	1
	def.sounds = def.sounds or			default.node_sound_wood_defaults()
	def.connects_to = def.connects_to or		{"group:choppy"}

	minetest.register_node(name .."_fence", {
		description = def.description or string.gsub(uname,"_"," ") .. " fence",
		inventory_image = def.texture  .. "^default_alpha_fence.png^[makealpha:0,255,0",
		tiles={def.texture},
		groups = def.groups,
		sounds = def.sounds,
		drawtype = "nodebox",
		paramtype = "light",
		connects_to=def.connects_to,
		node_box = {
			type = "connected",
			connect_front={{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},{-0.0625, 0.25, -0.5, 0.0625, 0.375, -0.0625},{-0.0625, -0.25, -0.5, 0.0625, -0.125, -0.0625}},
			connect_back={{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},{-0.0625, 0.25, 0.0625, 0.0625, 0.375, 0.5},{-0.0625, -0.25, 0.0625, 0.0625, -0.125, 0.5}},
			connect_right={{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},{0.0625, 0.25, -0.0625, 0.5, 0.375, 0.0625},{0.0625, -0.25, -0.0625, 0.5, -0.125, 0.0625}},
			connect_left={{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},{-0.5, 0.25, -0.0625, -0.0625, 0.375, 0.0625},{-0.5, -0.25, -0.0625, -0.0625, -0.125, 0.0625}},
			fixed = {-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
		},
		palette="default_palette.png",
		paramtype2="color",
		on_punch=default.dye_coloring
	})

	if def.craft then
		minetest.register_craft({
			output = name .. "_fence 6",
			recipe = def.craft
		})
	end
end

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
				minetest.sound_play("default_door_open",{pos=pos,gain=1,max_hear_distance=10})
			elseif pp==3 and p==2 then
				minetest.swap_node(pos, {name=name, param2=2})
				minetest.sound_play("default_door_close",{pos=pos,gain=1,max_hear_distance=10})
			elseif pp==0 and p==0 then
				minetest.swap_node(pos, {name=name, param2=1})
				minetest.sound_play("default_door_open",{pos=pos,gain=1,max_hear_distance=10})
			elseif pp==1 and p==0 then
				minetest.swap_node(pos, {name=name, param2=0})
				minetest.sound_play("default_door_close",{pos=pos,gain=1,max_hear_distance=10})	
			elseif pp==3 and p==3 then
				minetest.swap_node(pos, {name=name, param2=0})
				minetest.sound_play("default_door_open",{pos=pos,gain=1,max_hear_distance=10})
			elseif pp==0 and p==3 then
				minetest.swap_node(pos, {name=name, param2=3})
				minetest.sound_play("default_door_close",{pos=pos,gain=1,max_hear_distance=10})
			elseif pp==1 and p==1 then
				minetest.swap_node(pos, {name=name, param2=2})
				minetest.sound_play("default_door_open",{pos=pos,gain=1,max_hear_distance=10})
			elseif pp==2 and p==1 then
				minetest.swap_node(pos, {name=name, param2=1})
				minetest.sound_play("default_door_close",{pos=pos,gain=1,max_hear_distance=10})
			else
				meta:set_int("autoopen",1)
				minetest.get_node_timer(pos):start(0.2)
			end
		end,
		on_construct=function(pos)
			local meta=minetest.get_meta(pos)
			meta:set_int("p",minetest.get_node(pos).param2)
			meta:set_int("n",1)
		end,
		on_place=function(itemstack, placer, pointed_thing)
			local p = pointed_thing.under
			if default.defpos({x=p.x,y=p.y+1,z=p.z},"buildable_to") then
				local fd=minetest.dir_to_facedir(placer:get_look_dir())
				minetest.set_node({x=p.x,y=p.y+1,z=p.z},{name=name,param2=fd})
				itemstack:take_item()
				return itemstack
			end
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
		}},
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
	local groups = def.groups or {choppy = 2, oddly_breakable_by_hand = 2,chair=1,used_by_npc=1}

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
			player:set_pos({x=pos.x,y=pos.y-0.2,z=pos.z})
			local pname=player:get_player_name()
			if default.player_attached[pname] then
				player:set_physics_override(1, 1, 1)
				minetest.after(0.3, function(player,pname)
					player:set_eye_offset({x=0,y=0,z=0}, {x=0,y=0,z=0})
					default.player_attached[pname]=nil
					default.player_set_animation(player, "stand")
				end,player,pname)
			else
				local v = player:get_player_velocity()
					if math.abs(v.x)+math.abs(v.z) > 0 then
					return
				end
				player:set_physics_override(0, 0, 0)
				minetest.after(0.3, function(player,pname)
					player:set_eye_offset({x=0,y=-2,z=2}, {x=0,y=0,z=0})
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
		end,
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

default.register_chest=function(def)
	local uname = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
	local mod = minetest.get_current_modname() ..":"
	local name = mod .. def.name
	local groups = def.groups or {choppy = 2, oddly_breakable_by_hand = 2,chest=1,used_by_npc=1}
	local tiles
	local locked = def.locked
	groups.flammable = def.burnable and 1 or nil
	groups.exatec_tube_connected = not locked and 1 or nil
	if def.texture and string.find(def.texture,".png") then
		tiles = {
			def.texture .."^default_chest_top.png",
			def.texture .."^default_chest_top.png",
			def.texture .."^default_chest_side.png",
			def.texture .."^default_chest_side.png",
			def.texture .."^default_chest_side.png",
			def.locked and def.texture .."^default_chest_front_locked.png" or def.texture .."^default_chest_front.png",
		}
	end

	minetest.register_node(name,{
		description = def.description or uname .. " chest",
		groups = groups,
		paramtype2 = "facedir",
		tiles = tiles or def.tiles,
		paramtype = "light",
		sounds = def.sounds or default.node_sound_wood_defaults(),
		on_construct=function(pos)
			minetest.get_meta(pos):get_inventory():set_size("main", 32)
		end,
		after_place_node = function(pos, placer, itemstack)
			local meta = minetest.get_meta(pos)
			local pname = placer:get_player_name()
			if locked then
				meta:set_string("owner",pname)
				meta:set_string("infotext","Locked chest (" .. pname .. ")")
			else
				meta:set_string("infotext","Chest")
			end
		end,
		on_rightclick = function(pos, node, player, itemstack, pointed_thing)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local pname = player:get_player_name()
			if owner == "" or owner == pname or minetest.check_player_privs(pname, {protection_bypass=true}) then
				minetest.after(0.1, function(pname,pos)
					return minetest.show_formspec(pname, "default.chest",
						"size[8,8]" ..
						"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
						"list[current_player;main;0,4.2;8,4;]" ..
						"listring[current_player;main]" ..
						"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
					)
				end,pname,pos)
			end

		end,
		can_dig = function(pos, player)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local pname = player:get_player_name()
			return (owner == "" or owner == pname or minetest.check_player_privs(pname, {protection_bypass=true})) and meta:get_inventory():is_empty("main")
		end,
		exatec = not locked and {
			input_list="main",
			output_list="main",
		} or nil,
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

minetest.register_node("default:itemframe", {
	description = "Item frame",
	wield_image="default_frame.png",
	inventory_image="default_frame.png",
	tiles = {"default_frame.png"},
	groups = {choppy = 2, oddly_breakable_by_hand = 2,flammable=3,itemframe=1,used_by_npc=2},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.45, 0.5, 0.5, 0.5},
		}
	},
	after_place_node = function(pos, placer)
		minetest.get_meta(pos):set_string("owner",placer:get_player_name())
	end,
	on_punch=function(pos, node, player, pointed_thing)
		local meta=minetest.get_meta(pos)
		if meta:get_string("owner") ~= player:get_player_name() then
			return
		end
		local item = meta:get_string("item")
		player:get_inventory():add_item("main",item)
		meta:set_string("item","")
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			local en = ob:get_luaentity()
			if en and en.name == "default:item" then
				ob:remove()
			end
		end
	end,
	on_rightclick=function(pos, node, player, itemstack, pointed_thing)
		if itemstack:get_name() == "" then
			return
		end

		local meta = minetest.get_meta(pos)
		if meta:get_string("owner") ~= player:get_player_name() then
			return
		end
		if meta:get_string("item") ~= "" then
			return itemstack
		end
		local p = node.param2
		local c = {
			[1]={x=0.45,z=0},
			[3]={x=-0.45,z=0},
			[2]={x=0,z=-0.45},
			[0]={x=0,z=0.45}
		}
		c = c[p]
		meta:set_string("item",itemstack:get_name())
		local en = minetest.add_entity(pos, "default:item"):get_luaentity()
		itemstack:take_item()
		en.new_itemframe(en)
		return itemstack
	end,
	on_destruct=function(pos)
		local meta=minetest.get_meta(pos)
		local item = meta:get_string("item")
		if item ~= "" then
			minetest.add_item(pos,item):set_yaw(math.random(0,6.28))
		end
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			local en = ob:get_luaentity()
			if en and en.name == "default:item" then
				ob:remove()
			end
		end
	end,
})