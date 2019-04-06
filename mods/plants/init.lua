default.register_tree({
	name="pear",
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

default.register_chair({
	name = "pear_wood",
	description = "Pear wood chair",
	flammable = true,
	texture = "plants_pear_wood.png",
})