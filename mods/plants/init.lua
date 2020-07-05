dofile(minetest.get_modpath("plants") .. "/water.lua")

--||||||||||||||||
-- ======================= trees
--||||||||||||||||
-- ===================== Apple
default.register_tree({
	name="apple",
	chair = true,
	door = true,
	fence = true,
	mapgen={biomes={"deciduous"}},
	fruit={
		hp=1,
		gaps=4,
		wet=0,
		description = "Apple",
		tiles={"plants_apple.png"},
		inventory_image="plants_apple.png",
		dye_colors = {palette=4}
	},
	tree={tiles={"plants_apple_tree_top.png","plants_apple_tree_top.png","plants_apple_tree.png"}},
	sapling={tiles={"plants_apple_treesapling.png"}},
	wood={tiles={"plants_apple_wood.png"}},
	leaves={tiles={"plants_apple_leaves.png"}},
	schematic=minetest.get_modpath("plants").."/schematics/plants_apple_tree.mts",
	sapling_place_schematic=function(pos)
		minetest.place_schematic({x=pos.x-3,y=pos.y,z=pos.z-3}, minetest.get_modpath("plants").."/schematics/plants_apple_tree.mts", "random", nil, false)
	end,
})
-- ===================== Pear
default.register_tree({
	name="pear",
	chair = true,
	door = true,
	fence = true,
	mapgen={biomes={"deciduous"}},
	fruit={
		hp=1,
		gaps=4,
		wet=0.5,
		description = "Pear",
		tiles={"plants_pear.png"},
		inventory_image="plants_pear.png",
		dye_colors = {palette=94}
	},
	tree={tiles={"plants_pear_tree_top.png","plants_pear_tree_top.png","plants_pear_tree.png"}},
	sapling={tiles={"plants_pear_tree_sapling.png"}},
	wood={tiles={"plants_pear_wood.png"}},
	leaves={tiles={"plants_pear_leaves.png"}},
	schematic=minetest.get_modpath("plants").."/schematics/plants_pear_tree.mts",
	sapling_place_schematic=function(pos)
		minetest.place_schematic({x=pos.x-3,y=pos.y,z=pos.z-3}, minetest.get_modpath("plants").."/schematics/plants_pear_tree.mts", "random", nil, false)
	end
})
-- ===================== Pine
default.register_tree({
	name="pine",
	chair = true,
	door = true,
	fence = true,
	tree={tiles={"plants_pine_tree_top.png","plants_pine_tree_top.png","plants_pine_tree.png"}},
	sapling={tiles={"plants_pine_treesapling.png"}},
	wood={tiles={"plants_pine_wood.png"}},
	leaves={tiles={"plants_pine_needels.png"}},
	schematics={
		minetest.get_modpath("plants").."/schematics/plants_pine_tree1.mts",
		minetest.get_modpath("plants").."/schematics/plants_pine_tree2.mts",
		minetest.get_modpath("plants").."/schematics/plants_pine_tree3.mts",
		minetest.get_modpath("plants").."/schematics/plants_pine_tree4.mts"
	},
	sapling_place_schematic=function(pos)
		local r = math.random(1,3)
		local rad = {[1]=7,[2]=7,[3]=6,[4]=2}
		rad = rad[r]
		minetest.place_schematic({x=pos.x-rad,y=pos.y,z=pos.z-rad}, minetest.get_modpath("plants").."/schematics/plants_pine_tree" .. r .. ".mts", "random", nil, false)
	end,
	mapgen={
		biomes={"coniferous","coniferous_foggy"},
		place_on={"default:dirt_with_coniferous_grass"},
		noise_params={
			offset=0.001,
			scale=0.0004,
		}
	},
	fruit={
		hp=1,
		gaps=0,
		wet=-0.1,
		description = "Cone",
		tiles={"plants_cone.png"},
		inventory_image="plants_cone.png",
		visual_scale=0.5,
	},
})
-- ===================== Fir
default.register_tree({
	name="fir",
	chair = true,
	door = true,
	fence = true,
	tree={tiles={"plants_fir_tree_top.png","plants_fir_tree_top.png","plants_fir_tree.png"}},
	sapling={tiles={"plants_fir_treesapling.png"}},
	wood={tiles={"plants_fir_wood.png"}},
	leaves={tiles={"plants_fir_needels.png"}},
	sapling_place_schematic=function(pos)
		local r = math.random(1,3)
		local rad = {[1]=5,[2]=6,[3]=6,[4]=3}
		rad = rad[r]
		minetest.place_schematic({x=pos.x-rad,y=pos.y,z=pos.z-rad}, minetest.get_modpath("plants").."/schematics/plants_fir_tree" .. r .. ".mts", "random", nil, false)
	end,
	schematics={
		minetest.get_modpath("plants").."/schematics/plants_fir_tree1.mts",
		minetest.get_modpath("plants").."/schematics/plants_fir_tree2.mts",
		minetest.get_modpath("plants").."/schematics/plants_fir_tree3.mts",
		minetest.get_modpath("plants").."/schematics/plants_fir_tree4.mts"
	},
	mapgen={
		biomes={"coniferous","coniferous_foggy"},
		place_on={"default:dirt_with_coniferous_grass"},
		noise_params={
			offset=0.001,
			scale=0.0004,
		}
	}
})
-- ===================== Jungle
default.register_tree({
	name="jungle",
	chair = true,
	door = true,
	fence = true,
	tree={tiles={"plants_jungle_tree_top.png","plants_jungle_tree_top.png","plants_jungle_tree.png"}},
	sapling={tiles={"plants_jungle_treesapling.png"}},
	wood={tiles={"plants_jungle_wood.png"}},
	leaves={tiles={"plants_jungle_leavs.png"},groups={leaves=1,snappy=3,leafdecay=14,flammable=2}},
	sapling_place_schematic=function(pos)
		local r = math.random(1,3)
		local rad = {[1]=5,[2]=4,[3]=12,[4]=4}
		rad = rad[r]
		minetest.place_schematic({x=pos.x-rad,y=pos.y,z=pos.z-rad}, minetest.get_modpath("plants").."/schematics/plants_jungle_tree" .. r .. ".mts", "random", nil, false)
	end,
	schematics={
		minetest.get_modpath("plants").."/schematics/plants_jungle_tree1.mts",
		minetest.get_modpath("plants").."/schematics/plants_jungle_tree2.mts",
		minetest.get_modpath("plants").."/schematics/plants_jungle_tree3.mts",
		minetest.get_modpath("plants").."/schematics/plants_jungle_tree4.mts",
	},
	mapgen={
		biomes={"jungle","swamp",},
		place_on={"default:dirt_with_jungle_grass"},
		noise_params={
			offset=0.001,
			scale=0.0004,
		}
	}
})

for i=1,4 do
minetest.register_decoration({
	deco_type = "schematic",
	sidelen = 16,
	noise_params = {
			offset=0.0001,
			scale=0.0004,
			spread = {x = 250, y = 250, z = 250},
			seed = 1+i,
			octaves = 3,
			persist = 0.66,
	},
	biomes={"cold_coniferous","coniferous_foggy","cold_grassland"},
	place_on={"default:dirt_with_snow"},
	y_min = 1,
	y_max = 31000,
	schematic = minetest.get_modpath("plants").."/schematics/plants_snowtree" .. i ..".mts",
	flags = "place_center_x, place_center_z",
})
end
-- ===================== Palm
default.register_tree({
	name="palm",
	chair = true,
	door = true,
	fence = true,
	tree={tiles={"plants_palm_tree_top.png","plants_palm_tree_top.png","plants_palm_tree.png"}},
	sapling={tiles={"plants_palm_treesapling.png"}},
	wood={tiles={"plants_palm_wood.png"}},
	leaves={tiles={"plants_jungle_leavs.png"},groups={leaves=1,snappy=3,leafdecay=14,flammable=2}},
	sapling_place_schematic=function(pos)
		local r = math.random(1,3)
		local rad = {[1]=12,[2]=4,[3]=18,[4]=19}
		rad = rad[r]
		minetest.place_schematic({x=pos.x-rad,y=pos.y,z=pos.z-rad}, minetest.get_modpath("plants").."/schematics/plants_palm" .. r .. ".mts", "random", nil, false)
	end,
	schematics={
		minetest.get_modpath("plants").."/schematics/plants_palm1.mts",
		minetest.get_modpath("plants").."/schematics/plants_palm2.mts",
		minetest.get_modpath("plants").."/schematics/plants_palm3.mts",
		minetest.get_modpath("plants").."/schematics/plants_palm4.mts",
	},
	mapgen={
		biomes={"tropic",},
		place_on={"default:dirt_with_grass","default:sand"},
		noise_params={
			offset=0.0003,
			scale=0.00012,
		}
	}
})

minetest.register_node("plants:coconut", {
	description = "Coconut",
	drawtype = "plantlike",
	tiles={"plants_coconut.png"},
	groups = {choppy = 3, dig_immediate = 3,flammable=1,store=2},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
})

default.register_eatable("node","plants:coconut_broken",1,4,{
	description = "Broken coconut",
	drawtype = "plantlike",
	tiles={"plants_coconut2.png"},	
	drawtype="plantlike",
	visual_scale=0.5,
	inventory_image = "plants_coconut2.png",
	groups = {choppy = 3, dig_immediate = 3,flammable=1},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
	wet=1,
})

minetest.register_craft({
	output="plants:coconut_broken",
	recipe={{"plants:coconut"}}
})
-- ===================== Acacia
default.register_tree({
	name="acacia",
	chair = true,
	door = true,
	fence = true,
	tree={tiles={"plants_acacia_tree_top.png","plants_acacia_tree_top.png","plants_acacia_tree.png"}},
	sapling={tiles={"plants_acacia_treesapling.png"}},
	wood={tiles={"plants_acacia_wood.png"}},
	leaves={
		tiles={"plants_acacia_leaves.png"},groups={leaves=1,snappy=3,leafdecay=10,flammable=2}
	},
	sapling_place_schematic=function(pos)
		local r = math.random(1,3)
		r=4
		local rad = {[1]=8,[2]=11,[3]=6,[4]=3}
		rad = rad[r]
		minetest.place_schematic({x=pos.x-rad,y=pos.y,z=pos.z-rad}, minetest.get_modpath("plants").."/schematics/plants_acacia_tree" .. r .. ".mts", "random", nil, false)
	end,
	schematics={
		minetest.get_modpath("plants").."/schematics/plants_acacia_tree1.mts",
		minetest.get_modpath("plants").."/schematics/plants_acacia_tree2.mts",
		minetest.get_modpath("plants").."/schematics/plants_acacia_tree3.mts",
		minetest.get_modpath("plants").."/schematics/plants_acacia_tree4.mts",
	},
	mapgen={
		biomes={"savanna",},
		place_on={"default:dirt_with_dry_grass"},
		noise_params={
			offset=0.00003,
			scale=0.000012,
		}
	}
})
-- ===================== Maple
default.register_tree({
	name="maple",
	chair = true,
	door = true,
	fence = true,
	tree={tiles={"plants_maple_tree_top.png","plants_maple_tree_top.png","plants_maple_tree.png"}},
	sapling={tiles={"plants_maple_treesapling.png"}},
	wood={tiles={"plants_maple_wood.png"}},
	leaves={
		walkable=false,
		tiles={"plants_maple_leavs.png"},groups={leaves=1,snappy=3,leafdecay=14,flammable=2},
		drop={max_items = 1,items = {{items = {"plants:maple_sapling"}, rarity = 25},{items = {"default:stick"}, rarity = 10},{items = {"plants:maple_leaf"}, rarity = 5},{items = {"plants:maple_leaves"}}}},
	},
	mapgen={
		biomes={"deciduous"},
		noise_params={
			offset=0.001,
			scale=0.0004,
		}
	},
	sapling_place_schematic=function(pos)
		local r = math.random(1,2)
		local rad = {[1]=2,[2]=9}
		rad = rad[r]
		minetest.place_schematic({x=pos.x-rad,y=pos.y,z=pos.z-rad}, minetest.get_modpath("plants").."/schematics/plants_maple" .. r .. ".mts", "random", nil, false)
	end,
	schematics={
		minetest.get_modpath("plants").."/schematics/plants_maple1.mts",
		minetest.get_modpath("plants").."/schematics/plants_maple2.mts",
	},
})

minetest.register_craftitem("plants:maple_leaf", {
	description = "Maple leaf",
	inventory_image = "plants_maple_leaf.png",
	groups = {flammable = 1,leaves=1},
})
-- ===================== Hazel
default.register_tree({
	name="hazel",
	chair = true,
	door = true,
	fence = true,
	tree={tiles={"plants_hazel_tree_top.png","plants_hazel_tree_top.png","plants_hazel_tree.png"}},
	sapling={
		visual_scale=0.2,
		tiles={"plants_hazel_nut.png^[colorize:#00ff0022"}
		},
	wood={tiles={"plants_hazel_wood.png"}},
	mapgen={
		biomes={"deciduous"},
		noise_params={
			offset=0.001,
			scale=0.0004,
		}
	},
	leaves={
		tiles={"plants_hazel_leaves.png"},groups={leaves=1,snappy=3,leafdecay=14,flammable=2},
	},
	sapling_place_schematic=function(pos)
		local r = math.random(1,3)
		local rad = {[1]=4,[2]=6,[3]=4}
		rad = rad[r]

		minetest.place_schematic({x=pos.x-rad,y=pos.y,z=pos.z-rad}, minetest.get_modpath("plants").."/schematics/plants_hazel" .. r .. ".mts", "random", nil, false)
	end,
	schematics={
		minetest.get_modpath("plants").."/schematics/plants_hazel1.mts",
		minetest.get_modpath("plants").."/schematics/plants_hazel2.mts",
		minetest.get_modpath("plants").."/schematics/plants_hazel3.mts",
	},
	fruit={
		hp=1,
		gaps=1,
		wet=0,
		description = "Hazel nut",
		tiles={"plants_hazel_nut.png"},
		inventory_image="plants_hazel_nut.png",
		dye_colors = {palette=4},
		visual_scale=0.2,
	},
})


--||||||||||||||||
-- ======================= plants
--||||||||||||||||

for i,v in pairs({132,25,32,21,118,14,49,7,105,131,124,111,63,77,98,2}) do
default.register_plant({
	name="daisybush" .. i,
	description = "Daisy bush",
	groups = {store=1},
	tiles={default.dye_texturing(v,{opacity=255}).."^plants_daisybushflower.png^[makealpha:0,255,0"},
	decoration={noise_params={
		offset=-0.001,
		scale=0.003,
		seed=80*v,
	}},
	dye_colors = {palette=v},
})
	default.register_pebble({
		name = "glowing" .. i,
		light_source = 7,
		tiles={default.dye_texturing(v,{opacity=200})},
		groups = {store=3},
		dye_colors = {palette=v},
		alpha = 150,
		decoration = {
			place_on = {"default:stone","default:sand"},
			y_max = -10,
			y_min = -30000,
			seed = 80*v,
			offset = 0.0011,
			scale = 0.0012,
			flags = "all_floors",
		},
		
	})
end

default.register_eatable("craftitem","plants:lonicera_tatarica_berries",-2,0,{inventory_image="plats_berries.png^[colorize:#ff5b19ff",dye_colors = {palette=136}})
default.register_plant({
	name="lonicera_tatarica",
	tiles={"plants_lonicera_tatarica.png"},
	groups = {store=1},
	decoration={
		biomes={"tropic","jungle"},
		noise_params={
			offset=-0.0015,
			scale=0.005,
			seed=3454365,
		}
	},
	drop={max_items = 1,items = {
		{items = {"plants:lonicera_tatarica_berries"}, rarity = 3},
		{items = {"plants:lonicera_tatarica"}}
	}},
	dye_colors = {palette=136},
})

default.register_plant({
	name="verbena",
	tiles={"plants_verbena.png"},
	decoration={
		biomes={"deciduous"},
		noise_params={
			offset=-0.0015,
			scale=0.003,
			seed=545,
		}
	},
	dye_colors = {palette=28},
})

default.register_plant({
	name="lantana",
	tiles={"plants_lantana.png"},
	decoration={
		biomes={"deciduous","deciduous_grassland","coniferous"},
		noise_params={
			offset=-0.0015,
			scale=0.003,
			seed=8745,
		}
	},
	dye_colors = {palette=98},
})

default.register_eatable("craftitem","plants:dolls_eyes_berries",2,6,{
	inventory_image="plats_dolls_eyes_berries.png",
	on_eat=function(itemstack, user, pointed_thing)
		local r = math.random(30,60)
		local s = math.random(1,9999)
		local name = user:get_player_name()
		default.set_on_player_death(name,"dolls_eyes" .. s,true)
		for i=0,math.random(3,10) do
			minetest.after(r+i*0.1,function(name,user,s)
				if default.get_on_player_death(name,"dolls_eyes" .. s) then
					default.punch(user,user,2)
				end
			end,name,user,s)
		end
	end,
	dye_colors = {palette=15}
})

default.register_plant({
	name="dolls_eyes",
	tiles={"plants_dolls_eyes.png"},
	groups = {store=2},
	decoration={
		biomes={"tropic","jungle"},
		noise_params={
			offset=-0.0015,
			scale=0.005,
			seed=3454365,
		}
	},
	drop={max_items = 1,items = {
		{items = {"plants:dolls_eyes_berries 3"}, rarity = 2},
		{items = {"plants:dolls_eyes"}}
	}},
	dye_colors = {palette=15},
})

default.register_plant({
	name="cow_parsnip",
	tiles={"plants_cow_parsnip.png"},
	decoration={
		biomes={"deciduous","jungle"},
		noise_params={
			offset=-0.0015,
			scale=0.015,
			seed=3365,
		}
	},
	damage_per_second=4,
	groups={snappy=1},
	on_punch=function(pos,node,player,pointed_thing)
		if player:get_wielded_item():get_name() == "" then
			default.punch(player,player,4)
		end
	end,
	groups={spreading_plant=20},
	visual_scale=2.5,
	selection_box ={type="fixed",fixed={-0.25,-0.5,-0.25,0.25,2,0.25}},
})
default.register_plant({
	name="cow_parsnip_big",
	tiles={"plants_cow_parsnip.png"},
	groups = {store=2},
	decoration={
		biomes={"deciduous","jungle"},
		noise_params={
			offset=-0.0015,
			scale=0.015,
			seed=3365,
		}
	},
	damage_per_second=4,
	groups={snappy=3},
	on_punch=function(pos,node,player,pointed_thing)
		if player:get_wielded_item():get_name() == "" then
			default.punch(player,player,4)
		end
	end,
	groups={spreading_plant=16},
	visual_scale=3.5,
	selection_box ={type="fixed",fixed={-0.25,-0.5,-0.25,0.25,3,0.25}},
})


default.register_plant({
	name="anthriscus_sylvestris_big",
	tiles={"plants_cow_parsnip.png"},
	decoration={
		biomes={"deciduous","jungle"},
		noise_params={
			offset=-0.0015,
			scale=0.015,
			seed=3366,
		}
	},
	groups={spreading_plant=15},
	visual_scale=1.3,
	selection_box ={type="fixed",fixed={-0.25,-0.5,-0.25,0.25,0.8,0.25}},
})

default.register_plant({
	name="anthriscus_sylvestris",
	tiles={"plants_cow_parsnip.png"},
	decoration={
		biomes={"deciduous","jungle"},
		noise_params={
			offset=-0.0015,
			scale=0.015,
			seed=3366,
		}
	},
	groups={spreading_plant=10},
	visual_scale=1.1,
})

default.register_plant({
	name="jungle_grass",
	drawtype="firelike",
	tiles={"plants_junglegrass.png"},
	visual_scale=2,
	selection_box ={type="fixed",fixed={-0.4,-0.5,-0.4,0.4,-0.4,0.4}},
	liquidtype = "source",
	liquid_alternative_flowing="plants:jungle_grass",
	liquid_alternative_source="plants:jungle_grass",
	liquid_renewable = false,
	liquid_range = 0,
	liquid_viscosity = 15,
	decoration={
		biomes={"swamp","jungle"},
		place_on={"default:dirt_with_jungle_grass"},
		noise_params={
			offset=0.5,
			scale=0.03,
			spread={x=3,y=3,z=3},
			seed=0,
		},
	},
	dye_colors = {palette=93},
})

default.register_plant({
	name="dry_plant",
	tiles={"plants_dry_plant.png"},
	groups={dig_immediate=3},
})

for i=1,5 do
default.register_plant({
	name="grass" .. i,
	description = "Grass",
	tiles={"plants_grass"..i..".png"},
	drop="plants:grass3",
	selection_box ={type="fixed",fixed={-0.4,-0.5,-0.4,0.4,-0.4,0.4}},
	decoration={
		biomes={"deciduous","deciduous_grassland","tropic","grass_land","coniferous","coniferous_foggy"},
		place_on={"default:dirt_with_grass","default:dirt_with_coniferous_grass"},
		noise_params={
			offset=0.2,
			scale=0.01,
			spread={x=3,y=3,z=3},
			seed=0,
		},
	},
	groups={grass=1,spreading_plant=7,dig_immediate=3,not_in_creative_inventory = i ~= 3 and 3 or nil},
	after_place_node=function(pos, placer)
		minetest.set_node(pos,{name="plants:grass"..math.random(1,5)})
	end,
	on_plant_spreading=function(pos)
		minetest.set_node(pos,{name="plants:grass"..math.random(1,5)})
		return true
	end,
	dye_colors = {palette=87},
})
default.register_plant({
	name="dry_grass" .. i,
	description = "Dry grass",
	tiles={"plants_dry_grass"..i..".png"},
	drop="plants:dry_grass3",
	selection_box ={type="fixed",fixed={-0.4,-0.5,-0.4,0.4,-0.4,0.4}},
	decoration={
		biomes={"savanna"},
		place_on={"default:dirt_with_dry_grass"},
		noise_params={
			offset=0.2,
			scale=0.01,
			spread={x=3,y=3,z=3},
			seed=0,
		},
	},
	groups={spreading_plant=7,dig_immediate=3,not_in_creative_inventory = i ~= 3 and 3 or nil},
	after_place_node=function(pos, placer)
		minetest.set_node(pos,{name="plants:dry_grass"..math.random(1,5)})
	end,
	on_plant_spreading=function(pos)
		minetest.set_node(pos,{name="plants:dry_grass"..math.random(1,5)})
		return true
	end,
	dye_colors = {palette=132},
})
end

minetest.register_lbm({
	name="plants:spreading_plant",
	nodenames={"group:spreading_plant"},
	run_at_every_load = true,
	action=function(pos,node)
		if math.random(0,minetest.get_item_group(node.name,"spreading_plant")) == 1 then
			local p = minetest.find_nodes_in_area_under_air(vector.add(pos, 1),vector.subtract(pos, 1),{"group:spreading_dirt_type"})
			if #p > 0 then
				local p2 = p[1]
				local def = default.def(minetest.get_node(pos).name)
				local up = {x=p2.x,y=p2.y+1,z=p2.z}
				if def.on_plant_spreading and def.on_plant_spreading(up) then
					return
				else
					minetest.set_node(up,node)
				end
				
			end
		end
	end
})

default.register_plant({
	name="wild_cotton",
	tiles={"plants_wildcotton.png"},
	groups = {store=2},
	decoration={
		biomes={"deciduous","tropic","jungle","grass_land","semi_desert"},
		noise_params={
		offset=-0.0015,
		scale=0.005,
		seed=3454365,
	}},
	on_construct=function(pos)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"dirt") > 0 then
			local meta = minetest.get_meta(pos)
			meta:set_int("date",default.date("get"))
			meta:set_int("spreadtime",math.random(5,30))
			minetest.get_node_timer(pos):start(10)
		end
	end,
	on_timer=function(pos, elapsed)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"dirt") > 0 and (minetest.get_node_light(pos,0.5) or 0) >= 13 then
			local meta = minetest.get_meta(pos)
			if default.date("m",meta:get_int("date")) >= meta:get_int("spreadtime") then
				local np = minetest.find_nodes_in_area_under_air(vector.add(pos, 1),vector.subtract(pos, 1),{"group:dirt"})
				if #np > 0 then
					local p = np[1]
					minetest.set_node({x=p.x,y=p.y+1,z=p.z},{name="plants:wild_cotton"})
				end
				meta:set_int("date",default.date("get"))
				meta:set_int("spreadtime",math.random(5,30))

			end
			return true
		end
	end
})

minetest.register_craft({output="plants:cotton",recipe={{"plants:wild_cotton"}}})

minetest.register_craftitem("plants:cotton", {
	description = "Cotton",
	inventory_image = "plants_cotton.png",
	groups = {flammable = 1},
})

default.register_plant({
	name="cactus",
	tiles={"plants_cactus.png"},
	damage_per_second=5,
	walkable = true,
	groups={choppy=1,snappy=0,attached_node=0,store=4},
	sounds = default.node_sound_wood_defaults(),
	buildable_to=false,
	drawtype = "nodebox",
	paramtype = "light",
	waving=0,
	floodable=false,
	drawtype = "nodebox",
	paramtype = "light",
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.19, -0.19, -0.19, 0.19, 0.19, 0.19},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		}
	},
	decoration={
		biomes={"desert","semi_desert"},
		place_on={"default:desert_sand"},
		noise_params={
			offset=-0.00015,
			scale=0.0005,
			seed=3454365,
		},
		height = 4,
		height_max = 8,
	},
})

for i=1,10 do
default.register_plant({
	name="unknown"..i,
	tiles={"plants_unknown"..i..".png"},
	decoration={
		biomes={"deciduous","tropic","jungle","grass_land","semi_desert"},
		noise_params={
			offset=-0.15,
			scale=0.5,
			seed=345*i,
		}
	},
})
end

for i=1,3 do
default.register_plant({
	name="wheat"..i,
	tiles={"plants_wheat"..i..".png"},
	drop= i == 3 and {max_items = 1,items = {{items = {"plants:wheat_seed 3"}, rarity = 3},{items = {"plants:wheat"..i}}}} or "plants:wheat"..i,
	on_timer = i < 3 and function(pos, elapsed)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"wet_soil") == 0 then
			minetest.set_node(pos,{name="plants:dry_plant"})
		elseif default.date("m",minetest.get_meta(pos):get_int("date")) >= 30 and (minetest.get_node_light(pos,0.5) or 0) >= 13 then
			minetest.set_node(pos,{name="plants:wheat"..i+1})
			if i < 3 then
				minetest.get_meta(pos):set_int("date",default.date("get"))
				minetest.get_node_timer(pos):start(1)
			end
		else
			return true
		end
	end or nil,
	decoration={
		biomes={"deciduous","tropic","jungle","grass_land","semi_desert","savanna"},
		noise_params={
			offset=-0.15,
			scale=0.5,
			seed=37*i,
		}
	},
})
end

minetest.register_node("plants:wheat_seed", {
	description = "Wheat seed",
	drawtype = "raillike",
	tiles={"plants_wheat_seed.png"},
	groups = {dig_immediate = 3,flammable=1},
	sunlight_propagates = true,
	paramtype = "light",
	walkable=false,
	inventory_image="plants_wheat_seed.png",
	wield_image="plants_wheat_seed.png",
	selection_box ={type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.45,0.5}},
	on_construct = function(pos)
		minetest.get_meta(pos):set_int("date",default.date("get"))
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function (pos, elapsed)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name,"wet_soil") == 0 then
			minetest.remove_node(pos)
			minetest.add_item(pos,"plants:wheat_seed")
		elseif default.date("m",minetest.get_meta(pos):get_int("date")) >= 1 and (minetest.get_node_light(pos,0.5) or 0) >= 13 then
			minetest.set_node(pos,{name="plants:wheat1"})
			minetest.get_meta(pos):set_int("date",default.date("get"))
			minetest.get_node_timer(pos):start(1)
		else
			return true
		end
	end
})

minetest.register_craftitem("plants:flour", {
	description = "Flour",
	inventory_image = "plants_flour.png",
})

minetest.register_craft({
	output="plants:flour",
	recipe={
		{"plants:wheat_seed","plants:wheat_seed","plants:wheat_seed"},
	},
})

minetest.register_craft({
	output="plants:wheat_seed 3",
	recipe={
		{"plants:wheat3"},
	},
})

default.register_plant({
	name="cabbage",
	tiles={"plants_cabbage.png"},
	drawtype = "mesh",
	inventory_image="plants_cabbage_broken.png",	
	mesh = "plants_cabbage.obj",
	waving =  0,
	groups = {dig_immediate = 3,flammable=1,spreading_plant=20,store=4},
	decoration={
		biomes={"tropic","jungle"},
		noise_params={
			offset=-0.0015,
			scale=0.005,
			seed=3454365,
		}
	}
})
default.register_eatable("node","plants:cabbage_broken",1,4,{
	description = "Broke cabbage",
	inventory_image="plants_cabbage_broken.png",	
	name="plants_cabbage",
	tiles={"plants_cabbage.png"},
	drawtype = "mesh",
	mesh = "plants_cabbage.obj",
	groups = {dig_immediate = 3,flammable=1,spreading_plant=20},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	sounds = default.node_sound_leaves_defaults(),
	wet=1,
	selection_box  = {type="fixed",fixed={-0.25,-0.5,-0.25,0.25,0.25,0.25}},

})
minetest.register_craft({
	output="plants:cabbage_broken",
	recipe={
		{"plants:cabbage"},
	},
})