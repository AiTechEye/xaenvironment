weather.while_rain=function(pos)
	for i, w in pairs(weather.currweather) do
		if vector.distance(pos,w.pos) <= w.size and w.bio == 1 then
			minetest.registered_nodes[minetest.get_node(pos).name].on_rain(pos)
		end
	end

end

minetest.register_lbm({
	name="weather:collect_rainwater",
	nodenames={"group:collect_rainwater"},
	run_at_every_load = true,
	action=function(pos,node)
		weather.while_rain(pos)
	end
})

minetest.register_node("weather:woodenbarrel", {
	description = "Wooden barrel (collect rainwater)",
	tiles={"default_wood.png","default_wood.png","default_wood.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,collect_rainwater=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{0.4375, -0.4375, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.4375, -0.5, -0.4375, 0.5, 0.5},
			{-0.5, -0.4375, 0.4375, 0.5, 0.5, 0.5},
			{-0.5, -0.4375, -0.5, 0.5, 0.5, -0.4375},
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
		}
	},
	on_rain=function(pos)
		minetest.set_node(pos,{name="weather:woodenbarrel2"})
	end,
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(30)
	end,
	on_timer = function (pos, elapsed)
		weather.while_rain(pos)
	end,
})

minetest.register_node("weather:woodenbarrel2", {
	description = "Wooden barrel (collect rainwater)",
	drop="weather:woodenbarrel",
	tiles={"default_wood.png^(default_water.png^weather_frame.png^[makealpha:0,255,0)","default_wood.png","default_wood.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,drinkable=1,not_in_creative_inventory=1},
	sounds = default.node_sound_wood_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{0.4375, -0.4375, -0.5, 0.5, 0.5, 0.5},
			{-0.5, -0.4375, -0.5, -0.4375, 0.5, 0.5},
			{-0.5, -0.4375, 0.4375, 0.5, 0.5, 0.5},
			{-0.5, -0.4375, -0.5, 0.5, 0.5, -0.4375},
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			{-0.5, -0.5, -0.5, 0.5, 0.2, 0.5},
		}
	}
})

minetest.register_craft({
	output="weather:woodenbarrel",
	recipe={
		{"group:wood","","group:wood"},
		{"group:wood","","group:wood"},
		{"group:wood","group:wood","group:wood"},
	},
})