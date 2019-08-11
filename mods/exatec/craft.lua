minetest.register_craft({
	output="exatec:autocrafter",
	recipe={
		{"default:iron_ingot","default:steel_ingot","default:iron_ingot"},
		{"group:wood","default:copper_ingot","group:wood"},
		{"group:wood","group:stick","group:wood"},
	},
})