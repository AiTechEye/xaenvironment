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
	burnable = true,
	texture = "plants_pear_wood.png",
	craft={{"group:stick","",""},{"plants:pear_wood","",""},{"group:stick","",""}}
})

for i,c in pairs({"d8e41d","b21db5","601db5","bb91f0","e4d9f3","fd0084","6f86ff","ff3030","ff4d00","ffb047","ffb0c5","a6421f"}) do
	default.register_plant({
		name="daisybush" .. i,
		description = "Daisy bush",
		tiles={"plants_pear_tree_top.png^[colorize:#"..c.."ff^plants_daisybushflower.png^[makealpha:0,255,0"},
		decoration={noise_params={
			offset=-0.001,
			scale=0.003,
		}},
	})
end

default.register_eatable("craftitem","plants:lonicera_tatarica_berries",-2,0,{inventory_image="plats_berries.png^[colorize:#ff5b19ff"})
default.register_plant({
	name="lonicera_tatarica",
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