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
		{"default:iron_ingot","materials:fanblade_metal","default:iron_ingot"},
		{"materials:plastic_sheet","default:copper_ingot","materials:plastic_sheet"},
		{"materials:plastic_sheet","materials:tube_metal","materials:plastic_sheet"},
	},
})
minetest.register_craft({
	output="exatec:dump",
	recipe={
		{"default:iron_ingot","materials:fanblade_plastic","default:iron_ingot"},
		{"materials:plastic_sheet","default:copper_ingot","materials:plastic_sheet"},
		{"materials:plastic_sheet","materials:tube_metal","materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output="exatec:tube",
	recipe={
		{"materials:plastic_sheet","materials:plastic_sheet",""},
		{"materials:plastic_sheet","materials:plastic_sheet",""},
	},
})

minetest.register_craft({
	output="exatec:tube_detector",
	recipe={
		{"exatec:tube","exatec:wire",""},
	},
})

minetest.register_craft({
	output="exatec:button",
	recipe={
		{"group:wood","exatec:wire",""},
	},
})

minetest.register_craft({
	output="exatec:wire 20",
	recipe={
		{"materials:plastic_sheet","materials:plastic_sheet","materials:plastic_sheet"},
		{"materials:plastic_sheet","default:copper_ingot","materials:plastic_sheet"},
		{"materials:plastic_sheet","materials:plastic_sheet","materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output="exatec:autosender",
	recipe={
		{"default:iron_ingot","exatec:button","exatec:wire"},
		{"materials:plastic_sheet","materials:gear_metal","materials:plastic_sheet"},
		{"materials:plastic_sheet","materials:gear_metal","materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output="exatec:counter",
	recipe={
		{"default:copper_ingot","exatec:button","exatec:wire"},
		{"materials:plastic_sheet","materials:gear_metal","materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output="exatec:delayer",
	recipe={
		{"default:copper_ingot","exatec:button","exatec:wire"},
		{"materials:plastic_sheet","clock:clock1","materials:plastic_sheet"},
	},
})