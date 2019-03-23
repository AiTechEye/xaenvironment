
minetest.register_craftitem("default:stick", {
	description = "Wooden stick",
	inventory_image = "default_stick.png",
	groups = {flammable = 1,stick=1},
})
minetest.register_craftitem("default:flint", {
	description = "Flint",
	inventory_image = "default_flint.png",
	groups = {flint=1},
})

--||||||||||||||||
-- ======================= Ingots
--||||||||||||||||

minetest.register_craftitem("default:uraniumactive_ingot", {
	description = "Active uranium",
	inventory_image = "default_ingot_uraniumactive.png",
	groups = {metal=1},
})

minetest.register_craftitem("default:copper_ingot", {
	description = "Copper",
	inventory_image = "default_ingot_copper.png",
	groups = {metal=1},
})
minetest.register_craftitem("default:bronze_ingot", {
	description = "Bronze",
	inventory_image = "default_ingot_bronze.png",
	groups = {metal=1},
})

minetest.register_craftitem("default:uranium_ingot", {
	description = "Uranium",
	inventory_image = "default_ingot_uranium.png",
	groups = {metal=1},
})

minetest.register_craftitem("default:gold_ingot", {
	description = "Gold ",
	inventory_image = "default_ingot_gold.png",
	groups = {metal=1},
})

minetest.register_craftitem("default:tin_ingot", {
	description = "Tin",
	inventory_image = "default_ingot_tin.png",
	groups = {metal=1},
})

minetest.register_craftitem("default:iron_ingot", {
	description = "Iron",
	inventory_image = "default_ingot_iron.png",
	groups = {metal=1},
})

minetest.register_craftitem("default:steel_ingot", {
	description = "Steel",
	inventory_image = "default_ingot_steel.png",
	groups = {metal=1},
})

--||||||||||||||||
-- ======================= Lumps
--||||||||||||||||

minetest.register_craftitem("default:tin_lump", {
	description = "Tin lump",
	inventory_image = "default_lump_tin.png",
})

minetest.register_craftitem("default:copper_lump", {
	description = "Copper lump",
	inventory_image = "default_lump_copper.png",
})
minetest.register_craftitem("default:gold_lump", {
	description = "Gold lump",
	inventory_image = "default_lump_gold.png",
})
minetest.register_craftitem("default:iron_lump", {
	description = "Iron lump",
	inventory_image = "default_lump_iron.png",
})
minetest.register_craftitem("default:coal_lump", {
	description = "Coal lump",
	inventory_image = "default_lump_coal.png",
})
minetest.register_craftitem("default:silver_lump", {
	description = "Silver lump",
	inventory_image = "default_lump_silver.png",
})
