minetest.register_craft({
	output="exatec:list",
	recipe={
		{"default:paper","exatec:wire",""},
	},
})

minetest.register_craft({
	output="exatec:trader",
	recipe={
		{"materials:diode","player_style:coin","materials:diode"},
		{"player_style:coin","default:goldblock","player_style:coin"},
		{"materials:plastic_sheet","player_style:coin","materials:plastic_sheet"},
	},
})

minetest.register_craft({
	output="exatec:industrial_miner",
	recipe={
		{"materials:diode","default:cloud","default:gold_ingot"},
		{"materials:plastic_sheet","default:copperblock","materials:plastic_sheet"},
		{"materials:plastic_sheet","default:steelblock","materials:plastic_sheet"},
	},
})

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
	output="exatec:tube 8",
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
	output="exatec:tube_dir",
	recipe={
		{"","materials:diode",""},
		{"","exatec:tube",""},
		{"","materials:fanblade_plastic",""},
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
	output="exatec:datawire 20",
	recipe={
		{"materials:plastic_sheet","materials:plastic_sheet","materials:plastic_sheet"},
		{"materials:plastic_sheet","materials:diode","materials:plastic_sheet"},
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
		{"default:tin_ingot","exatec:wire","materials:diode"},
		{"group:wood","group:wood","group:wood"},
	},
})

minetest.register_craft({
	output="exatec:wire_gate_toggleable",
	recipe={
		{"materials:diode","exatec:wire_gate","materials:diode"},
	},
})

minetest.register_craft({
	output="exatec:vacuum",
	recipe={
		{"default:chest","materials:tube_metal","exatec:wire"},
		{"materials:plastic_sheet","materials:diode","materials:plastic_sheet"},
		{"materials:plastic_sheet","materials:fanblade_metal","materials:plastic_sheet"},
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

minetest.register_craft({
	output="exatec:light_detector",
	recipe={
		{"materials:diode","exatec:tube_detector","exatec:wire"},
		{"default:glass_tabletop","materials:plant_extracts_gas","default:tin_ingot"},
		{"default:glass_tabletop","materials:plastic_sheet","default:glass_tabletop"},
	},
})
minetest.register_craft({
	output="exatec:destroyer",
	recipe={
		{"exatec:tube","materials:tube_metal","default:obsidian"},
		{"default:glass_tabletop","default:bucket_with_lava_source","default:tin_ingot"},
		{"default:glass_tabletop","materials:plastic_sheet","default:glass_tabletop"},
	},
})

minetest.register_craft({
	output="exatec:node_detector",
	recipe={
		{"default:tin_ingot","exatec:wire","materials:diode"},
		{"group:wood","default:iron_ingot","group:wood"},
		{"group:wood","exatec:wire_gate","group:wood"},
	},
})

minetest.register_craft({
	output="exatec:wire_dir_gate",
	recipe={
		{"materials:diode","exatec:wire","materials:diode"},
		{"","exatec:wire",""},
	},
})

minetest.register_craft({
	output="exatec:node_detector",
	recipe={
		{"default:tin_ingot","exatec:wire","materials:diode"},
		{"group:wood","default:iron_ingot","group:wood"},
		{"group:wood","exatec:wire_gate","group:wood"},
	},
})

minetest.register_craft({
	output="exatec:bow",
	recipe={
		{"default:bow_iron","exatec:datawire","materials:diode"},
		{"group:wood","default:iron_ingot","group:wood"},
		{"group:wood","exatec:wire_gate","group:wood"},
	},
})

minetest.register_craft({
	output="exatec:pcb",
	recipe={
		{"materials:diode","exatec:datawire","materials:diode"},
		{"default:copper_ingot","default:iron_ingot","materials:gear_metal"},
		{"materials:diode","materials:plastic_sheet","materials:diode"},
	},
})

minetest.register_craft({
	output="exatec:node_constructor",
	recipe={
		{"exatec:node_breaker","exatec:datawire","materials:diode"},
		{"default:quantumblock","exatec:pcb","default:uraniumactive_ingot"},
		{"default:steel_ingot","materials:plastic_sheet","default:steel_ingot"},
	},
})

minetest.register_craft({
	output="exatec:cmd",
	recipe={
		{"exatec:wire","materials:plastic_sheet","exatec:wire"},
		{"materials:plastic_sheet","exatec:pcb","materials:plastic_sheet"},
		{"exatec:datawire","materials:plastic_sheet","exatec:datawire"},
	},
})
minetest.register_craft({
	output="exatec:weather_detector",
	recipe={
		{"exatec:wire","materials:plastic_sheet","exatec:datawire"},
		{"default:glass","exatec:pcb","default:glass"},
		{"default:glass","default:copper_ingot","default:glass"},
	},
})
