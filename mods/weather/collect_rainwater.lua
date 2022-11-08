weather.while_rain=function(pos)
	for i, w in pairs(weather.currweather) do
		if vector.distance(pos,w.pos) <= w.size and w.bio == 1 then
			return true,w.strength
		end
	end
	return false
end

minetest.register_node("weather:woodenbarrel", {
	description = "Wooden barrel (collect rainwater)",
	tiles={"default_wood.png","default_wood.png","default_wood.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,collect_rainwater=1},
	sounds = default.node_sound_wood_defaults(),
	manual_page="weather:woodenbarrel weather:woodenbarrel2 default:bucket default:bucket_with_water_source This barrel will be filled with rainwater during rain.\nMake sure it is under the sky.\nYou can take and add the water to it with a bucket\nWater that players can drink from or fill bottles.",
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
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(30)
	end,
	on_timer = function (pos, elapsed)
		if minetest.get_node_light(pos,0.5) == 15 and weather.while_rain(pos) then
			local c = minetest.raycast(pos,vector.new(pos.x,pos.y+150,pos.z))
			local n = c:next()
			while n do
				if n and n.type == "node" then
					return true
				end
				n = c:next()
			end
			minetest.set_node(pos,{name="weather:woodenbarrel2"})
		else
			return true
		end
	end,
	on_bucket_add=function(pos,itemstack, user)
		if itemstack:get_name() == "default:bucket_with_water_source" then
			minetest.set_node(pos,{name="weather:woodenbarrel2"})
			return ItemStack("default:bucket")
		end
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
	},
	on_bucket=function(pos,itemstack, user)
		if itemstack:get_name() == "default:bucket" then
			minetest.set_node(pos,{name="weather:woodenbarrel"})
			return ItemStack("default:bucket_with_water_source")
		end
	end,
})

minetest.register_tool("weather:umbrella", {
	description = "Umbrella (stop the weather)",
	inventory_image = "weather_umbrella.png",
	manual_page="weather:umbrella Stop the weather",
	on_use=function(itemstack, user, pointed_thing)
		local stops
		local pos=user:get_pos()
		for i, w in pairs(weather.currweather) do
			if vector.distance(w.pos,pos)<w.size and pos.y>-20 and pos.y<120 then
				stops = true
				weather.currweather[i]=nil
			end
		end
		if stops then
			itemstack:add_wear(600)
		end
		return itemstack
	end
})

minetest.register_craft({
	output="weather:woodenbarrel",
	recipe={
		{"group:wood","","group:wood"},
		{"group:wood","","group:wood"},
		{"group:wood","group:wood","group:wood"},
	},
})

minetest.register_craft({
	output="weather:umbrella",
	recipe={
		{"default:gold_ingot","default:gold_ingot","default:gold_ingot"},
		{"","default:gold_ingot",""},
		{"","default:gold_ingot",""},
	},
})