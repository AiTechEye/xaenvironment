for i=1,20 do
default.register_plant({
	name="coral_" .. i,
	description = "Coral",
	tiles={"default_sand.png"},
	special_tiles = {{name  = "plants_coral.png^" .. default.dye_texturing(i*7,{opacity=150}).."^plants_coral_alpha.png^[makealpha:0,255,0"}, tileable_vertical = true},
	drawtype = "plantlike_rooted",
	groups={not_in_craftguide=1},
	visual_scale = i <7 and 1 or i< 12 and 1.5 or 2,
	floodable = false,
	walkable = true,
	decoration={
		noise_params={
			offset=0.006,
			scale=0.0004,
			spread={x=17,y=17,z=17},
			seed=9*i,
		},
		place_on = {"default:sand","default:desert_sand"},
		place_offset_y = -1,
		flags = "force_placement",
		sidelen = 4,
		y_max = -5,
		y_min = -30,
		spawn_by = "default:salt_water_source",
		biomes ={
			"hot_ocean",
		}, 
	},
	dye_colors = {palette=i*7},
})
default.register_plant({
	name="coral2_" .. i,
	description = "Coral",
	tiles={"default_sand.png"},
	special_tiles = {{name  = "plants_coral2.png^" .. default.dye_texturing(i*7+4,{opacity=150}).."^plants_coral2_alpha.png^[makealpha:0,255,0"}, tileable_vertical = true},
	drawtype = "plantlike_rooted",
	groups={not_in_craftguide=1},
	visual_scale = i <11 and 1 or i< 16 and 1.5 or 2,
	floodable = false,
	walkable = true,
	decoration={
		biomes={"hot_ocean"}, 
		noise_params={
			offset=0.006,
			scale=0.0004,
			spread={x=17,y=17,z=17},
			seed=6*i,
		},
		place_on = {"default:sand","default:desert_sand"},
		place_offset_y = -1,
		flags = "force_placement",
		sidelen = 4,
		y_max = -5,
		y_min = -30,
		spawn_by = "default:salt_water_source",
	},
	dye_colors = {palette=i*7+4},
})

if i <= 4 then
default.register_plant({
	name="kelp" .. i,
	description = "Kelp",
	tiles={"default_sand.png"},
	special_tiles = {{name  = "plants_kelp"..i..".png",tileable_vertical = true}},
	inventory_image = "plants_kelp"..i..".png",
	drawtype = "plantlike_rooted",
	groups={not_in_craftguide=1,on_load=1},
	floodable = false,
	walkable=true,
	paramtype="light",
	paramtype2="leveled",
	on_load=function(pos,node)
		local rndh = math.random(4,16)
		if node.param2 == 0 and minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name,"water") > 0 then
			for h=1,16 do
				if h == rndh or minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y+h,z=pos.z}).name,"water") == 0 then
					minetest.set_node(pos,{name="plants:kelp"..i,param2=(h*16)-16})
					return
				end
			end
		end
	end,
	decoration={
		biomes={"ocean","hot_ocean"}, 
		noise_params={
			offset=0.009,
			scale=0.00018,
			spread={x=25,y=25,z=25},
			seed=8456,
		},
		place_on = {"default:sand","default:desert_sand"},
		place_offset_y = -1,
		flags = "force_placement",
		sidelen = 4,
		y_max = -5,
		y_min = -30,
		spawn_by = "default:salt_water_source",
	},
})
end

if i <= 3 then
default.register_plant({
	name="seaweed" .. i,
	description = "Seaweed",
	tiles={"default_sand.png"},
	special_tiles = {{name  = "plants_seaweed"..i..".png",tileable_vertical = true}},
	groups={not_in_craftguide=1},
	floodable = false,
	paramtype="light",
	drawtype = "plantlike_rooted",
	decoration={
		biomes={"ocean","hot_ocean"}, 
		noise_params={
			offset=0.009,
			scale=0.0008,
			spread={x=25,y=25,z=25},
			seed=554,
		},
		place_on = {"default:sand","default:desert_sand"},
		flags = "force_placement",
		place_offset_y = -1,
		sidelen = 4,
		y_max = -5,
		y_min = -30,
		spawn_by = "default:salt_water_source",
	},
})
end
end

default.register_plant({
	name="seaweedlong",
	description = "Seaweed",
	tiles={"default_sand.png"},
	special_tiles = {{name  = "plants_seaweed3.png",tileable_vertical = true}},
	inventory_image = "plants_seaweed3.png",
	drawtype = "plantlike_rooted",
	groups={not_in_craftguide=1,on_load=1},
	floodable = false,
	walkable=true,
	paramtype="light",
	paramtype2="leveled",
	on_load=function(pos,node)
		if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z}).name,"water") > 0 then
			for h=1,5 do
				if minetest.get_item_group(minetest.get_node({x=pos.x,y=pos.y+h,z=pos.z}).name,"water") == 0 then
					minetest.set_node(pos,{name="plants:seaweedlong",param2=(h*16)-16})
					return
				end
			end
		end
	end,
	decoration={
		biomes={"ocean","hot_ocean"}, 
		noise_params={
			offset=0.001,
			scale=0.00018,
			spread={x=25,y=25,z=25},
			seed=856,
		},
		place_on = {"default:sand","default:desert_sand"},
		place_offset_y = -1,
		flags = "force_placement",
		sidelen = 4,
		y_max = -5,
		y_min = -30,
		spawn_by = "default:salt_water_source",
	},
})