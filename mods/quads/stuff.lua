minetest.register_craft({
	output="quads:petrol_tank",
	recipe={
		{"materials:plant_extracts_gas","default:carbon_lump","quads:petrol_tank_empty"},
		{"player_style:bottle","quads:bottle_with_oil",""},
	},
	replacements={
		{"player_style:bottle","materials:glass_bottle"},
		{"quads:bottle_with_oil","materials:glass_bottle"}
	}
})

minetest.register_craft({
	output="quads:petrol_tank_empty",
	recipe={
		{"default:iron_ingot","default:iron_ingot","default:carbon_lump"},
		{"default:iron_ingot","default:iron_ingot",""},
	},
})

minetest.register_craft({
	output="quads:bottle",
	recipe={
		{"materials:glass_bottle","default:coal_lump"},
	},
})

minetest.register_node("quads:petrol_tank", {
	stack_max = 1,
	description="Petrol tank",
	tiles={"default_ironblock.png"},
	groups = {dig_immediate = 3,flammable=3,treasure=1,store=200},
	paramtype = "light",
	paramtype2="facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.25, 0.125, 0.0625, 0.25},
			{-0.0625, 0.1875, -0.1875, 0.0625, 0.25, 0.1875},
			{-0.0625, 0.0625, -0.25, 0.0625, 0.25, -0.125},
			{-0.0625, 0.0625, 0.0625, 0.0625, 0.25, 0.25},
		}
	},
	on_blast=function(pos)
		minetest.set_node(pos,{name="air"})
		nitroglycerin.explode(pos,{radius=3,set="fire:basic_flame"})
	end,
	on_burn = function(pos)
		minetest.registered_nodes["quads:petrol_tank"].on_blast(pos)
	end,
	on_ignite = function(pos, igniter)
		minetest.registered_nodes["quads:petrol_tank"].on_blast(pos)
	end,
})

minetest.register_node("quads:petrol_tank_empty", {
	stack_max = 1,
	description="Petrol tank (empty)",
	tiles={"default_ironblock.png"},
	groups = {dig_immediate = 3,treasure=1},
	paramtype = "light",
	paramtype2="facedir",
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.25, 0.125, 0.0625, 0.25},
			{-0.0625, 0.1875, -0.1875, 0.0625, 0.25, 0.1875},
			{-0.0625, 0.0625, -0.25, 0.0625, 0.25, -0.125},
			{-0.0625, 0.0625, 0.0625, 0.0625, 0.25, 0.25},
		}
	}
})

minetest.register_tool("quads:bottle", {
	description = "Oil storable bottle",
	liquids_pointable = true,
	inventory_image = "materials_plant_extracts.png",
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.under and minetest.get_item_group(minetest.get_node(pointed_thing.under).name,"oil") > 0 then
			local item = itemstack:to_table()
			item.name = "quads:bottle_with_oil"
			return item
		end
		return itemstack
	end
})
minetest.register_node("quads:bottle_with_oil", {
	description = "Bottle with oil",
	liquids_pointable = true,
	inventory_image = "materials_plant_extracts_gas.png^[invert:rg^materials_plant_extracts.png",
	tiles = {"materials_plant_extracts_gas.png^[invert:rg^materials_plant_extracts.png"},
	drawtype="plantlike",
	groups = {dig_immediate = 3,treasure=1,flammable=3},
})