minetest.register_node("materials:wood_table", {
	description = "Wooden table (rightclick to change in 5s)",
	tiles = {"plants_apple_wood.png"},
	groups = {wood=1,flammable = 1,choppy=3,oddly_breakable_by_hand=3},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5}
		}
	},
	palette="default_palette.png",
	paramtype2="color",
	on_punch=default.dye_coloring,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.get_meta(pos):get_int("timeout") == 0 then
			minetest.swap_node(pos,{name="materials:wood_table_center_leg"})
			minetest.get_node_timer(pos):start(5)
		end
	end,
	on_timer = function (pos, elapsed)
		minetest.get_meta(pos):set_int("timeout",1)
	end
})

minetest.register_node("materials:wood_table_center_leg", {
	description = "Wooden table center leg",
	tiles = {"plants_apple_wood.png"},
	groups = {wood=1,flammable = 1,choppy=3,oddly_breakable_by_hand=3},
	drawtype = "nodebox",
	paramtype = "light",
	drop = "materials:wood_table",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
			{-0.125, -0.5, -0.0625, 0.0625, 0.4375, 0.0625}
		}
	},
	palette="default_palette.png",
	paramtype2="color",
	on_punch=default.dye_coloring,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.get_meta(pos):get_int("timeout") == 0 then
			minetest.swap_node(pos,{name="materials:wood_table_corner_leg1"})
			minetest.get_node_timer(pos):start(5)
		end
	end,
	on_timer = function (pos, elapsed)
		minetest.get_meta(pos):set_int("timeout",1)
	end,
})

minetest.register_node("materials:wood_table_corner_leg1", {
	description = "Wooden table corner leg",
	tiles = {"plants_apple_wood.png"},
	groups = {wood=1,flammable = 1,choppy=3,oddly_breakable_by_hand=3,used_by_npc=1,treasure=1},
	drawtype = "nodebox",
	paramtype = "light",
	drop = "materials:wood_table",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
			{0.375, -0.5, 0.375, 0.5, 0.4375, 0.5}
		}
	},
	palette="default_palette.png",
	paramtype2="color",
	on_punch=default.dye_coloring,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.get_meta(pos):get_int("timeout") == 0 then
			minetest.swap_node(pos,{name="materials:wood_table_corner_leg2"})
			minetest.get_node_timer(pos):start(5)
		end
	end,
	on_timer = function (pos, elapsed)
		minetest.get_meta(pos):set_int("timeout",1)
	end,
})
minetest.register_node("materials:wood_table_corner_leg2", {
	description = "Wooden table corner leg",
	tiles = {"plants_apple_wood.png"},
	groups = {wood=1,flammable = 1,choppy=3,oddly_breakable_by_hand=3,used_by_npc=1,treasure=1,not_in_creative_inventory=1},
	drawtype = "nodebox",
	paramtype = "light",
	drop = "materials:wood_table",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.375, -0.375, 0.5, 0.5},
		}
	},
	palette="default_palette.png",
	paramtype2="color",
	on_punch=default.dye_coloring,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.get_meta(pos):get_int("timeout") == 0 then
			minetest.swap_node(pos,{name="materials:wood_table_corner_leg3"})
			minetest.get_node_timer(pos):start(5)
		end
	end,
	on_timer = function (pos, elapsed)
		minetest.get_meta(pos):set_int("timeout",1)
	end,
})
minetest.register_node("materials:wood_table_corner_leg3", {
	description = "Wooden table corner leg",
	tiles = {"plants_apple_wood.png"},
	groups = {wood=1,flammable = 1,choppy=3,oddly_breakable_by_hand=3,used_by_npc=1,treasure=1,not_in_creative_inventory=1},
	drawtype = "nodebox",
	paramtype = "light",
	drop = "materials:wood_table",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, -0.375, 0.5, -0.375}
		}
	},
	palette="default_palette.png",
	paramtype2="color",
	on_punch=default.dye_coloring,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.get_meta(pos):get_int("timeout") == 0 then
			minetest.swap_node(pos,{name="materials:wood_table_corner_leg4"})
			minetest.get_node_timer(pos):start(5)
		end
	end,
	on_timer = function (pos, elapsed)
		minetest.get_meta(pos):set_int("timeout",1)
	end,
})
minetest.register_node("materials:wood_table_corner_leg4", {
	description = "Wooden table corner leg",
	tiles = {"plants_apple_wood.png"},
	groups = {wood=1,flammable = 1,choppy=3,oddly_breakable_by_hand=3,used_by_npc=1,treasure=1,not_in_creative_inventory=1},
	drawtype = "nodebox",
	paramtype = "light",
	drop = "materials:wood_table",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, 0.4375, -0.5, 0.5, 0.5, 0.5},
			{0.375, -0.5, -0.5, 0.5, 0.5, -0.375}
		}
	},
	palette="default_palette.png",
	paramtype2="color",
	on_punch=default.dye_coloring,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(5)
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if minetest.get_meta(pos):get_int("timeout") == 0 then
			minetest.swap_node(pos,{name="materials:wood_table"})
			minetest.get_node_timer(pos):start(5)
		end
	end,
	on_timer = function (pos, elapsed)
		minetest.get_meta(pos):set_int("timeout",1)
	end,
})

minetest.register_node("materials:cup", {
	description = "Cup",
	tiles={"materials_cup.png"},
	drawtype = "plantlike",
	sounds = default.node_sound_glass_defaults(),
	groups = {dig_immediate = 3,treasure=1},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	visual_scale=0.5,
	palette="default_palette.png",
	paramtype2="color",
	on_punch=default.dye_coloring,
	selection_box = {type="fixed",fixed={-0.1,-0.5,-0.1,0.1,-0.2,0.1}}
})

minetest.register_node("materials:cup_plate", {
	description = "Cup plate",
	tiles= {"default_snow.png^[colorize:#5556","default_snow.png^[colorize:#5556","default_air.png","default_air.png","default_air.png","default_air.png"},
	drawtype = "nodebox",
	sounds = default.node_sound_glass_defaults(),
	groups = {dig_immediate = 3,treasure=1},
	sunlight_propagates = true,
	use_texture_alpha = "clip",
	walkable = false,
	paramtype = "light",
	palette="default_palette.png",
	paramtype2="color",
	on_punch=default.dye_coloring,
	node_box = {type="fixed",fixed={-0.2,-0.5,-0.2,0.2,-0.49,0.2}}
})

minetest.register_node("materials:plate", {
	description = "Plate",
	tiles= {"default_snow.png^[colorize:#5556^default_alpha_gem_round.png^[makealpha:0,255,0","default_snow.png^[colorize:#5556^default_alpha_gem_round.png^[makealpha:0,255,0","default_air.png","default_air.png","default_air.png","default_air.png"},
	drawtype = "nodebox",
	sounds = default.node_sound_glass_defaults(),
	groups = {dig_immediate = 3,treasure=1},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	palette="default_palette.png",
	paramtype2="color",
	use_texture_alpha = "clip",
	on_punch=default.dye_coloring,
	node_box = {type="fixed",fixed={-0.5,-0.5,-0.5,0.5,-0.49,0.5}}
})

minetest.register_node("materials:cup_on_plate", {
	description = "Cup on plate",
	tiles={"materials_cup_on_plate.png"},
	drawtype = "plantlike",
	sounds = default.node_sound_glass_defaults(),
	groups = {dig_immediate = 3,treasure=1},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	visual_scale=0.5,
	palette="default_palette.png",
	paramtype2="color",
	on_punch=default.dye_coloring,
	selection_box = {type="fixed",fixed={-0.1,-0.5,-0.1,0.1,-0.2,0.1}}
})

minetest.register_node("materials:pallet_box", {
	description = "Pallet box",
	tiles={"materials_pallet_box.png"},
	groups = {dig_immediate = 3,flammable=3,used_by_npc=1},
	sunlight_propagates = true,
	drawtype = "glasslike",
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
})
minetest.register_node("materials:metal_beam", {
	description = "Metal beam",
	tiles={"materials_metal_beam.png"},
	groups = {cracky = 1,level=3,used_by_npc=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype2 = "facedir",
	on_place=minetest.rotate_node,
})

minetest.register_node("materials:metal_beam_rusty", {
	description = "Rusty Metal beam",
	tiles={"materials_metal_beam_rusty.png"},
	groups = {cracky = 1,level=3,used_by_npc=1},
	sounds = default.node_sound_metal_defaults(),
	paramtype2 = "facedir",
	on_place=minetest.rotate_node,
})

minetest.register_craftitem("materials:piece_of_cloth", {
	description = "Piece of cloth",
	inventory_image = "materials_piece_of_cloth.png",
	groups = {cloth=1,flammable = 1,treasure=1},
})

minetest.register_node("materials:plant_extracts", {
	description = "Plant extracts",
	inventory_image = "materials_plant_extracts.png",
	drawtype = "plantlike",
	tiles={"materials_plant_extracts.png"},
	groups = {dig_immediate = 3,flammable=1,used_by_npc=1,treasure=1,store=100},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("materials:glass_bottle", {
	description = "Glass bottle",
	inventory_image = "materials_plant_extracts.png",
	drawtype = "plantlike",
	tiles={"materials_plant_extracts.png"},
	groups = {dig_immediate = 3,used_by_npc=1,treasure=1},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_node("materials:plant_extracts_gas", {
	description = "Plant extracts gas",
	inventory_image = "materials_plant_extracts_gas.png",
	drawtype = "plantlike",
	tiles={"materials_plant_extracts_gas.png"},
	groups = {dig_immediate = 3,flammable=1,used_by_npc=1,treasure=1},
	sunlight_propagates = true,
	walkable = false,
	paramtype = "light",
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craftitem("materials:piece_of_wood", {
	description = "Piece of wood",
	inventory_image = "materials_piece_of_wood.png",
	groups = {peace_of_wood=1,flammable = 1,treasure=1},
})

minetest.register_node("materials:mixed_wood", {
	description = "Mixed wood",
	tiles = {"materials_mixed_wood.png"},
	groups = {wood=1,flammable = 1,choppy=3,oddly_breakable_by_hand=3,used_by_npc=1,treasure=1},
	sounds = default.node_sound_wood_defaults(),
})
minetest.register_craftitem("materials:string", {
	description = "String",
	inventory_image = "materials_string.png",
	groups = {flammable = 1,treasure=1},
})

default.register_eatable("craftitem","materials:bread",1,10,{
	description = "Bread",
	inventory_image="materials_bread.png",
	groups={flammable=3,treasure=1},
})
minetest.register_craftitem("materials:plastic_sheet", {
	description = "Plastic sheet",
	inventory_image = "materials_plastic_sheet.png",
	groups = {flammable = 1,treasure=1},
})
minetest.register_craftitem("materials:gear_metal", {
	description = "Metal megear",
	inventory_image = "materials_gear_metal.png",
	groups = {treasure=1},
})
minetest.register_craftitem("materials:fanblade_metal", {
	description = "Metal fanblade",
	inventory_image = "materials_fanblade_metal.png",
	groups = {treasure=1},
})
minetest.register_craftitem("materials:fanblade_plastic", {
	description = "Plastic fanblade",
	inventory_image = "materials_fanblade_plastic.png",
	groups = {flammable=1,treasure=1},
})
minetest.register_craftitem("materials:tube_metal", {
	description = "Tube",
	inventory_image = "materials_tube_metal.png",
	groups = {flammable=1,treasure=1},
})

minetest.register_node("materials:spaceyfloor", {
	description = "Spacey floor",
	tiles={"materials_spaceyfloor.png"},
	groups = {cracky=2},
	sounds = default.node_sound_metal_defaults(),
})

minetest.register_craftitem("materials:diode", {
	description = "Diode",
	inventory_image = "materials_diode.png"
})

minetest.register_craftitem("materials:sawblade", {
	description = "Sawblade",
	inventory_image = "materials_sawblade.png"
})

minetest.register_tool("materials:firethrower", {
	description = "Firethrower",
	inventory_image = "materials_firethrower.png",
	on_use=function(itemstack, user, pointed_thing)
		local d = user:get_look_dir()
		local p = user:get_pos()
		local inv = user:get_inventory()
		local index = user:get_wield_index()-1
		local stack = inv:get_stack("main",index)
		local n = user:get_player_name()

		if itemstack:get_wear() > 60000 then
			if stack:get_name() == "materials:plant_extracts_gas" then
				stack:take_item()
				inv:set_stack("main",index,stack)
				itemstack:set_wear(1)
				return itemstack
			else
				minetest.chat_send_player(n,"Put 'extracts gas' left slot of the tool to load")
				return itemstack
			end
		else
			itemstack:set_wear(itemstack:get_wear() + (65535/12))	
		end

		for i = 2,12,1 do
			local po = {x=p.x+(d.x*i),y=p.y+1.5+(d.y*i),z=p.z+(d.z*i)}
			if not minetest.is_protected(po, n) and default.defpos(po,"buildable_to") then
				minetest.add_node(po,{name="fire:basic_flame"})
			else
				break
			end
		end
		return itemstack
	end
})

minetest.register_node("materials:concrete", {
	description = "Concrete",
	tiles = {"materials_concrete.png"},
	groups = {cracky=2,treasure=1},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("materials:concrete_floor", {
	description = "Concrete floor",
	tiles = {"materials_concretefloor.png"},
	groups = {cracky=2,treasure=1},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("materials:concrete_stair",{
	description = "Concrete stair",
	tiles = {"materials_concrete.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2,treasure=1},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0},
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}
		}
	},
	on_place = minetest.rotate_node,
})
minetest.register_node("materials:concrete_floor_stair",{
	description = "Concrete floor stair",
	tiles = {"materials_concretefloor.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2,treasure=1},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0},
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}
		}
	},
	on_place = minetest.rotate_node,
})

default.register_chest({
	name = "iron_chest",
	description = "Iron chest",
	texture="default_ironblock.png",
		groups = {cracky=2,treasure=1},
	craft={
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
		{"default:iron_ingot","","default:iron_ingot"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"}
	}
})


minetest.register_node("materials:granite", {
	description = "Granite",
	tiles = {"materials_granite.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("materials:granite_block", {
	description = "Granite block",
	tiles = {"materials_granite_block.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
})
minetest.register_node("materials:granite_brick", {
	description = "Granite brick",
	tiles = {"materials_granite_brick.png"},
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("materials:granite_stair",{
	description = "Granite stair",
	tiles = {"materials_granite.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0},
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}
		}
	},
	on_place = minetest.rotate_node,
})
minetest.register_node("materials:granite_brick_stair",{
	description = "Granite brick stair",
	tiles = {"materials_granite_brick.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0, 0},
			{-0.5, -0.5, 0, 0.5, 0.5, 0.5}
		}
	},
	on_place = minetest.rotate_node,
})

minetest.register_node("materials:granite_cylinder",{
	description = "Granite cylinder",
	tiles = {"materials_granite.png"},
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	mesh = "materials_cylinder.obj",
	on_place = minetest.rotate_node,
})

minetest.register_node("materials:granite_orb",{
	description = "Granite orb",
	tiles = {"materials_granite.png"},
	drawtype = "mesh",
	paramtype = "light",
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	mesh = "materials_orb.obj",
})

minetest.register_node("materials:pelletsblock",{
	description = "Pellets block",
	tiles = {"default_salt_water.png^[invert:rgb^plants_wheat_seed.png"},
	groups = {wood=1,flammable = 3,choppy=3,dig_immediate = 3,treasure=1,store=100},
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craftitem("materials:pellets", {
	description = "Pellets",
	inventory_image = "plants_wheat_seed.png",
	groups = {flammable = 1},
})

minetest.register_node("materials:asphalt",{
	description = "Asphalt",
	tiles = {"default_oil.png^[colorize:#9995"},
	groups = {cracky=2,asphalt=1,treasure=1,store=100},
	sounds = default.node_sound_stone_defaults(),
	use_texture_alpha = "clip",
})
default.register_stair("materials:asphalt")

minetest.register_node("materials:slime_source", {
	description = "Source slime",
	drawtype = "liquid",
	use_texture_alpha = "blend",
	tiles = {"default_stone.png^[colorize:#0f05"},
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	pointable = false,
	drowning = 1,
	liquidtype = "source",
	liquid_range = 2,
	liquid_alternative_flowing = "materials:slime_flowing",
	liquid_alternative_source = "materials:slime_source",
	liquid_viscosity = 20,
	post_effect_color = {a=60,r=0,g=150,b=0},
	groups = {liquid = 1,water=1},
})

minetest.register_node("materials:slime_flowing", {
	description = "Flowing slime",
	drawtype = "liquid",
	use_texture_alpha = "blend",
	tiles = {"default_stone.png^[colorize:#0f15"},
	paramtype = "light",
	walkable = false,
	buildable_to = true,
	pointable = false,
	drowning = 1,
	liquidtype = "flowing",
	liquid_range = 2,
	liquid_alternative_flowing = "materials:slime_flowing",
	liquid_alternative_source = "materials:slime_source",
	liquid_viscosity = 20,
	post_effect_color = {a=60,r=0,g=150,b=0},
	groups = {liquid = 1,water=1},
})

minetest.register_node("materials:slime", {
	description = "Slime block",
	drawtype = "glasslike",
	tiles = {"default_water.png^[colorize:#0f0c"},
	paramtype = "light",
	use_texture_alpha = "blend",
	drowning = 1,
	sunlight_propagates = true,
	liquid_viscosity = 30,
	post_effect_color = {a=60,r=0,g=150,b=0},
	groups = {crumbly = 1, fall_damage_add_percent=-100,bouncy=99},
})

minetest.register_node("materials:shelf", {
	description = "Shelf",
	tiles={"default_wood.png"},
	groups = {wood=1,flammable = 1,choppy=3,oddly_breakable_by_hand=3,used_by_npc=1,treasure=1,exatec_tube_connected=1},
	sounds = default.node_sound_wood_defaults(),
	drawtype = "nodebox",
	paramtype2 = "facedir",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.25, 0.5, -0.4375, 0.5},
			{-0.5, -0.5, 0.4375, 0.5, 0.5, 0.5},
			{-0.5, 0.4375, -0.25, 0.5, 0.5, 0.5},
			{0.4375, -0.5, -0.25, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.25, -0.4375, 0.5, 0.5},
			{-0.4375, 0, -0.25, 0.4375, 0.0625, 0.4375},
		}
	},
	exatec={
		input_list="main",
		output_list="main",
	},
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 32)
		m:set_string("infotext","Shelf")
		m:set_string("formspec",
			"size[8,8]listcolors[#77777777;#777777aa;#000000ff]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
			"list[current_player;main;0,4.2;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
		)
	end,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end
})

minetest.register_node("materials:wood_tabletop", {
	description = "Wood tabletop",
	tiles={"default_wood.png"},
	groups = {wood=1,cracky=3,flammable=1,oddly_breakable_by_hand=3,treasure=1},
	sounds = default.node_sound_wood_defaults(),
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

minetest.register_node("materials:wood_tabletop2", {
	description = "Wood tabletop (3/4)",
	tiles={"default_wood.png"},
	groups = {wood=1,cracky=3,flammable=1,oddly_breakable_by_hand=3,treasure=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.45, 0.3},
		}
	},
})

minetest.register_node("materials:wood_tabletop3", {
	description = "Wood tabletop (2/4)",
	tiles={"default_wood.png"},
	groups = {wood=1,cracky=3,flammable=1,oddly_breakable_by_hand=3,treasure=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.45, 0},
		}
	},
})

minetest.register_node("materials:wood_tabletop4", {
	description = "Wood tabletop (1/4)",
	tiles={"default_wood.png"},
	groups = {wood=1,cracky=3,flammable=1,oddly_breakable_by_hand=3,treasure=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	drawtype="nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.45, -0.2},
		}
	},
})

minetest.register_node("materials:fridge", {
	description = "Fridge",
	tiles={"default_steelblock.png"},
	groups = {cracky=2,used_by_npc=1,treasure=1,exatec_tube_connected=1,store=2000},
	sounds = default.node_sound_metal_defaults(),
	drawtype = "nodebox",
	paramtype2 = "facedir",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.375, 0.5, 0.5, 0.5},
			{-0.375, -0.1875, -0.5, -0.3125, 0.125, -0.4375},
			{-0.4375, -0.5, -0.4375, 0.4375, 0.4375, -0.375},
		}
	},
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 32)
		m:set_string("infotext","Fridge")
		m:set_string("formspec",
			"size[8,8]listcolors[#77777777;#777777aa;#000000ff]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
			"list[current_player;main;0,4.2;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
		)
	end,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
	exatec={
		input_list="main",
		output_list="main",
		test_input=function(pos,stack)
			local inv = minetest.get_meta(pos):get_inventory()
			return (minetest.get_item_group(stack:get_name(),"eatable") > 0 or minetest.get_item_group(stack:get_name(),"drinkable") > 0) and stack:get_count() or 0
		end,
	},
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return (minetest.get_item_group(stack:get_name(),"eatable") > 0 or minetest.get_item_group(stack:get_name(),"drinkable") > 0) and stack:get_count() or 0
	end
})

minetest.register_craftitem("materials:aluminium_sheet", {
	description = "Aluminium sheet",
	inventory_image = "materials_aluminium_sheet.png",
	groups = {treasure=1},
})

minetest.register_node("materials:xecoke",{
	description = "XECoke",
	tiles = {"materials_sodacan_xecoke.png"},
	groups = {cracky=2,dig_immediate = 3,treasure=1,store=100,junk=1},
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	wield_scale = {x=2,y=-2,z=2},
	sounds = default.node_sound_stone_defaults(),
	mesh = "materials_sodacan.obj",
	walkable = false,
	selection_box = {
		type="fixed",
		fixed={-0.1,-0.5,-0.1,0.1,-0.2,0.1}
	},
	on_punch = function(pos, node, player, pointed_thing)
		local inv = player:get_inventory()
		if minetest.is_protected(pos,player:get_player_name())
		and minetest.get_meta(pos):get_int("placed") == 0
		and inv:room_for_item("main",node.name) then
			inv:add_item("main",node.name)
			minetest.remove_node(pos)
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		minetest.rotate_node(itemstack, placer, pointed_thing)
		minetest.get_meta(pointed_thing.above):set_int("placed",1)
		return itemstack
	end,
	on_timer = function (pos, elapsed)
		minetest.remove_node(pos)
	end,
})

minetest.register_node("materials:plasticbag",{
	description = "Plastic bag",
	wield_image = "materials_plasticbag.png^[colorize:#999a",
	inventory_image = "materials_plasticbag.png",
	tiles = {"materials_plasticbag.png"},
	groups = {dig_immediate = 3,treasure=1,junk=1,flammable=1},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	sounds = default.node_sound_leaves_defaults(),
	walkable = false,
	use_texture_alpha = "blend",
	drawtype = "nodebox",
	node_box = {
		type="fixed",
		fixed={-0.5,-0.5,-0.5,0.5,-0.495,0.5}
	},
	on_punch = function(pos, node, player, pointed_thing)
		local inv = player:get_inventory()
		if minetest.is_protected(pos,player:get_player_name())
		and minetest.get_meta(pos):get_int("placed") == 0
		and inv:room_for_item("main",node.name) then
			inv:add_item("main",node.name)
			minetest.remove_node(pos)
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		minetest.rotate_node(itemstack, placer, pointed_thing)
		minetest.get_meta(pointed_thing.above):set_int("placed",1)
		return itemstack
	end,
	on_timer = function (pos, elapsed)
		minetest.remove_node(pos)
	end,
})

minetest.register_node("materials:dirty_papper",{
	description = "Dirty papper",
	wield_image = "materials_dirtypapper.png",
	inventory_image = "materials_dirtypapper.png",
	tiles = {"materials_dirtypapper.png"},
	groups = {dig_immediate = 3,treasure=1,papper=1,junk=1,flammable=1},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	sounds = default.node_sound_leaves_defaults(),
	walkable = false,
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	node_box = {
		type="fixed",
		fixed={-0.5,-0.5,-0.5,0.5,-0.495,0.5}
	},
	on_punch = function(pos, node, player, pointed_thing)
		local inv = player:get_inventory()
		if minetest.is_protected(pos,player:get_player_name())
		and minetest.get_meta(pos):get_int("placed") == 0
		and inv:room_for_item("main",node.name) then
			inv:add_item("main",node.name)
			minetest.remove_node(pos)
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		minetest.rotate_node(itemstack, placer, pointed_thing)
		minetest.get_meta(pointed_thing.above):set_int("placed",1)
		return itemstack
	end,
	on_timer = function (pos, elapsed)
		minetest.remove_node(pos)
	end,
})