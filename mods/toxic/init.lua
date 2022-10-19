toxic = {
	radia = 20,
	groups = {"air","group:water","group:dirt","group:plant","group:leaves","group:tree","group:stair","group:wood","group:door","group:chair","group:fence"},
	group = {"dirt","water","plant","leaves","tree","stair","wood","door","chair","fence"},
	random_items = {"toxic:barrel","toxic:bottle","plants:pebble_crystal10","plants:pebble_crystal12","plants:pebble_crystal14","plants:pebble_crystal15"},
	nodes = {
		dirt="toxic:dirt",
		plant="toxic:toxic_plant",
		leaves="toxic:toxic_leaves",
		tree="toxic:toxic_tree",
		stair="toxic:toxic_stair",
		wood="toxic:toxic_wood",
		chair="toxic:toxic_wood_chair",
		fence="toxic:toxic_wood_fence",
		door="toxic:toxic_wood_door",
		water="toxic:water_source",
	}
}

minetest.register_craft({
	output="default:uraniumactive_ingot",
	recipe={
		{"toxic:barrel"},
	},
})

default.register_fence({
	name = "chain",
	texture = "examobs_barbed_wire.png",
	sounds = default.node_sound_metal_defaults(),
	groups = {choppy=0,cracky=1,flammable=0,fence=0},
	use_texture_alpha = "clip",
	connects_to = {"group:cracky"},
	damage_per_second = 4,
	node_box = {
		type = "connected",
		connect_front={{-0.0625, -0.5, -0.5, 0.0625, 0.5, 0.0625}},
		connect_back={{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.5}},
		connect_right={{-0.0625, -0.5, -0.0625, 0.5, 0.5, 0.0625}},
		connect_left={{-0.5, -0.5, -0.0625, 0.0625, 0.5, 0.0625}},
		fixed = {-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
	},
	craft={
		{"group:metalstick","group:metalstick","group:metalstick"},
		{"group:metalstick","materials:gear_metal","group:metalstick"}
	}
})

minetest.register_node("toxic:barbed_wire", {
	description = "Barbed wire",
	tiles = {"examobs_barbed_wire.png"},
	use_texture_alpha = "clip",
	paramtype = "light",
	drawtype = "firelike",
	sunlight_propagates=true,
	walkable = false,
	groups = {cracky=1,level=1},
	sounds=default.node_sound_metal_defaults(),
	damage_per_second = 5,
})

bows.register_arrow("arrow",{
	description="Botulinumtoxin (extremely toxic)",
	texture="toxic_bottle.png",
	damage=1100,
	craft_count=4,
	groups =  {store=400,treasure=3},
	craft={{"group:tip","group:stick","toxic:bottle"}},
	on_hit_object=function(self,target,hp,user,lastpos)
		bows.arrow_remove(self)
	end,

})

minetest.register_node("toxic:bottle", {
	description = "Botulinumtoxin bottle",
	drawtype = "mesh",
	mesh = "toxic_bottle.obj",
	visual_scale = 1.0,
	inventory_image = "toxic_bottleinv.png",
	wield_image = "toxic_bottleinv.png",
	wield_scale = {x=1, y=1, z=1},
	use_texture_alpha = "blend",
	tiles = {"toxic_bottle.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	light_source=4,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.1, 0.2, 0.10, 0.1}
	},
	groups = {dig_immediate = 3,coin=500},
	sounds = default.node_sound_glass_defaults(),
})

toxic.node_sound_plate=function(a)
	a = a or {}
	a.dig =		a.dig or {name = "toxic_punch", gain = 1}
	a.dug =		a.dug or {name = "toxic_punch", gain = 1}
	a.place =		a.place or {name = "default_metal_place", gain = 1}
	return default.node_sound_stone_defaults(a)
end

minetest.register_node("toxic:barrel", {
	description = "Toxic barrel",
	drawtype = "mesh",
	mesh = "toxic_barrel.obj",
	drop = "toxic:barrel",
	wield_scale = {x=1, y=1, z=1},
	use_texture_alpha = "clip",
selection_box = {
		type = "fixed",
		fixed = {-0.4, -0.5, -0.4, 0.4,  0.9, 0.4}
	},
collision_box = {
		type = "fixed",
		fixed = {{-0.4, -0.5, -0.4, 0.4,  0.9, 0.4},}},
	tiles = {"toxic_barrel1.png"},
	groups = {barrel=1,cracky = 1, level = 2}, --, not_in_creative_inventory=0
	sounds = toxic.node_sound_plate(),
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	--on_punch = function(pos, node, puncher, pointed_thing)
	--end,
})

default.register_tree({
	name="toxic",
	mapgen = false,
	chair = {groups={toxic_spreading=1,choppy = 2, oddly_breakable_by_hand = 2,chair=1,used_by_npc=1}},
	door = {groups={toxic_spreading=1,choppy = 2, oddly_breakable_by_hand = 2,door=1}},
	fence = {groups={toxic_spreading=1}},
	stair = {groups={toxic_spreading=1,stair=1,choppy=3,flammable=2}},
	tree={tiles={"plants_apple_tree_top.png^[colorize:#7c775055","plants_apple_tree_top.png^[colorize:#7c775055","plants_apple_tree.png^[colorize:#7c775055"},groups={tree=1,choppy=2,flammable=3,toxic_spreading=1}},
	wood={tiles={"default_wood.png^[colorize:#7c775055"},groups={wood=1,choppy=2,flammable=3,toxic_spreading=1}},
	leaves={
		tiles={"default_stick.png^[colorize:#7c775055"},
		use_texture_alpha = "clip",
		groups={leaves=1,snappy=3,leafdecay=5,flammable=2,toxic_spreading=1},
		drawtype = "plantlike",
	},
	schematic = false,
	sapling={on_timer=function(pos, elapsed)
		minetest.set_node(pos, {name = "toxic:toxic_plant"})
		end
	}
})

default.register_plant({
	name="toxic_plant",
	decoration = false,
	tiles={"plants_dry_plant.png^[colorize:#7c775055"},
	groups={dig_immediate=3,toxic_spreading=1},
})

minetest.register_node("toxic:snowblock_thin", {
	description = "Thin snowblock",
	tiles={"default_snow.png^[colorize:#7c775011"},
	groups = {snowy=1,crumbly=3,cools_lava=1,toxic_spreading=1},
	sounds = default.node_sound_snow_defaults(),
	walkable=false,
	drowning = 1,
	drawtype = "glasslike",
	buildable_to=true,
	pointable = false,
	diggable = false,
	liquid_viscosity = 20,
	post_effect_color = {a = 255, r = 150, g = 150, b = 90},
	damage_per_second = 1,
})

minetest.register_node("toxic:water_source", {
	description = "Toxic water Source",
	drawtype = "liquid",
	tiles = {name = "default_water.png^[colorize:#7c7750cc",},
	tiles = {
		{
		name = "default_water.png^[colorize:#7c7750cc",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 2.0,
		},
	},},
	use_texture_alpha = "blend",
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "source",
	liquid_alternative_flowing = "toxic:water_flowing",
	liquid_alternative_source = "toxic:water_source",
	liquid_viscosity = 3,
	damage_per_second = 1,
	post_effect_color = {a = 220, r = 150, g = 150, b = 90},
	sounds = default.node_sound_water_defaults(),
	groups = {liquid = 3, puts_out_fire = 1,not_in_creative_inventory=0,toxic_spreading=1},
	
})

minetest.register_node("toxic:water_flowing", {
	description = "Toxic flowing Water",
	drawtype = "flowingliquid",
	tiles = {"default_water.png^[colorize:#7c7750cc"},
	special_tiles = {
		{
		name = "default_water_animated.png^[colorize:#7c7750cc",
		backface_culling = false,
		animation = {type = "vertical_frames",aspect_w = 16,aspect_h = 16,length = 0.8,},
		},{
		name = "default_water_animated.png^[colorize:#7c7750cc",
		backface_culling = true,animation = {type = "vertical_frames",aspect_w = 16,aspect_h = 16,length = 0.8,},
		},},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "flowingliquid",
	walkable = false,
	pointable = false,
	diggable = false, 
	buildable_to = true,
	is_ground_content = false,
	drop = "",
	drowning = 1,
	liquidtype = "flowing",
	liquid_alternative_flowing = "toxic:water_flowing",
	liquid_alternative_source = "toxic:water_source",
	liquid_viscosity = 3,
	damage_per_second = 1,
	sounds = default.node_sound_water_defaults(),
	post_effect_color = {a = 220, r = 150, g = 150, b = 90},
	groups = {liquid = 3, puts_out_fire = 1,not_in_creative_inventory = 1,toxic_spreading=1},
})

minetest.register_node("toxic:dirt", {
	description = "Toxic dirt",
	tiles = {"default_dirt.png^[colorize:#7c775055"},
	groups = {crumbly = 3,toxic_spreading=1},
	sounds = default.node_sound_dirt_defaults(),
})

toxic.spread=function(pos,node,nogen)
	local m = minetest.get_meta(pos)
	local r = m:get_int("t_rad")
	local group = default.def(node.name).groups or {}
	if r > toxic.radia and not (group.tree or group.stair or group.wood or group.door or group.chair or group.fence) then
		return
	end
	local p = minetest.find_nodes_in_area(vector.add(pos, 1),vector.subtract(pos, 1),toxic.groups)
	for i,n in pairs(p) do
		local nn = minetest.get_node(n).name
		if not minetest.is_protected(n, "") then
			for i2,g in ipairs(toxic.group) do
				if nn == "air" then
					minetest.set_node(n, {name = "default:gas"})
					minetest.get_meta(n):set_int("t_rad",r+1)
				elseif nn == "default:dirt_with_snow" or nn == "default:snow" then
					minetest.set_node(n, {name = "toxic:snowblock_thin"})
					minetest.get_meta(n):set_int("t_rad",r+1)
				elseif minetest.get_item_group(nn,g) > 0 and minetest.get_item_group(nn,"toxic_spreading") == 0 then
					minetest.swap_node(n, {name = toxic.nodes[g]})
					minetest.get_meta(n):set_int("t_rad",r+1)
					if g == "dirt" and math.random(0,50) == 0 and default.def(minetest.get_node(apos(n,0,1)).name).buildable_to then
						local start = nogen and 3 or 1
						local rnd = math.random(start,#toxic.random_items)
						local item = toxic.random_items[rnd]
						local param2 = 0
						if rnd == 1 or rnd == 2 then
							param2 = math.random(0,19)
						end
						minetest.set_node(apos(n,0,1), {name = item,param2=param2})
					end
				end
			end
		end
	end
end

minetest.register_abm({
	nodenames = {"group:toxic_spreading"},
	interval = 30,
	chance = 20,
	action=function(pos,node)
		toxic.spread(pos,node,true)
	end
})

lakes.registry_lake("toxic lake",{
	spawn_in = "default:dirt_with_grass",
	chance = 50,
	min_y = -50,
	max_y = 50,
	radius = math.random(5,20),
	source = "toxic:water_source",
	in_nodes = {
		"default:dirt",
		"default:dirt_with_grass",
		"default:sand",
		"default:water_source",
	},
	after_generate=function(pos)
		local n = minetest.find_nodes_in_area(vector.add(pos, 10),vector.subtract(pos, 10),toxic.groups)

		for i,p in pairs(n) do
			local a = minetest.get_node(p)

			if a.name ~= "default:gas" and a.name ~= "air" then
				toxic.spread(p,a,false)
			end
		end

		n = minetest.find_nodes_in_area(vector.add(pos, 10),vector.subtract(pos, 10),{"toxic:water_source"})

		for i,p in pairs(n) do
			local node = minetest.get_node(apos(p,0,-1)).name
			if math.random(0,30) == 0 and (minetest.get_item_group(node,"stone") > 0 or minetest.get_item_group(node,"sand") > 0) then
				local item = toxic.random_items[math.random(1,2)]
				minetest.set_node(p, {name = item,param2=math.random(0,19)})
			elseif node == "default:coal_ore" then
				minetest.set_node(apos(p,0,-1), {name = "default:uranium_ore"})


			end
		end

		local set = {}
		local r = toxic.radia*math.random(1,4)
		for x =-r,r do
		for z =-r,r do
			local p = z.." "..x
			if (math.abs(x) == r or math.abs(z) == r) and not set[p] then
				for y = r,-r,-1 do
					local g5 = default.def(minetest.get_node(apos(pos,x,y+5,z)).name).groups or {}
					if not default.def(minetest.get_node(apos(pos,x,y,z)).name).buildable_to
					and (default.def(minetest.get_node(apos(pos,x,y+1,z)).name).buildable_to and g5.water == nil) then
						minetest.set_node(apos(pos,x,y+1,z), {name = "toxic:chain_fence"})
						minetest.set_node(apos(pos,x,y+2,z), {name = "toxic:chain_fence"})
						minetest.set_node(apos(pos,x,y+3,z), {name = "toxic:chain_fence"})
						minetest.set_node(apos(pos,x,y+4,z), {name = "toxic:chain_fence"})
						minetest.set_node(apos(pos,x,y+5,z), {name = "toxic:barbed_wire"})
						set[p] = true
						for i=0,20 do
							local pp = apos(pos,x,y-i,z)
							if minetest.get_item_group(minetest.get_node(pp).name,"stone") > 0 then
								break
							end
							minetest.set_node(pp, {name = "materials:concrete"})
						end
					end
				end
			end
		end
		end
	end
})

lakes.registry_lake("toxic ice lake",{
	spawn_in = "default:dirt_with_snow",
	chance = 50,
	min_y = -50,
	max_y = 50,
	radius = math.random(5,20),
	source = "toxic:water_source",
	in_nodes = {
		"default:dirt",
		"default:dirt_with_snow",
		"default:sand",
		"default:water_source",
		"default:snow",
		"default:ice",
	},
	after_generate=function(pos)
		local set = {}
		local r = toxic.radia*math.random(1,4)
		for x =-r,r do
		for z =-r,r do
			local p = z.." "..x
			if (math.abs(x) == r or math.abs(z) == r) and not set[p] then
				for y = r,-r,-1 do
					local g5 = default.def(minetest.get_node(apos(pos,x,y+5,z)).name).groups or {}
					if not default.def(minetest.get_node(apos(pos,x,y,z)).name).buildable_to
					and (default.def(minetest.get_node(apos(pos,x,y+1,z)).name).buildable_to and g5.water == nil) then
						minetest.set_node(apos(pos,x,y+1,z), {name = "toxic:chain_fence"})
						minetest.set_node(apos(pos,x,y+2,z), {name = "toxic:chain_fence"})
						minetest.set_node(apos(pos,x,y+3,z), {name = "toxic:chain_fence"})
						minetest.set_node(apos(pos,x,y+4,z), {name = "toxic:chain_fence"})
						minetest.set_node(apos(pos,x,y+5,z), {name = "toxic:barbed_wire"})
						set[p] = true
						for i=0,20 do
							local pp = apos(pos,x,y-i,z)
							if minetest.get_item_group(minetest.get_node(pp).name,"stone") > 0 then
								break
							end
							minetest.set_node(pp, {name = "materials:concrete"})
						end
					end
				end
			end
		end
		end

		for x =-20,20 do
		for y =-20,20 do
		for z =-20,20 do
			if minetest.get_node(apos(pos,x,y,z)).name == "toxic:water_source"
			and minetest.get_node(apos(pos,x,y+1,z)).name == "air" then
				minetest.set_node(apos(pos,x,y,z), {name = "default:ice"})
			end
		end
		end
		end
	end
})

examobs.register_mob({
	description = "The toxic spider shoots barbed wires catch you\nThis mob is also explosive.",
	name = "toxic_spider",
	team = "toxic",
	type = "monster",
	hp = 40,
	coin = 4,
	breathing = 0,
	swiming = 0,
	textures = {"default_dirt.png^[colorize:#7c775055"},
	mesh = "examobs_spider.b3d",
	aggressivity = 2,
	animation = {
		stand={x=1,y=2,speed=0,loop=false},
		walk={x=1,y=20,speed=30},
	},
	inv={["default:steel_ingot"]=4,["default:iron_ingot"]=2,["nitroglycerin:c4"]=1},
	collisionbox={-0.5,-0.5,-0.5,0.5,0.5,0.5},
	spawn_on={"group:toxic_spreading"},
	max_spawn_y = -50,
	resist_nodes = {["examobs:barbed_wire"]=1},
	floating = {["examobs:barbed_wire"]=1},
	step=function(self,time)
		if self.fight then
			self.am = (self.am or 0) -0.1
			if self.am <= 0 then
				local pos2 = self.fight:get_pos()
				if pos2 and pos2.x then
					examobs.shoot_arrow(self,pos2,"examobs:arrow_barbed_wire")
				end
				self.am = math.random(1,5) * 0.1
			end
		end
	end,
	death=function(self)
		if not self.ex then
			self.ex = 1
			nitroglycerin.explode(self:pos(),{radius=5,set="fire:basic_flame",})
			self.object:remove()
		end
	end,
	use_bow=function(pos1,pos2,arrow)
		if not (pos2 and pos2.x and pos1 and pos1.x) then
			return
		end
		local d=math.floor(vector.distance(pos1,pos2)+0.5)
		local dir = {x=(pos1.x-pos2.x)/-d,y=((pos1.y-pos2.y)/-d)+(d*0.005),z=(pos1.z-pos2.z)/-d}
		local user = {
			get_look_dir=function()
				return dir
			end,
			punch=function()
			end,
			get_pos=function()
				return pos1
			end,
			set_pos=function(pos)
				return self.object:set_pos(pos)
			end,
			get_player_control=function()
				return {}
			end,
			get_look_horizontal=function()
				return self.object:get_yaw() or 0
			end,
			get_player_name=function()
				return self.examob ..""
			end,
			is_player=function()
				return true
			end,
			examob=self.examob,
			object=self.object,
		}
		local item = ItemStack({
			name="default:bow_wood_loaded",
			metadata=minetest.serialize({arrow=arrow,shots=1})
		})
		bows.shoot(item, user,nil,function(item)
			item:remove()
		end)
	end
})

examobs.register_mob({
	description = "A bunch of toxic mud",
	name = "toxicmonster",
	textures = {"toxic_monster.png"},
	mesh = "examobs_stonemonster.b3d",
	type = "monster",
	team = "toxic",
	dmg = 5,
	hp = 40,
	coin = 6,
	swiming = 0,
	breathing = 0,
	aggressivity = 2,
	run_speed = 10,
	light_min = 1,
	light_max = 14,
	visual_size = {x=0.5,y=0.75,z=0.5},
	inv={["toxic:dirt"]=2,["default:iron_lump"]=1},
	bottom=-1,
	animation = {
		stand = {x=1,y=10,speed=0},
		walk = {x=11,y=30,speed=15},
		run = {x=31,y=51,speed=60},
		lay = {x=69,y=70,speed=0},
		attack = {x=53,y=66},
	},
	collisionbox={-0.6,-1.2,-0.6,0.6,1,0.6,},
	spawn_on={"group:toxic_spreading"},
})