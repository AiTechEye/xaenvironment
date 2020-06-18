examobs.register_mob({
	name = "terminator",
	type = "monster",
	team = "metal",
	dmg = 10,
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
	spawn_chance = 500,
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
				ob:add_player_velocity(v)
			end
		end
	end,
})

examobs.register_mob({
	name = "mouse",
	team = "mouse",
	hp = 2,
	textures = {"examobs_wolf.png^[combine:0x0:-15,-15=examobs_skin.png"},
	mesh = "examobs_mouse.obj",
	aggressivity = -2,
	run_speed = 2,
	inv={["examobs:flesh_piece"]=1},
	collisionbox={-0.2,-0.1,-0.2,0.2,0.1,0.2},
	spawn_on={"group:wood","group:stone","group:spreading_dirt_type"},
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
		local r = self.object:get_rotation()
		self.object:set_rotation({x=r.x,y=r.y,z=math.pi})
	end,
})

examobs.register_mob({
	name = "brown_bear",
	team = "bear",
	hp = 50,
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
})

examobs.register_mob({
	name = "black_bear",
	team = "blackbear",
	hp = 50,
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
})

examobs.register_mob({
	name = "ice_bear",
	team = "icebear",
	hp = 50,
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
})

examobs.register_mob({
	name = "lava_bear",
	team = "lavabear",
	hp = 50,
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
	resist_nodes = {["default:lava_source"]=1,["default:lava_flowing"]=1,["fire:basic_flame"]=1,["fire:not_igniter"]=1,["fire:basic_flame"]=1,["fire:permanent_flame"]=1},
	is_food=function(self,item)
		return minetest.get_item_group(item,"meat") > 0
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
	name = "ball",
	hp=60,
	reach=2,
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
	name = "gingerbread",
	hp=40,
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
	name = "icecreammonstermaster",
	hp=300,
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
		if not self.throwing and self.fight and self.fight:get_pos() and examobs.visiable(self,self.fight) and examobs.viewfield(self,self.fight) then
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
					if self.fight then
						local pos2=self.fight:get_pos()
						local pos1=self.object:get_pos()
						if not (pos1 and pos2 and self) then return end
						local d={x=examobs.num((pos2.x-pos1.x)*d),y=examobs.num((pos2.y-pos1.y)*d),z=examobs.num((pos2.z-pos1.z)*d)}
						examobs.lookat(self,pos2)
						minetest.add_entity({x=p.x,y=p.y+3,z=p.z}, "examobs:icecreamball"):set_velocity(d)
					end
				end,p,d,self)
					minetest.after(1.2, function(self)
						if not self.object:get_pos() then return end
						self.throwing=nil
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
		examobs.anim(self,"throw")
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
	name = "candycane",
	hp=40,
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
	name = "lollipop",
	hp=40,
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
	name = "tntbox",
	type = "monster",
	team = "box",
	dmg = 1,
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
	name = "stoneblock",
	type = "monster",
	team = "box",
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
		local d = vector.distance(self.lpos,self:pos())
		if d > 0.5 and self.object:get_velocity().y == 0 then
			self.lpos = self:pos()	
			minetest.sound_play("default_place_hard", {object=self.object, gain = 1, max_hear_distance = 20})
		end
	end,
})

examobs.register_mob({
	name = "underground_npc",
	type = "monster",
	team = "unpc",
	dmg = 2,
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
	name = "skeleton",
	type = "monster",
	team="metal",
	dmg = 1,
	hp= 50,
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
	use_bow=function(self,target)
		local pos1 = apos(self.object:get_pos(),0,-1)
		local pos2 = target:get_pos()
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
			metadata=minetest.serialize({arrow="default:arrow_arrow",shots=1})
		})
		bows.shoot(item, user,nil,function(item)
			item:remove()
		end)
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
				self:use_bow(self.fight)
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
	type = "monster",
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
	name = "underground_wolf",
	textures = {"uexamobs_underground_wolf.png"},
	mesh = "examobs_wolf.b3d",
	type = "monster",
	team = "coal",
	dmg = 2,
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
	punch_chance=6,
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
	name = "duck",
	bird=true,
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