minetest.register_craft({
	output="exatec:autocrafter",
	recipe={
		{"default:iron_ingot","default:steel_ingot","default:iron_ingot"},
		{"materials:plastic_sheet","default:copper_ingot","materials:plastic_sheet"},
		{"materials:plastic_sheet","group:stick","materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output="exatec:extraction",
	recipe={
		{"default:iron_ingot","","default:iron_ingot"},
		{"materials:plastic_sheet","default:copper_ingot","materials:plastic_sheet"},
		{"materials:plastic_sheet","default:tin_ingot","materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output="exatec:tube",
	recipe={
		{"materials:plastic_sheet","materials:plastic_sheet",""},
		{"materials:plastic_sheet","materials:plastic_sheet",""},
	},
})