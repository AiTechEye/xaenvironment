minetest.register_node("fire:basic_flame", {
	description = "Fire",
	tiles={"fire_basic_flame.png"},
	groups = {dig_immediate=3,fire=1,igniter=2,not_in_creative_inventory=1},
	sounds = default.node_sound_defaults(),
	drawtype = "firelike",
	paramtype = "light",
	sunlight_propagetes = true,
	walkable = false,
	light_source = 13,
	buildable_to =true,
	floodable = true,
	damage_per_second = 5,
	drop = "",
--[[ adding this later
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1
			},
		},
	},
--]]

})

minetest.register_node("fire:not_igniter", {
	description = "Fire (not igniter)",
	tiles={"fire_basic_flame.png"},
	groups = {fire=1,dig_immediate=3,not_in_creative_inventory=1},
	sounds = default.node_sound_defaults(),
	drawtype = "firelike",
	paramtype = "light",
	sunlight_propagetes = true,
	walkable = false,
	light_source = 13,
	buildable_to =true,
	floodable = true,
	damage_per_second = 5,
	drop = "",
})

minetest.register_abm({
	nodenames = {"group:fire"},
	interval = 1,
	chance = 20,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.remove_node(pos)
	end,
})