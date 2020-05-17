minetest.register_node("default:lamp", {
	description = "Lamp",
	tiles={"default_cloud.png"},
	groups = {dig_immediate=3,exatec_wire_connected=1,wallmounted=1},
	sounds = default.node_sound_glass_defaults(),
	drawtype = "nodebox",
	node_box = {type = "fixed",fixed={-0.2, -0.5, -0.2, 0.2, -0.3, 0.2}},
	paramtype = "light",
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	sunlight_propagates = true,
	light_source = 15,
	exatec={
		on_wire = function(pos)
			minetest.set_node(pos,{name="default:lamp_off",param2=minetest.get_node(pos).param2})
		end
	}
})

minetest.register_node("default:lamp_off", {
	description = "Lamp (off)",
	drop="default:lamp",
	tiles={"default_cloud.png^[colorize:#33333333"},
	groups = {dig_immediate=3,wallmounted=1,exatec_wire_connected=1,not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	drawtype = "nodebox",
	node_box = {type = "fixed",fixed={-0.2, -0.5, -0.2, 0.2, -0.3, 0.2}},
	paramtype = "light",
	paramtype2 = "facedir",
	on_place = minetest.rotate_node,
	exatec={
		on_wire = function(pos)
			minetest.set_node(pos,{name="default:lamp",param2=minetest.get_node(pos).param2})
		end
	}

})

minetest.register_node("default:cloud", {
	description="Cloud",
	drawtype="glasslike",
	tiles={"default_cloud.png"},
	groups = {cracky=1,level=2,fall_damage_add_percent=-90,treasure=2},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 13,
	post_effect_color = {a = 220, r = 255, g = 255, b = 255},
	drowning = 1,
	alpha=240,
})

minetest.register_node("default:dye", {
	tiles={"default_wool.png"},
	groups = {dig_immediate = 3,flammable=3,not_in_creative_inventory=1},
	palette="default_palette.png",
	paramtype2="color",
	drawtype = "mesh",
	mesh = "default_dye.obj",
	walkable= false,
	paramtype = "light",
	sunlight_propagates = true,
	selection_box = {
		type = "fixed",
		fixed = {{-0.2, -0.5, -0.1, 0.2, -0.3, 0.1}}
	},
	on_place=function()
	end
})

minetest.register_node("default:wool", {
	description = "Wool",
	tiles={"default_wool.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,flammable=3,treasure=1},
	sounds = default.node_sound_wood_defaults(),
	palette="default_palette.png",
	paramtype2="color",
	on_punch=default.dye_coloring
})

minetest.register_node("default:quantumblock", {
	tiles={"default_quantumblock.png"},
	groups = {cracky=1,level=2,treasure=3},
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 13
})

minetest.register_node("default:gas", {
	description = "Gas",
	tiles={"default_gas.png"},
	groups = {gas=1,flammable=2,on_update=1,not_in_craftguide=1},
	drawtype="glasslike",
	paramtype = "light",
	pointable=false,
	sunlight_propagates = true,
	walkable=false,
	post_effect_color = {a = 20, r = 213, g = 255, b = 0},
	drowning = 1,
	buildable_to = true,
	alpha=10,
	drop = "",
	on_update = function(pos)
		minetest.after(0.1,function(pos)
			for i, p in pairs(minetest.find_nodes_in_area(vector.subtract(pos, 1),vector.add(pos,1),{"air"})) do
				if p.y <= 0 then
					minetest.set_node(p,{name="default:gas"})
					default.def("default:gas").on_update(p)
				end
			end
		end,pos)
	end,
	on_burn=function(pos)
		default.def(minetest.get_node(pos).name).on_ignite(pos)
	end,
	on_ignite=function(pos)
		minetest.set_node(pos,{name="fire:not_igniter"})
		minetest.after(0.1,function(pos)
			default.punch_pos(pos,10)
			for _,p in pairs(minetest.find_nodes_in_area(vector.add(pos,1),vector.subtract(pos,1),{"default:gas"})) do
				default.def(minetest.get_node(p).name).on_ignite(p)
			end
		end,pos)
	end
})

minetest.register_node("default:ladder", {
	description = "Ladder",
	tiles={"default_wood.png"},
	groups = {ladder=1,choppy=3,oddly_breakable_by_hand=3,flammable=2,treasure=1},
	sounds = default.node_sound_wood_defaults(),
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4375, -0.5, -0.35, 0.4375, -0.4375, -0.25},
			{-0.4375, -0.5, -0.05, 0.4375, -0.4375, 0.05},
			{-0.4375, -0.5, 0.25, 0.4375, -0.4375, 0.35},
			{-0.5, -0.5, -0.5, -0.4375, -0.375, 0.5},
			{0.4375, -0.5, -0.5, 0.5, -0.375, 0.5},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5}}
	},
	climbable = true,
	paramtype = "light",
	paramtype2 = "wallmounted",
	legacy_wallmounted=true,
	walkable=false,
})

minetest.register_node("default:stick_on_ground", {
	description = "Stick",
	drop="default:stick",
	tiles={"default_tree.png"},
	groups = {stick=1,dig_immediate=3,flammable=2,not_in_craftguide=1},
	sounds = default.node_sound_wood_defaults(),
	drawtype="nodebox",
	node_box = {type="fixed",fixed={-0.05,-0.5,-0.5,0.05,-0.45,0.5}},
	paramtype = "light",
	paramtype2 = "facedir",
	walkable=false,
	on_construct = function(pos)
		minetest.swap_node(pos,{name="default:stick_on_ground",param2=math.random(0,3)})
	end
})

minetest.register_node("default:torch", {
	description = "Torch",
	tiles={"default_torch.png"},
	wield_scale = {x=2,y=2,z=2},
	groups = {dig_immediate=3,flammable=3,igniter=1,treasure=1},
	drawtype = "mesh",
	mesh="default_torch.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	on_place=function(itemstack, placer, pointed_thing)
		if minetest.get_item_group(minetest.get_node(pointed_thing.under).name,"attached_node")>0 then
			return itemstack
		end
		local fdw=minetest.dir_to_wallmounted(vector.subtract(pointed_thing.under,pointed_thing.above))
		if fdw == 1 then
			minetest.set_node(pointed_thing.above,{name="default:torch_floor",param2=fdw})
		else
			minetest.set_node(pointed_thing.above,{name="default:torch_lean",param2=fdw})
		end
		local meta = minetest.get_meta(pointed_thing.above)
		meta:set_int("date",default.date("get"))
		meta:set_int("hours",math.random(24,72))
		minetest.get_node_timer(pointed_thing.above):start(10)
		itemstack:take_item()
		return itemstack
	end,
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type =="object" then
			local p = pointed_thing.ref:get_pos()
			if not minetest.is_protected(p, user:get_player_name()) and default.defpos(p,"buildable_to") then
				minetest.set_node(p,{name="fire:basic_flame"})
				local en =  pointed_thing.ref:get_luaentity()
				if not (en and en.name == "__builtin:item") and math.random(1,5) == 1 then
					user:get_inventory():add_item("main","default:stick")
					itemstack:take_item()
					return itemstack
				end
			end
		end
		default.wieldlight(user:get_player_name(),user:get_wield_index(),"default:torch")
	end

})

minetest.register_node("default:torch_floor", {
	description = "Torch",
	drop = "default:torch",
	tiles={"default_torch.png"},
	groups = {dig_immediate=3,flammable=3,igniter=1,attached_node=1,not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	floodable = true,
	drawtype = "mesh",
	mesh="default_torch.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	light_source = 10,
	damage_per_second = 2,
	selection_box = {type = "fixed",fixed={-0.1, -0.5, -0.1, 0.1, 0.2, 0.1}},
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		if default.date("h",meta:get_int("date")) > meta:get_int("hours") then
			minetest.remove_node(pos)
			return false
		end
		return true
	end
})

minetest.register_node("default:torch_lean", {
	description = "Torch",
	drop = "default:torch",
	tiles={"default_torch.png"},
	groups = {dig_immediate=3,flammable=3,igniter=1,not_in_creative_inventory=1,attached_node=1},
	sounds = default.node_sound_wood_defaults(),
	drawtype = "mesh",
	floodable = true,
	mesh="default_torch_lean.obj",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	light_source = 10,
	damage_per_second = 2,
	selection_box = {type = "fixed",fixed={-0.1, -0.5, -0.3, 0.1, 0, 0.3}},
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_int("date",default.date("get"))
		meta:set_int("hours",math.random(24,72))
		minetest.get_node_timer(pos):start(10)
	end,
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		if default.date("h",meta:get_int("date")) > meta:get_int("hours") then
			minetest.remove_node(pos)
			return false
		end
		return true
	end
})

minetest.register_node("default:lightsource", {
	drawtype = "airlike",
	floodable = true,
	pointable=false,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	light_source = 10,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.5)
	end,
	on_timer = function (pos, elapsed)
		minetest.remove_node(pos)
	end
})
--||||||||||||||||
-- ======================= glass
--||||||||||||||||

minetest.register_node("default:tankstorage", {
	description = "Tankstorage",
	tiles={"default_glass_with_frame.png"},
	groups = {glass=1,cracky=3,oddly_breakable_by_hand=3,tankstorage=1,treasure=1},
	sounds = default.node_sound_glass_defaults(),
	drawtype = "glasslike_framed",
	sunlight_propagates = true,
	paramtype = "light",
})

minetest.register_node("default:glass_tabletop", {
	description = "Glass tabletop",
	tiles={"default_glass_with_frame.png"}, --,"default_glass.png"
	groups = {glass=1,cracky=3,oddly_breakable_by_hand=3,treasure=1},
	sounds = default.node_sound_glass_defaults(),
	drawtype = "glasslike_framed_optional",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.45, 0.5},
		}
	},
})

minetest.register_node("default:glass", {
	description = "Glass",
	tiles={"default_glass_with_frame.png","default_glass.png"},
	groups = {glass=1,cracky=3,oddly_breakable_by_hand=3,treasure=1},
	sounds = default.node_sound_glass_defaults(),
	drawtype = "glasslike_framed_optional",
	sunlight_propagates = true,
	paramtype = "light",
})

--||||||||||||||||
-- ======================= grass
--||||||||||||||||

minetest.register_node("default:dirt_with_red_permafrost_grass", {
	description = "Dirt with red permafrost  grass",
	drop="default:permafrost_dirt",
	tiles={"default_permafrost_redgrass.png","default_permafrostdirt.png","default_permafrostdirt.png^default_permafrost_redgrass_side.png"},
	groups = {dirt=1,crumbly=1,spreading_dirt_type=1,},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default:dirt_with_permafrost_grass", {
	description = "Dirt with permafrost grass",
	drop="default:permafrost_dirt",
	tiles={"default_permafrost_grass.png","default_permafrostdirt.png","default_permafrostdirt.png^default_permafrost_grass_side.png"},
	groups = {dirt=1,crumbly=1,spreading_dirt_type=1,},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default:permafrost_dirt", {
	description = "Permafrost dirt",
	tiles={"default_permafrostdirt.png"},
	groups = {dirt=1,crumbly=1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default:dirt_with_snow", {
	description = "Dirt with snow",
	drop="default:dirt",
	tiles={"default_snow.png","default_dirt.png","default_dirt.png^default_snow_side.png"},
	groups = {dirt=1,crumbly=3,cools_lava=1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default:dirt_with_dry_grass", {
	description = "Dirt with dry grass",
	drop="default:dirt",
	tiles={"default_dry_grass.png","default_dirt.png","default_dirt.png^default_dry_grass_side.png"},
	groups = {dirt=1,soil=1,crumbly=3,spreading_dirt_type=1,},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default:dirt_with_jungle_grass", {
	description = "Dirt with jungle grass",
	drop="default:dirt",
	tiles={"default_jungle_grass.png","default_dirt.png","default_dirt.png^default_jungle_grass_side.png"},
	groups = {dirt=1,soil=1,crumbly=3,spreading_dirt_type=1,},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default:dirt_with_coniferous_grass", {
	description = "Dirt with coniferous grass",
	drop="default:dirt",
	tiles={"default_coniferous_grass.png","default_dirt.png","default_dirt.png^default_coniferous_grass_side.png"},
	groups = {dirt=1,soil=1,crumbly=3,spreading_dirt_type=1,},
	sounds = default.node_sound_dirt_defaults(),
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

minetest.register_node("default:wet_soil", {
	description = "Wet soil",
	drop="default:dirt",
	tiles={"default_dirt.png^[colorize:#00000022"},
	groups = {dirt=1,soil=1,wet_soil=1,crumbly=3,not_in_creative_inventory=1},
	sounds = default.node_sound_dirt_defaults(),
})

--||||||||||||||||
-- ======================= Stone
--||||||||||||||||

default.register_pebble({
	name="stone",
	block="default:sand",
	decoration={seed=543}
})

default.register_pebble({
	name="desert_stone",
	tiles={"default_desertstone.png","default_desert_sand.png"},
	block="default:desert_sand",
	decoration={
		seed=532,
		place_on={"default:desert_stone","default:desert_sand"},
	}	
})

default.register_blockdetails({
	name="starfish",
	node={
		tiles={"default_sand.png","default_starfish.png"},
		drop="default:starfish",
		block="default:sand",
	},
	item={},
})
default.register_blockdetails({
	name="shell",
	node={
		tiles={"default_sand.png","default_shell.png"},
		drop="default:shell",
		block="default:sand",
	},
	item={},
})

minetest.register_node("default:obsidian", {
	description = "Obsidian",
	tiles={"default_obsidian.png"},
	groups = {cracky=1,level=3,treasure=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:cooledlava", {
	description = "Cooled lava",
	tiles={"default_cooledlava.png"},
	groups = {cracky=2,treasure=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:stone", {
	description = "Stone",
	drop = "default:cobble",
	tiles={"default_stone.png"},
	groups = {stone=1,cracky=3,treasure=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:cobble", {
	description = "Cobble",
	tiles={"default_cobble.png"},
	groups = {stone=1,cracky=3,treasure=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:stone_hot", {
	description = "Hot stone",
	drop = "default:cobble",
	tiles={"default_stone.png"},
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	light_source=2,
	after_destruct=function(pos)
		minetest.set_node(pos,{name="default:lava_source"})
	end
})

minetest.register_node("default:cobble_porous", {
	description = "Porous cobble",
	tiles={"default_cobble.png"},
	groups = {stone=1,cracky=3,falling_node=1,treasure=1},
	sounds = default.node_sound_stone_defaults(),
	damage_per_second = 10,
})

minetest.register_node("default:bedrock", {
	description = "Bedrock",
	tiles={"default_cooledlava.png"},
	groups = {cracky=1,level=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:mossycobble", {
	description = "Mossy cobble",
	tiles={"default_cobble.png^default_stonemoss.png"},
	groups = {stone=1,cracky=3,treasure=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:desert_stone", {
	description = "Desert stone",
	drop = "default:desert_cobble",
	tiles={"default_desertstone.png"},
	groups = {stone=1,cracky=3,treasure=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:desert_cobble", {
	description = "Desert cobble",
	tiles={"default_desertcobble.png"},
	groups = {stone=1,cracky=3,treasure=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:gravel", {
	description = "Gravel",
	tiles={"default_gravel.png"},
	groups = {crumbly=2,falling_node=1,treasure=1},
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

minetest.register_node("default:desert_sand", {
	description = "Desert sand",
	tiles={"default_desert_sand.png"},
	groups = {crumbly=3,sand=1,falling_node=1,treasure=1},
	sounds = default.node_sound_dirt_defaults(),
	drowning = 1
})

minetest.register_node("default:sandstone", {
	description = "Sand stone",
	tiles={"default_sandstone.png"},
	groups = {cracky=3,treasure=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:sand", {
	description = "Sand",
	tiles={"default_sand.png"},
	groups = {crumbly=3,sand=1,falling_node=1,treasure=1},
	sounds = default.node_sound_dirt_defaults(),
	drowning = 1,
	drop ={
		max_items = 1,
		items = {
			{items = {"default:flint"}, rarity = 30},
			{items = {"default:pebble_stone"}, rarity = 30},
			{items = {"default:sand"}}
		}
	},
	after_place_node = function(pos, placer,itemstack)
		minetest.set_node(pos,{name="default:sand"})
	end,
	after_destruct=function(pos)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name,"water") > 0 then
			local items ={
				["default:pebble_stone"]=20,
				["default:gold_flake"]=50,
				["default:micro_gold_flake"]=30,
				["default:amber_lump"]=40,
				["default:iron_lump"]=70,
				["default:copper_lump"]=70,
			}
			for i,r in pairs(items) do
				if math.random(1,r) == 1 then
					minetest.add_item(pos,i)
				end
			end
		end
	end,
})

--||||||||||||||||
-- ======================= Water
--||||||||||||||||

minetest.register_node("default:snowblock_thin", {
	description = "Thin snowblock",
	tiles={"default_snow.png"},
	groups = {snowy=1,crumbly=3,cools_lava=1},
	sounds = default.node_sound_dirt_defaults(),
	walkable=false,
	buildable_to=true,
	drowning = 1,
	drawtype = "glasslike",
	post_effect_color = {a = 255, r = 255, g = 255, b =255},
})

minetest.register_node("default:snowblock", {
	description = "Snowblock",
	tiles={"default_snow.png"},
	groups = {snowy=1,crumbly=3,cools_lava=1,fall_damage_add_percent=-25,disable_jump=1,treasure=1},
	sounds = default.node_sound_dirt_defaults(),
})

minetest.register_node("default:snow", {
	description = "Snow",
	tiles={"default_snow.png"},
	inventory_image="default_snowball.png",
	wield_image="default_snowball.png",
	wield_scale = {x=0.5,y=0.5,z=2},
	groups = {snowy=1,crumbly=3,falling_node=1,cools_lava=1,treasure=1},
	buildable_to=true,
	sunlight_propagates=true,
	paramtype="light",
	sounds = default.node_sound_dirt_defaults(),
	drawtype="nodebox",
	walkable=false,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5},
		}
	},
})

minetest.register_node("default:ice", {
	description = "Ice",
	tiles={"default_ice.png"},
	groups = {cracky=3,slippery=10,treasure=1},
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
	groups = {drinkable=1,water=1, liquid=1, cools_lava=1,not_in_craftguide=1,treasure=1},
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
	groups = {drinkable=1,water=1, liquid=1, cools_lava=1,not_in_creative_inventory=1},
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
	groups = {water=1, liquid=1, cools_lava=1,not_in_craftguide=1},
	drawtype = "liquid",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	sunlight_propagates = true,
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
	groups = {lava=1, liquid=1,igniter=3,not_in_craftguide=1},
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
	liquid_renewable = false,
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
	liquid_renewable = false,
	post_effect_color = {a = 240, r = 255, g = 55, b = 0},
})

--||||||||||||||||
-- ======================= oil
--||||||||||||||||

minetest.register_node("default:oil_source", {
	description = "Oil source",
	tiles={"default_oil.png"},
	groups = {oil=1, liquid=1,disable_jump=1,flammable=3,not_in_craftguide=1},
	drawtype = "liquid",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_renewable = false,
	liquid_alternative_flowing = "default:oil_flowing",
	liquid_alternative_source = "default:oil_source",
	liquid_viscosity = 25,
	post_effect_color = {a = 255, r = 0, g = 0, b = 0},
	on_burn=function(pos)
		default.def(minetest.get_node(pos).name).on_ignite(pos)
	end,
	on_ignite=function(pos)
		minetest.set_node(pos,{name="fire:basic_flame"})
		default.punch_pos(pos,10)
		minetest.after(0,function(pos)
			for _,p in pairs(minetest.find_nodes_in_area(vector.add(pos,1),vector.subtract(pos,1),{"group:oil"})) do
				default.def(minetest.get_node(p).name).on_ignite(p)
			end
		end,pos)
	end
})

minetest.register_node("default:oil_flowing", {
	description = "Oil flowing",
	special_tiles={
		{
			name = "default_oil.png",
			backface_culling = false,
		},
		{
			name = "default_oil.png",
			backface_culling = true,
		}
	},

	liquid_renewable = false,
	groups = {oil=1,liquid=1,not_in_creative_inventory=1,disable_jump=1,flammable=3,},
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
	liquid_alternative_flowing = "default:oil_flowing",
	liquid_alternative_source = "default:oil_source",
	post_effect_color = {a = 255, r = 0, g = 0, b = 0},
	liquid_viscosity = 25,
	on_burn=function(pos)
		default.def(minetest.get_node(pos).name).on_ignite(pos)
	end,
	on_ignite=function(pos)
		minetest.set_node(pos,{name="fire:basic_flame"})
		default.punch_pos(pos,10)
		minetest.after(0,function(pos)
			for _,p in pairs(minetest.find_nodes_in_area(vector.add(pos,1),vector.subtract(pos,1),{"group:oil"})) do
				default.def(minetest.get_node(p).name).on_ignite(p)
			end
		end,pos)
	end
})

minetest.register_node("default:cave_drops", {
	description = "Cave drops",
	drawtype = "airlike",
	groups = {dig_immediate=3,attached_node=1,on_load=1,not_in_creative_inventory=1},
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	floodable = true,
	paramtype = "light",
	walkable = false,
	pointable = false,
	buildable_to = true,
	drop = "",
	on_timer = function (pos, elapsed)
		minetest.add_particle({
			pos=pos,
			velocity={x=0,y=-math.random(7,9),z=0},
			acceleration={x=0,y=-4,z=0},
			expirationtime=3,
			size=3,
			collisiondetection=true,
			collision_removal=true,
			vertical=true,
			texture="weather_drop.png",
		})
		minetest.sound_play("default_drop", {pos=pos, gain = 1})
		minetest.get_node_timer(pos):start(math.random(1,10))
	end,
	on_load = function(pos,node)
		minetest.get_node_timer(pos):start(1)
	end
})

minetest.register_node("default:stone_spike_drop", {
	description = "Stone spike drop",
	tiles = {"default_stone.png"},
	groups = {cracky=3,attached_node=1,on_load=1},
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	paramtype = "light",
	damage_per_second = 20,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.25, 0.1875},
			{-0.125, -0.25, -0.125, 0.125, 0.0625, 0.125},
			{-0.0625, 0.0625, -0.0625, 0.0625, 0.3125, 0.0625},
			{-0.025, 0.3125, -0.025, 0.025, 0.5, 0.025},
		}
	},
	sounds = default.node_sound_stone_defaults(),
	on_timer = function (pos, elapsed)
		for i = 1,50, 1 do
			local p = {x=pos.x,y=pos.y-i,z=pos.z}
			if minetest.get_node(p).name ~= "air" then
				break
			end
			for _, ob in pairs(minetest.get_objects_inside_radius(p, 1)) do
				local en = ob:get_luaentity()
				if en == nil or en and en.name ~= "__builtin:item" and en.name ~= " __builtin:falling_node" then
					minetest.spawn_falling_node(pos)
					return
				end
			end
		end
		minetest.get_node_timer(pos):start(math.random(1,10))
	end,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_load = function(pos,node)
		minetest.get_node_timer(pos):start(1)
	end
})

minetest.register_node("default:stone_spike", {
	description = "Stone spike",
	tiles = {"default_stone.png"},
	groups = {cracky=3,stone=1},
	damage_per_second = 1,
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {

			{-0.1875, -0.5, -0.1875, 0.1875, -0.25, 0.1875},
			{-0.125, -0.25, -0.125, 0.125, 0.0625, 0.125},
			{-0.0625, 0.0625, -0.0625, 0.0625, 0.3125, 0.0625},
			{-0.025, 0.3125, -0.025, 0.025, 0.5, 0.025},
		}
	},
	sounds = default.node_sound_stone_defaults(),
})


minetest.register_node("default:stone_with_red_moss", {
	description = "Stone with red moss",
	tiles={"default_permafrost_redgrass.png","default_stone.png","default_stone.png^default_permafrost_redgrass_side.png"},
	groups = {stone=1,cracky=3},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("default:stone_with_moss", {
	description = "Dirt with moss",
	tiles={"default_permafrost_grass.png","default_stone.png","default_stone.png^default_permafrost_grass_side.png"},
	groups = {stone=1,cracky=3},
	sounds = default.node_sound_stone_defaults(),
})