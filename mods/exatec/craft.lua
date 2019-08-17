minetest.register_craft({
	output="exatec:autocrafter",
	recipe={
		{"default:iron_ingot","default:steel_ingot","default:iron_ingot"},
		{"materials:plastic_sheet","default:copper_ingot","materials:plastic_sheet"},
		{"materials:plastic_sheet","materials:diode","materials:plastic_sheet"},
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
	output="exatec:tube_detector 2",
	recipe={
		{"exatec:tube","exatec:button","materials:diode"},
	},
})

minetest.register_craft({
	output="exatec:tube_gate 2",
	recipe={
		{"exatec:tube","exatec:wire","materials:diode"},
	},
})

minetest.register_craft({
	output="exatec:tube_filter 5",
	recipe={
		{"materials:diode","exatec:tube","materials:diode"},
		{"exatec:tube","exatec:tube","exatec:tube"},
		{"materials:diode","exatec:tube","materials:diode"},
	},
})

minetest.register_craft({
	output="exatec:button",
	recipe={
		{"group:wood","exatec:wire","materials:diode"},
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
		{"materials:plastic_sheet","materials:diode","materials:plastic_sheet"},
		{"materials:plastic_sheet","materials:gear_metal","materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output="exatec:counter",
	recipe={
		{"default:copper_ingot","materials:diode","exatec:wire"},
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
minetest.register_craft({
	output="exatec:toggleable_storage",
	recipe={
		{"default:chest","exatec:wire","materials:diode"},
	},
})

minetest.register_craft({
	output="exatec:wire_gate",
	recipe={
		{"exatec:tube","exatec:wire","materials:diode"},
		{"group:wood","group:wood","group:wood"},
	},
})

minetest.register_craft({
	output="exatec:vacuum",
	recipe={
		{"default:chest","materials:tube_metal","exatec:wire"},
		{"materials:plastic_sheet","materials:diode","materials:plastic_sheet"},
		{"materials:plastic_sheet","materials:fanblade_plastic","materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output="exatec:object_detector",
	recipe={
		{"default:copper_ingot","exatec:vacuum","exatec:wire"},
		{"default:stone","materials:diode","default:stone"},
		{"default:stone","materials:gear_metal","default:stone"},
	},
})

minetest.register_craft({
	output="exatec:nodeswitch",
	recipe={
		{"default:bronze_ingot","materials:gear_metal","exatec:wire"},
		{"materials:plastic_sheet","materials:diode","materials:plastic_sheet"},
		{"materials:plastic_sheet","default:diamond","materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output="exatec:node_breaker",
	recipe={
		{"exatec:tube","materials:sawblade","exatec:wire"},
		{"default:iron_ingot","materials:tube_metal","default:iron_ingot"},
		{"default:iron_ingot","materials:gear_metal","default:iron_ingot"},
	},
})

minetest.register_craft({
	output="exatec:placer",
	recipe={
		{"materials:diode","exatec:tube_detector","exatec:wire"},
		{"default:iron_ingot","materials:tube_metal","default:iron_ingot"},
		{"default:iron_ingot","materials:gear_metal","default:iron_ingot"},
	},
})
