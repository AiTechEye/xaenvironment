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
