
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
	texture="default_coalblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_ingot=true,
	not_vineyardknife=true,
	regular_additional_craft={
		{
			type = "fuel",
			recipe = "default:coal_lump",
			burntime = 40,
		},
		{output="default:coalblock",recipe={
			{"default:coal_lump","default:coal_lump","default:coal_lump"},
			{"default:coal_lump","default:coal_lump","default:coal_lump"},
			{"default:coal_lump","default:coal_lump","default:coal_lump"},
		}},
		{output="default:coal_lump 9",recipe={
			{"default:coalblock"},
		}},
	},
	ore_settings={
		clust_num_ores=5,
		clust_size=5,
		y_max=50,
	}

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
	ore_settings={
		clust_scarcity= 10 * 10 * 10,
		clust_num_ores=4,
		clust_size=6,
		y_max=-50,
	},
	pick={tool_capabilities={
		full_punch_interval = 1.2,
		max_drop_level = 1,
		groupcaps = {
			cracky={times={[1]=10,[2]=3,[3]=1.4},uses=17,maxlevel=1}
		},
		damage_groups={fleshy=2}
	}},
	shovel={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			crumbly={times={[1]=2,[2]=1},uses=17,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	axe={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			choppy={times={[1]=3,[2]=1.8,[3]=1.1},uses=17,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	vineyardknife={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			choppy={times={[1]=2,[2]=1.8,[3]=1.5},uses=17,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}}
})

default.registry_mineral({
	name="tin",
	texture="default_tinblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
	ore_settings={
		clust_scarcity= 10 * 10 * 10,
		clust_num_ores=4,
		clust_size=6,
		y_max=-50,
	}
})

default.registry_mineral({
	name="bronze",
	texture="default_bronzeblock.png",
	not_lump = true,
	not_ore = true,
	regular_additional_craft={{
		output="default:bronze_ingot 15",
		recipe={
			{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
			{"default:copper_ingot","default:tin_ingot","default:copper_ingot"},
			{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
		}
	}},
	pick={tool_capabilities={
		full_punch_interval = 1.2,
		max_drop_level = 1,
		groupcaps = {
			cracky={times={[1]=10,[2]=3,[3]=1.4},uses=20,maxlevel=1}
		},
		damage_groups={fleshy=2}
	}},
	shovel={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			crumbly={times={[1]=2,[2]=1},uses=20,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	axe={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			choppy={times={[1]=3,[2]=1.8,[3]=1.1},uses=20,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	vineyardknife={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			choppy={times={[1]=2,[2]=1.8,[3]=1.5},uses=20,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}}
})

default.registry_mineral({
	name="iron",
	texture="default_ironblock.png",
	lump={inventory_image="default_lump_iron.png"},
	ore={tiles={"default_stone.png^default_ore_iron.png"}},
	ore_settings={
		clust_scarcity= 12 * 12 * 12,
		clust_num_ores=4,
		clust_size=7,
		y_max=5,
	},
	pick={tool_capabilities={
		full_punch_interval = 1.1,
		max_drop_level = 1,
		groupcaps = {
			cracky={times={[1]=8,[2]=2.5,[3]=1.2},uses=22,maxlevel=2}
		},
		damage_groups={fleshy=3}
	}},
	shovel={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			crumbly={times={[1]=10,[2]=1.8,[3]=1.2},uses=22,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	axe={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			choppy={times={[1]=2.7,[2]=1.5,[3]=1},uses=22,maxlevel=2}
		},
		damage_groups={fleshy=4}
	}},
	vineyardknife={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			choppy={times={[1]=1.9,[2]=1.7,[3]=1.4},uses=22,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}}
})

default.registry_mineral({
	name="steel",
	texture="default_steelblock.png",
	not_lump = true,
	not_ore = true,
	block={groups={cracky=1}},
	regular_additional_craft={{
		type = "cooking",
		output = "default:steel_ingot",
		recipe = "default:iron_ingot",
		cooktime = 10
	}},
	pick={tool_capabilities={
		full_punch_interval = 1,
		max_drop_level = 3,
		groupcaps = {
			cracky={times={[1]=5,[2]=2,[3]=1.1},uses=25,maxlevel=3}
		},
		damage_groups={fleshy=3}
	}},
	shovel={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			crumbly={times={[1]=5,[2]=1.6,[3]=1},uses=25,maxlevel=3}
		},
		damage_groups={fleshy=2}
	}},
	axe={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			choppy={times={[1]=2.5,[2]=1.2,[3]=0.9},uses=25,maxlevel=2}
		},
		damage_groups={fleshy=4}
	}},
	vineyardknife={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			choppy={times={[1]=1.8,[2]=1.6,[3]=1.3},uses=25,maxlevel=2}
		},
		damage_groups={fleshy=2}
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
	ore_settings={
		clust_scarcity= 20 * 20 * 20,
		clust_num_ores=3,
		clust_size=7,
		y_max=-70,
	},
})

default.registry_mineral({
	name="silver",
	texture="default_silverblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
	ore_settings={
		clust_scarcity= 20 * 20 * 20,
		clust_num_ores=3,
		clust_size=7,
		y_max=-70,
	}
})

default.registry_mineral({
	name="diamond",
	texture="default_diamondblock.png",
	drop={inventory_image="diamond"},
	block={groups={cracky=1}},
	not_lump = true,
	not_ingot = true,
	ore_settings={
		clust_scarcity= 25 * 25 * 25,
		clust_num_ores=2,
		clust_size=8,
		y_max=-90,
	},
	pick={tool_capabilities={
		full_punch_interval = 1,
		max_drop_level = 2,
		groupcaps = {
			cracky={times={[1]=2,[2]=1,[3]=0.5},uses=30,maxlevel=1}
		},
		damage_groups={fleshy=4}
	}},
	shovel={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			crumbly={times={[1]=3,[2]=0.7,[3]=0.5},uses=30,maxlevel=3}
		},
		damage_groups={fleshy=3}
	}},
	axe={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			choppy={times={[1]=2,[2]=1,[3]=0.6},uses=30,maxlevel=2}
		},
		damage_groups={fleshy=5}
	}},
	vineyardknife={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			choppy={times={[1]=1.5,[2]=1.2,[3]=1},uses=30,maxlevel=2}
		},
		damage_groups={fleshy=3}
	}}
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
	ore_settings={
		clust_scarcity= 30 * 30 * 30,
		clust_num_ores=1,
		clust_size=9,
		y_max=-100,
	}
})

default.registry_mineral({
	name="uranium",
	texture="default_uraniumblock.png",
	ore_settings={
		clust_scarcity= 32 * 32 * 32,
		clust_num_ores=2,
		clust_size=10,
		y_max=-100,
	},
	pick={tool_capabilities={
		full_punch_interval = 1,
		max_drop_level = 2,
		groupcaps = {
			cracky={times={[1]=1.95,[2]=0.95,[3]=0.45},uses=33,maxlevel=1}
		},
		damage_groups={fleshy=4}
	}},
	shovel={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			crumbly={times={[1]=2.5,[2]=0.6,[3]=0.3},uses=33,maxlevel=3}
		},
		damage_groups={fleshy=3}
	}},
	axe={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			choppy={times={[1]=1.5,[2]=0.8,[3]=0.5},uses=33,maxlevel=2}
		},
		damage_groups={fleshy=6}
	}},
	vineyardknife={tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			choppy={times={[1]=1.3,[2]=1,[3]=0.9},uses=33,maxlevel=2}
		},
		damage_groups={fleshy=4}
	}}
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