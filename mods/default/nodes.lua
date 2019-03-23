

--[[
default:tree
default:wood

default:dirt_with_grass
default:dirt
default:stone
default:cobble
default:sandstone
--]]


minetest.register_node("default:sapling", {
	description = "Tree sapling (not working yet)",
	tiles={"default_treesapling.png"},
	groups = {leaves=1,dig_immediate=3,snappy=3,leafdecay=3,flammable=1},
	sounds = default.node_sound_leaves_defaults(),
	attached_node = 1,
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagetes = true,
	walkable = false,
})


minetest.register_node("default:leaves", {
	description = "Leaves",
	tiles={"default_leaves.png"},
	groups = {leaves=1,snappy=3,leafdecay=3,flammable=1},
	sounds = default.node_sound_leaves_defaults(),
	drawtype = "allfaces_optional",
	paramtype = "light",
	drop ={
		max_items = 1,
		items = {
			{items = {"default:sapling"}, rarity = 25},
			{items = {"default:leaves"}}
		}
	}
})


minetest.register_node("default:tree", {
	description = "Tree",
	tiles={"default_tree_top.png","default_tree.png"},
	paramtype2="facedir",
	on_place=minetest.rotate_node,
	groups = {tree=1,choppy=2,flammable=1},
	sounds = default.node_sound_wood_defaults(),
})
minetest.register_node("default:wood", {
	description = "Wood",
	tiles={"default_wood.png"},
	groups = {wood=1,choppy=3,flammable=2},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("default:dirt_with_grass", {
	description = "Dirt with grass",
	drop="default:dirt",
	tiles={"default_grass.png","default_dirt.png","default_dirt.png^default_grass_side.png"},
	groups = {dirt=1,soil=1,crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default:dirt", {
	description = "Dirt",
	tiles={"default_dirt.png"},
	groups = {dirt=1,soil=1,crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
})

--||||||||||||||||
-- ======================= Stone
--||||||||||||||||

minetest.register_node("default:stone", {
	description = "Stone",
	tiles={"default_stone.png"},
	groups = {stone=1,cracky=3},
	sounds = default.node_sound_stone_defaults(),

})
minetest.register_node("default:cobble", {
	description = "Cobble",
	tiles={"default_cobble.png"},
	groups = {stone=1,cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:gravel", {
	description = "Gravel",
	tiles={"default_gravel.png"},
	groups = {crumbly=2},
	sounds = default.node_sound_gravel_defaults(),
	drop ={
		max_items = 1,
		items = {
			{items = {"default:flint"}, rarity = 8},
			{items = {"default:gravel"}}
		}
	}
})

minetest.register_node("default:sandstone", {
	description = "Sand stone",
	tiles={"default_sandstone.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:sand", {
	description = "Sand",
	tiles={"default_sand.png"},
	groups = {crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
	drop ={
		max_items = 1,
		items = {
			{items = {"default:flint"}, rarity = 8},
			{items = {"default:sand"}}
		}
	}
})

--||||||||||||||||
-- ======================= Ores
--||||||||||||||||


minetest.register_node("default:coal_ore", {
	description = "Coal ore",
	tiles={"default_stone.png^default_ore_coal.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	drop="default:coal_lump",
})

minetest.register_node("default:iron_ore", {
	description = "Iron ore",
	tiles={"default_stone.png^default_ore_iron.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	drop="default:iron_lump",
})

minetest.register_node("default:copper_ore", {
	description = "Copper ore",
	tiles={"default_stone.png^default_ore_copper.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	drop="default:copper_lump",
})

minetest.register_node("default:tin_ore", {
	description = "Tin ore",
	tiles={"default_stone.png^default_ore_tin.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	drop="default:tin_lump",
})

minetest.register_node("default:silver_ore", {
	description = "Silver ore",
	tiles={"default_stone.png^default_ore_silver.png"},
	groups = {cracky=1},
	sounds = default.node_sound_stone_defaults(),
	drop="default:silver_lump",
})

minetest.register_node("default:gold_ore", {
	description = "Gold ore",
	tiles={"default_stone.png^default_ore_gold.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	drop="default:gold_lump",
})

minetest.register_node("default:electric_ore", {
	description = "Electric ore",
	tiles={"default_stone.png^default_ore_electric.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	drop="default:electric_lump",
})

minetest.register_node("default:electric_ore", {
	description = "Electric ore",
	tiles={"default_stone.png^default_ore_electric.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	drop="default:electric_lump",
})

minetest.register_node("default:uranium_ore", {
	description = "Uranium ore",
	tiles={"default_stone.png^default_ore_uranium.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	drop="default:uranium_lump",
})

--||||||||||||||||
-- ======================= Water
--||||||||||||||||


minetest.register_node("default:water_source", {
	description = "Water source",
	tiles={
		{
			name = "default_water_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		},
		{
			name = "default_water_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		}
	},
	alpha =165,
	groups = {water=1, liquid=1, cools_lava=1},
	drawtype = "liquid",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "default:water_flowing",
	liquid_alternative_source = "default:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 110, r = 42, g = 128, b = 231},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("default:water_flowing", {
	description = "Water flowing",
	special_tiles={
		{
			name = "default_water_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		},
		{
			name = "default_water_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		}
	},
	alpha =165,
	groups = {water=1, liquid=1, cools_lava=1,not_in_creative_inventory=1},
	drawtype = "flowingliquid",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default:water_flowing",
	liquid_alternative_source = "default:water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 110, r = 42, g = 128, b = 231},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("default:salt_water_source", {
	description = "Salt water source",
	tiles={
		{
			name = "default_salt_water_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		},
		{
			name = "default_salt_water_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		}
	},
	alpha =165,
	groups = {water=1, liquid=1, cools_lava=1},
	drawtype = "liquid",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "default:salt_water_flowing",
	liquid_alternative_source = "default:salt_water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 100, r = 0, g = 90, b = 133},
	sounds = default.node_sound_water_defaults(),
})

minetest.register_node("default:salt_water_flowing", {
	description = "Salt water flowing",
	special_tiles={
		{
			name = "default_salt_water_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		},
		{
			name = "default_salt_water_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2,
			}
		}
	},
	alpha =165,
	groups = {water=1, liquid=1, cools_lava=1,not_in_creative_inventory=1},
	drawtype = "flowingliquid",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default:salt_water_flowing",
	liquid_alternative_source = "default:salt_water_source",
	liquid_viscosity = 1,
	post_effect_color = {a = 100, r = 0, g = 90, b = 133},
	sounds = default.node_sound_water_defaults(),
})