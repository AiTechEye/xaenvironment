
minetest.register_craftitem("default:stick", {
	description = "Wooden stick",
	inventory_image = "default_stick.png",
	groups = {flammable = 1,stick=1},
})

--||||||||||||||||
-- ======================= minerals
--||||||||||||||||

default.registry_mineral({
	name="coal",
	texture="default_copperblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
	regular_additional_craft={{
		type = "fuel",
		recipe = "default:coal_lump",
		burntime = 40,
	}}
})

default.registry_mineral({
	name="flint",
	texture="default_flintblock.png",
	not_ore=true,
	not_lump=true,
	not_ingot=true,
	drop={inventory_image="flint"},
	block={
		groups={cracky=3,stone=1},
		sounds=default.node_sound_stone_defaults()
	},
	regular_additional_craft={

	{output="default:flint_pick",
	recipe={
		{"default:flint","default:flint","default:flint"},
		{"","default:stick",""},
		{"","default:stick",""},
	}},
	{output="default:flint_shovel",
	recipe={
		{"","default:flint",""},
		{"","default:stick",""},
		{"","default:stick",""},
	}},
	{output="default:flint_axe",
	recipe={
		{"default:flint","default:flint",""},
		{"default:flint","default:stick",""},
		{"","default:stick",""},
	}},
	{output="default:flint_hoe",
	recipe={
		{"default:flint","default:flint",""},
		{"","default:stick",""},
		{"","default:stick",""},
	}},
	{output="default:flint_vineyardknife",
	recipe={
		{"default:flint","default:flint",""},
		{"","default:stick",""},
		{"","default:stick",""},
	}},
	{output="default:flint",
	recipe={
		{"default:gravel","default:gravel","default:gravel"},
		{"default:gravel","default:gravel","default:gravel"},
		{"default:gravel","default:gravel","default:gravel"},
	}}
}})

default.registry_mineral({
	name="copper",
	texture="default_copperblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
})

default.registry_mineral({
	name="tin",
	texture="default_tinblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
})

default.registry_mineral({
	name="bronze",
	texture="default_bronzeblock.png",
	not_lump = true,
	not_ore = true,
	regular_additional_craft={{
		output="default:bronze_ingot 9",
		recipe={
			{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
			{"default:copper_ingot","default:tin_ingot","default:copper_ingot"},
			{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
		}
	}}
})

default.registry_mineral({
	name="iron",
	texture="default_ironblock.png",
	lump={inventory_image="default_lump_iron.png"},
	ore={tiles={"default_stone.png^default_ore_iron.png"}}
})

default.registry_mineral({
	name="steel",
	texture="default_steelblock.png",
	not_lump = true,
	not_ore = true,
	regular_additional_craft={{
		type = "cooking",
		output = "default:steel_ingot",
		recipe = "default:iron_ingot",
		cooktime = 10
	}}
})

default.registry_mineral({
	name="gold",
	texture="default_goldblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
})

default.registry_mineral({
	name="silver",
	texture="default_silverblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
})

default.registry_mineral({
	name="diamond",
	texture="default_diamondblock.png",
	drop={inventory_image="diamond"},
	not_lump = true,
	not_ingot = true
})

default.registry_mineral({
	name="electric",
	texture="default_electricblock.png",
	not_ingot=true,
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
})

default.registry_mineral({
	name="uranium",
	texture="default_uraniumblock.png",
})

default.registry_mineral({
	name="uraniumactive",
	texture="default_uraniumactiveblock.png",
	not_lump=true,
	not_ore=true,
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
	regular_additional_craft={{
		type = "cooking",
		output = "default:uraniumactive_ingot",
		recipe = "default:uranium_ingot",
		cooktime = 100
	}}
})