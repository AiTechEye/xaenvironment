minetest.register_craft({
	output="materials:pallet_box",
	recipe={
		{"group:stick","","group:stick"},
		{"","group:stick",""},
		{"group:stick","","group:stick"},
	},
})

minetest.register_craft({
	output="materials:metal_beam 8",
	recipe={
		{"default:ironblock","default:ironblock"},
	},
})

minetest.register_craft({
	type = "cooking",
	output = "materials:metal_beam_rusty",
	recipe = "materials:metal_beam",
	cooktime = 20,
})

minetest.register_craft({
	output="materials:piece_of_cloth",
	recipe={
		{"plants:cotton","plants:cotton","plants:cotton"},
		{"plants:cotton","plants:cotton","plants:cotton"},
		{"plants:cotton","plants:cotton","plants:cotton"},
	},
})

minetest.register_craft({
	output="materials:plant_extracts",
	recipe={
		{"group:leaves","group:leaves","group:leaves"},
		{"group:leaves","group:leaves","group:leaves"},
	},
})
minetest.register_craft({
	type = "cooking",
	output = "materials:plant_extracts_gas",
	recipe = "materials:plant_extracts",
	cooktime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "materials:plant_extracts_gas",
	burntime = 10,
})
minetest.register_craft({
	output="materials:piece_of_wood 8",
	recipe={{"group:wood","group:wood"}},
})

minetest.register_craft({
	output="materials:mixed_wood",
	recipe={
		{"group:stick","group:stick","group:stick"},
		{"group:stick","group:stick","group:stick"},
		{"group:stick","group:stick","group:stick"},
	},
})
