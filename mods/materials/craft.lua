minetest.register_craft({
	output="materials:concrete_stair 3",
	recipe={
		{"","materials:concrete"},
		{"materials:concrete","materials:concrete"}
	},
})

minetest.register_craft({
	type = "cooking",
	output = "materials:concrete",
	recipe = "default:clay_lump",
	cooktime = 5,
})

minetest.register_craft({
	output="materials:wood_table_corner_leg1",
	recipe={
		{"group:wood","group:wood","group:wood"},
		{"group:wood","","group:wood"},
		{"group:wood","","group:wood"},
	},
})
minetest.register_craft({
	output="materials:wood_table_center_leg",
	recipe={
		{"materials:wood_table_corner_leg1"},
	},
})
minetest.register_craft({
	output="materials:wood_table",
	recipe={
		{"materials:wood_table_center_leg"},
	},
})
minetest.register_craft({
	output="materials:wood_table_corner_leg1",
	recipe={
		{"materials:wood_table"},
	},
})

minetest.register_craft({
	output="materials:cup 6",
	recipe={
		{"default:clay_lump","default:clay_lump",""},
		{"default:clay_lump","default:clay_lump",""},
		{"default:clay_lump","default:clay_lump",""},
	},
})
minetest.register_craft({
	output="materials:cup_plate 2",
	recipe={
		{"default:clay_lump","default:clay_lump",""},
	},
})
minetest.register_craft({
	output="materials:cup_on_plate",
	recipe={
		{"materials:cup","",""},
		{"materials:cup_plate","",""},
	},
})
minetest.register_craft({
	output="materials:plate 3",
	recipe={
		{"default:clay_lump","default:clay_lump","default:clay_lump"},
	},
})

minetest.register_craft({
	output="materials:pallet_box",
	recipe={
		{"group:stick","","group:stick"},
		{"","group:stick",""},
		{"group:stick","","group:stick"},
	},
})
minetest.register_craft({
	output="materials:firethrower",
	recipe={
		{"materials:tube_metal","materials:tube_metal","default:tankstorage"},
		{"default:torch","default:carbon_ingot","default:iron_ingot"},
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