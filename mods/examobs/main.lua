examobs={}

examobs.main=function(self, dtime)
	self.timer = self.timer + dtime
	if self.timer < self.time then return end
	self.timer = 0

	if self.step(self,dtime) then return end
	if examobs.fighting(self) then return end
	if examobs.exploring(self) then return end
end

examobs.register_mob=function(def)

	local name = minetest.get_current_modname() ..":" .. def.name

	def.hp_max = 			def.hp or				20
	def.physical =			def.physical or			true
	def.collisionbox =			def.collisionbox or			{-0.35,-1.0,-0.35,0.35,0.8,0.35}
	def.visual =			def.visual or			"mesh"
	def.visual_size =			def.visual_size or			{x=1,y=1}
	def.mesh =			def.mesh or			"character.b3d"
	def.makes_footstep_sound =		def.makes_footstep_sound or		true


	def.textures =			def.textures or			{"characrter.png"}
	def.type =			def.type or			"npc"
	def.team =			def.team or			"default"
	def.step =			def.step or			function() end
	def.range =			def.range or			10
	def.reach =			def.reach or			4
	def.dmg =			def.dmg or			1

	def.timer = 0
	def.time = 0.5


	def.animation =			def.animation or			{
										stand={x=1,y=39,speed=30},
										walk={x=41,y=61,speed=30},
										run={x=41,y=61,speed=60},
										attack={x=65,y=75,speed=30},
										lay={x=113,y=123,speed=0},
									}
	if def.animation.walk then
		def.animation.run = def.animation.run or {x=def.animation.walk.x,y=def.animation.walk.y,speed = 60}
	end
	for i, a in pairs(def.animation) do
		def.animation[i].speed = def.animation[i].speed or 30
	end

	def.on_rightclick=function(self, clicker,name)
		if not self.fight then
			examobs.lookat(self,clicker)
		end
	end
	def.on_activate=function(self, staticdata)
		self.storage = minetest.deserialize(staticdata) or {}
		self.exploring = {}
		self.move={x=0,y=0,z=0,jump=0,speed=1}
		self.object:set_velocity({x=0,y=-1,z=0})
		self.object:set_acceleration({x=0,y=-10,z =0})
	end
	def.on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		self.fight = puncher
		examobs.lookat(self,self.fight)
	end
	def.get_staticdata = function(self)
		return minetest.serialize(self.storage)
	end
	def.on_step=examobs.main,

	minetest.register_entity(name,def)

	if def.visual == "mesh" then
		minetest.register_node(name .."_spawner", {
			description = def.name .." spawner",
			wield_scale={x=0.2,y=0.2,z=0.2},
			tiles = def.textures,
			drawtype="mesh",
			mesh=def.mesh,
			paramtype="light",
			visual_scale=0.1,
			on_place = function(itemstack, user, pointed_thing)
				if pointed_thing.type=="node" then
					local p = pointed_thing.above
					minetest.add_entity({x=p.x,y=p.y+1,z=p.z}, name):set_yaw(math.random(0,6.28))
					itemstack:take_item()
				end
				return itemstack
			end,
		})
	else
		minetest.register_craftitem(name .."_spawner", {
			description = def.name .." spawner",
			inventory_image = def.textures[1] .. "^examobs_alpha_egg.png^[makealpha:0,255,0",
			on_place = function(itemstack, user, pointed_thing)
				if pointed_thing.type=="node" then
					local p = pointed_thing.above
					minetest.add_entity({x=p.x,y=p.y+1,z=p.z}, name):set_yaw(math.random(0,6.28))
					itemstack:take_item()
				end
				return itemstack
			end
		})
	end
--[[
minetest.register_abm({
	nodenames = def.spawn_on or {"group:spreading_dirt_type","group:sand","default:snow"},
	interval = def.spawn_interval or 30,
	chance = def.spawn_chance,
	action = function(pos)
		if aliveai.systemfreeze==1 then
			return
		end
		local pos1={x=pos.x,y=pos.y+1,z=pos.z}
		local pos2={x=pos.x,y=pos.y+2,z=pos.z}
		local l=minetest.get_node_light(pos1)
		if l==nil then return true end
		if aliveai.random(1,def.spawn_chance)==1
		and (def.light==0 
		or (def.light>0 and l>=def.lowest_light) 
		or (def.light<0 and l<=def.lowest_light)) then
			if aliveai.check_spawn_space==false or def.check_spawn_space==0 or ((minetest.get_node(pos1).name==def.spawn_in and minetest.get_node(pos2).name==def.spawn_in) or minetest.get_item_group(minetest.get_node(pos1).name,def.spawn_in)>0) then
				aliveai.newbot=true
				pos1.y=pos1.y+def.spawn_y
				minetest.add_entity(pos1, def.mod_name ..":" .. def.name):set_yaw(math.random(0,6.28))
			end
		end
	end,
})
--]]
end