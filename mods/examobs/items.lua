default.register_eatable("craftitem","examobs:flesh",1,4,{
	description = "Flesh",
	groups={meat=1},
	inventory_image = "examobs_flesh.png^examobs_alpha_fleshpiece.png^[makealpha:0,255,0"
})
default.register_eatable("craftitem","examobs:meat",3,4,{
	description = "Cooked meat",
	groups={meat=1},
	inventory_image = "examobs_meat.png^examobs_alpha_fleshpiece.png^[makealpha:0,255,0"
})

-- ================ Wolf ================

minetest.register_craftitem("examobs:pelt",{
	description = "Pelt",
	groups = {flammable=3},
	inventory_image = "examobs_pelt.png",
	wield_scale={x=2,y=2,z=1},
})
minetest.register_craftitem("examobs:tooth",{
	description = "Tooth",
	inventory_image = "examobs_tooth.png",
	wield_scale={x=0.3,y=0.3,z=0.4},
})
minetest.register_craft({
	type = "cooking",
	output = "examobs:meat",
	recipe = "examobs:flesh",
})

-- ================ mud ================

minetest.register_node("examobs:mud", {
	description = "Mud",
	tiles={"default_dirt.png^default_stonemoss.png"},
	groups = {dirt=1,soil=1,crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
})

-- ================ chicken ================

default.register_eatable("craftitem","examobs:chickenleg",1,2,{
	description = "Chicken leg",
	groups={meat=1},
	inventory_image = "examobs_skin.png^examobs_alpha_chickenleg.png^[makealpha:0,255,0"
})
default.register_eatable("craftitem","examobs:chickenleg_fried",2,3,{
	description = "Fried chicken leg",
	groups={meat=1},
	inventory_image = "examobs_meat.png^examobs_alpha_chickenleg.png^[makealpha:0,255,0"
})
minetest.register_craft({
	type = "cooking",
	output = "examobs:chickenleg_fried",
	recipe = "examobs:chickenleg",
})

minetest.register_node("examobs:egg", {
	description = "Egg",
	drawtype = "plantlike",
	inventory_image = "default_snowball.png^[colorize:#ffffff^examobs_alpha_egg.png^[makealpha:0,255,0",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	visual_scale = 0.3,
	groups = {dig_immediate=3},
	selection_box = {
		type = "fixed",
		fixed = {-0.1, -0.5, -0.1, 0.1, -0.2, 0.1}
	},
	tiles={"default_snowball.png^[colorize:#ffffff^examobs_alpha_egg.png^[makealpha:0,255,0"},
	sounds = default.node_sound_dirt_defaults(),
})
minetest.register_craftitem("examobs:feather",{
	description = "Feather",
	groups = {flammable=3},
	inventory_image = "examobs_feather.png",
	wield_scale={x=0.5,y=0.5,z=0.2},
})
-- ================ sheep ================
minetest.register_tool("examobs:shears",{
	description = "Shears",
	inventory_image = "examobs_shears.png",
})
minetest.register_craft({
	output = "examobs:shears",
	recipe = {
		{"","default:iron_ingot",""},
		{"","default:iron_ingot","default:iron_ingot"},
		{"","",""}
	}
})
minetest.register_node("examobs:wool", {
	description = "Wool",
	groups = {oddly_breakable_by_hand=2,choppy=3,wool=1},
	tiles={"examobs_wool.png"},
	sounds = default.node_sound_wood_defaults(),
})