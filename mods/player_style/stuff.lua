minetest.register_tool("player_style:bottle", {
	description = "Liquid storable bottle",
	liquids_pointable = true,
	inventory_image = "materials_plant_extracts_gas.png^[invert:b^materials_plant_extracts.png",
	on_use=function(itemstack, user, pointed_thing)
		local wear = itemstack:get_wear()
		local max = 65535
		wear = wear ~= 0 and wear or max
		if pointed_thing.under and player_style.drinkable(pointed_thing.under,user) and wear > 1 then
			wear=math.floor(wear-(max/5))
			minetest.remove_node(pointed_thing.under)
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
	groups = {dig_immediate = 3,used_by_npc=1,not_in_craftguide=1},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
})