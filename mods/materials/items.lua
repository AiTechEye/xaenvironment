minetest.register_craftitem("materials:piece_of_cloth", {
	description = "Piece of cloth",
	inventory_image = "materials_piece_of_cloth.png",
	groups = {cloth=1,flammable = 1},
})

minetest.register_craftitem("materials:plant_extracts", {
	description = "Plant extracts",
	inventory_image = "materials_plant_extracts.png",
	groups = {flammable = 1},
})

minetest.register_craftitem("materials:plant_extracts_gas", {
	description = "Plant extracts gas",
	inventory_image = "materials_plant_extracts_gas.png",
	groups = {flammable = 1},
})

minetest.register_craftitem("materials:piece_of_wood", {
	description = "Piece of wood",
	inventory_image = "materials_piece_of_wood.png",
	groups = {peace_of_wood=1,flammable = 1},
})