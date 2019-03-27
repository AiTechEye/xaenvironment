minetest.register_craft({
	output="air_balloons:balloon",
	recipe={
		{"materials:piece_of_cloth","materials:piece_of_cloth","materials:piece_of_cloth"},
		{"materials:piece_of_cloth","materials:piece_of_cloth","materials:piece_of_cloth"},
		{"group:wood","group:tree","default:furnace"},
	},
})

minetest.register_craft({
	output="air_balloons:gastank_empty",
	recipe={
		{"","default:iron_ingot",""},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	},
})

minetest.register_craft({
	output="air_balloons:gastank",
	recipe={
		{"materials:plant_extracts_gas","materials:plant_extracts_gas","materials:plant_extracts_gas"},
		{"materials:plant_extracts_gas","materials:plant_extracts_gas","materials:plant_extracts_gas"},
		{"","air_balloons:gastank_empty",""},
	},
})

minetest.register_tool("air_balloons:balloon", {
	description = "Air baloon",
	inventory_image = "air_balloons_item.png",
	groups={dig_immediate=3},
	on_place=function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" then
			local en=minetest.add_entity(pointed_thing.above,"air_balloons:balloon"):get_luaentity()
			en.owner = user:get_player_name()
			local data = itemstack:to_table()
			local meta = minetest.deserialize(data.metadata) or {fuel=0}
			en.fuel = meta.fuel or 0
			itemstack:take_item()
		end
		return itemstack	
	end,
})

minetest.register_node("air_balloons:gastank", {
	description = "Air balloon gastank",
	tiles = {"air_balloons_gastank.png"},
	groups={dig_immediate=3},
	drawtype = "mesh",
	mesh = "air_balloons_gastank.obj",
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
		}
	}
})

minetest.register_node("air_balloons:gastank_empty", {
	description = "Air balloon gastank (empty)",
	tiles = {"air_balloons_gastank.png"},
	groups={dig_immediate=3},
	drawtype = "mesh",
	mesh = "air_balloons_gastank.obj",
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25},
		}
	}
})


minetest.register_entity("air_balloons:balloon",{
	hp_max = 20,
	physical = true,
	--weight = 0,
	collisionbox = {-2,-0.5,-2,2,7,2},
	visual = "mesh",
	mesh = "air_balloons.b3d",
	visual_size = {x=1,y=1},
	textures ={"air_balloons_material1.png"},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	--is_visible = true,
	makes_footstep_sound = true,
	on_rightclick=function(self, clicker,name)
		if clicker:is_player() and clicker:get_player_name() == self.owner then

			if clicker:get_wielded_item():get_name() == "air_balloons:gastank" then
				if self.fuel<1000 then
					local i = clicker:get_wield_index()
					local inv = clicker:get_inventory()
					local stack = inv:get_stack("main", i)
					stack:take_item()
					inv:set_stack("main", i,stack)
					inv:add_item("main","air_balloons:gastank_empty")
					self.fuel = self.fuel + 200
					minetest.chat_send_player(self.owner, self.fuel .." fuel")
				end
				return
			end

			if self.user then
				self.user:set_detach()
				self.user = nil
			else
				self.user = clicker
				self.user:set_attach(self.object, "",{x = 0, y = -5, z = 0}, {x = 0, y = 0, z = 0})
			end
			return self
		end
	end,
	on_punch=function(self,puncher)
		if puncher:is_player() and (self.owner == "" or (puncher:get_player_name() == self.owner)) then
			local item = ItemStack("air_balloons:balloon")
			local data = item:to_table()
			data.metadata = minetest.serialize({fuel=self.fuel})
			puncher:get_inventory():add_item("main",data)
			self.object:remove()
			return self
		end
	end,
	anim=function(self,typ)
		if self.an ~= typ then
			self.an = typ
			if typ=="on" then
				self.object:set_animation({x=5,y=10},0,0)
			else
				self.object:set_animation({x=0,y=1},0,0)
			end
		end
	end,
	on_activate=function(self, staticdata)
		self.dir = {x=0,y=0,z=0}
		local s = minetest.deserialize(staticdata) or {}
		if not s.owner then return end
		self.owner = s.owner
		self.fuel = s.fuel
	end,
	get_staticdata = function(self)
		return minetest.serialize({fuel=self.fuel,owner=self.owner})
	end,
	on_step=function(self, dtime)
		self.time=self.time+dtime
		if self.time<self.timer then return self end
		self.time=0

		local p = self.object:get_pos()
		local n = minetest.get_node({x=p.x,y=p.y-0.6,z=p.z}).name
		if self.user then
			local d = self.user:get_look_dir()
			self.dir.x = d.x
			self.dir.z = d.z
			local key = self.user:get_player_control()

			if key.up then
				if self.speed <2 then
					self.speed = self.speed + 0.1
				end
				self.move = true
			end
			if key.jump and self.fuel > 0 then
				if self.dir.y < 1 then
					self.dir.y = self.dir.y + 0.1
					self.anim(self,"on")
					self.rise = true
				end

				self.fuel = self.fuel -1
				minetest.chat_send_player(self.owner, self.fuel .." fuel left")
			elseif key.sneak and n == "air" then
				self.anim(self,"off")
				if self.dir.y > -1 then
					self.dir.y = self.dir.y - 0.1
					self.rise = true
				end
			else
				self.anim(self,"off")
			end
		end

		if not self.move and self.speed > 0.1 then
			self.speed = self.speed * 0.95
			self.rep = true
		end

		if not self.rise and self.dir.y > -0.1 and n == "air" then
			self.dir.y = self.dir.y - 0.1
			self.rep = true
		elseif not self.rise and math.abs(self.dir.y) > 0.1 then
			self.dir.y = self.dir.y*0.95
			self.rep = true
		end
		if not (self.move or self.rise or self.rep) then
			self.speed = 0
			self.dir.y = 0
		end
		self.rep = nil
		self.move = nil
		self.rise = nil

		self.object:set_velocity({
			x=self.dir.x*self.speed,
			y=self.dir.y,
			z=self.dir.z*self.speed,
		})

--not in water
	end,
	time=0,
	timer=0.1,
	fuel=0,
	speed=0,
	owner="",
})