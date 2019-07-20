examobs.register_mob({
	name = "npc",
	type = "npc",
	dmg = 1,
	aggressivity = 1,
	walk_speed = 4,
	run_speed = 8,
	animation = "default",
	spawn_chance = 1000,
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
	end,
	on_lifedeadline=function(self)
		return self.storage.npc_generated
	end,
})

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
	spawn_on={"default:dirt_with_snow","default:dirt_with_coniferous_grass","default:dirt_with_grass"},
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
	team = "coal",
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
		attack_freeze = {x=80,y=100,speed=0},
	},
	collisionbox={-0.5,-1.2,-0.5,0.5,0.9,0.5,},
	spawn_on={"default:dirt","","group:spreading_dirt_type"},
	step=function(self)
		if (minetest.get_node_light(self:pos()) or 0) > 9 then
			self:hurt(1)
			if not self.muddry and self.dying then
				examobs.stand(self)
				if self.fight then
					examobs.anim(self,"attack_freeze")
				end
				return self
			end
		end
	end,
})
examobs.register_mob({
	name = "chicken",
	bird=true,
	swiming = 0,
	textures = {"examobs_chicken1.png"},
	mesh = "examobs_chicken.b3d",
	type = "animal",
	team = "chicken",
	dmg = 1,
	hp = 5,
	aggressivity = -2,
	flee_from_threats_only = 1,
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
	egg_timer = math.random(1,600),
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
				self.egg_timer = math.random(1,600)
			elseif minetest.get_item_group(minetest.get_node(apos(self:pos(),0,-1)).name,"soil") > 0 and self.object:get_velocity().y == 0 then
				local pos = self:pos()
				minetest.add_node(pos,{name="examobs:egg"})
				local meta = minetest.get_meta(pos)
				meta:set_int("date",default.date("get"))
				meta:set_int("hours",math.random(1,6))
				minetest.get_node_timer(pos):start(10)
				self.egg_timer = math.random(1,600)
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
	flee_from_threats_only = 1,
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
		if self.lifetimer < 0 and self.storage.tamed then
			examobs.dying(self,2)
			return true
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"grass") > 0
	end,
	on_spawn=function(self)
		self.storage.woolen = 1
		self:on_load()
	end,
	on_load=function(self)
		if self.storage.color and self.storage.color.palette_index then
			self.storage.palette_index = self.storage.color.palette_index
			self.storage.color = nil
		end
		local color = self.storage.palette_index and ("^"..default.dye_texturing(self.storage.palette_index,{opacity=180})) or ""
		self.object:set_properties({textures={
			(self.storage.woolen and ("examobs_wool.png" .. color .."^") or "") .. "examobs_sheep.png"
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
				drop.meta = {palette_index=self.storage.palette_index}
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
				self.storage.palette_index = color.meta and color.meta.palette_index
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
					minetest.sound_play("examobs_sheep", {object=self.object, gain = 1, max_hear_distance = 10})
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
	bird=true,
	textures = {"examobs_duck1.png"},
	mesh = "examobs_duck.b3d",
	type = "animal",
	team = "duck",
	dmg = 1,
	hp = 5,
	aggressivity = -1,
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
			local np = minetest.find_nodes_in_area_under_air(apos(p,-7,-3,-7),apos(p,7,3,7),{"group:grass","group:water"})
			for i,v in pairs(np) do
				if examobs.visiable(self.object,v) then
					if minetest.get_item_group(minetest.get_node(v).name,"grass") > 0 then
						self.grass = v
					elseif self.lifetimer > self.lifetime/2 then
						self.water = v
					end
					examobs.stand(self)
					minetest.sound_play("examobs_duck", {object=self.object, gain = 1, max_hear_distance = 10})
					return true
				end
			end
		elseif self.water then
			examobs.lookat(self,self.water)
			examobs.walk(self)
			if not examobs.visiable(self.object,self.water) or minetest.get_item_group(minetest.get_node(self.water).name,"water") == 0 then
				self.water = nil
			elseif examobs.distance(self.object,self.water) <= 2 then
				self.water = nil
				examobs.stand(self)
				return true
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

examobs.register_bird({
	visual_size= {x=0.5,y=0.5,z=0.5},
	collisionbox={-0.2,-0.13,-0.2,0.2,0.2,0.2},
	on_spawn=function(self)
		self:on_load()
	end,
	on_load=function(self)
		self.storage.palette_index = self.storage.palette_index or math.random(1,15*7)
		self.storage.kind = self.storage.kind or math.random(1,6)
		self.object:set_properties({textures={"examobs_bird.png^"..default.dye_texturing(self.storage.palette_index,{opacity=140}) }})
	end,
	step=function(self)
		if self.storage.fly and not (self.fight or self.flee) and math.random(1,30) == 1 then
			minetest.sound_play("examobs_bird"..self.storage.kind, {object=self.object, gain = 1, max_hear_distance = 20})
		end
	end,
	is_food=function(self,item)
		return false
	end
})

examobs.register_bird({
	name = "magpie",
	textures={"examobs_magpie.png"},
	on_click=function(self)
		return self
	end,
	step=function(self)
		if not self.item and math.random(1,5) == 1 then
			for _, ob in pairs(minetest.get_objects_inside_radius(self:pos(), self.range)) do
				local en = ob:get_luaentity()
				if en and en.name == "__builtin:item" and examobs.visiable(self.object,ob) then
					self.item = ob
					self.target = ob
					return
				end
			end
		elseif self.item then
			if not self.item:get_pos() or not examobs.visiable(self.object,self.item) then
				self.item = nil
				self.target = nil
				return
			elseif examobs.distance(self.object,self.item) <= 1 then
				local item = string.split(self.item:get_luaentity().itemstring," ")
				if minetest.get_item_group(item[1],"eatable") > 0 then
					self:eat_item(item[1])
				elseif item[1] then
					self.inv[item[1]] = (self.inv[item[1]] or 0) + (item[2] and tonumber(item[2]) or 1)
				end
				self.lifetimer = self.lifetime
				self.item:remove()
				self.item = nil
				self.target = nil
			else
				examobs.lookat(self,self.item)
				examobs.walk(self)
			end
			return self
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"eatable") > 0
	end
})

examobs.register_bird({
	name = "crow",
	aggressivity = -2,
	textures={"examobs_crow.png"},
	is_food=function(self,item)
		return minetest.get_item_group(item,"eatable") > 0
	end
})

examobs.register_bird({
	name = "gull",
	textures={"examobs_gull.png"},
	aggressivity = -2,
	flee_from_threats_only = 1,
	visual_size={x=1.5,y=1.5,z=1.5},
	collisionbox={-0.4,-0.33,-0.4,0.4,0.3,0.4},
	step=function(self)
		if self.storage.fly and not self.flee and math.random(1,10) == 1 then
			minetest.sound_play("examobs_gull", {object=self.object, gain = 1, max_hear_distance = 20})
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"eatable") > 0
	end
})

examobs.register_bird({
	name = "coalcrow",
	aggressivity = 2,
	is_food=function(self,item)
		return true
	end,
	hp = 10,
	dmg = 4,
	team = "coal",
	type = "monster",
	run_speed = 4,
	walk_speed = 2,
	inv = {["default:coal_lump"]=1},
	spawn_on = {"group:stone"},
	light_min = 1,
	light_max = 10,
	textures={"examobs_coalcrow.png"},
	on_spawn=function(self)
		self.storage.size = math.random(1,2)
		self:on_load(self)
	end,
	on_load=function(self)
		if self.storage.size == 2 then
			self.object:set_properties({
				visual_size={x=1.5,y=1.5},
				collisionbox={-0.4,-0.33,-0.4,0.4,0.3,0.4}
			})
		end
	end,
	is_food=function(self,item)
		return true
	end
})

examobs.register_bird({
	name = "hawk",
	aggressivity = 1,
	is_food=function(self,item)
		return true
	end,
	hp = 20,
	dmg = 4,
	team = "hawk",
	type = "animal",
	run_speed = 4,
	walk_speed = 2,
	textures={"examobs_hawk.png"},
	on_spawn=function(self)
		self:on_load(self)
	end,
	on_load=function(self)
		self.object:set_properties({
			visual_size={x=2,y=2},
			collisionbox={-0.4,-0.33,-0.5,0.5,0.3,0.5}
		})
	end,
	step=function(self)
		for _, ob in pairs(minetest.get_objects_inside_radius(self:pos(), self.range)) do
			local en = ob:get_luaentity()
			if en and en.bird and en.examob ~= self.examob and examobs.visiable(self.object,ob) then
				self.fight = ob
				return
			end
		end
	end,
	before_punching=function(self)
		local en = self.fight:get_luaentity()
		if en and examobs.gethp(self.fight)-self.dmg <=0 then
			en.inv["examobs:feather"]=nil
			en.inv["examobs:chickenleg"]=nil
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end
})

examobs.register_fish({
	color = true,
	on_spawn=function(self)
		local n
		local c = ""
		local t="0123456789ABCDEF"
		if math.random(1,2) == 1 then
  			for i=1,3,1 do
        				n=math.random(1,16)
       				c=c .. string.sub(t,n,n) .. string.sub(t,n,n)
			end
		else
  			for i=1,6,1 do
        				n=math.random(1,16)
       				c=c ..string.sub(t,n,n)
			end
		end
		 for i=1,2,1 do
        			n=math.random(8,16)
       			c=c ..string.sub(t,n,n)
		end
		self.storage.size = math.random(0.5,2)
		self.storage.color = c
		self:on_load()
	end,
	on_load=function(self)
		local s = self.storage.size or 1
		self.object:set_properties({
			textures={"examobs_fish.png^[colorize:#" .. self.storage.color or "ffffff"},
			visual_size= {x=s,y=s,z=s},
		})
	end
})

examobs.register_fish({
	name = "perch",
	textures = {"examobs_perch.png"},
	on_spawn=function(self)
		self.storage.size = math.random(0.5,2)
		self:on_load()
	end,
	on_load=function(self)
		local s = self.storage.size or 1
		self.object:set_properties({visual_size= {x=s,y=s,z=s}})
	end
})
examobs.register_fish({
	name = "pike",
	team = "pike",
	type = "monster",
	hp = 10,
	dmg = 5,
	aggressivity = 2,
	run_speed = 6,
	spawn_chance = 500,
	textures = {"examobs_pike.png"},
	on_spawn=function(self)
		self.storage.size = math.random(1.5,2)
		self:on_load()
	end,
	on_load=function(self)
		local s = self.storage.size or 1
		self.object:set_properties({visual_size= {x=s,y=s,z=s*2}})
	end
})
examobs.register_fish({
	name = "piranha",
	team = "piranha",
	type = "monster",
	hp = 10,
	dmg = 2,
	spawn_chance = 1000,
	aggressivity = 2,
	run_speed = 10,
	light_min = 1,
	textures = {"examobs_piranha.png"},
	step=function(self)
		if self.fight and examobs.distance(self.object,self.fight) <= 3 and self.fight:get_pos() then
			local p = apos(self:pos(),math.random(-1,1),math.random(-1,1),math.random(-1,1))
			if minetest.get_item_group(minetest.get_node(p).name,"water") > 0 then
				self.object:set_pos(p)
				examobs.lookat(self,self.fight)
				examobs.punch(self.object,self.fight,2)
			end
		end
	end,
	on_spawn=function(self)
		local p = self:pos()
		minetest.after(0.1,function(p)
			if not self.clone then
				for i=0,math.random(1,5) do
					local en = minetest.add_entity(p,"examobs:piranha")
					en:get_luaentity().clone = true
				end
			end
		end,p)
	end
})

examobs.register_mob({
	name = "gass_man",
	type = "npc",
	team = "gass",
	textures = {"examobs_gassman.png"},
	aggressivity = 2,
	walk_speed = 1,
	dmg = 0,
	run_speed = 4,
	animation = "default",
	spawn_chance = 800,
	extimer = 20,
	inv = {["nitroglycerin:c4"]=1},
	step=function(self)
		if self.fight and examobs.distance(self.object,self.fight) < 3 then
			examobs.showtext(self,self.extimer,"ffff00")
			self.extimer = self.extimer - 1
			if self.extimer and self.extimer < 0 then
				self.extimer = nil
				local pos = self:pos()
				self.object:remove()
				nitroglycerin.explode(pos,{radius=4,set="air"})
			end
		end
	end
})

examobs.register_mob({
	name = "sandmonster",
	type = "monster",
	dmg = 2,
	aggressivity = 2,
	walk_speed = 4,
	run_speed = 5,
	lay_on_death = 0,
	swiming = 0,
	animation = {
		stand={x=1,y=39,speed=30},
		walk={x=80,y=99,speed=30},
		run={x=80,y=99,speed=30},
		attack={x=65,y=75,speed=30},
		lay={x=113,y=123,speed=0},
	},
	textures = {"default_desert_sand.png"},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end,
	spawn_on={"default:desert_sand","default:desert_stone"},
	death=function(self)
		local pos=apos(self:pos(),0,1.5)
		minetest.add_particlespawner({
			amount = 15,
			time =0.1,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-2, y=-2, z=-2},
			maxvel = {x=2, y=2, z=2},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.1,
			maxsize = 3,
			texture = "default_desert_sand.png",
			collisiondetection = true,
		})
	end,
	step=function(self)
		if minetest.get_item_group(minetest.get_node(self:pos()).name,"water") > 0 then
			self:hurt(100)
		end
	end
})