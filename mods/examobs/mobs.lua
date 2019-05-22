-- npc monster animal

examobs.register_mob({
	name = "wolf",
	textures = {"examobs_wolf.png"},
	mesh = "examobs_wolf.b3d",
	dmg = 2,
	aggressivity = 1,
	run_speed = 8,
	inv={["examobs:flesh"]=1,["examobs:pelt"]=1,["examobs:tooth"]=1},
	punch_chance=3,
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		run = {x=32,y=52,speed=60},
		lay = {x=66,y=75},
		attack = {x=53,y=65},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
	spawn_on={"default:dirt_with_snow","default:dirt_with_coniferous_grass"},
	on_click=function(self,clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item():get_name()
			if minetest.get_item_group(item,"meat")> 0 then
				self:eat_item(item)
				default.take_item(clicker)
				self.folow = clicker
				examobs.known(self,clicker,"folow")
			end
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end
})

examobs.register_mob({
	name = "arctic_wolf",
	textures = {"examobs_arctic_wolf.png"},
	mesh = "examobs_wolf.b3d",
	dmg = 2,
	aggressivity = 1,
	run_speed = 8,
	punch_chance=3,
	inv={["examobs:flesh"]=1,["examobs:pelt"]=1,["examobs:tooth"]=1},
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		run = {x=32,y=52,speed=60},
		lay = {x=66,y=75},
		attack = {x=53,y=65},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
	spawn_on={"group:snowy"},
	on_click=function(self,clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item():get_name()
			if minetest.get_item_group(item,"meat")> 0 then
				self:eat_item(item)
				default.take_item(clicker)
				self.folow = clicker
				examobs.known(self,clicker,"folow")
			end
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end
})

examobs.register_mob({
	name = "golden_wolf",
	textures = {"examobs_golden_wolf.png"},
	mesh = "examobs_wolf.b3d",
	dmg = 2,
	aggressivity = 1,
	run_speed = 8,
	punch_chance=3,
	inv={["examobs:flesh"]=1,["examobs:pelt"]=1,["examobs:tooth"]=1},
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		run = {x=32,y=52,speed=60},
		lay = {x=66,y=75},
		attack = {x=53,y=65},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
	spawn_on={"default:dirt_with_dry_grass"},
	on_click=function(self,clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item():get_name()
			if minetest.get_item_group(item,"meat")> 0 then
				self:eat_item(item)
				default.take_item(clicker)
				self.folow = clicker
				examobs.known(self,clicker,"folow")
			end
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end
})

examobs.register_mob({
	name = "underground_wolf",
	textures = {"uexamobs_underground_wolf.png"},
	mesh = "examobs_wolf.b3d",
	type = "monster",
	team = "carbon",
	dmg = 4,
	hp = 30,
	aggressivity = 2,
	swiming = 0,
	run_speed = 10,
	light_min = 1,
	light_max = 9,
	inv={["default:carbon_ingot"]=1,["examobs:tooth"]=1},
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		run = {x=32,y=52,speed=60},
		lay = {x=66,y=75},
		attack = {x=53,y=65},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
	spawn_on={"default:stone","default:cobble"},
	on_click=function(self,clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item():get_name()
			if minetest.get_item_group(item,"meat")> 0 then
				self:eat_item(item)
				default.take_item(clicker)
				self.fight = clicker
				examobs.known(self,clicker,"fight")
			end
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end
})

examobs.register_mob({
	name = "stonemonster",
	textures = {"examobs_stonemonster.png"},
	mesh = "examobs_stonemonster.b3d",
	type = "monster",
	team = "stone",
	dmg = 5,
	hp = 40,
	swiming = 0,
	aggressivity = 2,
	run_speed = 6,
	light_min = 1,
	light_max = 9,
	inv={["default:stone"]=2,["default:iron_lump"]=1},
	bottom=-1,
	animation = {
		stand = {x=1,y=10,speed=0},
		walk = {x=11,y=30,speed=15},
		run = {x=31,y=51,speed=60},
		lay = {x=69,y=70,speed=0},
		attack = {x=53,y=66},
	},
	collisionbox={-0.6,-1.2,-0.6,0.6,1.1,0.6,},
	spawn_on={"default:stone","default:cobble"},
})

examobs.register_mob({
	name = "mudmonster",
	textures = {"examobs_mudmonster.png"},
	mesh = "examobs_mudmonster.b3d",
	type = "monster",
	team = "dirt",
	dmg = 5,
	hp = 30,
	swiming = 0,
	aggressivity = 2,
	inv={["default:dirt"]=2,["examobs:mud"]=5},
	light_min = 1,
	light_max = 9,
	bottom=-1,
	animation = {
		stand = {x=0,y=10,speed=0},
		walk = {x=20,y=40,speed=15},
		run = {x=50,y=70,speed=15},
		lay = {x=106,y=110,speed=0},
		attack = {x=80,y=100},
	},
	collisionbox={-0.5,-1.2,-0.5,0.5,0.9,0.5,},
	spawn_on={"default:dirt","","group:spreading_dirt_type"},
})
examobs.register_mob({
	name = "chicken",
	textures = {"examobs_chicken1.png"},
	mesh = "examobs_chicken.b3d",
	type = "animal",
	team = "chicken",
	dmg = 1,
	hp = 5,
	aggressivity = -1,
	inv={["examobs:chickenleg"]=1,["examobs:feather"]=1},
	walk_speed=2,
	run_speed=4,
	animation = {
		stand = {x=0,y=10,speed=0},
		walk = {x=20,y=30},
		run = {x=20,y=30,speed=60},
		lay = {x=41,y=45,speed=0},
		attack = {x=20,y=30},
	},
	collisionbox={-0.3,-0.35,-0.3,0.3,0.4,0.3},
	spawn_on={"group:spreading_dirt_type"},
	egg_timer = math.random(60,600),
	on_spawn=function(self)
		self.inv["examobs:feather"]=math.random(1,3)
		self.storage.skin="examobs_chicken" .. math.random(1,3) ..".png"
		self.object:set_properties({textures={self.storage.skin}})
	end,
	on_load=function(self)
		self.object:set_properties({textures={self.storage.skin or "examobs_chicken1.png"}})
	end,
	step=function(self)
		self.egg_timer = self.egg_timer -1
		if self.egg_timer < 1 then
			if self.flee or self.fight then
				self.egg_timer = math.random(60,600)
			elseif minetest.get_item_group(minetest.get_node(apos(self:pos(),0,-1)).name,"soil") > 0 and self.object:get_velocity().y == 0 then
				minetest.add_node(self:pos(),{name="examobs:egg"})
				self.egg_timer = math.random(60,600)
			end
		end
	end,
	is_food=function(self,item)
		return false
	end,
	on_click=function(self,clicker)
		if math.random(1,5) == 1 and not self.fight then
			clicker:get_inventory():add_item("main","examobs:chicken_spawner")
			self.folow = clicker
			self.object:remove()
		else
			self.flee = clicker
			examobs.known(self,clicker,"flee")
		end
	end,
})

examobs.register_mob({
	name = "sheep",
	spawner_egg = true,
	textures = {"examobs_wool.png^examobs_sheep.png"},
	mesh = "examobs_sheep.b3d",
	type = "animal",
	team = "sheep",
	dmg = 1,
	hp = 15,
	aggressivity = -1,
	inv={["examobs:flesh"]=1},
	walk_speed=2,
	run_speed=4,
	animation = {
		stand = {x=0,y=10,speed=0},
		walk = {x=20,y=40,speed=40},
		run = {x=20,y=40,speed=80},
		lay = {x=101,y=105,speed=0},
		attack = {x=50,y=90},
	},
	collisionbox={-0.5,-0.7,-0.5,0.5,0.5,0.5},
	spawn_on={"group:spreading_dirt_type"},
	egg_timer = math.random(60,600),
	on_lifedeadline=function(self)
		if self.storage.tamed then
			examobs.dying(self,2)
			return true
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"grass") > 0
	end,
	on_spawn=function(self)
		self.storage.wool = "examobs_wool.png"
		self.storage.woolen = 1
		self:on_load()
	end,
	on_load=function(self)
		local color = self.storage.color and self.storage.color.hex and ("^[colorize:" .. self.storage.color.hex .."cc") or ""
		self.storage.wool = (self.storage.wool or "examobs_wool.png") .. color
		self.object:set_properties({textures={
			(self.storage.woolen and (self.storage.wool .. "^") or "") .. "examobs_sheep.png"
		}})
	end,
	on_click=function(self,clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item():get_name()
			if item == "examobs:shears" and self.storage.woolen and examobs.known(self,clicker,"folow",true) then
				local i = clicker:get_wield_index()
				local item = clicker:get_inventory():get_stack("main",i)
				local pos = self:pos()
				item:add_wear(600)
				clicker:get_inventory():set_stack("main",i,item)
				local drop = ItemStack("default:wool"):to_table()
				drop.meta = self.storage.color
				minetest.add_item(pos,drop)
				self.storage.woolen = nil
				self.object:set_properties({textures={"examobs_sheep.png"}})
				self.storage.wool_grow = 0
				examobs.showtext(self,self.storage.wool_grow .."/10","ffffff")
			elseif minetest.get_item_group(item,"grass")> 0 then
				self:eat_item(item,2)
				default.take_item(clicker)
				self.folow = clicker
				examobs.known(self,clicker,"folow")
				self.storage.tamed = 1
			elseif item == "default:dye" then
				local color = clicker:get_wielded_item():to_table()
				self.storage.color = color.meta
				default.take_item(clicker)
				self:on_load()
			end
		end
	end,
	step=function(self)
		if not self.grass and (math.random(1,10) == 1 or self.lifetimer < self.lifetime/2) then
			local p = self:pos()
			local np = minetest.find_nodes_in_area_under_air(apos(p,-7,-3,-7),apos(p,7,3,7),{"group:grass"})
			for i,v in pairs(np) do
				if examobs.visiable(self.object,v) then
					self.grass = v
					examobs.stand(self)
					return true
				end
			end
		elseif self.grass then
			examobs.lookat(self,self.grass)
			examobs.walk(self)
			if not examobs.visiable(self.object,self.grass) or minetest.get_item_group(minetest.get_node(self.grass).name,"grass") == 0 then
				self.grass = nil
			elseif examobs.distance(self.object,self.grass) <= 2 then
				minetest.remove_node(self.grass)
				self.grass = nil
				if self.storage.tamed then
					self.lifetimer = self.lifetime
				end
				examobs.stand(self)
				examobs.anim(self,"attack")
				self:heal(1)
				if self.storage.wool_grow then
					self.storage.wool_grow = self.storage.wool_grow + 1
					examobs.showtext(self,self.storage.wool_grow .."/10","ffffff")
					if self.storage.wool_grow > 10 then
						self.storage.wool_grow = nil
						self.storage.woolen = 1
						self:on_load()
					end
				end
				return true
			end
		end
	end
})

examobs.register_mob({
	name = "duck",
	textures = {"examobs_duck1.png"},
	mesh = "examobs_duck.b3d",
	type = "animal",
	team = "duck",
	dmg = 1,
	hp = 5,
	aggressivity = -2,
	inv={["examobs:chickenleg"]=1,["examobs:feather"]=1},
	walk_speed=2,
	run_speed=4,
	animation = {
		stand = {x=0,y=6,speed=0},
		walk = {x=10,y=20,speed=20},
		run = {x=10,y=20,speed=40},
		lay = {x=59,y=60,speed=0},
		attack = {x=35,y=44},
		eat = {x=45,y=55},
	},
	collisionbox={-0.4,-0.42,-0.4,0.4,0.25,0.4},
	spawn_on={"group:spreading_dirt_type"},
	on_spawn=function(self)
		self.inv["examobs:feather"]=math.random(1,3)
		self.storage.skin="examobs_duck" .. math.random(1,4) ..".png"
		self.object:set_properties({textures={self.storage.skin}})
	end,
	on_load=function(self)
		self.object:set_properties({textures={self.storage.skin or "examobs_duck1.png"}})
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"grass") > 0
	end,
	on_click=function(self,clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item():get_name()
			if not self.fight and minetest.get_item_group(item,"grass")> 0 then
				self:eat_item(item,2)
				default.take_item(clicker)
				self.folow = clicker
				examobs.known(self,clicker,"folow")
			elseif math.random(1,5) == 1 and not self.fight then
				clicker:get_inventory():add_item("main","examobs:duck_spawner")
				self.folow = clicker
				self.object:remove()
			else
				self.flee = clicker
				examobs.known(self,clicker,"flee")
			end
		end
	end,
	step=function(self)
		if not self.grass and (math.random(1,10) == 1 or self.lifetimer < self.lifetime/2) then
			local p = self:pos()
			local np = minetest.find_nodes_in_area_under_air(apos(p,-7,-3,-7),apos(p,7,3,7),{"group:grass"})
			for i,v in pairs(np) do
				if examobs.visiable(self.object,v) then
					self.grass = v
					examobs.stand(self)
					return true
				end
			end
		elseif self.grass then
			examobs.lookat(self,self.grass)
			examobs.walk(self)
			if not examobs.visiable(self.object,self.grass) or minetest.get_item_group(minetest.get_node(self.grass).name,"grass") == 0 then
				self.grass = nil
			elseif examobs.distance(self.object,self.grass) <= 2 then
				minetest.remove_node(self.grass)
				self.grass = nil
				if self.storage.tamed then
					self.lifetimer = self.lifetime
				end
				examobs.stand(self)
				examobs.anim(self,"eat")
				self:heal(1)
				return true
			end
		end
	end
})