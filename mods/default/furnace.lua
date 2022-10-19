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
				minetest.swap_node(pos,{name="default:furnace_active",param2=minetest.get_node(pos).param2})
				minetest.get_node_timer(pos):start(1)
			end
			return stack:get_count()
		end
	end
	return 0
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

local timer =  function (pos, elapsed)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local fulltime = meta:get_int("fulltime")
	local burntime = meta:get_int("time") -1
	local newtime = 0
	local cook_slot = meta:get_int("cook_slot")
	local cooking_time = meta:get_int("cooking_time") -1
	local fuel_slot = math.random(1,16)
	local cook_stack = inv:get_stack("cook",cook_slot)
	local fuel_stack

	meta:set_int("time", burntime)
	meta:set_int("cooking_time",cooking_time)
--fuel slot

	if burntime <= 0 then
		local slots={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16}
		for i=fuel_slot,fuel_slot+16 do
			fuel_slot=slots[i]
			fuel_stack=inv:get_stack("fuel",fuel_slot)
			if fuel_stack:get_count()>0 then
				newtime = default.get_fuel(fuel_stack)
				break
			end
		end
	end

--result

	if burntime > 0 or newtime > 0 then
		local result,after=minetest.get_craft_result({method="cooking", width=1, items={cook_stack}})

		local new_cook
		if inv:room_for_item("fried", result.item) then
-- new fuel
			if cooking_time >= 0 and burntime <= 0 then
				burntime = newtime
				fulltime = newtime
				meta:set_int("time", newtime)
				meta:set_int("fulltime", newtime)
				fuel_stack:take_item()
				inv:set_stack("fuel",fuel_slot,fuel_stack)
			end
-- done
			if cooking_time <= 0 and burntime >= 0 then
				inv:add_item("fried", result.item)
				cook_stack:take_item()
				inv:set_stack("cook",cook_slot,cook_stack)
				new_cook = true
				--return true
			end
-- new cook
			if new_cook or (cooking_time <= 0 and burntime <= 0) then
				local slots = {1,2,3,4,1,2,3,4}
				cook_slot = math.random(1,4) 
				cooking_time = result.time
				for i=cook_slot,cook_slot+4 do
					cook_slot = slots[i]
					cook_stack=inv:get_stack("cook",cook_slot)
					if cook_stack:get_count()>0 then
						meta:set_int("cooking_time",cooking_time)
						meta:set_int("cooking_fulltime",cooking_time)
						meta:set_int("cook_slot",cook_slot)
						return true
					end
				end
			end
		end
	end
--formspec
	if cook_stack:get_count() == 0 then
		burntime = 0
	end


	local label = ""

	if meta:get_int("cooking_fulltime") ~= 0 and burntime ~= 0 then
		label = "label[3.6,0.2;" .. (100 - math.floor(cooking_time / meta:get_int("cooking_fulltime") * 100)) .."%]"
	end

	meta:set_string("formspec",
	"size[8,9]" ..
	"list[context;cook;1.5,0;2,2;]" ..
	"list[context;fried;4.5,0;2,2;]" ..
	"list[context;fuel;0,3;8,2;]" ..
	 label ..
	"image[3.5,1;1,1;default_fire_bg.png^[lowpart:" .. math.floor(burntime / fulltime * 100) .. ":default_fire.png]" ..
	"list[current_player;main;0,5.3;8,4;]" ..
	"listring[current_player;main]" ..
	"listring[current_name;fuel]" .. 
	"listring[current_name;fried]" .. 
	"listring[current_name;cook]"
	)
	if burntime > 0 then
		return true
	else
		meta:set_int("time",0)
		meta:set_int("cooking_time",0)
		minetest.swap_node(pos,{name="default:furnace",param2=minetest.get_node(pos).param2})
		return false
	end
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
			minetest.swap_node(pos,{name="default:furnace_active",param2=minetest.get_node(pos).param2})
			minetest.get_node_timer(pos):start(1)
		end
	end
}

minetest.register_node("default:furnace", {
	description = "Furnace",
	tiles = {"default_cobble.png","default_air.png"},
	groups = {stone=2,cracky=3,used_by_npc=1,exatec_tube_connected = 1},
	drawtype="mesh",
	use_texture_alpha = "blend",
	mesh="default_furnace.b3d",
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
		meta:set_string("infotext", " Furnace (inactive)")
		meta:set_string("formspec",
		"size[8,9]" ..
		"list[context;cook;1.5,0;2,2;]" ..
		"list[context;fried;4.5,0;2,2;]" ..
		"list[context;fuel;0,3;8,2;]" ..
		"image[3.5,1;1,1;default_fire_bg.png]" ..
		"list[current_player;main;0,5.3;8,4;]" ..
		"listring[current_player;main]" ..
		"listring[current_name;fuel]" .. 
		"listring[current_name;fried]" .. 
		"listring[current_name;cook]"
		)
	end,
	allow_metadata_inventory_put = put,
	allow_metadata_inventory_take = take,
	allow_metadata_inventory_move = move,
	can_dig = dig,
	on_timer = timer,
	exatec = exatec_furnace,
})

minetest.register_node("default:furnace_active", {
	description = "Furnace",
	drop = "default:furnace",
	use_texture_alpha = "opaque",
	tiles = {"default_cobble.png","default_fire.png"},
	groups = {stone=2,cracky=2,not_in_creative_inventory=1,exatec_tube_connected = 1},
	drawtype="mesh",
	mesh="default_furnace.b3d",
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
	can_dig = dig,
	on_timer = timer,
	exatec = exatec_furnace,
})