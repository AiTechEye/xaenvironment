

--[[
default:tree
default:wood

default:dirt_with_grass
default:dirt
default:stone
default:cobble
default:sandstone
--]]

default.register_eatable("node","default:apple",1,4,{
	description = "Apple",
	inventory_image="default_apple.png",
	tiles={"default_apple.png"},
	groups = {dig_immediate=3,leafdecay=3,snappy=3,flammable=3,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagetes = true,
	walkable = false,
	visual_scale = 0.5,
	selection_box = {type = "fixed",fixed={-0.1, -0.5, -0.1, 0.1, -0.1, 0.1}},
	after_place_node = function(pos, placer)
		minetest.set_node(pos,{name="default:apple",param2=1})
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if oldnode.param2 == 0 then
			local meta = minetest.get_meta(pos)
			minetest.set_node(pos,{name="default:apple_spawner"})
			meta:set_int("date",default.date("get"))
			meta:set_int("growtime",math.random(1,30))
			minetest.get_node_timer(pos):start(10)
		end
	end
})

minetest.register_node("default:apple_spawner", {
	description = "Apple spawner",
	tiles={"default_treesapling.png"},
	groups = {not_in_creative_inventory=1},
	drop = "",
	drawtype = "airlike",
	paramtype = "light",
	pointable = false,
	sunlight_propagetes = true,
	walkable = false,
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		if default.date("m",meta:get_int("date")) > meta:get_int("growtime") then
			if minetest.find_node_near(pos,1,"default:leaves") then
				minetest.set_node(pos,{name="default:apple",param2=0})
			else
				minetest.remove_node(pos)
			end
		end
		return true
	end
})

minetest.register_node("default:sapling", {
	description = "Tree sapling",
	inventory_image="default_treesapling.png",
	tiles={"default_treesapling.png"},
	groups = {leaves=1,dig_immediate=3,snappy=3,flammable=3},
	sounds = default.node_sound_leaves_defaults(),
	attached_node = 1,
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagetes = true,
	walkable = false,
	after_place_node = function(pos, placer)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"soil") > 0 then
			local meta = minetest.get_meta(pos)
			meta:set_int("date",default.date("get"))
			meta:set_int("growtime",math.random(10,60))
			minetest.get_node_timer(pos):start(10)
		end
	end,
	on_timer = function (pos, elapsed)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"soil") and (minetest.get_node_light(pos,0.5) or 0) >= 13 then
			local meta = minetest.get_meta(pos)
			if default.date("m",meta:get_int("date")) >= meta:get_int("growtime") then
				local applm = math.random(5,20)
				minetest.remove_node(pos)
				minetest.place_schematic({x=pos.x-3,y=pos.y,z=pos.z-3}, minetest.get_modpath("default").."/schematics/default_tree.mts", "random", {}, false)
				for z=-3,3 do
				for x=-3,3 do
				for y=4,10 do
					local pos2 = {x=pos.x+x,y=pos.y+y,z=pos.z+z}
					if math.random(1,applm) == 1 and minetest.get_node(pos2).name == "default:leaves" then
						local meta = minetest.get_meta(pos2)
						minetest.set_node(pos2,{name="default:apple_spawner"})
						meta:set_int("date",default.date("get"))
						meta:set_int("growtime",math.random(1,30))
						minetest.get_node_timer(pos2):start(10)
					end
				end
				end
				end
			end
			return true
		end
	end
})

minetest.register_node("default:leaves", {
	description = "Leaves",
	tiles={"default_leaves.png"},
	groups = {leaves=1,snappy=3,leafdecay=3,flammable=2},
	sounds = default.node_sound_leaves_defaults(),
	drawtype = "allfaces_optional",
	sunlight_propagetes = true,
	paramtype = "light",
	drop ={
		max_items = 1,
		items = {
			{items = {"default:sapling"}, rarity = 25},
			{items = {"default:leaves"}}
		}
	}
})

minetest.register_node("default:glass", {
	description = "Glass",
	tiles={"default_glass_with_frame.png","default_glass.png"},
	groups = {glass=1,cracky=3,oddly_breakable_by_hand=3},
	sounds = default.node_sound_glass_defaults(),
	drawtype = "glasslike_framed_optional",
	paramtype = "light",
	paramtype2 = "glasslikeliquidelevel",
})

minetest.register_node("default:tree", {
	description = "Tree",
	tiles={"default_tree_top.png","default_tree_top.png","default_tree.png"},
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
	groups = {dirt=1,soil=1,crumbly=3,spreading_dirt_type=1,},
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
	drop = "default:cobble",
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
	groups = {crumbly=2,falling_node=1},
	sounds = default.node_sound_gravel_defaults(),
	drowning = 1,
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
	groups = {crumbly=3,sand=1,falling_node=1},
	sounds = default.node_sound_dirt_defaults(),
	drowning = 1,
	drop ={
		max_items = 1,
		items = {
			{items = {"default:flint"}, rarity = 8},
			{items = {"default:sand"}}
		}
	}
})

--||||||||||||||||
-- ======================= Water
--||||||||||||||||

minetest.register_node("default:ice", {
	description = "Ice",
	tiles={"default_ice.png"},
	groups = {cracky=3},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("default:water_source", {
	description = "Water source (fresh water)",
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
	groups = {saltwater=1, liquid=1, cools_lava=1},
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
	groups = {saltwater=1, liquid=1, cools_lava=1,not_in_creative_inventory=1},
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

--||||||||||||||||
-- ======================= Lava
--||||||||||||||||

minetest.register_node("default:lava_source", {
	description = "Lava source",
	tiles={
		{
			name = "default_lava_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		},
		{
			name = "default_lava_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		}
	},
	groups = {lava=1, liquid=1,igniter=3},
	drawtype = "liquid",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	light_source=13,
	buildable_to = true,
	drop = "",
	drowning = 1,
	damage_per_second = 9,
	liquidtype = "source",
	liquid_alternative_flowing = "default:lava_flowing",
	liquid_alternative_source = "default:lava_source",
	liquid_viscosity = 20,
	post_effect_color = {a = 240, r = 255, g = 55, b = 0},
})

minetest.register_node("default:lava_flowing", {
	description = "Lava flowing",
	special_tiles={
		{
			name = "default_lava_animated.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		},
		{
			name = "default_lava_animated.png",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2,
			}
		}
	},
	groups = {lava=1, liquid=1,not_in_creative_inventory=1,igniter=3},
	drawtype = "flowingliquid",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	light_source=13,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	damage_per_second = 9,
	liquidtype = "flowing",
	liquid_alternative_flowing = "default:lava_flowing",
	liquid_alternative_source = "default:lava_source",
	liquid_viscosity = 20,
	post_effect_color = {a = 240, r = 255, g = 55, b = 0}
})



--||||||||||||||||
-- ======================= Metal
--||||||||||||||||

minetest.register_node("default:ironblock", {
	description = "Ironblock",
	tiles={"default_ironblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:goldblock", {
	description = "Goldblock",
	tiles={"default_goldblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:uraniumactiveblock", {
	description = "Active uraniumblock",
	tiles={"default_uraniumactiveblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:silverblock", {
	description = "Silverblock",
	tiles={"default_silverblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:uraniumblock", {
	description = "Uraniumblock",
	tiles={"default_uraniumblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:copperblock", {
	description = "Copperblock",
	tiles={"default_copperblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:steelblock", {
	description = "Steelblock",
	tiles={"default_steelblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:tinblock", {
	description = "Tinblock",
	tiles={"default_tinblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})
minetest.register_node("default:bronzeblock", {
	description = "Bronzeblock",
	tiles={"default_bronzeblock.png"},
	groups = {cracky=1},
	sounds = default.node_sound_metal_defaults(),
})