minetest.register_tool(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale={x=1,y=1,z=2},
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 0,
		groupcaps={
			crumbly = {times={[2]=3, [3]=0.7}, uses=0, maxlevel=1},
			snappy = {times={[3]=0.4}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[3]=3.5,[2]=2,[3]=0.7}, uses=0}
		},
		damage_groups = {fleshy=1},
	},
})

minetest.register_tool("default:admin_pickaxe", {
	description ="Admin pickaxe",
	range = 15,
	inventory_image = "default_admin_pickaxe.png",
	groups = {admin_tool=1,not_in_creative_inventory=1},
	tool_capabilities = {
		full_punch_interval = 0.20,
		max_drop_level = 3,
		groupcaps = {
			unbreakable={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			fleshy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			choppy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			bendy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			cracky={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			crumbly={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			snappy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			dig_immediate={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
		},
		damage_groups={fleshy=9000},
	},
})

minetest.register_tool("default:cudgel", {
	description = "Wooden cudgel",
	inventory_image = "default_stick.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.3}, uses=105, maxlevel=0},
			cracky = {times={[3]=10}, uses=2, maxlevel=1},
			oddly_breakable_by_hand = {times={[3]=3.5,[2]=2,[3]=0.7}, uses=0},
			choppy = {times={[3]=3.5}, uses=0}
		},
		damage_groups = {fleshy=3},
	},
	groups = {flammable = 2,stick=1},
	sound=default.tool_breaks_defaults()
})

minetest.register_tool("default:pick_flint", {
	description ="Flint pickaxe",
	inventory_image = "default_pick_flint.png",
	groups = {tool=1,flint=1},
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 0,
		groupcaps = {
			cracky={times={[2]=1.9,[3]=0.9},uses=20,maxlevel=1},
		},
		damage_groups={fleshy=2},
	},
	sound=default.tool_breaks_defaults()
})

minetest.register_tool("default:axe_flint", {
	description ="Flint axe",
	inventory_image = "default_axe_flint.png",
	groups = {tool=1,flint=1},
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 0,
		groupcaps = {
			choppy={times={[1]=2,[2]=1.9,[3]=1.2},uses=20,maxlevel=1},
		},
		damage_groups={fleshy=2},
	},
	sound=default.tool_breaks_defaults()
})

minetest.register_tool("default:axe_flint", {
	description ="Flint axe",
	inventory_image = "default_axe_flint.png",
	groups = {tool=1,flint=1},
	tool_capabilities = {
		full_punch_interval = 1,
		max_drop_level = 0,
		groupcaps = {
			choppy={times={[1]=2,[2]=1.9,[3]=1.2},uses=20,maxlevel=1},
		},
		damage_groups={fleshy=2},
	},
	sound=default.tool_breaks_defaults()
})

minetest.register_tool("default:shovel_flint", {
	description ="Flint shovel",
	inventory_image = "default_shovel_flint.png",
	groups = {tool=1,flint=1},
	tool_capabilities = {
		full_punch_interval = 1.5,
		max_drop_level = 0,
		groupcaps = {
			crumbly={times={[1]=1.9,[2]=1.4,[3]=0.6},uses=20,maxlevel=1},
		},
		damage_groups={fleshy=2},
	},
	sound=default.tool_breaks_defaults()
})

minetest.register_tool("default:vineyardknife_flint", {
	description ="Flint vineyard knife",
	inventory_image = "default_vineyardknife_flint.png",
	groups = {tool=1,flint=1},
	tool_capabilities = {
		full_punch_interval = 1.5,
		max_drop_level = 0,
		groupcaps = {
			snappy={times={[2]=1.6,[3]=0.5},uses=20,maxlevel=1},
		},
		damage_groups={fleshy=2},
	},
	sound=default.tool_breaks_defaults()
})