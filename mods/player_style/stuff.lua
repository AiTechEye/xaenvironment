minetest.register_tool("player_style:bottle", {
	description = "Liquid storable bottle",
	liquids_pointable = true,
	groups = {treasure=1},
	inventory_image = "materials_plant_extracts_gas.png^[invert:b^materials_plant_extracts.png",
	on_use=function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		local max = 65535
		wear = wear ~= 0 and wear or max
		if pointed_thing.under and player_style.drinkable(pointed_thing.under,user) and wear > 1 then
			wear=math.floor(wear-(max/5))
		elseif wear < max then
			wear=math.floor(wear+(max/5))
			player_style.thirst(user,1)
		end
		if wear > max then
			wear = max
		elseif wear < 1 then
			wear = 1
		end
		itemstack:set_wear(wear)
		return itemstack
	end,
	on_place=function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		if not minetest.is_protected(pointed_thing.above,user:get_player_name()) and default.defpos(pointed_thing.above,"buildable_to") then
			if wear == 65535 then
				minetest.add_node(pointed_thing.above,{name="materials:glass_bottle"})
				itemstack:take_item()
			elseif wear == 1 then
				minetest.add_node(pointed_thing.above,{name="player_style:glass_bottle_water"})
				itemstack:take_item()
			end
		end
		return itemstack
	end
})

minetest.register_craft({
	output="player_style:bottle 1 65535",
	recipe={{"materials:glass_bottle"}},
})

minetest.register_node("player_style:glass_bottle_water", {
	description = "Bottle with water",
	drop = "player_style:bottle 1 1",
	tiles={"materials_plant_extracts_gas.png^[invert:b^materials_plant_extracts.png"},
	inventory_image = "materials_plant_extracts_gas.png^[invert:b^materials_plant_extracts.png",
	drawtype = "plantlike",
	groups = {dig_immediate = 3,used_by_npc=1,not_in_craftguide=1,treasure=1},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
})

minetest.register_tool("player_style:matel_bottle", {
	description = "Liquid storable metal bottle",
	liquids_pointable = true,
	inventory_image = "materials_metal_bottle.png",
	groups = {treasure=2},
	on_use=function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		local max = 65535
		wear = wear ~= 0 and wear or max
		if pointed_thing.under and player_style.drinkable(pointed_thing.under,user) and wear > 1 then
			wear=math.floor(wear-(max/20))
		elseif wear < max then
			wear=math.floor(wear+(max/20))
			player_style.thirst(user,1)
		end
		if wear > max then
			wear = max
		elseif wear < 1 then
			wear = 1
		end
		itemstack:set_wear(wear)
		return itemstack
	end,
})

minetest.register_craft({
	output="player_style:matel_bottle",
	recipe={
		{"","default:iron_ingot",""},
		{"default:iron_ingot","","default:iron_ingot"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
	},
})

minetest.register_node("player_style:edgehook", {
	drawtype = "airlike",
	drop = "",
	liquid_viscosity = 3,
	pointable= false,
	liquidtype = "source",
	liquid_alternative_flowing="player_style:edgehook",
	liquid_alternative_source="player_style:edgehook",
	liquid_renewable = false,
	liquid_range = 0,
	sunlight_propagates = false,
	walkable = false,
	groups = {not_in_creative_inventory=1},
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.5)
	end,
	on_timer = function (pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do
			if ob:is_player() then
				return true
			end
		end
		minetest.remove_node(pos)
		default.update_nodes(pos)
	end
})

minetest.register_tool("player_style:backpack", {
	description = "Backpack",
	inventory_image = "player_style_backpack.png",
	wield_scale={x=2,y=2,z=3},
	groups={treasure=1,backpack=2,flammable=1},
})
minetest.register_craft({
	output="player_style:backpack",
	recipe={
		{"materials:string","examobs:pelt","materials:string"},
		{"examobs:pelt","materials:piece_of_cloth","examobs:pelt"},
		{"examobs:pelt","examobs:pelt","examobs:pelt"},
	},
})