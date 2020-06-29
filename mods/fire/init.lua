fire = {}
minetest.register_craft({
	output="fire:flint_and_steel",
	recipe={{"default:flint","default:steel_ingot"},},
})
minetest.register_tool("fire:flint_and_steel", {
	description = "Flint and steel",
	inventory_image = "fire_flint_and_steel.png",
	sound=default.tool_breaks_defaults(),
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" and minetest.get_item_group(minetest.get_node(pointed_thing.under).name,"flammable") > 0 and not minetest.is_protected(pointed_thing.above,user:get_player_name()) then
			minetest.set_node(pointed_thing.above,{name="fire:basic_flame"})
			itemstack:add_wear(1000)
		end
		return itemstack
	end,
})

minetest.register_node("fire:basic_flame", {
	description = "Fire",
	tiles={"fire_basic_flame.png"},
	groups = {dig_immediate=3,fire=1,igniter=2,not_in_craftguide=1},
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
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 1
			},
		},
	},
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function (pos, elapsed)
		local m = minetest.get_meta(pos)
		local r = m:get_int("radius")
		local sr
		r = r > 0 and r or 1.5
		for i, ob in ipairs(minetest.get_objects_inside_radius(pos,r)) do
			local p = ob:get_pos()
			p = {x=p.x,y=p.y+0.1,z=p.z}
			if default.def(minetest.get_node(p).name).buildable_to then
				minetest.add_node(p,{name="fire:not_igniter"})
				minetest.get_meta(p):set_int("radius",3)
				minetest.get_node_timer(p):start(0.1)
				sr = true
			end
		end
		if not sr and r > 1.5 then
			minetest.get_meta(pos):set_int("radius",1.5)
			minetest.get_node_timer(pos):start(1)
		end
		return true
	end,
})

minetest.register_node("fire:not_igniter", {
	description = "Fire (not igniter)",
	tiles={"fire_basic_flame.png"},
	groups = {fire=1,dig_immediate=3,igniter=1,not_in_craftguide=1},
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
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 1
			},
		},
	},
	on_construct=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer = function (pos, elapsed)
		local m = minetest.get_meta(pos)
		local r = m:get_int("radius")
		local sr
		r = r > 0 and r or 1.5
		for i, ob in ipairs(minetest.get_objects_inside_radius(pos,r)) do
			local p = ob:get_pos()
			p = {x=p.x,y=p.y+0.1,z=p.z}
			if default.def(minetest.get_node(p).name).buildable_to then
				minetest.add_node(p,{name="fire:not_igniter"})
				minetest.get_meta(p):set_int("radius",3)
				minetest.get_node_timer(p):start(0.1)
				sr = true
			end
		end
		if not sr and r > 1.5 then
			minetest.get_meta(pos):set_int("radius",1.5)
			minetest.get_node_timer(pos):start(1)
		end
		return true
	end,
})

minetest.register_node("fire:permanent_flame", {
	description = "Permanent fire",
	tiles={"fire_basic_flame.png"},
	groups = {dig_immediate=3,igniter=2,not_in_craftguide=1},
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
	tiles = {
		{
			name = "fire_basic_flame_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 1
			},
		},
	},
})

minetest.register_abm({
	nodenames = {"group:fire"},
	interval = 1,
	chance = 20,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if minetest.get_item_group(node.name,"igniter") > 1 and #minetest.find_nodes_in_area(vector.add(pos,1),vector.subtract(pos,1),{"group:flammable"}) > 0 then
			return
		end
		minetest.remove_node(pos)
	end,
})

minetest.register_abm({
	nodenames = {"group:igniter"},
	interval = 1,
	chance = 20,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local ig = minetest.get_item_group(node.name,"igniter")
		if ig == 1 then
			return
		elseif ig == 2 then
			local flam = minetest.find_nodes_in_area(vector.add(pos,1),vector.subtract(pos,1),{"group:flammable"})
			for _, np in pairs(flam) do
				local ndef = minetest.registered_nodes[minetest.get_node(np).name]
				if math.random(1,3) == 1 then
					if not (ndef.on_burn and ndef.on_burn(np)) then
						minetest.set_node(np,{name="fire:not_igniter"})
					end
				else
					if not (ndef.on_ignite and ndef.on_ignite(np)) then
						local npp = minetest.find_node_near(np,1.5,{"air"})
						if npp and npp.x then
							minetest.set_node(npp,{name="fire:not_igniter"})
						end
					end
				end
			end
		elseif node.name ~= "air" then
			local flam = minetest.find_nodes_in_area(vector.add(pos,2),vector.subtract(pos,2),{"group:flammable"})
			for _, np in pairs(flam) do
				local ndef = minetest.registered_nodes[minetest.get_node(np).name]
				if math.random(1,2) == 1 then
					if not (ndef.on_burn and ndef.on_burn(np)) then
						minetest.set_node(np,{name="fire:basic_flame"})
					end
				else
					if not (ndef.on_ignite and ndef.on_ignite(np)) then
						local npp = minetest.find_node_near(np,1,"air")
						if npp and npp.x then
							minetest.set_node(npp,{name="fire:basic_flame"})
						end
					end
				end
			end
		end
	end
})