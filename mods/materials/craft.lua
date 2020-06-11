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
	output="materials:plant_extracts 4",
	recipe={
		{"group:leaves","group:leaves","group:leaves"},
		{"group:leaves","group:leaves","group:leaves"},
	},
})

minetest.register_craft({
	type = "cooking",
	output = "materials:plastic_sheet",
	recipe = "materials:plant_extracts_gas",
	cooktime = 10,
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
	}
})
minetest.register_craft({
	output="materials:string",
	recipe={{"plants:cotton"}}
})

minetest.register_craft({
	output="materials:glass_bottle 12",
	recipe={
		{"","default:glass",""},
		{"default:glass","","default:glass"},
		{"default:glass","default:glass","default:glass"},
	}
})

minetest.register_craft({
	type = "cooking",
	output = "materials:bread",
	recipe = "plants:flour",
})

minetest.register_craft({
	output="materials:gear_metal 10",
	recipe={
		{"default:iron_ingot","","default:iron_ingot"},
		{"","default:iron_ingot",""},
		{"default:iron_ingot","","default:iron_ingot"},
	}
})

minetest.register_craft({
	output="materials:fanblade_metal 10",
	recipe={
		{"","default:iron_ingot",""},
		{"","default:iron_ingot",""},
		{"default:iron_ingot","","default:iron_ingot"},
	}
})
minetest.register_craft({
	output="materials:fanblade_plastic 10",
	recipe={
		{"","materials:plastic_sheet",""},
		{"","materials:plastic_sheet",""},
		{"materials:plastic_sheet","","materials:plastic_sheet"},
	}
})
minetest.register_craft({
	output="materials:tube_metal 10",
	recipe={
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
		{"","",""},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
	}
})
minetest.register_craft({
	output="materials:diode 20",
	recipe={
		{"materials:plastic_sheet","default:copper_ingot"},
	}
})

minetest.register_craft({
	output="materials:sawblade 3",
	recipe={
		{"default:iron_lump","default:iron_ingot","default:iron_lump"},
		{"default:iron_ingot","default:iron_ingot","default:iron_ingot"},
		{"default:iron_lump","default:iron_ingot","default:iron_lump"},
	}
})

minetest.register_craft({
	output="materials:spaceyfloor 10",
	recipe={
		{"default:steel_lump","default:iron_ingot","default:steel_lump"},
		{"default:iron_ingot","default:steel_ingot","default:iron_ingot"},
		{"default:steel_lump","default:iron_ingot","default:steel_lump"},
	}
})