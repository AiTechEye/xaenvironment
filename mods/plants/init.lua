--||||||||||||||||
-- ======================= trees
--||||||||||||||||

default.register_tree({
	name="apple",
	mapgen={biomes={"deciduous"}},
	fruit={
		hp=1,
		gaps=4,
		description = "Apple",
		tiles={"plants_apple.png"},
		inventory_image="plants_apple.png",
	},
	tree={tiles={"plants_apple_tree_top.png","plants_apple_tree_top.png","plants_apple_tree.png"}},
	sapling={tiles={"plants_apple_treesapling.png"}},
	wood={tiles={"plants_apple_wood.png"}},
	leaves={tiles={"plants_apple_leaves.png"}},
	schematic=minetest.get_modpath("plants").."/schematics/plants_apple_tree.mts",
	sapling_place_schematic=function(pos)
		minetest.place_schematic({x=pos.x-3,y=pos.y,z=pos.z-3}, minetest.get_modpath("plants").."/schematics/plants_apple_tree.mts", "random", nil, false)
	end
})


default.register_door({
	name="apple_wood_door",
	description = "Apple wood door",
	texture="plants_apple_wood.png",
	burnable = true,
	craft={
		{"plants:apple_wood","plants:apple_wood",""},
		{"plants:apple_wood","plants:apple_wood",""},
		{"plants:apple_wood","plants:apple_wood",""},
	}
})

default.register_chair({
	name = "apple_wood",
	description = "Apple wood chair",
	burnable = true,
	texture = "plants_apple_wood.png",
	craft={{"group:stick","",""},{"plants:apple_wood","",""},{"group:stick","",""}}
})

default.register_fence({
	name = "apple_wood",
	texture = "plants_apple_wood.png",
	craft={
		{"group:stick","group:stick","group:stick"},
		{"group:stick","plants:apple_wood","group:stick"},
	}
})

default.register_tree({
	name="pear",
	mapgen={biomes={"deciduous","tropic"}},
	fruit={
		hp=1,
		gaps=4,
		description = "Pear",
		tiles={"plants_pear.png"},
		inventory_image="plants_pear.png",
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

default.register_door({
	name="pear_wood_door",
	description = "Pear wood door",
	texture="plants_pear_wood.png",
	burnable = true,
	craft={
		{"plants:pear_wood","plants:pear_wood",""},
		{"plants:pear_wood","plants:pear_wood",""},
		{"plants:pear_wood","plants:pear_wood",""}
	}
})

default.register_fence({
	name = "pear_wood",
	texture = "plants_pear_wood.png",
	craft={
		{"group:stick","group:stick","group:stick"},
		{"group:stick","plants:pear_wood","group:stick"},
	}
})

default.register_chair({
	name = "pear_wood",
	description = "Pear wood chair",
	burnable = true,
	texture = "plants_pear_wood.png",
	craft={{"group:stick","",""},{"plants:pear_wood","",""},{"group:stick","",""}}
})

default.register_tree({
	name="pine",
	mapgen={biomes={"all"}}, --"deciduous"
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
	}
})

default.register_tree({
	name="fir",
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

default.register_tree({
	name="jungle",
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

minetest.register_decoration({
	deco_type = "schematic",
	sidelen = 16,
	noise_params = {
			offset=0.1,
			scale=0.04,
			spread = {x = 250, y = 250, z = 250},
			seed = 3,
			octaves = 3,
			persist = 0.66,
	},
	biomes={"jungle","swamp",},
	place_on={"default:dirt_with_jungle_grass"},
	y_min = 1,
	y_max = 31000,
	schematic = minetest.get_modpath("plants").."/schematics/plants_jungletree_massive.mts",
	flags = "place_center_x, place_center_z",
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

--||||||||||||||||
-- ======================= plants
--||||||||||||||||

for i,c in pairs({"d8e41d","b21db5","601db5","bb91f0","e4d9f3","fd0084","6f86ff","ff3030","ff4d00","ffb047","ffb0c5","a6421f"}) do
	default.register_plant({
		name="daisybush" .. i,
		description = "Daisy bush",
		tiles={"plants_pear_tree_top.png^[colorize:#"..c.."ff^plants_daisybushflower.png^[makealpha:0,255,0"},
		decoration={noise_params={
			offset=-0.001,
			scale=0.003,
			seed=80*i,
		}},
	})
end

default.register_eatable("craftitem","plants:lonicera_tatarica_berries",-2,0,{inventory_image="plats_berries.png^[colorize:#ff5b19ff"})
default.register_plant({
	name="lonicera_tatarica",
	biomes={"deciduous"},
	tiles={"plants_lonicera_tatarica.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.003,
	}},
	drop={max_items = 1,items = {
		{items = {"plants:lonicera_tatarica_berries"}, rarity = 3},
		{items = {"plants:lonicera_tatarica"}}
	}}
})

default.register_plant({
	name="verbena",
	biomes={"deciduous"},
	tiles={"plants_verbena.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.003,
		seed=545,
	}}
})

default.register_plant({
	name="lantana",
	biomes={"deciduous","deciduous_grassland","coniferous"},
	tiles={"plants_lantana.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.003,
		seed=8745,
	}}
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
	end
})

default.register_plant({
	name="dolls_eyes",
	biomes={"tropic","jungle"},
	tiles={"plants_dolls_eyes.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.005,
		seed=3454365,
	}},
	drop={max_items = 1,items = {
		{items = {"plants:dolls_eyes_berries 3"}, rarity = 2},
		{items = {"plants:dolls_eyes"}}
	}}
})

default.register_plant({
	name="cow_parsnip",
	biomes={"deciduous"},
	tiles={"plants_cow_parsnip.png"},
	decoration={noise_params={
		offset=0.0015,
		scale=0.015,
		seed=3365,
	}},
	damage_per_second=4,
	groups={snappy=1},
	on_punch=function(pos,node,player,pointed_thing)
		if player:get_wielded_item():get_name() == "" then
			default.punch(player,player,4)
		end
	end,
	groups={spreading_plant=20},
	visual_scale=2.5,
	selection_box ={type="fixed",fixed={-0.25,-0.5,-0.25,0.25,2,0.25}}
})
default.register_plant({
	name="cow_parsnip_big",
	biomes={"deciduous"},
	tiles={"plants_cow_parsnip.png"},
	decoration={noise_params={
		offset=0.0015,
		scale=0.015,
		seed=3365,
	}},
	damage_per_second=4,
	groups={snappy=3},
	on_punch=function(pos,node,player,pointed_thing)
		if player:get_wielded_item():get_name() == "" then
			default.punch(player,player,4)
		end
	end,
	groups={spreading_plant=16},
	visual_scale=3.5,
	selection_box ={type="fixed",fixed={-0.25,-0.5,-0.25,0.25,3,0.25}}
})


default.register_plant({
	name="anthriscus_sylvestris_big",
	biomes={"deciduous","tropic","jungle"},
	tiles={"plants_cow_parsnip.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.015,
		seed=3365,
	}},
	groups={spreading_plant=15},
	visual_scale=1.3,
	selection_box ={type="fixed",fixed={-0.25,-0.5,-0.25,0.25,0.8,0.25}}
})

default.register_plant({
	name="anthriscus_sylvestris",
	biomes={"deciduous","tropic","jungle"},
	tiles={"plants_cow_parsnip.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.015,
		seed=3365,
	}},
	groups={spreading_plant=10},
	visual_scale=1.1,
})

for i=1,5 do
default.register_plant({
	name="grass" .. i,
	description = "Grass",
	tiles={"plants_grass"..i..".png"},
	drop="plants:grass3",
	selection_box ={type="fixed",fixed={-0.4,-0.5,-0.4,0.4,-0.4,0.4}},
	decoration={
		place_on={"default:dirt_with_grass","default:dirt_with_coniferous_grass"},
		noise_params={
			offset=0.2,
			scale=0.01,
			spread={x=3,y=3,z=3},
			seed=0,
		},
	},
	groups={spreading_plant=7,not_in_creative_inventory = i ~= 3 and 3 or nil},
	after_place_node=function(pos, placer)
		minetest.set_node(pos,{name="plants:grass"..math.random(1,5)})
	end
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
				minetest.set_node({x=p2.x,y=p2.y+1,z=p2.z},node)
			end
		end
	end
})

default.register_plant({
	name="wild_cotton",
	biomes={"deciduous","tropic","jungle","grass_land","semi_desert"},
	tiles={"plants_wildcotton.png"},
	decoration={noise_params={
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