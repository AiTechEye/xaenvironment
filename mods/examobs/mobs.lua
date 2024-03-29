examobs.register_mob({
	description = "Another spider, avoid it",
	name = "spider",
	team = "spider",
	type = "monster",
	hp = 10,
	coin = 20,
	dmg = 10,
	swiming = 0,
	textures = {"[combine:32x32:0,0=default_obsidian.png:16,0=bones_bone2.png:0,16=default_xe.png:16,16=default_xe.png"},
	mesh = "examobs_spider2.x",
	aggressivity = 1,
	animation = {
		stand={x=1,y=5,speed=0,loop=false},
		walk={x=10,y=20},
		run = {x=10,y=30,speed=60},
		lay = {x=41,y=42,speed=0,loop=false},
		attack = {x=25,y=35},

	},
	inv={["bones:bone"]=8,["default:obsidian"]=1},
	collisionbox={-0.2,-0.2,-0.2,0.2,0.2,0.2},
	spawn_on={"default:desert_stone"},
	max_spawn_y = -10,
	resist_nodes = {["examobs:barbed_wire"]=1},
	step=function(self,time)
		local pos2 = self.fight and self.fight:get_pos()
		local c
		local rot = self.object:get_rotation()
		local pos = self.object:get_pos()

		if pos2 and vector.distance(pos,pos2) > 10 then
			self.am = (self.am or 0) -0.1
			if self.am <= 0 then
				examobs.shoot_arrow(self,pos2,"examobs:arrow_barbed_wire")
				self.am = math.random(1,5) * 0.1
			end
		end

		if self.wall then
			if math.random(0,1) == 1 then
				local s = self.storage.size*2
				local x = self.wall.z ~= 0 and math.random(-s,s) or 0
				local z = self.wall.x ~= 0 and math.random(-s,s) or 0
				self.object:set_rotation({
					x = x * math.pi/2,
					y = rot.y,
					z = z * math.pi/2
				})
				self.object:set_velocity({
					x = x,
					y = math.random(-s,s),
					z = z
				})
			else
				examobs.stand(self)
			end
		end

		for _,r in pairs(exatec.wire_rules) do
			if r.y == 0 and default.defpos(vector.add(pos,r),"walkable") then
				c = r
				break
			end
		end

		if c then
			local p = math.pi/2
			self.object:set_rotation({
				x=c.z*p,
				y=0,
				z=c.x*p*-1
			})
			self.wall = c
			self.floating.air = 1
		elseif self.wall then
			self.wall = nil
			self.floating.air = nil
			self.object:set_rotation({x=0,y=rot.y,z=0})
		end
	end,
	on_spawn=function(self)
		local skin1 = {"default_xe","default_steelblock","default_ironblock","default_steelblock","default_copperblock","default_diamondblock","default_electricblock","default_obsidian","default_silverblock","default_uraniumactiveblock","default_uraniumblock","default_bronzeblock","default_goldblock","default_lava"}
		local skin2 = {"default_peridotblock","default_rubyblock","default_taaffeiteblock","default_uraniumactiveblock","default_xe","default_ore_mineral","default_oil","default_lava","default_jadeiteblock","default_lava","default_electricblock","default_diamondblock_blank","default_amethystblock","default_amberblock"}
		skin1 = skin1[math.random(1,#skin1)]..".png"
		skin2 = skin2[math.random(1,#skin2)]..".png"

		self.storage.skin = "[combine:32x32:0,0="..skin1..":16,0=bones_bone2.png:0,16="..skin2..":16,16="..skin2
		self.storage.size = math.random(1,5)

		self.on_load(self)
	end,
	on_load=function(self)
		self.floating = {["examobs:barbed_wire"]=1}
		if self.storage.skin then
			local s = self.storage.size
			self.dmg = 10+(s*2)
			self.walk_speed = 2*s
			self.run_speed = 4*s
			self.hp = 10*s
			self.object:set_properties({
				textures={self.storage.skin},
				visual_size = {x=s,y=s},
				collisionbox={-0.2*s,-0.2*s,-0.2*s,0.2*s,0.1*s,0.2*s},
				hp_max = 10*s,
			})
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
	description = "The most rideable and useful animal in the history.",
	name = "horse",
	team = "horse",
	type = "animal",
	reach = 4,
	hp = 80,
	coin = 5,
	dmg = 0,
	bottom = -0.5,
	textures = {"examobs_horse_brown.png"},
	mesh = "examobs_horse.x",
	aggressivity = 0,
	walk_speed = 6,
	run_speed = 20,
	inv={["examobs:flesh"]=3,["examobs:leather"]=3},
	collisionbox={-0.9,-1.1,-0.9, 0.9,0.4,0.9},
	stepheight = 1.5,
	spawn_on={"group:spreading_dirt_type"},
	hunger = 1,
	animation = {
		stand = {x=0,y=2,speed=0},
		eat = {x=2,y=8},
		walk = {x=10,y=30,speed=50},
		run = {x=10,y=30,speed=80},
		lay = {x=60,y=61,speed=0},
		attack = {x=40,y=54},
	},
	on_spawn=function(self)
		local c = {"2e1c09","37210b","40270d","492c0e","523210","5b3712","6d3700","7c4b19","9e5f1f","bbbbbb","d8d8d8","ededed","2f2f2f","171717"}
		local color1 = c[math.random(1,#c)]
		local color2 = c[math.random(1,#c)]
		self.storage.skin = "examobs_horse.png^[colorize:#" .. color1 .."^examobs_horse_details.png" .. (math.random(1,2) == 1 and "" or "^(examobs_horse_spots.png^[colorize:#" .. color2..")")
		self.on_load(self)
	end,
	on_load=function(self)
		local skin = self.storage.skin or "examobs_horse_brown.png"
		if self.storage.saddle and not (self.dead or self.dying) then
			minetest.add_entity(self.object:get_pos(), "examobs:saddle"):set_attach(self.object, "",{x=0, y=0, z=-3}, {x=0, y=0,z=0})
			skin = skin .. "^examobs_horse_bridle.png"
		end
		self.object:set_properties({textures={skin}})
	end,
	punch_timeout = 0,
	on_punching=function(self)
		self.punch_timeout = 0.5
	end,
	on_lifedeadline=function(self)
		return self.storage.tamed
	end,
	death=function(self)
		if self.rider then
			if self.hud1 then
				self.rider:hud_remove(self.hud1)
				self.rider:hud_remove(self.hud2)
			end
			self.rider:set_detach()
			self.rider:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
			player_style.player_attached[self.rider:get_player_name()] = nil
			self.rider = nil
		end
		if self.storage.saddle then
			for i,v in ipairs(self.object:get_children()) do
				v:set_detach()
				if v:get_luaentity() then
					v:remove()
				end
			end
		end
	end,
	on_abs_step=function(self,dtime)
		if self.dead or self.dying or self.rider and self.rider:get_hp() == 0 then
			if self.rider and self.rider then
				self:on_click(self.rider)
			end
			return
		elseif self.eattime then
			self.eattime = self.eattime - dtime
			if self.eattime < 0 then
				self.eattime = nil
				examobs.stand(self)
			end
			return true
		elseif self.punch_timeout > 0 then
			self.punch_timeout = self.punch_timeout - dtime
			local p1 = self:pos()
			local p2 = self.fight and self.fight:get_pos() or self.kickpos

			if not self.hkickedt and p2 and (self.kickpos and vector.distance(p1,self.kickpos) < 6 or vector.distance(p1,p2) <= 4) and self.punch_timeout < 0.2 then
				self.hkickedt = true
				self.hunger = self.hunger - 0.5
				local p2 = examobs.pointat(self,50)
				local v = {x=p2.x-p1.x,y=(p2.y+20)-p1.y,z=p2.z-p1.z}
				if self.kickpos then
					nitroglycerin.explode(self.kickpos,{radius=1,set="air",place = {"air","air"},hurt=0})
					self.kickpos = nil
					return
				end
				self.fight:add_velocity(v)
				examobs.punch(self.object,self.fight,15)
			end
			if self.punch_timeout <= 0 then
				self.hkickedt = nil
			end
			return self
		elseif self.rider and not (self.punch_timeout and self.punch_timeout > 0) then
			local key = self.rider and self.rider:get_player_control() or {}
			local pos = apos(self:pos(),0,self.bottom)
			local drowning = default.defpos(pos,"drowning") or 0
			if drowning > 0 and not self.breathbar_set then
				self.breathbar_set = true
				self.rider:hud_change(self.hud2, "number", self.breath)
				self.rider:hud_change(self.hud2, "item", 20)
			elseif drowning == 0 and self.breathbar_set then
				self.rider:hud_change(self.hud2, "number", 0)
				self.rider:hud_change(self.hud2, "item", 0)
			end

			if self.hp and (self.last_hp ~= self.hp or self.last_breath ~= self.breath or self.hunger < 0) then
				if self.hunger < 0 then
					self.hunger = 1
					self.hp = self.hp - 1
				end

				self.last_breath = self.breath
				self.last_hp = self.hp
				self.rider:hud_change(self.hud1, "number", self.hp)

				if self.hp < self.hp_max/3 then
					self.rider:hud_change(self.hud1, "text", "default_rubyblock.png")
				elseif self.hp < self.hp_max/1.5 then
					self.rider:hud_change(self.hud1, "text", "default_peridotblock.png")
				else
					self.rider:hud_change(self.hud1, "text", "quads_petrolbar.png")
				end

				if drowning > 0 then
					self.rider:hud_change(self.hud2, "number", self.breath)
				end
			end

			if self.in_liquid then
				self.hunger = self.hunger - dtime*0.01
			end

			if key.jump then
				if self.in_liquid then
					local v = self.object:get_velocity() or {x=0,y=0,z=0}
					self.object:set_velocity({x=0,y=5,z=0})
				elseif self.hp > self.hp_max/3 then
					examobs.jump(self,7)
				end
			elseif key.sneak and self.in_liquid then
				local v = self.object:get_velocity() or {x=0,y=0,z=0}
				self.object:set_velocity({x=0,y=-5,z=0})
			end

			if key.LMB and self.rider:get_wielded_item():get_name() == "" then
				local dir = self.rider:get_look_dir()
				local pos = vector.offset(self.object:get_pos(),0,2,0)
				local pos2 = vector.add(pos,vector.multiply(dir,50))

				for v in minetest.raycast(pos,pos2) do
					if v and v.type == "node" then
 						if not minetest.is_protected(v.under, "") and vector.distance(pos,v.under) < 6 and minetest.get_node(v.under).name ~= "examobs:rope" then
							examobs.lookat(self,v.under)
							self.punch_timeout = 0.5
							examobs.anim(self,"attack")
							self.fight = nil
							self.kickpos = v.under
							return true
						end
						break
					elseif v and v.type == "object" and v.ref ~= self.object and v.ref ~= self.rider and not default.is_decoration(v.ref,true) then
						self.fight = v.ref
						examobs.lookat(self,v.ref)
						self.punch_timeout = 0.5
						examobs.anim(self,"attack")
						break
					end
				end
			end

			if key.right or key.left or key.up or key.down then
				if self.hp < self.hp_max/3 or self.in_liquid then
					self.walk_speed = 3
					self.run_speed = 5
				else
					self.walk_speed = 6
					self.run_speed = self.hp > self.hp_max/1.5 and 20 or 10
				end

				self.fight = nil
				self.folow = nil
				local r = self.rider:get_look_horizontal()
				self.object:set_yaw(r + (key.right and -math.pi/2 or key.left and math.pi/2 or key.down and math.pi or 0))
				examobs.walk(self,key.aux1)
				self.hunger = self.hunger - dtime*(key.aux1 and 0.1 or 0.01)
				return self
			elseif not self.fight then
				examobs.stand(self)
				if self.hp < self.hp_max then
					local p = self:pos()
					local np = minetest.find_nodes_in_area_under_air(vector.add(p,5),vector.subtract(p,5),{"group:grass","group:wheat","plants:pear","plants:apple"})
					for i,v in pairs(np) do
						if examobs.visiable(self.object,v) then
							examobs.lookat(self,v)
							minetest.remove_node(v)
							self:heal(1)
							self.eattime = 0.2
							self.hunger = 1
							examobs.anim(self,"eat")
							return
						end
					end
				end
				return self
			end
		end

		if not self.fight and not self.grass and (math.random(1,100) == 1 or self.hp < self.hp_max) then
			local p = self:pos()
			local np = minetest.find_nodes_in_area_under_air(vector.add(p,10),vector.subtract(p,10),{"group:grass","group:wheat","plants:pear","plants:apple"})
			local d1 = 100
			for i,v in pairs(np) do
				local d2 = vector.distance(p,v)
				if d2 < d1 and examobs.visiable(self.object,v) then
					d1 = d2
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
			elseif examobs.distance(self.object,self.grass) <= 4 then
				minetest.remove_node(self.grass)
				self.grass = nil
				self.lifetimer = self.lifetime
				examobs.stand(self)
				self.eattime = 0.2
				examobs.anim(self,"eat")
				self:heal(1)
			end
			return true
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"grass") > 0
	end,
	on_click=function(self,clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item()

			if item:get_name() ~= "" then
				local eat = true
				if minetest.get_item_group(item:get_name(),"grass") > 0 then
					self:eat_item(item:get_name(),2)
				elseif minetest.get_item_group(item:get_name(),"wheat") > 0 then
					self:eat_item(item:get_name(),10)
				elseif item:get_name() == "plants:pear" or item:get_name() == "plants:apple" then
					self:eat_item(item:get_name(),5)
				else
					eat = nil
				end
				if eat then
					if self.fight == clicker then
						self.fight = nil
					end
					default.take_item(clicker)
					return
				end
			end

			if not self.storage.saddle and item:get_name() == "examobs:saddle" then
				self.storage.tamed = 1
				self.storage.saddle = 1
				self.inv["examobs:saddle"] = 1
				default.take_item(clicker)
				self:on_load()
				return
			end

			local name = clicker:get_player_name()
			if self.storage.saddle and not self.rider and not player_style.player_attached[name] then
				self.rider = clicker
				player_style.reset_player(clicker)

				player_style.player_attached[name] = true
				clicker:set_attach(self.object, "",{x=0, y=1, z=-3}, {x=0, y=0,z=0})
				clicker:set_eye_offset({x=0, y=1.5, z=0}, {x=0, y=0, z=0})

				player_style.set_animation(name,"sit")
				self.lifetimer = self.lifetime
				self.grass = nil
				self.last_hp = 0
				self.last_breath = 0

				self.hud1 = clicker:hud_add({
					hud_elem_type = "statbar",
					text ="quads_petrolbar.png",
					text2 ="quads_backbar.png",
					number = self.hp_max,
					item = self.hp_max,
					size = {x=10,y=30},
					position = {x=1,y=0},
					direction = 1,
				})
				self.hud2 = clicker:hud_add({
					hud_elem_type = "statbar",
					text = "bubble.png",
					text2 = "bubble.png^[colorize:#000",
					number = 0,
					item = 0,
					size = {x=30,y=30},
					position = {x=1,y=0},
					direction = 1,
					offset = {x=-30,y=50},
				})
			elseif clicker == self.rider then
				self.rider:set_detach()
				self.rider:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
				player_style.player_attached[name] = nil
				self.rider = nil
				self.fight = nil
				if self.hud1 then
					clicker:hud_remove(self.hud1)
					clicker:hud_remove(self.hud2)
				end
			end
		end
	end,
})

examobs.register_mob({
	description = "The terminator spider machine shoots barbed wires catch you\nThis mob is also explosive.",
	name = "terminator_spider",
	team = "terminator",
	type = "monster",
	hp = 40,
	coin = 4,
	breathing = 0,
	swiming = 0,
	textures = {"default_steelblock.png"},
	mesh = "examobs_spider.b3d",
	aggressivity = 2,
	animation = {
		stand={x=1,y=2,speed=0,loop=false},
		walk={x=1,y=20,speed=30},
	},
	inv={["default:steel_ingot"]=4,["default:iron_ingot"]=2,["nitroglycerin:c4"]=1},
	collisionbox={-0.5,-0.5,-0.5,0.5,0.5,0.5},
	spawn_on={"group:stone"},
	max_spawn_y = -50,
	resist_nodes = {["examobs:barbed_wire"]=1},
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
	on_spawn=function(self)
		local skins = {"default_steelblock","default_ironblock","default_steelblock","default_copperblock","default_diamondblock","default_electricblock","default_obsidian","default_silverblock","default_uraniumactiveblock","default_uraniumblock","default_bronzeblock","default_goldblock"}
		self.storage.skin = skins[math.random(1,12)]..".png"
		self.on_load(self)
	end,
	on_load=function(self)
		if self.storage.skin then
			self.object:set_properties({textures={self.storage.skin}})
		end
	end,
	death=function(self)
		if not self.ex then
			self.ex = 1
			local pos = self.object:get_pos()
			if pos then
				nitroglycerin.explode(pos,{radius=5,set="fire:basic_flame",})
				self.object:remove()
			end
		end
	end,
	use_bow=function(pos1,pos2,arrow)
		--local pos1 = apos(self.object:get_pos(),0,-1)
		--local pos2 = target:get_pos()
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
	description = "A little animal that usually hides in sand",
	name = "crab",
	team = "crab",
	type = "animal",
	hp = 4,
	coin = 1,
	breathing = 0,
	swiming = 0,
	range = 5,
	textures = {"examobs_crab1.png"},
	mesh = "examobs_crab.b3d",
	aggressivity = -2,
	walk_speed = 1,
	run_speed = 4,
	spawn_chance = 50,
	pickupable = true,
	animation = {
		stand={x=1,y=10,speed=0,loop=false},
		walk={x=15,y=25,speed=30},
		run={x=15,y=25,speed=60},
		lay={x=31,y=35,speed=2,loop=false},
		run={x=15,y=25,speed=30},
	},
	inv={["examobs:crab_claw"]=2},
	collisionbox={-0.2,-0.05,-0.2,0.2,0.15,0.2},
	spawn_on={"group:sand"},
	step=function(self,time)
		local p = self:pos()
		if not self.hidejtimer and self.flee then
			local obs = {}
			for _, ob in pairs(minetest.get_objects_inside_radius(p, 10)) do
				local en = ob:get_luaentity()
				if en and en.examob and en.examob ~= self.examob and examobs.team(ob) == "crab" and examobs.gethp(ob) > 0 and examobs.visiable(self.object,ob) then
					table.insert(obs,ob)
				end
			end
			if #obs > 4 then
				for i,ob in pairs(obs) do
					local en = ob:get_luaentity()
					en.fight = self.flee
					en.flee = nil
					examobs.lookat(en,self.flee)
				end
				self.fight = self.flee
				self.flee = nil
			end
			if not walkable(p) and minetest.get_item_group(minetest.get_node(apos(p,0,-1)).name,"sand") > 0 then
				self.object:set_pos(apos(p,0,-0.5))
				self.jump = 0
				self.hide_in_sand = self.flee
				self.hidejtimer = 10
			end
		elseif self.hidejtimer then
			if self.flee or self.hide_in_sand and examobs.distance(self.object,self.hide_in_sand) <= 5 then
				self.hidejtimer = 3
			else
				self.hidejtimer = self.hidejtimer - 1
				if self.hidejtimer < 0 then
					self.hidejtimer = nil
					self.hide_in_sand = nil
					self.jump = nil
				end
			end
		end
	end,
	on_spawn=function(self)
		self.storage.skin = math.random(1,6)
		self.on_load(self)
	end,
	on_load=function(self)
		if self.storage.skin then
			self.object:set_properties({textures={"examobs_crab"..self.storage.skin..".png"}})
		end
	end
})

examobs.register_mob({
	description = "A very powerful monster that creates paths by lava, due its heat it is not water resistant and dies in water, it also eats its enemies or whatever it is",
	name = "titan_lava",
	type = "monster",
	team = "titan",
	reach = 4.5,
	coin = 100,
	dmg = 0,
	hp = 2000,
	textures={"examobs_titan_lava.png"},
	mesh="examobs_titan.b3d",
	spawn_on={"group:stone","default:gravel","default:bedrock","default:obsidian"},
	max_spawn_y = -100,
	inv={["default:obsidian"]=9,["default:diamond"]=3},
	collisionbox = {-1.5,-2.8,-1.5,1.5,2,1.5},
	aggressivity = 2,
	walk_speed = 4,
	run_speed = 6,
	bottom=1,
	breathing = 0,
	spawn_chance = 2000,
	bottom = -2,
	animation = {
		stand={x=1,y=10,speed=0,loop=false},
		walk={x=11,y=21,speed=15,loop=false},
		run={x=22,y=31,speed=15},
		lay={x=48,y=49,speed=0,loop=false},
		attack={x=33,y=47,speed=15},
	},
	resist_nodes = {["default:lava_source"]=1,["default:lava_flowing"]=1,["fire:basic_flame"]=1,["fire:not_igniter"]=1,["fire:basic_flame"]=1,["fire:permanent_flame"]=1},
	on_spawn=function(self)
		self.object:set_pos(apos(self:pos(),0,3))
	end,
	step=function(self)
		if self.eating then
			self.eating = self.eating + 1
			if self.eating >= 3 then
				if self.fight and examobs.distance(self.object,self.fight) <= 5 then
					self:heal(examobs.gethp(self.fight))
					if self.fight:is_player() then
					default.respawn_player(self.fight,true)
					else
						local en = self.fight:get_luaentity()
						if en and en.examob then
							examobs.dropall(en)
						end
						self.fight:remove()
					end
				end
				self.eating = nil
			end
			return self
		end
		local p = self:pos()
		if minetest.get_item_group(minetest.get_node(p).name,"cools_lava") > 0 then
			if minetest.is_protected(p, "") then
				self:hurt(50)
			else
				for x=-1,1 do
				for y=-1,1 do
				for z=-1,1 do
					minetest.add_node({x=p.x+x,y=p.y+y,z=p.z+z},{name="default:obsidian"})
				end
				end
				end
				examobs.dropall(self)
				self.object:remove()
				return self
			end
		elseif not minetest.is_protected(p, "") then
			minetest.set_node(apos(p,0,-2),{name="default:lava_flowing",param2=5})
		end
		if walkable(apos(examobs.pointat(self,2),0,-2)) then
			examobs.jump(self,10)
		end
		if math.random(1,50) == 1 then
			minetest.sound_play("examobs_titan_growl", {object=self.object, gain = 2, max_hear_distance = 100})
		end
	end,
	on_punching=function(self)
		if not self.eating and examobs.gethp(self.fight) < 100 then
			self.eating = 0
			examobs.anim(self,"attack")
		elseif examobs.gethp(self.fight) > 0 then
			local ob = self.fight
			local en =ob:get_luaentity()
			local p1 = self:pos()
			local p2 = examobs.pointat(self,50)
			local v = {x=p2.x-p1.x,y=(p2.y+20)-p1.y,z=p2.z-p1.z}
			if en then
				ob:set_velocity(v)
			else
				ob:add_velocity(v)
			end
			examobs.punch(self.object,ob,100)
		end
	end,
	on_dying=function(self)
		minetest.after(0, function(self)
			examobs.dying(self,2)
		end, self)
	end,
	death=function(self)
		minetest.set_node(self:pos(),{name="examobs:titan_core"})
	end,
	walktimer = 0,
	on_walk=function(self)
		self.walktimer = self.walktimer + 1
		if self.walktimer > 2 then
			self.walktimer = 0
			minetest.sound_play("examobs_heavy_step", {object=self.object, gain = 2, max_hear_distance = 50})
		end
	end,
})

examobs.register_mob({
	description = "The most powerful monster in XaEnvironmen and destroys everything around with lava, fire and extreme heat, it also eats its enemies or whatever it is\nWhen you hears its typyal roar its not time to think or explore, just evacuate before it detects you.",
	name = "titan_magma",
	type = "monster",
	team = "titan",
	reach = 4.5,
	coin = 150,
	dmg = 0,
	hp = 3000,
	textures={"examobs_titan_magma.png"},
	mesh="examobs_titan.b3d",
	spawn_on={"group:stone","default:gravel","default:bedrock","default:obsidian"},
	max_spawn_y = -100,
	inv={["default:obsidian"]=9,["default:diamond"]=3},
	collisionbox = {-1.5,-2.8,-1.5,1.5,2,1.5},
	aggressivity = 2,
	walk_speed = 4,
	run_speed = 6,
	bottom=1,
	breathing = 0,
	spawn_chance = 3000,
	bottom = -2,
	animation = {
		stand={x=1,y=10,speed=0,loop=false},
		walk={x=11,y=21,speed=15,loop=false},
		run={x=22,y=31,speed=15},
		lay={x=48,y=49,speed=0,loop=false},
		attack={x=33,y=47,speed=15},
	},
	resist_nodes = {["default:lava_source"]=1,["default:lava_flowing"]=1,["fire:basic_flame"]=1,["fire:not_igniter"]=1,["fire:basic_flame"]=1,["fire:permanent_flame"]=1},
	on_spawn=function(self)
		self.object:set_pos(apos(self:pos(),0,3))
	end,
	step=function(self)
		if self.eating then
			self.eating = self.eating + 1
			if self.eating >= 3 then
				if self.fight and examobs.distance(self.object,self.fight) <= 5 then
					self:heal(examobs.gethp(self.fight))
					if self.fight:is_player() then
					default.respawn_player(self.fight,true)
					else
						local en = self.fight:get_luaentity()
						if en and en.examob then
							examobs.dropall(en)
						end
						self.fight:remove()
					end
				end
				self.eating = nil
			end
			return self
		end

		local p = self:pos()

		for x=-3,3 do
		for y=-3,3 do
		for z=-3,3 do
			local np = {x=p.x+x,y=p.y+y,z=p.z+z}
			local n = minetest.get_node(np).name
			if not minetest.is_protected(np, "") then
				if minetest.get_item_group(n,"cools_lava") > 0 then
					minetest.remove_node(np)
				elseif minetest.get_item_group(n,"flammable") > 0 then
					minetest.set_node(np,{name="fire:basic_flame"})
				elseif np.y > p.y-3 and n ~= "air" and minetest.get_item_group(n,"fire") == 0 and minetest.get_item_group(n,"lava") == 0 and default.def(name).drawtype ~= "airlike" then
					minetest.set_node(np,{name="default:lava_source"})
				end
			end
		end
		end
		end
		for _, ob in pairs(minetest.get_objects_inside_radius(p, 10)) do
			if examobs.team(ob) ~= "titan" then
				local obp = ob:get_pos()
				if not minetest.is_protected(obp, "") then
					minetest.set_node(obp,{name="fire:basic_flame"})
				end
				examobs.punch(self.object,ob,5)
			end
		end
		if minetest.get_item_group(minetest.get_node(p).name,"cools_lava") > 0 then

		elseif not minetest.is_protected(p, "") then
			minetest.set_node(apos(p,0,-2),{name="default:lava_flowing",param2=5})
		end
		if walkable(apos(examobs.pointat(self,2),0,-2)) then
			examobs.jump(self,10)
		end
		if math.random(1,50) == 1 then
			minetest.sound_play("examobs_titan_growl", {object=self.object, gain = 2, max_hear_distance = 100})
		end
	end,
	on_punching=function(self)
		if not self.eating and examobs.gethp(self.fight) < 100 then
			self.eating = 0
			examobs.anim(self,"attack")
		elseif examobs.gethp(self.fight) > 0 then
			local ob = self.fight
			local en =ob:get_luaentity()
			local p1 = self:pos()
			local p2 = examobs.pointat(self,50)
			local v = {x=p2.x-p1.x,y=(p2.y+20)-p1.y,z=p2.z-p1.z}
			if en then
				ob:set_velocity(v)
			else
				ob:add_velocity(v)
			end
			examobs.punch(self.object,ob,100)
		end
	end,
	on_dying=function(self)
		minetest.after(0, function(self)
			examobs.dying(self,2)
		end, self)
	end,
	death=function(self)
		minetest.set_node(self:pos(),{name="examobs:titan_core"})
		minetest.set_node(apos(self:pos(),0,1),{name="examobs:titan_core"})
	end,
	walktimer = 0,
	on_walk=function(self)
		self.walktimer = self.walktimer + 1
		if self.walktimer > 2 then
			self.walktimer = 0
			minetest.sound_play("examobs_heavy_step", {object=self.object, gain = 2, max_hear_distance = 50})
		end
	end,
})

examobs.register_mob({
	description = "The second most powerful monster in XaEnvironment and just destroys everything is it its way and spitting fragments of stone, it also eats its enemies or whatever it is\nWhen you hears its typyal roar its not time to think or explore, just evacuate before it detects you.",
	name = "titan_stone",
	type = "monster",
	team = "titan",
	coin = 150,
	reach = 9,
	range = 40,
	dmg = 0,
	hp = 3000,
	textures={"examobs_titan_stone.png"},
	mesh="examobs_titan.b3d",
	visual_size = {x=2,y=2,z=2},
	spawn_on={"group:stone","default:gravel","default:bedrock","default:obsidian"},
	max_spawn_y = -100,
	inv={["default:stone"]=9,["default:diamond"]=1},
	collisionbox = {-3,-5.8,-3,3,4,3},
	aggressivity = 2,
	walk_speed = 8,
	run_speed = 12,
	bottom=4,
	breathing = 0,
	spawn_chance = 3000,
	bottom = -5,
	animation = {
		stand={x=1,y=10,speed=0,loop=false},
		walk={x=11,y=21,speed=15,loop=false},
		run={x=22,y=31,speed=15},
		lay={x=48,y=49,speed=0,loop=false},
		attack={x=33,y=47,speed=15},
	},
	resist_nodes = {["default:lava_source"]=1,["default:lava_flowing"]=1,["fire:basic_flame"]=1,["fire:not_igniter"]=1,["fire:basic_flame"]=1,["fire:permanent_flame"]=1},
	on_spawn=function(self)
		self.object:set_pos(apos(self:pos(),0,3))
	end,
	step=function(self)
		if self.eating then
			self.eating = self.eating + 1
			if self.eating >= 3 then
				if self.fight and examobs.distance(self.object,self.fight) <= 9 then
					self:heal(examobs.gethp(self.fight))
					if self.fight:is_player() then
					default.respawn_player(self.fight,true)
					else
						local en = self.fight:get_luaentity()
						if en and en.examob then
							examobs.dropall(en)
						end
						self.fight:remove()
					end
				end
				self.eating = nil
			end
			return self
		end
		if walkable(apos(examobs.pointat(self,5),0,-6)) then
			examobs.jump(self)
		end
		if self.fight and examobs.gethp(self.fight) > 0 then
			local p1 = apos(examobs.pointat(self,2),0,5)
			local p2 = apos(self.fight:get_pos(),math.random(-2,2),math.random(-2,2),math.random(-2,2))
			local v = {x=(p2.x-p1.x)*2,y=(p2.y-p1.y)*2,z=(p2.z-p1.z)*2}
	
			local node = "default:stone_spike"
			if math.random(1,5) == 1 then
				node = "default:cobble_porous"
			end

			minetest.add_node(p1,{name=node})
			minetest.spawn_falling_node(p1)

			for _, ob in ipairs(minetest.get_objects_inside_radius(p1, 1)) do
				local en =  ob:get_luaentity()
				if en and en.name == "__builtin:falling_node" and en.itemstring == node then
					ob:set_velocity(v)
				end
			end
		end

		local p = self:pos()

		for y=-4,7,1 do
		for x=-6,6,1 do
		for z=-6,6,1 do
			local np = {x=p.x+x,y=p.y+y,z=p.z+z}
			local n = minetest.get_node(np).name
			if not minetest.is_protected(np, "") and walkable(np) then
				local r = math.random(1,5)
				if r == 1 then
					minetest.spawn_falling_node(np)
				elseif r == 2 then
					minetest.add_item(np,minetest.get_node(np).name):get_luaentity().age = 895
				else
					minetest.remove_node(np)
				end
			end
		end
		end
		end
		if math.random(1,50) == 1 then
			minetest.sound_play("examobs_titan_growl", {object=self.object, gain = 4, max_hear_distance = 100})
		end
	end,
	on_punching=function(self)
		if not self.eating and examobs.gethp(self.fight) < 100 then
			self.eating = 0
			examobs.anim(self,"attack")
		elseif examobs.gethp(self.fight) > 0 then
			local ob = self.fight
			local en =ob:get_luaentity()
			local p1 = self:pos()
			local p2 = examobs.pointat(self,50)
			local v = {x=p2.x-p1.x,y=(p2.y+20)-p1.y,z=p2.z-p1.z}
			if en then
				ob:set_velocity(v)
			else
				ob:add_velocity(v)
			end
			examobs.punch(self.object,ob,100)
		end
	end,
	on_dying=function(self)
		minetest.after(0, function(self)
			examobs.dying(self,2)
		end, self)
	end,
	death=function(self)
		minetest.set_node(self:pos(),{name="examobs:titan_core"})
		minetest.set_node(apos(self:pos(),0,1),{name="examobs:titan_core"})
	end,
	walktimer = 0,
	on_walk=function(self)
		self.walktimer = self.walktimer + 1
		if self.walktimer > 2 then
			self.walktimer = 0
			minetest.sound_play("examobs_heavy_step", {object=self.object, gain = 4, max_hear_distance = 100})
		end
	end,
})

examobs.register_mob({
	description = "Just another murder machine the cooperating with the terminators, also called terminators skeletons",
	name = "skeleton",
	type = "monster",
	team="metal",
	dmg = 1,
	hp= 50,
	coin = 5,
	textures = {"examobs_skeleton.png","default_air.png"},
	mesh = "examobs_skeleton.b3d",
	inv={["default:iron_ingot"]=1},
	punch_chance=4,
	collisionbox = {-0.35,-1.1,-0.35,0.35,0.8,0.35},
	bottom=-1,
	animation = {
		stand = {x=1,y=10,speed=0},
		walk = {x=12,y=31},
		run = {x=12,y=32,speed=60},
		lay = {x=60,y=65},
		attack = {x=34,y=42},
		sit = {x=55,y=56,speed=0},
		aim = {x=47,y=50,speed=0},
	},
	aggressivity = 2,
	walk_speed = 2,
	run_speed = 4,
	spawn_chance = 400,
	spawn_on={"default:dirt","group:stone","group:spreading_dirt_type","default:gravel","default:bedrock"},
	light_min = 1,
	light_max = 15,
	is_food=function(self,item)
		return false
	end,
	on_spawn=function(self)
		local types = {"fight_ingot","fight_hand","fight_bow"}
		self.storage.type = types[math.random(1,3)]
		self:on_load()
	end,
	on_load=function(self)
		self[self.storage.type] = true
		local t
		if self.fight_ingot then
			t = "default_ironblock.png^default_alpha_ingot.png^[makealpha:0,255,0"
			self.dmg = 3
		elseif self.fight_bow then
			t = "default_wood.png^default_bow.png^[makealpha:0,255,0"
			self.bow_t1 = t
			self.bow_t2 = "default_wood.png^default_bow_loaded.png^[makealpha:0,255,0"
			self.inv["default:bow_wood"] = math.random(0,1)
			self.inv["default:arrow_arrow"] = math.random(0,10)
		else
			t = "default_air.png"
		end
		self.object:set_properties({textures={"examobs_skeleton.png",t}})
	end,
	step=function(self)
		if self.fight and self.fight_bow and (self.aim > 0 or math.random(1,3)) and examobs.distance(self.object,self.fight) > self.reach then
			examobs.stand(self)
			examobs.anim(self,"aim")
			examobs.lookat(self,self.fight)
			if self.aim == 0 then
				self.object:set_properties({textures={"examobs_skeleton.png",self.bow_t2}})
			end
			self.aim = self.aim +math.random(0.1,0.5)
			if examobs.gethp(self.fight) == 0 or not examobs.visiable(self.object,self.fight) or examobs.distance(self.object,self.fight) > self.range then
				self.aim = 0
				self.object:set_properties({textures={"examobs_skeleton.png",self.bow_t1}})
				self.fight = nil
			elseif self.aim >= 0.5 then
				self.aim = 0
				self.object:set_properties({textures={"examobs_skeleton.png",self.bow_t1}})
				local pos2 = self.fight:get_pos()
				if pos2 and pos2.x then
					examobs.shoot_arrow(self,pos2,"default:arrow_arrow")
				end
			end
			return self
		elseif self.aim > 0 then
			self.aim = 0
			self.object:set_properties({textures={"examobs_skeleton.png",self.bow_t1}})
		end
	end,
	aim=0,
})

examobs.register_mob({
	description = "A classic murder machine that with its strength punch targets over great distances.",
	name = "terminator",
	type = "monster",
	team = "metal",
	dmg = 10,
	coin = 300,
	hp = 250,
	textures={"examobs_terminator.png"},
	mesh="character.b3d",
	spawn_on={"default:dirt","group:stone","default:gravel","default:bedrock"},
	inv={["default:steel_ingot"]=2},
	collisionbox = {-0.35,-0.01,-0.35,0.35,1.8,0.35},
	aggressivity = 2,
	walk_speed = 4,
	run_speed = 6,
	bottom=1,
	spawn_chance = 400,
	animation = {
		stand={x=1,y=39,speed=30,loop=false},
		walk={x=41,y=61,speed=30,loop=false},
		run={x=80,y=99,speed=60},
		lay={x=113,y=123,speed=0,loop=false},
		attack={x=80,y=99,speed=60},
	},
	is_food=function(self,item)
		return false
	end,
	on_punching=function(self)
		local ob = self.fight
		if examobs.gethp(ob) > 1 then
			local en =ob:get_luaentity()
			local p1 = self:pos()
			local p2 = examobs.pointat(self,50)
			local v = {x=p2.x-p1.x,y=(p2.y+20)-p1.y,z=p2.z-p1.z}
			if en then
				ob:set_velocity(v)
			else
				ob:add_velocity(v)
			end
		end
	end,
})

examobs.register_mob({
	description = "A little animal that brings some life in caes and buildings of wood.",
	name = "mouse",
	team = "mouse",
	type = "animal",
	hp = 2,
	coin = 1,
	textures = {"examobs_wolf.png^[combine:0x0:-15,-15=examobs_skin.png"},
	mesh = "examobs_mouse.obj",
	aggressivity = -2,
	run_speed = 2,
	inv={["examobs:flesh_piece"]=1},
	collisionbox={-0.2,-0.1,-0.2,0.2,0.1,0.2},
	spawn_on={"group:wood","group:stone","group:spreading_dirt_type"},
	pickupable = true,
	on_spawn=function(self)
		local a = {"examobs_wolf.png","examobs_golden_wolf.png","examobs_arctic_wolf.png","examobs_bear.png","examobs_blackbear.png"}
		self.storage.skin = a[math.random(1,5)] .. "^[combine:0x0:-15,-15=examobs_skin.png"
		self.on_load(self)
	end,
	on_load=function(self)
		if self.storage.skin then
			self.object:set_properties({textures={self.storage.skin}})
		end
	end,
	on_punched=function(self,puncher)
		examobs.dying(self,2)
		local r = self.object:get_rotation() or {{x=0,y=0,z=0}}
		self.object:set_rotation({x=r.x,y=r.y,z=math.pi})
	end,
})

examobs.register_mob({
	description = "Simply dangerous animal, made to a monster just to clear out other animals and it self.\nWas done primarily to clear away wolves and create more action in the forest.",
	name = "brown_bear",
	team = "bear",
	hp = 50,
	coin = 15,
	type = "monster",
	textures = {"examobs_bear.png"},
	mesh = "examobs_bear.b3d",
	dmg = 8,
	reach = 3,
	aggressivity = 2,
	run_speed = 6,
	inv={["examobs:flesh"]=2,["examobs:tooth"]=1},
	punch_chance=6,
	spawn_chance = 500,
	animation = {
		stand = {x=1,y=10},
		walk = {x=15,y=35},
		run = {x=15,y=35,speed=60},
		lay = {x=11,y=12,speed=0},
		attack = {x=36,y=44},
	},
	collisionbox={-1,-0.65,-1,1,0.8,1},
	spawn_on={"default:dirt_with_coniferous_grass","default:dirt_with_grass"},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end,
	on_spawn=function(self)
		self.storage.team = self.storage.team or "bear"..math.random(1,3)
		self.team = self.storage.team
	end,
	on_load=function(self)
		self.team = self.storage.team or self.team
	end,
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
})

examobs.register_mob({
	description = "Simply dangerous animal\nWas done primarily to compete with brown bears and create more action in the forest",
	name = "black_bear",
	team = "blackbear",
	hp = 50,
	coin = 15,
	type = "monster",
	textures = {"examobs_blackbear.png"},
	mesh = "examobs_bear.b3d",
	dmg = 8,
	reach = 3,
	aggressivity = 2,
	run_speed = 6,
	inv={["examobs:flesh"]=2,["examobs:tooth"]=1},
	punch_chance=6,
	spawn_chance = 300,
	animation = {
		stand = {x=1,y=10},
		walk = {x=15,y=35},
		run = {x=15,y=35,speed=60},
		lay = {x=11,y=12,speed=0},
		attack = {x=36,y=44},
	},
	collisionbox={-1,-0.65,-1,1,0.8,1},
	spawn_on={"default:dirt_with_dry_grass","default:dirt_with_jungle_grass","default:dirt_with_grass"},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end,
	on_spawn=function(self)
		self.storage.team = self.storage.team or "blackbear"..math.random(1,30)
		self.team = self.storage.team
	end,
	on_load=function(self)
		self.team = self.storage.team or self.team
	end,
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
})

examobs.register_mob({
	description = "Simply dangerous animal\nWas done primarily to bring some more life in cold biometrics",
	name = "ice_bear",
	team = "icebear",
	hp = 50,
	coin = 15,
	type = "monster",
	textures = {"examobs_icebear.png"},
	mesh = "examobs_bear.b3d",
	dmg = 8,
	reach = 3,
	aggressivity = 2,
	run_speed = 6,
	inv={["examobs:flesh"]=2,["examobs:tooth"]=1,["default:ice"]=1},
	punch_chance=6,
	spawn_chance = 300,
	animation = {
		stand = {x=1,y=10},
		walk = {x=15,y=35},
		run = {x=15,y=35,speed=60},
		lay = {x=11,y=12,speed=0},
		attack = {x=36,y=44},
	},
	collisionbox={-1,-0.65,-1,1,0.8,1},
	spawn_on={"default:ice","default:dirt_with_red_permafrost_grass","default:dirt_with_permafrost_grass","default:permafrost_dirt","default:dirt_with_snow"},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end,
	on_spawn=function(self)
		self.storage.team = self.storage.team or "icebear"..math.random(1,30)
		self.team = self.storage.team
	end,
	on_load=function(self)
		self.team = self.storage.team or self.team
	end,
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
})

examobs.register_mob({
	description = "Simply very dangerous animal that area made of lava and spreads fire",
	name = "lava_bear",
	team = "lavabear",
	hp = 50,
	coin = 25,
	type = "monster",
	textures = {"default_lava.png"},
	mesh = "examobs_bear.b3d",
	dmg = 5,
	reach = 3,
	aggressivity = 2,
	run_speed = 6,
	inv={["default:cooledlava"]=2,["examobs:tooth"]=1,["default:diamond"]=1},
	punch_chance=2,
	spawn_chance = 200,
	animation = {
		stand = {x=1,y=10},
		walk = {x=15,y=35},
		run = {x=15,y=35,speed=60},
		lay = {x=11,y=12,speed=0},
		attack = {x=36,y=44},
	},
	collisionbox={-1,-0.65,-1,1,0.8,1},
	spawn_on={"default:stone","default:cobble","default:lava_source","default:cooledlava"},
	resist_nodes = {["default:lava_source"]=1,["default:lava_flowing"]=1,["fire:basic_flame"]=1,["fire:not_igniter"]=1,["fire:permanent_flame"]=1},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end,
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
	step=function(self,dtime)
		local p = self:pos()
		if minetest.get_item_group(minetest.get_node(p).name,"cools_lava") > 0 then
			if minetest.is_protected(p, "") then
				self:hurt(50)
			else
				minetest.add_node(p,{name="default:cooledlava"})
				examobs.dropall(self)
				self.object:remove()
				return self
			end
		elseif not minetest.is_protected(p, "") then
			minetest.add_node(p,{name="fire:basic_flame"})
		end
	end,
})

examobs.register_mob({
	description = "Ice cream ball from the candy dimension.",
	name = "ball",
	hp=60,
	reach=2,
	coin = 3,
	type = "monster",
	team = "candyball",
	dmg = 1,
	textures={"examobs_icecreammonstermaster.png^[colorize:#ff75ec55"},
	mesh="examobs_icecreamball.b3d",
	visual_size={x=0.5,y=0.5},
	spawn_on={"group:candy_ground"},
	aggressivity = 2,
	walk_speed = 2,
	run_speed = 4,
	lay_on_death=0,
	max_spawn_y = 3000,
	min_spawn_y = 2000,
	animation={
		stand={x=0,y=0,speed=0},
		lay={x=0,y=0,speed=0},
		walk={x=1,y=80,speed=40},
		attack={x=1,y=8,speed=60},
	},
	collisionbox={-0.2,-0.25,-0.2,0.2,0.25,0.2},
	death=function(self)
		local pos=self:pos()
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-2, y=-2, z=-2},
			maxvel = {x=1, y=0.5, z=1},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "examobs_icecreammonstermaster.png^[colorize:#ff75ec55",
			collisiondetection = true,
		})
	end,
})

examobs.register_mob({
	description = "A little cookie from the candy dimension, hangs around with it countless family members spread over all kind of worlds.\nThis monster is especially exposed to traditions.",
	name = "gingerbread",
	hp=40,
	coin = 2,
	type = "monster",
	team = "candygingerbread",
	dmg = 1,
	textures={"examobs_gingerbread.png"},
	mesh="examobs_gingerbread.b3d",
	spawn_on={"group:candy_ground","group:candy_underground"},
	aggressivity = 2,
	walk_speed = 1.5,
	run_speed = 3,
	lay_on_death=0,
	max_spawn_y = 3000,
	min_spawn_y = 2000,
	inv={["examobs:gingerbread_piece1"]=1,["examobs:gingerbread_piece2"]=1},
	animation={
		stand={x=31,y=35,speed=0},
		walk={x=0,y=20,speed=60},
		attack={x=21,y=30,speed=30},
	},
	collisionbox={-0.2,-0.25,-0.2,0.2,0.25,0.2},
	death=function(self)
		local pos=self:pos()
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-2, y=-2, z=-2},
			maxvel = {x=1, y=0.5, z=1},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "examobs_gingerbread_piece1.png",
			collisiondetection = true,
		})
	end,
})

examobs.register_mob({
	description = "Dangerous ice cream who throws ice cream in large loads",
	name = "icecreammonstermaster",
	hp=300,
	coin = 80,
	type = "monster",
	team = "candyicecreammonstermaster",
	reach=5,
	dmg = 0,
	textures={"examobs_icecreammonstermaster.png"},
	mesh="examobs_icecreammaster.b3d",
	spawn_on={"group:candy_ground","group:candy_underground"},
	aggressivity = 2,
	bottom=-1,
	max_spawn_y = 3000,
	min_spawn_y = 2000,
	animation={
		stand={x=40,y=80,speed=30},
		walk={x=0,y=30,speed=30},
		run={x=0,y=30,speed=30},
		attack={x=80,y=105,speed=90},
		lay={x=142,y=149,speed=0},
		throw={x=105,y=140,speed=30}
	},
	collisionbox={-1,-1.0,-1,1,3,1},
	on_spawn=function(self)
		self.inv={["examobs:icecreamball"]=9}
	end,
	step=function(self,dtime)
		if self.dying or self.dead then
			return
		elseif not self.throwing and self.fight and self.fight:get_pos() and examobs.visiable(self.object,self.fight) and examobs.viewfield(self,self.fight) then
			local pos2=self.fight:get_pos()
			local pos1=self.object:get_pos()
			local d=vector.distance(pos1,pos2)
			if d>5 then
				self.is_throwing=1
				self.throwing=1
				self.time=self.otime
				examobs.stand(self)
				examobs.lookat(self,pos2)
				examobs.anim(self,"throw")
				d=d*0.05
				local p=examobs.pointat(self,4)
				minetest.after(0.7, function(p,d,self)
					if self.fight and not (self.dying or self.dead) then
						local pos2=self.fight:get_pos()
						local pos1=self.object:get_pos()
						if not (pos1 and pos2 and self) then return end
						local d={x=examobs.num((pos2.x-pos1.x)*d),y=examobs.num((pos2.y-pos1.y)*d),z=examobs.num((pos2.z-pos1.z)*d)}
						examobs.lookat(self,pos2)
						minetest.add_entity({x=p.x,y=p.y+3,z=p.z}, "examobs:icecreamball"):set_velocity(d)
					end
				end,p,d,self)
					minetest.after(1.2, function(self)
						self.throwing=nil
						if not self.object:get_pos() or self.dying or self.dead then
							return
						end
						examobs.stand(self)
					end,self)
				return self
			end
		elseif not self.throwing and self.is_throwing then
			self.is_throwing=nil
			examobs.stand(self)
		elseif self.throwing and self.fight then
			examobs.lookat(self,self.fight:get_pos())
			return self
		end
	end,
	on_punching=function(self,target)
		local pos=self.object:get_pos()
		pos.y=pos.y-0.5
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 5)) do
			local pos2=vector.round(ob:get_pos())
			if examobs.team(ob)~=self.team and examobs.visiable(self.object,ob) and examobs.viewfield(self.object,ob) then
				if ob:is_player() then
					local p2={x=pos2.x-pos.x, y=pos2.y-pos.y, z=pos2.z-pos.z}
					local a
					local ii1
					local ii2
					for i=1,10,1 do
						ii=i+1
						ii2=i
						if default.defpos({x=pos.x+(p2.x*ii), y=pos.y+(p2.y*ii)+2, z=pos.z+(p2.z*ii)},"walkable") then
							break
						end
					end
					ob:set_pos({x=pos.x+(p2.x*ii2), y=pos.y+(p2.y*ii2)+2, z=pos.z+(p2.z*ii2)})
					examobs.punch(self.object,ob,10)
				elseif ob then
					examobs.punch(self.object,ob,10)
					ob:set_velocity({x=(pos2.x-pos.x)*20, y=((pos2.y-pos.y))*30, z=(pos2.z-pos.z)*20})
				end
			end
		end
	end,
	on_punched=function(self,puncher)
		local pos=self:pos()
		if not (self.dying or self.dead) then
			examobs.anim(self,"throw")
		end
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-2, y=-2, z=-2},
			maxvel = {x=1, y=0.5, z=1},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.5,
			maxsize = 2,
			texture = "examobs_icecreamball.png",
			collisiondetection = true,
		})
	end
})

examobs.register_mob({
	description = "Living sweet appear in many different colors",
	name = "candycane",
	hp=40,
	coin = 5,
	type = "monster",
	team = "candycane",
	dmg = 1,
	textures={"examobs_candycane.png"},
	mesh="examobs_candycane.b3d",
	spawn_on={"group:candy_ground"},
	aggressivity = 2,
	inv={["examobs:candycane_piece"]=1},
	bottom=-1,
	max_spawn_y = 3000,
	min_spawn_y = 2000,
	animation={
		stand={x=1,y=150,speed=30,loop=0},
		walk={x=155,y=170,speed=30,loop=0},
		attack={x=180,y=195,speed=30,loop=0},
		lay={x=201,y=211,speed=0,loop=0}
	},
	collisionbox={-0.35,-1.0,-0.35,0.35,0.8,0.35},
	on_spawn=function(self)
		local n=0
		local t="0123456789ABCDEF"
		self.storage.color=""
  		for i=1,6,1 do
        			n=math.random(1,16)
       			self.storage.color=self.storage.color .. string.sub(t,n,n)
		end
		self.object:set_properties({textures={"default_stone.png^[colorize:#" .. self.storage.color .."ff^examobs_candycane.png"}})
	end,
	on_load=function(self)
		if not self.storage.color then
			self.spawn(self)
			return self
		end
		self.object:set_properties({textures={"default_stone.png^[colorize:#" .. self.storage.color .."ff^examobs_candycane.png"}})
	end,
	on_punched=function(self,puncher)
		local pos=self:pos()
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-2, y=-2, z=-2},
			maxvel = {x=1, y=0.5, z=1},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "examobs_candycane_piece.png^[colorize:#" .. self.storage.color .."ff^examobs_candycane.png",
			collisiondetection = true,
		})
	end,
})

examobs.register_mob({
	description = "Living sweet whose hobby is to play the clock's ding dong game",
	name = "lollipop",
	hp=40,
	coin = 5,
	type = "monster",
	team = "candylollipop",
	dmg = 1,
	textures={"examobs_lollipop.png"},
	mesh="examobs_lollipop.b3d",
	spawn_on={"group:candy_ground","group:candy_underground"},
	aggressivity = 2,
	inv={["examobs:candycane_piece"]=1},
	bottom=-1,
	max_spawn_y = 3000,
	min_spawn_y = 2000,
	animation={
		stand={x=20,y=360,speed=30},
		walk={x=1,y=20,speed=30},
		attack={x=370,y=380,speed=30},
		lay={x=381,y=386,speed=0}
	},
	collisionbox={-0.35,-1.0,-0.35,0.35,1,0.35},
	inv={["examobs:lollipop_piece"]=1},
	on_punched=function(self,puncher)
		local pos=self:pos()
		minetest.add_particlespawner({
			amount = 5,
			time =0.05,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-2, y=-2, z=-2},
			maxvel = {x=1, y=0.5, z=1},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.2,
			maxsize = 2,
			texture = "examobs_lollipop_piece.png",
			collisiondetection = true,
		})
	end,
})

examobs.register_mob({
	description = "Explosive TNT box",
	name = "tntbox",
	type = "monster",
	team = "box",
	dmg = 1,
	coin = 4,
	textures={"examobs_woodbox.png"},
	mesh="examobs_tntbox.b3d",
	spawn_on={"group:sand","group:stone"},
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	aggressivity = 2,
	walk_speed = 2,
	run_speed = 4,
	lay_on_death=0,
	spawn_chance = 300,
	animation = {
		walk = {x=0,y=40,speed=30,loop=false},
		stand = {x=0,y=0,speed=0,loop=false},
	},
	is_food=function(self,item)
		return false
	end,
	death=function(self)
		if not self.ex then
			self.ex = 1
			nitroglycerin.explode(self:pos(),{radius=5,set="fire:basic_flame",})
		end
	end,
	on_spawn=function(self)
		self:on_load(self)
	end,
	on_load=function(self)
		self.lpos = self:pos()
	end,
	wtimer = 0,
	on_abs_step=function(self)
		local d = vector.distance(self.lpos,self:pos())
		local v = self.object:get_velocity() or {x=0,y=0,z=0}
		if d > 0.5 and v.y == 0 then
			self.lpos = self:pos()	
			minetest.sound_play("examobs_wbox", {object=self.object, gain = 1, max_hear_distance = 20})
		end
	end,
})

examobs.register_mob({
	description = "Ores that comes to life by a yet unknown reason",
	name = "stoneblock",
	type = "monster",
	team = "box",
	coin = 4,
	dmg = 1,
	textures={"default_stone.png"},
	mesh="examobs_tntbox.b3d",
	spawn_on={"group:stone","default:gravel","default:bedrock","default:cobble"},
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	aggressivity = 2,
	walk_speed = 2,
	run_speed = 4,
	lay_on_death=0,
	light_min = 1,
	light_max = 15,
	animation = {
		walk = {x=0,y=40,speed=30,loop=false},
		stand = {x=0,y=0,speed=0,loop=false},
	},
	is_food=function(self,item)
		return false
	end,
	on_spawn=function(self)
		local t = {
			 {"default:stone","default_stone.png"},
			 {"default:bedrock","default_cooledlava.png"},
			 {"default:desert_cobble","default_desertcobble.png"},
			 {"default:desert_stone","default_desertstone.png"},
			 {"default:cobble","default_cobble.png"},
			 {"default:mossycobble","default_cobble.png^default_stonemoss.png"},
			 {"default:obsidian","default_obsidian.png"},
		}
		local mat = t[math.random(1,7)]
		local tex = {}
		for i = 1,6,1 do
			tex[i]=mat[2]
		end
		self.storage.tex = tex
		self.inv={[mat[1]]=1}
		self:on_load(self)
	end,
	mat={"default:stone","default_stone.png"},
	on_load=function(self)
		if self.storage.tex ~= nil then
			self.object:set_properties({textures=self.storage.tex})
		end
		self.lpos = self:pos()
	end,
	wtimer = 0,
	on_abs_step=function(self)
		local p = self:pos()
		if p then
			local d = vector.distance(self.lpos,self:pos())
			local v =  self.object:get_velocity()
			if d > 0.5 and v and v.y == 0 then
				self.lpos = self:pos()	
				minetest.sound_play("default_place_hard", {object=self.object, gain = 1, max_hear_distance = 20})
			end
		end
	end,
})

examobs.register_mob({
	description = "People that grows on stone and have there life and civilization in the underground for ages",
	name = "underground_npc",
	type = "monster",
	team = "unpc",
	dmg = 2,
	coin = 3,
	textures={"examobs_underground_npc.png"},
	mesh="character.b3d",
	spawn_on={"default:dirt","group:stone","default:gravel","default:bedrock"},
	inv={["examobs:flesh"]=1,["default:iron_ingot"]=1},
	collisionbox = {-0.35,-0.01,-0.35,0.35,1.8,0.35},
	aggressivity = 2,
	walk_speed = 2,
	run_speed = 4,
	light_min = 1,
	light_max = 10,
	bottom=1,
	animation = {
		stand={x=1,y=39,speed=30,loop=false},
		walk={x=41,y=61,speed=30,loop=false},
		run={x=80,y=99,speed=60},
		lay={x=113,y=123,speed=0,loop=false},
		attack={x=80,y=99,speed=60},
	},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end
})


examobs.register_mob({
	description = "A murder machine that shooting lightning bolts",
	name = "eletric_terminator",
	type = "monster",
	team = "metal",
	dmg = 5,
	coin = 200,
	hp = 150,
	textures={"player_style_eletric_terminator.png^[colorize:#fa7fff44"},
	mesh="character.b3d",
	spawn_on={"default:dirt","group:stone","default:gravel","default:bedrock"},
	inv={["default:steel_ingot"]=2},
	collisionbox = {-0.35,-0.01,-0.35,0.35,1.8,0.35},
	aggressivity = 2,
	floating = {["air"]=1,["default:water_source"]=1},
	walk_speed = 4,
	run_speed = 6,
	bottom=1,
	spawn_chance = 400,
	animation = {
		stand={x=1,y=39,speed=30},
		walk={x=41,y=60,speed=30},
		run={x=80,y=99,speed=60},
		lay={x=113,y=123,speed=0,loop=false},
		attack={x=65,y=75,speed=30},
	},
	is_food=function(self,item)
		return false
	end,
	on_spawn=function(self)
		self.on_load(self)
	end,
	on_load=function(self)
		self.storage.skin = "player_style_eletric_terminator.png^[colorize:#fa7fff44"
		self.bow_t1 = "default_iron.png^default_bow.png^[makealpha:0,255,0"
		self.bow_t2 = "default_iron.png^default_bow_loaded.png^[makealpha:0,255,0"
		self.inv["default:bow_iron"] = math.random(0,1)
		self.inv["default:arrow_lightning"] = math.random(0,3)
		self.object:set_properties({textures={self.storage.skin,self.bow_t1}})
	end,
	step=function(self)
		if self.fight and (self.aim > 0 or math.random(1,3)) and examobs.distance(self.object,self.fight) > self.reach then
			examobs.stand(self)
			examobs.anim(self,"aim")
			examobs.lookat(self,self.fight)
			if self.aim == 0 then
				self.object:set_properties({textures={self.storage.skin,self.bow_t2}})
			end
			self.aim = self.aim +math.random(0.1,0.5)
			if examobs.gethp(self.fight) == 0 or not examobs.visiable(self.object,self.fight) or examobs.distance(self.object,self.fight) > self.range then
				self.aim = 0
				self.object:set_properties({textures={self.storage.skin,self.bow_t1}})
				self.fight = nil
			elseif self.aim >= 0.5 then
				self.aim = 0
				self.object:set_properties({textures={self.storage.skin,self.bow_t1}})
				local pos2 = self.fight:get_pos()
				if pos2 and pos2.x then
					 pos2.y =  pos2.y -1.5
					examobs.shoot_arrow(self,pos2,"default:arrow_lightning")
				end
			end
			return self
		elseif self.aim > 0 then
			self.aim = 0
			self.object:set_properties({textures={self.storage.skin,self.bow_t1}})
		end
	end,
	aim=0,
})

examobs.register_mob({
	description = "A random person without mind",
	name = "npc",
	type = "npc",
	dmg = 1,
	coin = 2,
	reach = 3,
	textures={"character.png"},
	aggressivity = 1,
	walk_speed = 4,
	run_speed = 8,
	animation = "default",
	spawn_chance = 400,
	inv={["examobs:flesh"]=1},
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
	on_spawn=function(self)
		local r = math.random(0,4)
		local p = self.object:get_pos()

		if r <= 2 then										--single
			self.storage.skin = player_style.random_skin_type(0)
		else
			minetest.after(0,function()
				if not self.storage.family then
					local lad
					local skin1 = player_style.random_skin_type(1)
					local skin2 = player_style.random_skin_type(2)
					local skins = {skin1,skin2}

					if r == 3 then										--family
						self.storage.skin = skin1

						lad = minetest.add_entity(p,"examobs:npc"):get_luaentity()
						lad.storage.npc_generated = true
						lad.storage.family = true
						examobs.known(lad,self.object,"folow")
						examobs.known(self,lad.object,"folow")
						minetest.after(0,function()
							lad.storage.skin = skin2
							lad:on_load()
						end)
					else
						self.storage.skin = player_style.random_skin_type(0)
						skins = {self.storage.skin,self.storage.skin}
					end

					self.object:set_properties({textures={self.storage.skin}})

					if r >= 3 then										--family/single with children
						for i=1,math.random(1,4) do
							local chi = minetest.add_entity(p,"examobs:npc"):get_luaentity()
							chi.storage.npc_generated = true
							chi.storage.family = true
							chi.storage.child_size = math.random(5,9)*0.1
							examobs.known(chi,self.object,"folow")
							if lad then
								examobs.known(chi,lad.object,"folow")
							end
							minetest.after(0,function()
								chi.storage.skin = skins[math.random(1,2)]
								chi:on_load()
							end)
						end
					end
				end
			end)
		end
		self:on_load()
	end,
	on_load=function(self)
		if self.storage.skin then
			self.object:set_properties({textures={self.storage.skin}})
		end
		if self.storage.child_size then
			local s = self.storage.child_size
			local c = self.object:get_properties().collisionbox
			local c2 = {}
			for i,v in pairs(c) do
				c2[i] = v*s
			end
			self.object:set_properties({collisionbox=c2, visual_size={x=s,y=s,z=s}})
			self.aggressivity = -1
		end
	end,
})

examobs.register_mob({
	description = "Just an another random person without mind",
	name = "villager_npc",
	type = "npc",
	textures = {"examobs_villager.png"},
	dmg = 1,
	coin = 2,
	reach = 3,
	aggressivity = 1,
	walk_speed = 4,
	run_speed = 8,
	animation = "default",
	spawn_chance = 400,
	inv={["examobs:flesh"]=1},
	spawn_on={"group:wood"},
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
	on_spawn=function(self)
		self.storage.is_girl = math.random(1,2) == 1
		self.on_load(self)
	end,
	on_load=function(self)
		if self.storage.is_girl then
			self.object:set_properties({textures={"examobs_villagergirl.png"}})
		end
	end,
})

examobs.register_mob({
	description = "Another kind of humanity that farming its own relatives",
	name = "tomato_npc",
	type = "npc",
	speaking = 0,
	dmg = 1,
	coin = 2,
	reach = 3,
	aggressivity = 1,
	walk_speed = 3,
	run_speed = 6,
	animation = "default",
	textures = {"examobs_tomato_npc.png"},
	spawn_chance = 50,
	lay_on_death = 0,
	inv={["plants:tomato"]=1},
	spawn_on={"group:tomato_plant"},
	on_click=function(self,clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item():get_name()
			if item == "plants:tomato" then
				self:eat_item(item)
				default.take_item(clicker)
			end
		end
	end,
	is_food=function(self,item)
		return item == "plants:tomato"
	end,
	on_lifedeadline=function(self)
		return self.storage.npc_generated
	end,
	death=function(self)
		local pos=apos(self:pos(),0,1.5)
		minetest.add_particlespawner({
			amount = 100,
			time =0.1,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-4, y=-4, z=-4},
			maxvel = {x=4, y=8, z=4},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.1,
			maxsize = 2,
			texture = "examobs_flesh.png",
			collisiondetection = true,
		})
	end,
	tomtimer = 0,
	on_spawn=function(self)
		self.storage.planttomato_fail = 8
	end,
	step=function(self)
		if self.walkto then
			local pos = self:pos()
			local d = 5
			if pos then
				d = vector.distance(pos,self.walkto)
			end

			if d <= 2 then
				self.walkto = nil
				self.target = nil
				examobs.stand(self)
				return
			end

			examobs.lookat(self,self.walkto)
			examobs.walk(self)
			if math.random(1,4) == 1 then
				examobs.jump(self)
			end
		elseif self.tomtimer >= 5 and not self.fight and not self.flee then
			self.tomtimer = 0
			local pos = self:pos()
			if pos then

				local dis = self.storage.lasttomato and vector.distance(pos,self.storage.lasttomato) or 100
				local d2 = self.storage.lasttomato and vector.distance(pos,self.storage.lasttomato) or 100

				if not self.storage.lasttomato or not minetest.find_node_near(pos,5,{"group:tomato_plant"}) then
					dis = 100
					d2 = 100
					self.storage.lasttomato = nil
					for i,v in pairs(minetest.find_nodes_in_area(apos(pos,-20,-1,-20),apos(pos,20,5,20),{"group:tomato_plant"})) do
						local d = vector.distance(pos,v)
						if d > 4 and d < dis then
							dis = d
							self.walkto = v
							self.target = self.object
							self.storage.lasttomato = v
						end
						if d < d2 then
							d2 = d
						end
					end
				end
				if d2 > 30 then
					self:hurt(1)
					if not self.walkto then
						self.walkto = self.storage.lasttomato
					end
				else
					if self.hp < self.hp_max then
						self:heal(1)
					end
					local dp = apos(pos,0,-0.5)
					local n = minetest.get_node(dp).name
					local light = (minetest.get_node_light(pos) or 0) >= 13
					local wet = minetest.get_item_group(n,"wet_soil") > 0
					local test = (light and minetest.get_item_group(n,"soil") > 0 and not minetest.is_protected(dp, "") and not minetest.is_protected(pos,"")) == true
					local water = minetest.find_node_near(pos,7,{"group:water"}) ~= nil

					if self.storage.planttomato_fail > 10 and test and not water then
						minetest.set_node(dp,{name="default:water_source"})
						self.storage.planttomato_fail = 0

					end
					if d2 < 5 then
						if test and water and not wet then
							self.storage.planttomato_fail = 0
							minetest.set_node(dp,{name="default:wet_soil"})
							wet = true
						else
							self.storage.planttomato_fail = self.storage.planttomato_fail + 1
						end

						if test and water and wet then
							local n2 = minetest.get_node(pos).name
							if minetest.get_item_group(n2,"tomato_plant") == 0 then
								if n2 ~= "air" then
									minetest.add_item(pos,n2)
									minetest.remove_node(pos)
								end
								minetest.set_node(pos,{name="plants:tomato_seed"})
							end
						end
					end
				end
			end
		else
			self.tomtimer = self.tomtimer +1
		end
	end,
	before_spawn=function(pos)
		return true
	end,
})

examobs.register_mob({
	description = "A common form of animal, made to a monster just to clear out other animals and it self\nGive it meat to bring it to bring yourself a friend",
	name = "wolf",
	textures = {"examobs_wolf.png"},
	mesh = "examobs_wolf.b3d",
	type = "monster",
	dmg = 2,
	coin = 2,
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
	end,
	step=function(self)
		if self.fight and not self.detection then
			self.detection = true
			minetest.sound_play("examobs_wolf_detect", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.detection and not self.fight then
			self.detection = nil
		elseif math.random(1,100) == 1 then
			minetest.sound_play("examobs_wolf", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.fight and math.random(1,20) == 1 then
			minetest.sound_play("examobs_wolf_attack3", {object=self.object, gain = 1, max_hear_distance = 20})
		end
	end,
	on_punching = function(self)
		minetest.sound_play("examobs_wolf_attack"..math.random(1,2), {object=self.object, gain = 1, max_hear_distance = 20})
	end,
	on_spawn=function(self)
		self.storage.team = self.storage.team or "wolf"..math.random(1,5)
		self.team = self.storage.team
	end,
	on_load=function(self)
		self.team = self.storage.team or self.team
	end,
})

examobs.register_mob({
	description = "A rare form of machine, and an unusual dangerous alien, also called terminator wolf",
	name = "space_wolf",
	textures = {"examobs_space_wolf.png"},
	mesh = "examobs_wolf.b3d",
	type = "monster",
	dmg = 5,
	coin = 20,
	hp = 200,
	aggressivity = 2,
	run_speed = 8,
	breathing = 0,
	inv={["default:ironstick"]=4,["default:iron_ingot"]=2,["default:steel_ingot"]=1},
	punch_chance=3,
	spawn_chance = 400,
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		run = {x=32,y=52,speed=60},
		lay = {x=66,y=75},
		attack = {x=53,y=65},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
	spawn_on={"default:space_stone","default:space_dust"},
	spawn_in="default:vacuum",
	max_spawn_y = 4000,
	min_spawn_y = 2000,
	is_food=function(self,item)
		return item == "default:iron_ingot" or item == "default:iron_lump"
	end,
	step=function(self)
		if self.fight and not self.detection then
			self.detection = true
			minetest.sound_play("examobs_wolf_detect", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.detection and not self.fight then
			self.detection = nil
		elseif math.random(1,100) == 1 then
			minetest.sound_play("examobs_wolf", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.fight and math.random(1,20) == 1 then
			minetest.sound_play("examobs_wolf_attack3", {object=self.object, gain = 1, max_hear_distance = 20})
		end
	end,
	on_punching = function(self)
		minetest.sound_play("examobs_wolf_attack"..math.random(1,2), {object=self.object, gain = 1, max_hear_distance = 20})
	end,
	on_spawn=function(self)
		self.storage.team = self.storage.team or "wolf"..math.random(1,5)
		self.team = self.storage.team
	end,
	on_load=function(self)
		self.team = self.storage.team or self.team
	end,
})

examobs.register_mob({
	description = "A arctic wolf that competing with other wolfies\nGive it meat to bring it to bring yourself a friend",
	name = "arctic_wolf",
	textures = {"examobs_arctic_wolf.png"},
	mesh = "examobs_wolf.b3d",
	type = "monster",
	dmg = 2,
	coin = 2,
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
	spawn_on={"group:snowy","default:dirt_with_snow"},
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
	step=function(self)
		if self.fight and not self.detection then
			self.detection = true
			minetest.sound_play("examobs_wolf_detect", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.detection and not self.fight then
			self.detection = nil
		elseif math.random(1,100) == 1 then
			minetest.sound_play("examobs_wolf", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.fight and math.random(1,20) == 1 then
			minetest.sound_play("examobs_wolf_attack3", {object=self.object, gain = 1, max_hear_distance = 20})
		end
	end,
	on_punching = function(self)
		minetest.sound_play("examobs_wolf_attack"..math.random(1,2), {object=self.object, gain = 1, max_hear_distance = 20})
	end,
	on_spawn=function(self)
		self.storage.team = self.storage.team or "wolf"..math.random(1,5)
		self.team = self.storage.team
	end,
	on_load=function(self)
		self.team = self.storage.team or self.team
	end,
})

examobs.register_mob({
	description = "A savanna wolf that competing with other wolfies.\nGive it meat to bring it to bring yourself a friend",
	name = "golden_wolf",
	textures = {"examobs_golden_wolf.png"},
	mesh = "examobs_wolf.b3d",
	type = "monster",
	dmg = 2,
	coin = 2,
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
	end,
	step=function(self)
		if self.fight and not self.detection then
			self.detection = true
			minetest.sound_play("examobs_wolf_detect", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.detection and not self.fight then
			self.detection = nil
		elseif math.random(1,100) == 1 then
			minetest.sound_play("examobs_wolf", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.fight and math.random(1,20) == 1 then
			minetest.sound_play("examobs_wolf_attack3", {object=self.object, gain = 1, max_hear_distance = 20})
		end
	end,
	on_punching = function(self)
		minetest.sound_play("examobs_wolf_attack"..math.random(1,2), {object=self.object, gain = 1, max_hear_distance = 20})
	end,
	on_spawn=function(self)
		self.storage.team = self.storage.team or "wolf"..math.random(1,5)
		self.team = self.storage.team
	end,
	on_load=function(self)
		self.team = self.storage.team or self.team
	end,
})

examobs.register_mob({
	description = "Underground living wolf that consisting of carbon.",
	name = "underground_wolf",
	textures = {"uexamobs_underground_wolf.png"},
	mesh = "examobs_wolf.b3d",
	type = "monster",
	team = "coal",
	dmg = 2,
	coin = 2,
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
	end,
	step=function(self)
		if self.fight and not self.detection then
			self.detection = true
			minetest.sound_play("examobs_wolf_detect", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.detection and not self.fight then
			self.detection = nil
		elseif math.random(1,100) == 1 then
			minetest.sound_play("examobs_wolf", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.fight and math.random(1,20) == 1 then
			minetest.sound_play("examobs_wolf_attack3", {object=self.object, gain = 1, max_hear_distance = 20})
		end
	end,
	on_punching = function(self)
		minetest.sound_play("examobs_wolf_attack"..math.random(1,2), {object=self.object, gain = 1, max_hear_distance = 20})
	end
})

examobs.register_mob({
	description = "A fire creature living in hotness",
	name = "firewolf",
	textures = {"fire_basic_flame.png"},
	mesh = "examobs_wolf.b3d",
	type = "monster",
	team = "fire",
	dmg = 5,
	coin = 15,
	hp = 100,
	aggressivity = 2,
	swiming = 0,
	run_speed = 15,
	inv={["default:iron_ingot"]=20,["examobs:tooth"]=1},
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		run = {x=32,y=52,speed=60},
		lay = {x=66,y=75},
		attack = {x=53,y=65},
	},
	visual_size= {x=1.5,y=1.5,z=1.5},
	collisionbox={-0.9,-1.2,-0.9,0.9,0.45,0.9,},
	spawn_on={"group:fire"},
	resist_nodes = {["fire:basic_flame"]=1,["fire:not_igniter"]=1,["fire:permanent_flame"]=1},
	lay_on_death=0,
	bottom=-1,
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
	end,
	fireanim = 0,
	step=function(self)
		self.object:set_properties({textures={"[combine:16x16:0,"..(self.fireanim*-16).."=fire_basic_flame_animated.png"}})
		self.fireanim = self.fireanim + 1
		if self.fireanim > 7 then
			self.fireanim = 0
		end
		local p = self:pos()
		if minetest.get_item_group(minetest.get_node(p).name,"cools_lava") > 0 or minetest.get_item_group(minetest.get_node(apos(p,0,-1)).name,"cools_lava") > 0 then
			self:hurt(10)
		elseif not minetest.is_protected(p, "") and default.defpos(p,"buildable_to") then
			minetest.add_node(p,{name="fire:basic_flame"})
		end
		if self.fight and not self.detection then
			self.detection = true
			minetest.sound_play("examobs_wolf_detect", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.detection and not self.fight then
			self.detection = nil
		elseif math.random(1,100) == 1 then
			minetest.sound_play("examobs_wolf", {object=self.object, gain = 1, max_hear_distance = 20})
		elseif self.fight and math.random(1,20) == 1 then
			minetest.sound_play("examobs_wolf_attack3", {object=self.object, gain = 1, max_hear_distance = 20})
		end
	end,
	on_punching = function(self)
		minetest.sound_play("examobs_wolf_attack"..math.random(1,2), {object=self.object, gain = 1, max_hear_distance = 20})
	end,
	death=function(self)
		local pos=self:pos()
		local s = 5
		for x=-s,s,1 do
		for z=-s,s,1 do
		for y=-s,s,1 do
			local p = vector.new(x,y,z)
			local pos2 = vector.add(pos,p)
			if vector.length(p)/s<=1 and not minetest.is_protected(pos2, "") and default.defpos(pos2,"buildable_to") then
				minetest.add_node(pos2,{name="fire:basic_flame"})
			end
		end
		end
		end
	end
})

examobs.register_mob({
	description = "A bunch of stones",
	name = "stonemonster",
	textures = {"examobs_stonemonster.png"},
	mesh = "examobs_stonemonster.b3d",
	type = "monster",
	team = "stone",
	dmg = 5,
	hp = 40,
	coin = 6,
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
	description = "A bunch of mud",
	name = "mudmonster",
	textures = {"examobs_mudmonster.png"},
	mesh = "examobs_mudmonster.b3d",
	type = "monster",
	team = "dirt",
	dmg = 5,
	coin = 5,
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
	description = "A little bird that strange enough only lives on ground",
	name = "chicken",
	bird=true,
	swiming = 0,
	coin = 1,
	textures = {"examobs_chicken1.png"},
	mesh = "examobs_chicken.b3d",
	type = "animal",
	team = "chicken",
	punch_chance=6,
	dmg = 1,
	hp = 5,
	aggressivity = -2,
	flee_from_threats_only = 1,
	inv={["examobs:chickenleg"]=1,["examobs:feather"]=1},
	walk_speed=2,
	run_speed=4,
	pickupable = true,
	animation = {
		stand = {x=0,y=10,speed=0},
		walk = {x=20,y=30},
		run = {x=20,y=30,speed=60},
		lay = {x=41,y=45,speed=0},
		attack = {x=20,y=30},
	},
	collisionbox={-0.3,-0.35,-0.3,0.3,0.4,0.3},
	to_chick=function(self)
		self.storage.chick_collbox = self.object:get_properties().collisionbox
		self.storage.chick_size = 0.1
		self.object:set_properties({
			textures={"examobs_chick.png"},
		})
		self:chick()
	end,
	chick=function(self)
		self.storage.chick_size = self.storage.chick_size + 0.01

		local s = self.storage.chick_size
		local c1 = self.storage.chick_collbox
		local c2 = {}
		for i=1,6 do
			c2[i] = c1[i] * s
		end

		self.object:set_properties({
			collisionbox = c2,
			visual_size={x=s,y=s,z=s}
		})

		if self.storage.chick_size >= 1 then
			self.storage.chick_size = nil
			self.storage.chick_collbox = nil
			self.storage.chick_halfgrown = nil
			self:on_spawn()
		elseif not self.storage.chick_halfgrown and s >= 0.5 then
			self.storage.chick_halfgrown = 1
			self:on_spawn()
		end
	end,
	spawn_on={"group:spreading_dirt_type"},
	egg_timer = math.random(1,600),
	on_spawn=function(self)
		local r = math.random(1,3)
		self.inv["examobs:feather"]=math.random(1,3)
		self.storage.skin="examobs_chicken" .. r ..".png"
		self.object:set_properties({textures={self.storage.skin}})
		self.storage.rooster = r == 2
	end,
	on_load=function(self)
		if self.storage.chick_size then
			self:chick()
			if not self.storage.chick_halfgrown then
				self.object:set_properties({textures={"examobs_chick.png"}})
				return
			end
		end

		self.object:set_properties({textures={self.storage.skin or "examobs_chicken1.png"}})
	end,
	step=function(self)
		if self.storage.chick_size then
			self:chick()
			return
		end

		if self.storage.rooster and math.random(1,60) == 1 then
			minetest.sound_play("examobs_rooster", {object=self.object, gain = 1, max_hear_distance = 30, pitch = math.random(8,15)*0.1})
		end

		self.egg_timer = self.egg_timer -1
		if self.egg_timer < 1 then
			if self.flee or self.fight then
				self.egg_timer = math.random(1,600)
			elseif minetest.get_item_group(minetest.get_node(apos(self:pos(),0,-1)).name,"soil") > 0 and self.object:get_velocity().y == 0 then
				local pos = self:pos()
				minetest.add_node(pos,{name="examobs:egg"})
				self.egg_timer = math.random(1,600)
			end
		end
	end,
	is_food=function(self,item)
		return false
	end,
	on_click=function(self,clicker)
		self.flee = clicker
		examobs.known(self,clicker,"flee")
	end,
})

examobs.register_mob({
	description = "A new discover but yet unknown creature that farmers using as food source",
	name = "pig",
	textures = {"examobs_pig.png"},
	mesh = "examobs_pig.b3d",
	type = "animal",
	team = "pig",
	coin = 2,
	dmg = 1,
	hp = 15,
	aggressivity = -1,
	flee_from_threats_only = 1,
	inv={["examobs:flesh"]=3},
	walk_speed=2,
	run_speed=4,
	animation = {
		stand = {x=1,y=10,speed=0},
		walk = {x=20,y=40,speed=60},
		run = {x=20,y=40,speed=100},
		lay = {x=50,y=60,speed=0},
		attack = {x=1,y=10},
	},
	collisionbox={-0.5,-0.5,-0.5,0.5,0.3,0.5},
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
	on_click=function(self,clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item():get_name()
			if minetest.get_item_group(item,"grass") > 0 then
				self:eat_item(item,2)
				default.take_item(clicker)
				self.folow = clicker
				examobs.known(self,clicker,"folow")
				self.storage.tamed = 1
			end
		end
	end
})

examobs.register_mob({
	description = "A very common form of animal used as wool source, you can also color it by punch it with dye in your hand",
	name = "sheep",
	spawner_egg = true,
	textures = {"examobs_wool.png^examobs_sheep.png"},
	mesh = "examobs_sheep.b3d",
	type = "animal",
	team = "sheep",
	coin = 2,
	punch_chance=6,
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
	description = "A common type of bird that whose dedicate their lives to living on land and water but have a tendency to drown those it self",
	name = "duck",
	bird=true,
	coin = 1,
	textures = {"examobs_duck1.png"},
	mesh = "examobs_duck.b3d",
	type = "animal",
	team = "duck",
	dmg = 1,
	punch_chance=6,
	hp = 5,
	aggressivity = -1,
	inv={["examobs:chickenleg"]=1,["examobs:feather"]=1},
	walk_speed=2,
	run_speed=4,
	pickupable = true,
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
	description = "Random colored birds",
	pickupable = true,
	visual_size= {x=0.5,y=0.5,z=0.5},
	collisionbox={-0.2,-0.13,-0.2,0.2,0.2,0.2},
	coin = 1,
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
	description = "The bird that dedicate their lives to collect all kind of items",
	pickupable = true,
	name = "magpie",
	coin = 1,
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
			if not self.item:get_pos() or not examobs.visiable(self.object,self.item) or not self.item:get_luaentity() then
				self.item = nil
				self.target = nil
				return
			elseif examobs.distance(self.object,self.item) <= 1 then
				local item = string.split(self.item:get_luaentity().itemstring.." "," ")
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
	description = "A black bird",
	pickupable = true,
	name = "crow",
	coin = 1,
	aggressivity = -2,
	textures={"examobs_crow.png"},
	is_food=function(self,item)
		return minetest.get_item_group(item,"eatable") > 0
	end
})

examobs.register_bird({
	description = "A creaking kind of bird",
	pickupable = true,
	name = "gull",
	coin = 1,
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
	description = "A kind of underground living bird that consisting of coal",
	pickupable = true,
	name = "coalcrow",
	coin = 2,
	aggressivity = 2,
	is_food=function(self,item)
		return true
	end,
	hp = 10,
	dmg = 1,
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
	description = "A bigger kind of bird where the main purpose is to clear the air from birds. However those have a tendency to drown themselves in water",
	name = "hawk",
	coin = 2,
	aggressivity = 1,
	is_food=function(self,item)
		return true
	end,
	hp = 20,
	dmg = 2,
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
		if en and examobs.gethp(self.fight)-self.dmg <=0 and en.inv then
			en.inv["examobs:feather"]=nil
			en.inv["examobs:chickenleg"]=nil
		end
	end,
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end
})

examobs.register_fish({
	description = "Random colored fish",
	pickupable = true,
	color = true,
	coin = 1,
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
	description = "A common kind of fish",
	pickupable = true,
	name = "perch",
	coin = 1,
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
	description = "The monster fish",
	name = "shark",
	team = "shark",
	coin = 10,
	type = "monster",
	hp = 50,
	dmg = 5,
	mesh = "examobs_shark.b3d",
	lay_on_death = 1,
	textures = {"examobs_shark1.png"},
	inv={["examobs:flesh"]=5,["examobs:tooth"]=8},
	walk_speed=2,
	run_speed=5,
	reach=4,
	animation = {
		stand = {x=0,y=10,speed=0},
		walk = {x=20,y=38,speed=20},
		run = {x=40,y=48,speed=20},
		lay = {x=65,y=66,speed=0},
		attack = {x=55,y=60,speed=30},
	},
	aggressivity = 2,
	spawn_chance = 500,
	on_spawn=function(self)
		self.storage.size = math.random(1,7)
		self.storage.c = math.random(1,3)
		self:on_load()
	end,
	on_load=function(self)
		examobs.anim(self,"walk")
		local s = self.storage.size or 1
		local c = self.storage.c or 1
		self.object:set_properties({
			visual_size = {x=s,y=s,z=s},
			textures = {"examobs_shark"..c..".png"},
			collisionbox = {-0.5*(s/2),-0.2*(s/2),-0.5*(s/2),0.5*(s/2),0.5*(s/2),0.5*(s/2)},
		})
		self.reach = 1 + s
		self.dmg = 5 + s
	end,
	before_punching=function(self)
		local en = self.fight:get_luaentity()
		if en and examobs.gethp(self.fight)-self.dmg <= 0 and en.inv then
			for i,v in pairs(en.inv) do
				if minetest.get_item_group(i,"meat") > 0 then
					self:eat_item(i.." "..v)
				else
					self.inv[i] = (self.inv[i] or 0) + v
				end
				en.inv[i]=nil
			end
			local c = self.object:get_properties().collisionbox
			local es = math.max(math.abs(c[1])+math.abs(c[4]),math.abs(c[2])+math.abs(c[5]),math.abs(c[3])+math.abs(c[6]))
			if es < self.storage.size+0.5 then
				self.fight:remove()
			end
			
		end
	end,
	on_fly=function(self,x,y,z)
		if self.fight then
			examobs.anim(self,"run")
		end
	end,
})

examobs.register_fish({
	description = "The lava shark",
	name = "lavashark",
	team = "shark",
	coin = 10,
	type = "monster",
	hp = 150,
	dmg = 10,
	mesh = "examobs_shark.b3d",
	lay_on_death = 1,
	textures = {"examobs_sharklava.png"},
	hurt_outside = 0,
	inv={["default:obsidian"]=1,["default:cooledlava"]=2,["examobs:tooth"]=1,["default:diamond"]=3},
	walk_speed=2,
	run_speed=5,
	reach=4,
	floating_in_group = "lava",
	spawn_on = {"default:lava_source"},
	spawn_in = "default:lava_source",
	resist_nodes = {["default:lava_source"]=1,["default:lava_flowing"]=1,["fire:basic_flame"]=1,["fire:not_igniter"]=1,["fire:permanent_flame"]=1},
	animation = {
		stand = {x=0,y=10,speed=0},
		walk = {x=20,y=38,speed=20},
		run = {x=40,y=48,speed=20},
		lay = {x=65,y=66,speed=0},
		attack = {x=55,y=60,speed=30},
	},
	aggressivity = 2,
	spawn_chance = 500,
	on_spawn=function(self)
		self.storage.size = math.random(3,7)
		self:on_load()
	end,
	on_load=function(self)
		examobs.anim(self,"walk")
		local s = self.storage.size or 1
		self.object:set_properties({
			visual_size = {x=s,y=s,z=s},
			collisionbox = {-0.5*(s/2),-0.2*(s/2),-0.5*(s/2),0.5*(s/2),0.5*(s/2),0.5*(s/2)},
		})
		self.reach = 1 + s
		self.dmg = 10 + s
	end,
	before_punching=function(self)
		local en = self.fight:get_luaentity()
		if en and examobs.gethp(self.fight)-self.dmg <= 0 and en.inv then
			for i,v in pairs(en.inv) do
				if minetest.get_item_group(i,"meat") > 0 then
					self:eat_item(i.." "..v)
				else
					self.inv[i] = (self.inv[i] or 0) + v
				end
				en.inv[i]=nil
			end
			local c = self.object:get_properties().collisionbox
			local es = math.max(math.abs(c[1])+math.abs(c[4]),math.abs(c[2])+math.abs(c[5]),math.abs(c[3])+math.abs(c[6]))
			if es < self.storage.size+0.5 then
				self.fight:remove()
			end
		end
	end,
	on_fly=function(self,x,y,z)
		if self.fight then
			examobs.anim(self,"run")
		end
	end,
	step=function(self,dtime)
		local p = self:pos()
		if minetest.get_item_group(minetest.get_node(p).name,"cools_lava") > 0 then
			if minetest.is_protected(p, "") then
				self:hurt(50)
			else
				minetest.add_node(p,{name="default:obsidian"})
				examobs.dropall(self)
				self.object:remove()
				return self
			end
		elseif not minetest.is_protected(p, "") then
			minetest.add_node(p,{name="fire:basic_flame"})
		end
	end,


})

examobs.register_fish({
	description = "A monster some is calling fish",
	name = "pike",
	team = "pike",
	coin = 2,
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
	description = "A very dangerous kind of fish that cooperting with its family members in an effective way to clear the oceans of life",
	name = "piranha",
	team = "piranha",
	coin = 2,
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
examobs.register_fish({
	description = "Fish made of clouds",
	name = "cloud",
	floating = {["default:cloud"]=1,["air"]=1},
	floating_in_group = "cloud",
	textures = {"default_cloud.png"},
	physical = false,
	inv={["examobs:cloud"]=1,["default:cloud"]=1},
	spawn_on = {"default:cloud"},
	spawn_in = "default:cloud",
	hurt_outside = 0,
	on_spawn=function(self)
		self.storage.size = math.random(0.5,2)
		self:on_load()
	end,
	on_load=function(self)
		local s = self.storage.size or 1
		self.object:set_properties({visual_size= {x=s,y=s,z=s}})
		self.storage.lastcpos = self.storage.lastcpos or self:pos()
	end,
	step=function(self)
		local p = self:pos()
		if minetest.get_node(p).name == "default:cloud" then
			self.storage.lastcpos = p
			if self.was_outside then
				self.was_outside = nil
				local v = self.object:get_velocity()
				self.object:set_velocity({x=v.x,y=0,z=v.z})
			end
		else
			examobs.lookat(self,self.storage.lastcpos)
			examobs.walk(self)
			local v = self.object:get_velocity()
			local py = math.floor(p.y+0.5)
			local ly = math.floor(self.storage.lastcpos.y+0.5)
			if py > ly then
				self.object:set_velocity({x=v.x,y=-3,z=v.z})
			elseif py < ly then
				self.object:set_velocity({x=v.x,y=3,z=v.z})
			end
			self.was_outside = true
			return self
		end
	end
})

examobs.register_mob({
	description = "A classic terrorist",
	name = "gass_man",
	type = "monster",
	coin = 2,
	team = "gass",
	textures = {"examobs_gassman.png"},
	aggressivity = 2,
	walk_speed = 1,
	dmg = 0,
	run_speed = 4,
	animation = "default",
	spawn_chance = 600,
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
	description = "A yet unknown phenomenon without collision that floats around, even through materials.\nThe yet only known way to affect this mod is to blow it up",
	name = "airmonster",
	type = "monster",
	physical = false,
	coin = 30,
	team = "air",
	floating = {["air"]=1,["default:water_source"]=1,["defult:dirt"]=1,["default:sand"]=1,["default:desert_sand"]=1},
	floating_in_group = "cracky",
	textures = {"examobs_airmonster.png"},
	aggressivity = 1,
	walk_speed = 1,
	dmg = 1,
	run_speed = 4,
	lay_on_death=0,
	glow = 14,
	animation = {
		stand={x=136,y=156,speed=0},
		walk={x=136,y=156,speed=30},
		run={x=136,y=156,speed=60},
		attack={x=136,y=156,speed=60},
	},
	spawn_chance = 500,
	spawn_on={"default:desert_sand","group:spreading_dirt_type","group:stone"},
	step=function(self)
		self.is_floating = true
		if self.fight and math.random(1,10) == 1 and examobs.distance(self.object,self.fight) < 5 then
			local pos1 = self:pos()
			local pos2 = self.fight:get_pos()
			if pos1 and pos2 then
				local p = {
					x=pos2.x+((pos1.x-pos2.x)*-1),
					y=pos1.y,
					z=pos2.z+(pos1.z-pos2.z)*-1
				}
				self.object:set_pos(p)
			end
		elseif walkable(self.object:get_pos()) then
			self.object:set_velocity({x=0,y=1,z=0})
		elseif self.object:get_velocity().y == 1 then
			self.object:set_velocity({x=0,y=0,z=0})
		end
	end
})

examobs.register_mob({
	description = "Mob consisting of sand",
	name = "sandmonster",
	type = "monster",
	dmg = 2,
	coin = 1,
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

examobs.register_mob({
	description = "Just an alien",
	name = "alien",
	textures = {"player_style_alien1.png"},
	type = "monster",
	dmg = 2,
	coin = 5,
	hp = 100,
	aggressivity = 2,
	run_speed = 12,
	breathing = 0,
	inv={["default:iron"]=2},
	animation = "default",
	spawn_on={"default:space_stone","default:space_dust"},
	spawn_in="default:vacuum",
	spawn_chance = 400,
	max_spawn_y = 4000,
	min_spawn_y = 2000,
	is_food=function(self,item)
		return item == "default:iron_ingot" or item == "default:iron_lump"
	end,
	on_spawn=function(self)
		self.storage.texture ="player_style_alien"..math.random(1,8)..".png"
		self:on_load()
	end,
	on_load=function(self)
		self.object:set_properties({textures={self.storage.texture}})
		self.team = self.storage.texture
	end
})

examobs.register_mob({
	description = "You do not need a magnifying glass to see this bug",
	name = "macro_beetle",
	type = "monster",
	team = "beetle",
	dmg = 2,
	coin = 5,
	textures={"examobs_coalcrow.png"},
	mesh="examobs_beetle.b3d",
	spawn_on={"default:dirt","group:stone","default:bedrock"},
	inv={["examobs:bugflesh"]=1,["default:amethyst"]=1},
	collisionbox = {-2,-1,-2,2,0.5,2},
	aggressivity = 2,
	hp = 100,
	walk_speed = 4,
	run_speed = 8,
	light_min = 1,
	light_max = 15,
	visual_size = {x=10,y=10,z=10},
	reach = 5,
	min_spawn_y = 4000,
	max_spawn_y = 5000,
	bottom=2,
	animation = {
		stand={x=1,y=5,speed=0,loop=false},
		walk={x=10,y=20,speed=15},
		run={x=10,y=20,speed=30},
		lay={x=25,y=30,speed=0,loop=false},
		attack={x=1,y=5,speed=20},
	},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end
})
examobs.register_mob({
	description = "The big bug that survives through others blood",
	name = "macro_tick",
	type = "monster",
	team = "tick",
	dmg = 2,
	coin = 15,
	hp = 150,
	textures={"default_coalblock.png"},
	mesh="examobs_tick.b3d",
	spawn_on={"default:dirt","group:stone","default:bedrock"},
	inv={["examobs:bugflesh"]=1,["default:taaffeite"]=2},
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.25,0.5},
	aggressivity = 2,
	walk_speed = 4,
	run_speed = 8,
	light_min = 1,
	light_max = 15,
	visual_size = {x=5,y=5,z=5},
	reach = 2,
	min_spawn_y = 4000,
	max_spawn_y = 5000,
	animation = {
		stand={x=1,y=5,speed=0,loop=false},
		walk={x=10,y=20,speed=15},
		run={x=10,y=20,speed=30},
		lay={x=25,y=30,speed=0,loop=false},
		attack={x=1,y=5,speed=20},
	},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end,
	on_spawn=function(self)
		local t = {
			 {"default_stone.png"},
			 {"examobs_flesh.png"},
			 {"examobs_meat.png"},
			 {"default_desertstone.png"},
			 {"default_cobble.png"},
			 {"default_cobble.png^default_stonemoss.png"},
			 {"default_coalblock.png"},
		}
		self.storage.tex =  t[math.random(1,7)]
		self:on_load(self)
	end,
	on_load=function(self)
		if self.storage.tex ~= nil then
			self.object:set_properties({textures=self.storage.tex})
		end
	end
})

examobs.register_bird({
	description = "The only fly you should flee from, seriously",
	pickupable = true,
	name = "macro_fly",
	mesh="examobs_fly.b3d",
	coin = 5,
	aggressivity = 1,
	is_food=function(self,item)
		return true
	end,
	inv={["examobs:bugflesh"]=1,["default:opal"]=1},
	hp = 40,
	dmg = 1,
	team = "fly",
	type = "monster",
	walk_speed = 4,
	run_speed = 30,
	spawn_on = {"default:dirt","group:macroplant"},
	light_min = 9,
	light_max = 15,
	textures={"examobs_coalcrow.png"},
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.25,0.5},
	visual_size = {x=5,y=5,z=5},
	reach = 2,
	min_spawn_y = 4000,
	max_spawn_y = 5000,
	animation = {
		stand={x=1,y=5,speed=0,loop=false},
		walk={x=10,y=20,speed=15},
		run={x=10,y=20,speed=30},
		lay={x=25,y=30,speed=0,loop=false},
		attack={x=30,y=35,speed=20},
		eat={x=30,y=35,speed=20},
		fly={x=31,y=35,speed=50},
		float={x=31,y=35,speed=50},
	},
	on_spawn=function(self)
		local t = {"examobs_coalcrow.png","examobs_crow.png","examobs_hawk.png","examobs_gull.png^[colorize:#777777aa"}
		self.storage.tex = t[math.random(1,4)]
		self.storage.size = math.random(4,6)
		self:on_load(self)
	end,
	on_load=function(self)
		if self.storage.size then
			self.object:set_properties({
				visual_size={x=self.storage.size,y=self.storage.size ,self.storage.size},
				textures = {self.storage.tex}
			})
		end
	end,
	is_food=function(self,item)
		return true
	end,
	flysound_timeout= 0,
	step=function(self,dtime)

		local at = self.object:get_attach()
		if at and at:is_player() then
			self.storage.fly = 1
				at:add_velocity({x=math.random(-20,20) ,y=math.random(0,5) ,z=math.random(-20,20) })
		end

		if self.storage.fly then
			self.flysound_timeout = self.flysound_timeout - dtime*100
			if self.flysound_timeout <= 0 then
				self.flysound_timeout = 2
				self.flysound = minetest.sound_play("examobs_bee", {object=self.object, gain = 2, max_hear_distance = 20})
			end
		elseif self.flysound then
			minetest.sound_stop(self.flysound)
			self.flysound = nil
		end
	end,
})

examobs.register_bird({
	description = "Just run away from it",
	pickupable = true,
	name = "macro_wasp",
	mesh="examobs_wasp.b3d",
	coin = 200,
	aggressivity = 1,
	is_food=function(self,item)
		return true
	end,
	inv={["examobs:bugflesh"]=1,["default:peridotblock"]=1},
	hp = 100,
	dmg = 200,
	team = "wasp",
	type = "monster",
	walk_speed = 4,
	run_speed = 20,
	spawn_on = {"default:dirt","group:macroplant"},
	light_min = 9,
	light_max = 15,
	textures={"examobs_wasp.png"},
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.25,0.5},
	visual_size = {x=5,y=5,z=5},
	reach = 2,
	min_spawn_y = 4000,
	max_spawn_y = 5000,
	animation = {
		stand={x=1,y=5,speed=0,loop=false},
		walk={x=10,y=20,speed=15},
		run={x=10,y=20,speed=30},
		lay={x=25,y=30,speed=0,loop=false},
		attack={x=30,y=35,speed=20},
		eat={x=30,y=35,speed=20},
		fly={x=31,y=35,speed=50},
		float={x=31,y=35,speed=50},
	},
	on_spawn=function(self)
		self.storage.size = math.random(4,6)
		self:on_load(self)
	end,
	on_load=function(self)
		if self.storage.size then
			self.object:set_properties({
				visual_size={x=self.storage.size,y=self.storage.size ,self.storage.size},
			})
		end
	end,
	is_food=function(self,item)
		return true
	end,
	flysound_timeout= 0,
	step=function(self,dtime)

		local at = self.object:get_attach()
		if at and at:is_player() then
			self.storage.fly = 1
				at:add_velocity({x=math.random(-50,50) ,y=math.random(0,7) ,z=math.random(-50,50) })
		end

		if self.storage.fly then
			self.flysound_timeout = self.flysound_timeout - dtime*100
			if self.flysound_timeout <= 0 then
				self.flysound_timeout = 2
				self.flysound = minetest.sound_play("examobs_bee", {object=self.object, gain = 2, max_hear_distance = 20})
			end
		elseif self.flysound then
			minetest.sound_stop(self.flysound)
			self.flysound = nil
		end
	end,
})

examobs.register_mob({
	description = "A big bug",
	name = "beetle",
	type = "animal",
	team = "bug",
	dmg = 1,
	coin = 1,
	pickupable = true,
	textures={"examobs_coalcrow.png"},
	mesh="examobs_beetle.b3d",
	spawn_on={"default:dirt","group:stone","group:spreading_dirt_type"},
	inv={["examobs:bugflesh"]=1},
	collisionbox = {-0.2,-0.1,-0.2,0.2,0.05,0.2},
	aggressivity = 0,
	hp = 2,
	walk_speed = 1,
	run_speed = 2,
	light_min = 1,
	light_max = 15,
	visual_size = {x=1,y=1,z=1},
	reach = 5,
	animation = {
		stand={x=1,y=5,speed=0,loop=false},
		walk={x=10,y=20,speed=15},
		run={x=10,y=20,speed=30},
		lay={x=25,y=30,speed=0,loop=false},
		attack={x=1,y=5,speed=20},
	},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end
})

examobs.register_mob({
	description = "The bug that survives through others blood",
	name = "tick",
	type = "monster",
	team = "tick",
	dmg = 1,
	coin = 1,
	hp = 5,
	textures={"default_coalblock.png"},
	mesh="examobs_tick.b3d",
	spawn_on={"default:dirt","group:stone","group:leaves","group:spreading_dirt_type"},
	inv={["examobs:bugflesh"]=1},
	collisionbox = {-0.05,-0.05,-0.05,0.05,0.025,0.05},
	aggressivity = 2,
	walk_speed = 1,
	run_speed = 2,
	light_min = 1,
	light_max = 15,
	visual_size = {x=0.5,y=0.5,z=0.5},
	reach = 2,
	animation = {
		stand={x=1,y=5,speed=0,loop=false},
		walk={x=10,y=20,speed=15},
		run={x=10,y=20,speed=30},
		lay={x=25,y=30,speed=0,loop=false},
		attack={x=1,y=5,speed=20},
	},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
	end,
	on_spawn=function(self)
		local t = {
			 {"default_stone.png"},
			 {"examobs_flesh.png"},
			 {"examobs_meat.png"},
			 {"default_desertstone.png"},
			 {"default_cobble.png"},
			 {"default_cobble.png^default_stonemoss.png"},
			 {"default_coalblock.png"},
		}
		self.storage.tex =  t[math.random(1,7)]
		self:on_load(self)
	end,
	on_load=function(self)
		if self.storage.tex ~= nil then
			self.object:set_properties({textures=self.storage.tex})
		end
	end
})

examobs.register_bird({
	description = "A fly, seriously?",
	pickupable = true,
	name = "fly",
	mesh="examobs_fly.b3d",
	coin = 1,
	aggressivity = 1,
	is_food=function(self,item)
		return true
	end,
	inv={["examobs:bugflesh"]=1},
	hp = 1,
	dmg = 1,
	team = "fly",
	type = "animal",
	walk_speed = 2,
	run_speed = 4,
	spawn_on = {"default:dirt","group:spreading_dirt_type","group:wood"},
	light_min = 9,
	light_max = 15,
	textures={"examobs_coalcrow.png"},
	collisionbox = {-0.05,-0.05,-0.05,0.05,0.025,0.05},
	visual_size = {x=0.5,y=0.5,z=0.5},
	reach = 2,
	animation = {
		stand={x=1,y=5,speed=0,loop=false},
		walk={x=10,y=20,speed=15},
		run={x=10,y=20,speed=30},
		lay={x=25,y=30,speed=0,loop=false},
		attack={x=30,y=35,speed=20},
		eat={x=30,y=35,speed=20},
		fly={x=31,y=35,speed=50},
		float={x=31,y=35,speed=50},
	},
	on_spawn=function(self)
		local t = {"examobs_coalcrow.png","examobs_crow.png","examobs_hawk.png","examobs_gull.png^[colorize:#777777aa"}
		self.storage.tex = t[math.random(1,4)]
		self.storage.size = math.random(4,6)*0.1
		self:on_load(self)
	end,
	on_load=function(self)
		if self.storage.size then
			self.object:set_properties({
				visual_size={x=self.storage.size,y=self.storage.size ,self.storage.size},
				textures = {self.storage.tex}
			})
		end
	end,
	is_food=function(self,item)
		return true
	end,
	flysound_timeout= 0,
	step=function(self,dtime)
		local at = self.object:get_attach()
		if at and at:is_player() then
			self.storage.fly = 1
				at:add_velocity({x=math.random(-2,2) ,y=math.random(0,1) ,z=math.random(-2,2) })
		end
		if self.storage.fly then
			self.flysound_timeout = self.flysound_timeout - dtime*100
			if self.flysound_timeout <= 0 then
				self.flysound_timeout = 2
				self.flysound = minetest.sound_play("examobs_bee", {object=self.object, gain = 2, max_hear_distance = 20})
			end
		elseif self.flysound then
			minetest.sound_stop(self.flysound)
			self.flysound = nil
		end
	end,
})

examobs.register_bird({
	description = "Run away from that stinging alien",
	pickupable = true,
	name = "wasp",
	mesh="examobs_wasp.b3d",
	coin = 1,
	aggressivity = 1,
	is_food=function(self,item)
		return true
	end,
	inv={["examobs:bugflesh"]=1},
	hp = 3,
	dmg = 1,
	team = "wasp",
	type = "monster",
	walk_speed = 2,
	run_speed = 4,
	spawn_on = {"default:dirt","group:spreading_dirt_type","group:wood"},
	light_min = 9,
	light_max = 15,
	textures={"examobs_wasp.png"},
	collisionbox = {-0.05,-0.05,-0.05,0.05,0.025,0.05},
	visual_size = {x=0.5,y=0.5,z=0.5},
	reach = 2,
	animation = {
		stand={x=1,y=5,speed=0,loop=false},
		walk={x=10,y=20,speed=15},
		run={x=10,y=20,speed=30},
		lay={x=25,y=30,speed=0,loop=false},
		attack={x=30,y=35,speed=20},
		eat={x=30,y=35,speed=20},
		fly={x=31,y=35,speed=50},
		float={x=31,y=35,speed=50},
	},
	on_spawn=function(self)
		self.storage.size = math.random(4,6)*0.1
		self:on_load(self)
	end,
	on_load=function(self)
		if self.storage.size then
			self.object:set_properties({
				visual_size={x=self.storage.size,y=self.storage.size ,self.storage.size},
			})
		end
	end,
	is_food=function(self,item)
		return true
	end,
	flysound_timeout= 0,
	step=function(self,dtime)
		local at = self.object:get_attach()
		if at and at:is_player() then
			self.storage.fly = 1
				at:add_velocity({x=math.random(-5,5) ,y=math.random(0,1) ,z=math.random(-5,5) })
		end
		if self.storage.fly then
			self.flysound_timeout = self.flysound_timeout - dtime*100
			if self.flysound_timeout <= 0 then
				self.flysound_timeout = 2
				self.flysound = minetest.sound_play("examobs_bee", {object=self.object, gain = 2, max_hear_distance = 20})
			end
		elseif self.flysound then
			minetest.sound_stop(self.flysound)
			self.flysound = nil
		end
	end,
})

examobs.register_mob({
	description = "A living phenomenon made of slime, came from nowhere",
	name = "slime",
	type = "monster",
	team = "slime",
	hp = 5,
	light_min = 1,
	light_max = 15,
	reach = 2,
	min_spawn_y = 5000,
	max_spawn_y = 6000,
	speaking = 0,
	dmg = 1,
	coin = 1,
	aggressivity = 2,
	walk_speed = 3,
	run_speed = 6,
	animation = "default",
	textures = {"player_style_slime.png"},
	spawn_chance = 100,
	lay_on_death = 0,
	inv={["materials:slime"]=1},
	spawn_on={"materials:slime"},
	on_click=function(self,clicker)
		if clicker:is_player() then
			local item = clicker:get_wielded_item():get_name()
			if item == "materials:slime" then
				self:eat_item(item)
				default.take_item(clicker)
			end
		end
	end,
	is_food=function(self,item)
		return item == "materials:slime"
	end,
	death=function(self)
		local pos=apos(self:pos(),0,1.5)
		minetest.add_particlespawner({
			amount = 100,
			time =0.1,
			minpos = pos,
			maxpos = pos,
			minvel = {x=-4, y=-4, z=-4},
			maxvel = {x=4, y=8, z=4},
			minacc = {x=0, y=-8, z=0},
			maxacc = {x=0, y=-10, z=0},
			minexptime = 2,
			maxexptime = 1,
			minsize = 0.1,
			maxsize = 2,
			texture = "default_water.png^[colorize:#0f0c",
			collisiondetection = true,
		})
	end,
})

examobs.register_mob({
	description = "Dirt monster",
	name = "dirtmonster",
	hp=50,
	coin = 5,
	type = "monster",
	team = "dirt",
	walk_speed = 1,
	run_speed = 3,
	reach=5,
	dmg = 0,
	textures={"examobs_meat.png^[colorize:#544b30aa"},
	mesh="examobs_icecreammaster.b3d",
	spawn_on={"default:dirt","","group:spreading_dirt_type"},
	aggressivity = 2,
	bottom=-0.5,
	light_min = 1,
	light_max = 9,
	breathing = 0,
	visual_size={x=0.5,y=0.5,z=0.5},
	collisionbox={-0.5,-0.5,-0.5,0.5,1.5,0.5},
	animation={
		stand={x=40,y=80,speed=30},
		walk={x=0,y=30,speed=30},
		run={x=0,y=30,speed=30},
		attack={x=80,y=105,speed=90},
		lay={x=142,y=149,speed=0},
		throw={x=105,y=140,speed=30}
	},
	inv={["default:dirt"]=5,["examobs:poop"]=5},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0 or minetest.get_item_group(item,"dirt") > 0
	end,
	step=function(self,dtime)
		if self.dying or self.dead then
			return
		elseif (minetest.get_node_light(self:pos()) or 0) > 9 then
			self:hurt(1)
		elseif self.fight and math.random(1,30) == 1 then
			local pos = self.object:get_pos()
			local p = minetest.find_nodes_in_area(vector.add(pos, 5),vector.subtract(pos, 5),{"air"})
			local air = {}
			for i,n in pairs(p) do
				if not minetest.is_protected(n, "") then
					table.insert(air,n)
				end
			end
			if #air > 0 then
				minetest.sound_play("examobs_fart", {object=self.object, gain = 2, max_hear_distance = 30})
				minetest.bulk_set_node(air, {name = "default:gas"})
				for i,n in pairs(air) do
					if not minetest.is_protected(n, "") then
						minetest.get_node_timer(n):start(math.random(60,120))
					end
				end
			end
		elseif math.random(1,20) == 1 and not self.throwing and self.fight and self.fight:get_pos() and examobs.visiable(self.object,self.fight) and examobs.viewfield(self,self.fight) then
			local pos2=self.fight:get_pos()
			local pos1=self.object:get_pos()
			local d=vector.distance(pos1,pos2)
			if d>5 then
				self.is_throwing=1
				self.throwing=1
				self.time=self.otime
				examobs.stand(self)
				examobs.lookat(self,pos2)
				examobs.anim(self,"throw")
				d=d*0.05
				local p=examobs.pointat(self,4)
				minetest.after(0.7, function(p,d,self)
					if self.fight and not (self.dying or self.dead) then
						local pos2=self.fight:get_pos()
						local pos1=self.object:get_pos()
						if not (pos1 and pos2 and self) then
							return
						end
						local d={x=examobs.num((pos2.x-pos1.x)*d),y=examobs.num((pos2.y-pos1.y)*d),z=examobs.num((pos2.z-pos1.z)*d)}
						examobs.lookat(self,pos2)
						local ob = minetest.add_entity(vector.offset(p,0,1.5,0), "examobs:icecreamball")
						ob:set_velocity(d)
						local t = self.object:get_properties().textures
						ob:set_properties({
							textures = t,
							visual_size={x=0.5,y=0.5,z=0.5},
						})
					end
				end,p,d,self)
					minetest.after(1.2, function(self)
						self.throwing=nil
						if not self.object:get_pos() or self.dying or self.dead then
							return
						end
						examobs.stand(self)
					end,self)
				return self
			end
		elseif not self.throwing and self.is_throwing then
			self.is_throwing=nil
			examobs.stand(self)
		elseif self.throwing and self.fight then
			examobs.lookat(self,self.fight:get_pos())
			return self
		end
	end,
	on_punching=function(self,target)
		local pos=self.object:get_pos()
		pos.y=pos.y-0.5
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 5)) do
			local pos2=vector.round(ob:get_pos())
			if examobs.team(ob)~=self.team and examobs.visiable(self.object,ob) and examobs.viewfield(self.object,ob) then
				examobs.punch(self.object,ob,5)
				ob:add_velocity({x=(pos2.x-pos.x)*10, y=((pos2.y-pos.y))*20, z=(pos2.z-pos.z)*10})
			end
		end
	end
})