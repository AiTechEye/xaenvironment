default.furnace={}

default.get_fuel=function(stack)
	local time=minetest.get_craft_result({method="fuel", width=1, items={stack:get_name()}}).time
	if time==0 then
		time=minetest.get_item_group(stack:get_name(),"flammable")
	end
	if time==0 then
		time=minetest.get_item_group(stack:get_name(),"igniter")
	end
	return time
end

local put = function(pos, listname, index, stack, player)
	if listname=="cook" or (listname=="fuel" and default.get_fuel(stack)>0) then
		local meta = minetest.get_meta(pos)

		if listname=="cook" then
			local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})
			if result.item:get_name()=="" then
				return 0
			end
		end

		local name = player:get_player_name()
		if name==meta:get_string("owner") or not minetest.is_protected(pos,name) then
			local inv = minetest.get_meta(pos):get_inventory()
			if not (inv:is_empty("cook") and inv:is_empty("fuel")) then
				minetest.get_node_timer(pos):start(1)
			end
			return stack:get_count()
		end
	end
	return 0
end

local on_take = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local i = meta:get_int("cook_slot")
	if listname=="cook" and index == i and meta:get_inventory():get_stack("cook",i):get_count() == 0 then
		meta:set_int("cook_slot",0)
		meta:set_int("cooking_time",0)
		meta:set_int("cooking_fulltime",0)
	end
end

local take = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()
	if name==meta:get_string("owner") or not minetest.is_protected(pos,name) then
		return stack:get_count()
	end
	return 0
end

local move = function(pos, from_list, from_index, to_list, to_index, count, player)
	if from_list == "fuel" and from_list == to_list then
		return count
	end
	return 0
end

local dig = function(pos, player)
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("fuel") and inv:is_empty("fried") and inv:is_empty("cook")
end

local function create_furnace_formspec(meta, fire_image_append, append)
	fire_image_append = fire_image_append or ""
	append = append or ""
	meta:set_string("formspec",
		"size[8,9]" ..
		"listcolors[#77777777;#777777aa;#000000ff]" ..
		"list[context;cook;1.5,0;2,2;]" ..
		"list[context;fried;4.5,0;2,2;]" ..
		"label[0,2.5;Fuel:]" ..
		"list[context;fuel;0,3;8,2;]" ..
		"image[3.5,0.5;1,1;default_crafting_arrowright.png]" ..
		"image[3.5,1.5;1,1;default_fire_bg.png" .. fire_image_append .. "]" ..
		"list[current_player;main;0,5.3;8,4;]" ..
		"listring[current_player;main]" ..
		"listring[current_name;fuel]" .. 
		"listring[current_name;fried]" .. 
		"listring[current_name;cook]" ..
		append
	)
end

local timer =  function (pos, elapsed)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local fulltime = meta:get_int("fulltime")
	local burntime = meta:get_int("time") -1
	local cook_slot = meta:get_int("cook_slot")
	local cooking_time = meta:get_int("cooking_time") -1
	local cook_stack = inv:get_stack("cook",cook_slot)
	local new_fuel
	meta:set_int("time", burntime)
	meta:set_int("cooking_time",cooking_time)

-- new cook

	if cooking_time <= 0 or not cook_stack or cook_stack:get_count() <= 0 and inv:is_empty("cook") == false then
		local slots = {1,2,3,4,1,2,3,4}
		cook_slot = math.random(1,4) 
		for i=cook_slot,cook_slot+4 do
			cook_slot = slots[i]
			cook_stack=inv:get_stack("cook",cook_slot)
			if cook_stack:get_count() > 0 then
				local result,after=minetest.get_craft_result({method="cooking", width=1, items={cook_stack}})
				cooking_time = result.time
				meta:set_int("cooking_time",cooking_time)
				meta:set_int("cooking_fulltime",cooking_time)
				meta:set_int("cook_slot",cook_slot)
				meta:set_string("cook_name",cook_stack:get_name())
				break
			end
		end
	end

--fuel

	if burntime <= 0 and cook_stack:get_count() > 0 then
		local fuel_stack
		local slots={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
		local slot = math.random(1,16)
		for i=slot,slot+16 do
			local fuel_slot = slots[i]
			fuel_stack=inv:get_stack("fuel",fuel_slot)
			if fuel_stack:get_count() > 0 then
				new_fuel = fuel_slot
				local newburntime = default.get_fuel(fuel_stack)
				meta:set_int("time",newburntime)
				meta:set_int("fulltime", newburntime)
				burntime = newburntime
				fulltime = newburntime
				fuel_stack:take_item()
				inv:set_stack("fuel",fuel_slot,fuel_stack)
				break
			end
		end
	end

--result

	if burntime > 0 then
		local node = minetest.get_node(pos)
		if node.name == "default:furnace" then
			node.name="default:furnace_active"
			minetest.swap_node(pos,node)
			meta:set_string("infotext", "Furnace (active)")
		end
-- done

		if cook_stack:get_name() ~= meta:get_string("cook_name") then
			meta:set_int("cooking_time",0)
			meta:set_int("cook_slot",0)
		elseif cooking_time <= 1 then
			local result,after=minetest.get_craft_result({method="cooking", width=1, items={cook_stack}})
			if inv:room_for_item("fried", result.item) then
				inv:add_item("fried", result.item)
				cook_stack:take_item()
				inv:set_stack("cook",cook_slot,cook_stack)
				meta:set_int("cooking_time",0)
				meta:set_int("cook_slot",0)
			else
				local node = minetest.get_node(pos)
				node.name="default:furnace"
				minetest.swap_node(pos,node)
				meta:set_string("infotext", "Furnace (Full)")
				meta:set_int("time",burntime+1)
				meta:set_int("cooking_time",2)
				return
			end
		end
		local param2pos = vector.multiply(minetest.facedir_to_dir(minetest.get_node(pos).param2),0.5)
		local smokepos = vector.subtract(pos,param2pos)
		minetest.add_particlespawner({
			amount = math.random(5,10),
			time = 0.2,
			minpos = smokepos,
			maxpos = smokepos,
			minvel = {x=-0.1, y=0, z=-0.1},
			maxvel = {x=0.1, y=1, z=0.1},
			minacc = {x=0, y=2, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 2,
			maxexptime = 7,
			minsize = 1,
			maxsize = 5,
			texture = "default_item_smoke.png",
			collisiondetection = true,
		})

	else
		local node = minetest.get_node(pos)
		if node.name == "default:furnace_active" then
			node.name="default:furnace"
			minetest.swap_node(pos,node)
			meta:set_string("infotext", "Furnace (inactive)")
		end
	end
--formspec
	local progress_bar = ""
	local progress_percent = ""
	if cooking_time > 0 and cook_slot > 0 then
		local pos_x = 1.5 + (cook_slot - 1) % 2
		local pos_y = math.floor((cook_slot - 1) / 2)
		local required_time = meta:get_int("cooking_fulltime")
		local percent = 100 - math.floor((cooking_time - 1) / required_time * 100)
		local progress = 0.8 - (cooking_time - 1) / required_time * 0.8
		progress_bar = "box[" .. pos_x .. "," .. pos_y .. ";" .. progress .. ",0.9;green]"
		progress_percent = "label[" .. pos_x .. "," .. pos_y .. ";" .. percent .. "%]"
	end
	
	local new_fuel_append = ""
	if new_fuel then
		local pos_x = (new_fuel - 1) % 8
		local pos_y = 3 + math.floor((new_fuel - 1) / 8)
		new_fuel_append = "box[" .. pos_x .. "," .. pos_y .. ";0.8,0.9;#f70F]"
	end
	
	local fire_image_append = ""
	if burntime > 0 then
		fire_image_append = "^[lowpart:" .. math.floor(burntime / fulltime * 100) .. ":default_fire.png"
	end

	create_furnace_formspec(meta, fire_image_append, progress_bar .. progress_percent .. new_fuel_append)
	return burntime > 0
end

exatec_furnace = {
	output_list="fried",
	test_input=function(pos,stack,opos,cpos)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		cpos = cpos  or pos
		if (cpos.y < pos.y or cpos.y > pos.y) and default.get_fuel(stack) > 0 and inv:room_for_item("fuel",stack) then
			return true
		elseif cpos.y == pos.y and inv:room_for_item("cook",stack) then
			local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})
			return result.item:get_name() ~= ""
		end
	end,
	on_input=function(pos,stack,opos,cpos)
		local m = minetest.get_meta(pos)
		local inv = m:get_inventory()
		cpos = cpos  or pos
		if (cpos.y < pos.y or cpos.y > pos.y) and default.get_fuel(stack) > 0 and inv:room_for_item("fuel",stack) then
			inv:add_item("fuel",stack)
		elseif cpos.y == pos.y and inv:room_for_item("cook",stack) then
			local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})
			if result.item:get_name() ~= "" then
				inv:add_item("cook",stack)
			end
		end
		if not (inv:is_empty("cook") and inv:is_empty("fuel")) then
			--minetest.swap_node(pos,{name="default:furnace_active",param2=minetest.get_node(pos).param2})
			minetest.get_node_timer(pos):start(1)
		end
	end
}

minetest.register_node("default:furnace", {
	description = "Furnace",
	tiles = {"default_cobble.png","default_air.png"},
	groups = {stone=2,cracky=3,used_by_npc=1,exatec_tube_connected = 1},
	drawtype="mesh",
	use_texture_alpha = "clip",
	mesh = "default_furnace.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = default.node_sound_stone_defaults(),
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_string("owner", placer:get_player_name())
	end,
	on_construct=function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("cook", 4)
		inv:set_size("fuel", 16)
		inv:set_size("fried", 4)
		meta:set_string("infotext", "Furnace (inactive)")
		create_furnace_formspec(meta)
	end,
	allow_metadata_inventory_put = put,
	allow_metadata_inventory_take = take,
	allow_metadata_inventory_move = move,
	on_metadata_inventory_take = on_take,
	can_dig = dig,
	on_timer = timer,
	exatec = exatec_furnace,
})

minetest.register_node("default:furnace_active", {
	description = "Furnace",
	drop = "default:furnace",
	use_texture_alpha = "clip",
	tiles = {
		"default_cobble.png",
		{ name = "fire_basic_flame_animated.png", animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 3.0,
		} }
	},
	groups = {stone=2,cracky=2,not_in_creative_inventory=1,exatec_tube_connected = 1},
	drawtype="mesh",
	mesh = "default_furnace.obj",
	light_source = 10,
	paramtype = "light",
	paramtype2 = "facedir",
	sounds = default.node_sound_stone_defaults(),
	after_place_node = function(pos, placer, itemstack)
		minetest.set_node(pos,{name="default:furnace"})
		minetest.registered_nodes["default:furnace"].after_place_node(pos, placer, itemstack)
	end,
	allow_metadata_inventory_put = put,
	allow_metadata_inventory_take = take,
	allow_metadata_inventory_move = move,
	on_metadata_inventory_take = on_take,
	can_dig = dig,
	on_timer = timer,
	exatec = exatec_furnace,
})

local craftitempos = {
	vector.new(0,-0.3,0),
	vector.new(-0.3,-0.3,0),
	vector.new(0.3,-0.3,0),
	vector.new(0,-0.3,-0.3),
	vector.new(0,-0.3,0.3),
	vector.new(0.3,-0.3,0.3),
	vector.new(-0.3,-0.3,0.3),
	vector.new(0.3,-0.3,-0.3),
	vector.new(-0.3,-0.3,-0.3),
}

minetest.register_node("default:furnace_industrial", {
	description = "Industrial furnace (Power required)",
	manual_page_func=function()
		local a = ""
		for i,v in pairs(minetest.registered_nodes) do
			if v.groups and v.groups.tech_connect then
				a = a .. v.name .." "
			end
		end
		a = a .. "\nFurnaces is very important to craft things, but when you want to fry things faster you can use the Industrial furnace.\nTo use it you need a generator, like the 'Steam powered generator'.\nConnect it through gray wires to the furnace.\nThe more working generatorns that is connected to the gray wire network the more power you gets and faster it goes."
		return a
	end,
	tiles = {"default_steelblock.png","default_glass.png"},
	groups = {cracky=2,used_by_npc=1,tech_connect=1,exatec_tube_connected = 1,on_load=1},
	drop="default:furnace_industrial",
	use_texture_alpha = "blend",
	paramtype = "light",

	paramtype2 = "color4dir",
	palette="default_palette64x.png",

	drawtype="mesh",
	mesh="default_furnace_industrial.b3d",
	sounds = default.node_sound_metal_defaults(),
	after_place_node = function(pos, placer, itemstack)
		minetest.get_meta(pos):set_string("owner", placer:get_player_name())
	end,
	on_construct=function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_int("param2", minetest.get_node(pos).param2)
		inv:set_size("cook", 9)
		inv:set_size("fried", 9)
		meta:set_string("infotext", "Furnace (inactive) connect to a power generator through gray wires")
		minetest.registered_nodes["default:furnace_industrial"].update_form(pos)
	end,
	update_form=function(pos,effect)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local c = "123456789abcdef"
		local a = ""
		local stat = ""
		local x,y = 0,0
		for i=1,9 do
			local time = meta:get_int("time"..i)
			local fried = meta:get_string("fried"..i)
			local burn = meta:get_int("burntime"..i)

			if time > 0 then
				local def = default.def(meta:get_string("itemname"..i)) or {}
				stat = stat .. "\n" .. (def.description or meta:get_string("itemname"..i)) .. " " .. (time/burn*100).."%"
				local n = math.ceil((time/burn*150)*0.1)
				a = a .. "box["..x..","..y..";0.8,0.9;#"..c:sub(n,n).."00F]"
			elseif fried ~= "" then
				meta:set_string("fried"..i,"")
				local def= default.def(fried) or {}
				stat = stat .. "\n" .. (def.description or fried) .. " 100%"
				a = a .. "box["..x..","..y..";0.8,0.9;#F00F]"
			else
				a = a .. "box["..x..","..y..";0.8,0.9;#000F]"
			end
			x = x + 1
			if x >= 3 then
				x = 0
				y = y +1
			end
		end

		if stat == "" then
			meta:set_string("infotext","Furnace (inactive)")
			for i=1,9 do
				meta:set_int("time"..i,0)
				meta:set_string("itemname"..i,"")
			end
		else
			meta:set_string("infotext", "Furnace: (Heat: "..effect..")"..stat)
		end
		meta:set_string("formspec",
		"size[8,8]" ..
		"listcolors[#77777777;#777777aa;#000000ff]" ..
		(stat == "" and "image[3.1,0.5;2,2;fire_basic_flame.png^[colorize:#333]" or "animated_image[3.1,0.5;2,2;fire;fire_basic_flame_animated.png;8;1;1]") ..
		a..
		"list[context;cook;0,0;3,3;]" ..
		"list[context;fried;5,0;3,3;]" ..
		"list[current_player;main;0,4;8,4;]" ..
		"listring[current_player;main]"..
		"listring[current_name;cook]"..
		"listring[current_name;fried]".. 
		"listring[current_player;main]"
		)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local name = player:get_player_name()
		if listname=="cook" and (name == meta:get_string("owner") or not minetest.is_protected(pos,name)) then
			local inv = meta:get_inventory()
			local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})
			if result.item:get_name() ~= "" and inv:room_for_item("cook",stack) and inv:room_for_item("fried",result.item) then
				return stack:get_count()
			end
		end
		return 0
	end,
	allow_metadata_inventory_take = take,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if from_list == to_list and from_index == "cook" then
			return count
		end
		return 0
	end,
	can_dig = function(pos, player)
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("fried") and inv:is_empty("cook")
	end,
	exatec = {
		input_list="cook",
		output_list="fried",
		test_input=function(pos,stack,opos,cpos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})
			return result.item:get_name() ~= "" and inv:room_for_item("cook",stack) and inv:room_for_item("fried",result.item)
		end,
		on_input=function(pos,stack,opos,cpos)
			local m = minetest.get_meta(pos)
			local inv = m:get_inventory()
			if inv:room_for_item("cook",stack) then
				local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})
				if result.item:get_name() ~= "" then
					inv:add_item("cook",stack)
				end
			end
		end
	},
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local timeout = meta:get_int("timeout")
		timeout = timeout + 1
		meta:set_int("timeout",timeout)
		if timeout >= 7 then
			meta:set_int("timeout",0)
			for i=1,9 do
				meta:set_int("time"..i,0)
				meta:set_string("itemname"..i,"")
				meta:set_string("fried"..i,"")
			end
			minetest.registered_nodes["default:furnace_industrial"].update_form(pos,0)
			minetest.swap_node(pos,{name="default:furnace_industrial",param2=minetest.get_meta(pos):get_int("param2")})
			return
		elseif timeout > 1 then
			local a = {8,16,17,18,19}
			minetest.swap_node(pos,{name="default:furnace_industrial",param2=minetest.get_meta(pos):get_int("param2")+4*a[timeout-1]})
		end
		return true
	end,
	on_load=function(pos)
		minetest.get_meta(pos):set_int("update",1)
	end,
	color=function(pos,e)
		local meta = minetest.get_meta(pos)
		if meta:get_int("timeout") == 0 then
			local color = 0
			local n = {9,7,5,3,0}
			for i,v in ipairs({8,16,17,18,19}) do
				if e >= n[i] then
					color = v*4
					break
				end
			end
			minetest.swap_node(pos,{name="default:furnace_industrial",param2=meta:get_int("param2")+color})
		end
	end,
	on_effect=function(pos,effect)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local t = minetest.get_node_timer(pos)
		local update1
		if t:is_started() then
			t:set(1.2,0)
		else
			t:start(1.2)
		end
		meta:set_int("timeout",5-math.floor(effect/2))

		if meta:get_int("update") == 1 then
			update1 = true
			meta:set_int("update",0)
		end

		for i=1,9 do
			local time = meta:get_int("time"..i)
			local itemname = meta:get_string("itemname"..i)
			local stack = inv:get_stack("cook",i)
			local update2
			if stack:get_name() ~= "" then
				local result,after=minetest.get_craft_result({method="cooking", width=1, items={stack}})

				if time == 0 or itemname == "" then
					time = 0
					meta:set_int("time"..i,0)
					meta:set_string("fried"..i,"")
					meta:set_string("burntime"..i,result.time)
					meta:set_string("itemname"..i,stack:get_name())
					update2 = itemname ~= stack:get_name()
					itemname = stack:get_name()
				end

				if update1 or update2 then
					local self = minetest.add_entity(vector.add(pos,craftitempos[i]),"default:wielditem"):get_luaentity()
					self.object:set_properties({
						automatic_rotate = 0.5,
						visual_size = {x=0.2,y=0.2,z=0.2},
						textures = {itemname}
					})
					self.on_step=function(self,dtime)
						self.timer = (self.timer or 0) + dtime
						if self.timer > 0.1 then
							self.timer = 0
							if minetest.get_meta(pos):get_string("itemname"..i) ~= itemname then
								self.object:remove()
							end
						end
					end
				end

				time = time + effect

				if time >= result.time then
					if inv:room_for_item("fried", result.item) then
						inv:add_item("fried", result.item)
						stack:take_item()
						inv:set_stack("cook",i,stack)
						meta:set_int("time"..i,0)
						meta:set_string("fried"..i,stack:get_name())
					end
				else
					meta:set_int("time"..i,time)
				end
			else
				meta:set_int("time"..i,0)
				meta:set_string("itemname"..i,"")
			end
		end
		minetest.registered_nodes["default:furnace_industrial"].update_form(pos,effect)
		minetest.registered_nodes["default:furnace_industrial"].color(pos,effect)
	end
})

minetest.register_node("default:steam_powered_generator", {
	description = "Steam powered generator (Fuel power)",
	tiles = {"default_ironblock.png^default_glass.png^default_chest_top.png"},
	sounds = default.node_sound_glass_defaults(),
	groups = {cracky=3,exatec_tube_connected=1,tech_connect=1,used_by_npc=1,store=500},
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		local x = 0
		local y = 0
		local f = ""
		m:get_inventory():set_size("main", 32)

		for i=1,32 do
			f = f .. "image["..x..","..y..";1,1;fire_basic_flame.png]"
			x = x + 1
			if x == 8 then
				x = 0
				y =y +1
			end
		end

		m:set_string("formspec",
			"size[8,8]"
			.."listcolors[#77777777;#777777aa;#000000ff]"
			.."list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]"
			.."list[current_player;main;0,4.2;8,4;]"
			.."listring[current_player;main]"
			.."listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
			..f
		)
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return default.get_fuel(stack)>0 and stack:get_count() or 0
	end,
	on_metadata_inventory_put=function(pos)
		local t = minetest.get_node_timer(pos)
		if not t:is_started() then
			t:start(1)
		end
	end,
	exatec = {
		input_list="main",
		test_input=function(pos,stack,opos,cpos)
			local inv = minetest.get_meta(pos):get_inventory()
			return inv:room_for_item("main",stack) and minetest.registered_nodes["default:steam_powered_generator"].allow_metadata_inventory_put(pos,"main", 1, stack)
		end,
		on_input=function(pos,stack,opos,cpos)
			local t = minetest.get_node_timer(pos)
			if not t:is_started() then
				t:start(1)
			end
		end
	},
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local heat = meta:get_int("heat")
		local burning
		for i,v in pairs(inv:get_list("main")) do
			if v:get_name() ~= "" and heat < 100 then
				burning = true
				heat = heat + default.get_fuel(v)
				v:take_item()
				inv:set_stack("main",i,v)
				break
			end
		end
		heat = heat + (burning and 1 or -1)
		meta:set_int("heat",heat)
		local effect = math.ceil(heat*0.1)
		meta:set_string("infotext", "Steam powered generator\nHeat: "..heat.."\nPower: "..effect)
		default.effect(pos,effect)
		return heat > 0
	end
})

minetest.register_node("default:wire", {
	description = "Power Wire",
	tiles = {{name="default_cloud.png"}},
	wield_image="exatec_wire.png^[colorize:#555f",
	inventory_image="exatec_wire.png^[colorize:#555f",
	drop="default:wire",
	drawtype="nodebox",
	use_texture_alpha = "opaque",
	paramtype = "light",
	paramtype2="color",
	palette="default_palette.png",
	sunlight_propagates=true,
	walkable=false,
	node_box = {
		type = "connected",
		connect_back={-0.05,-0.5,0, 0.05,-0.45,0.5},
		connect_front={-0.05,-0.5,-0.5, 0.05,-0.45,0},
		connect_left={-0.5,-0.5,-0.05, 0.05,-0.45,0.05},
		connect_right={0,-0.5,-0.05, 0.5,-0.45,0.05},
		connect_top = {-0.05, -0.5, -0.05, 0.05, 0.5, 0.05},
		fixed = {-0.05, -0.5, -0.05, 0.05, -0.45, 0.05},
	},
	selection_box={type="fixed",fixed={-0.5,-0.5,-0.5,0.5,0.-0.4,0.5}},
	connects_to={"group:tech_connect"},
	groups = {dig_immediate = 3,tech_connect=1,treasure=1,store=100},
	after_destruct=function(pos)
		default.effects[minetest.pos_to_string(pos)] = nil
	end,
	after_place_node = function(pos, placer)
		minetest.set_node(pos,{name="default:wire",param2=132})
	end,
	on_timer = function (pos, elapsed)
		default.effects[minetest.pos_to_string(pos)] = nil
		minetest.set_node(pos,{name="default:wire",param2=132})
	end,
})