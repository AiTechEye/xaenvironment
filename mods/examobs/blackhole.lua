minetest.register_entity("examobs:blackhole",{
	hp_max = 1000,
	--physical = false,
	pointable = false,
	visual = "sprite",
	textures ={"examobs_blackhole.png"},
	on_activate=function(self, staticdata)
		self.sound2 = minetest.sound_play("examobs_blackhole_lightning", {object=self.object, gain = 2,max_hear_distance = 50})
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local en = puncher:get_luaentity()
		if en then
			puncher:remove()
		elseif puncher:is_player() then
			puncher:respawn()
		end
	end,
	on_step=function(self, dtime)
		local pos=self.object:get_pos()

		if not self.kill and math.floor(self.power*0.1)*10 ~= self.oldpower and self.power > 10 then
			if self.sound then
				minetest.sound_fade(self.sound,2,0)
			end
			self.oldpower = math.floor(self.power*10)*0.1

			self.sound = minetest.sound_play("examobs_blackhole", {object=self.object, gain = 1,max_hear_distance = 50,pitch=self.power <= 1000 and self.power*0.01 or 10})
		end

		for i=1,5 do
		local pw = self.power*0.1
		local ppos2 = vector.offset(pos,math.random(-pw,pw),math.random(-pw,pw),math.random(-pw,pw))
		minetest.add_particlespawner({
			amount = math.ceil(self.power*0.01),
			time = 0.1,
			minpos = vector.add(ppos2,0.5),
			maxpos = vector.subtract(ppos2,0.5),
			minvel = vector.subtract(pos,ppos2),
			maxvel = vector.subtract(pos,ppos2),
			minacc = vector.subtract(pos,ppos2),
			maxacc = vector.subtract(pos,ppos2),
			minexptime = 1,
			maxexptime = 1,
			minsize = 0.1,
			maxsize = self.power*0.02,
			texture = "default_coalblock.png^[colorize:#000^default_alpha_gem_round.png^[makealpha:0,255,0",
			collisiondetection = true,
		})
		end

		self.postimer = self.postimer + dtime
		if not self.kill and self.postimer > 0.5 then
			self.postimer = 0
			if not default.defpos(pos,"walkable") then
				local c = minetest.raycast(pos,vector.offset(pos,0,self.power*-0.01,0))
				local n = c:next()
				while n do
					if n.type == "node" and default.defpos(n.under,"walkable") then
						self.object:move_to(vector.offset(pos,0,1,0))
						break
					end
					n = c:next()
				end
			end
		end
		if self.kill then
			self.power=self.power-(self.power/10)
			self.object:set_properties({visual_size = {x=0.2+(self.power*0.02), y=0.2+(self.power*0.02)}})
		else
			self.power=self.power-(self.power*0.01)
		end

		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, self.power/10)) do
			local en=ob:get_luaentity()
			local opos=ob:get_pos()
			if examobs.visiable(self.object,opos) and not (en and en.blackhole and en.power >= self.power) then
				if vector.distance(pos,opos) < 1+(self.power*0.01) then
					if ob:is_player() then
						ob:respawn()
					elseif en and en.blackhole then
						en.killl = true
						en.power = -10000
						self.kill = true
					else
						if en and en.name == "__builtin:item" then
							local item = ItemStack(en.itemstring)
							self.power=self.power+item:get_count()
						end
						ob:remove()
					end
					self.power=self.power+5
				else
					if ob:is_player() and not ob:get_attach() then
						ob:add_velocity(vector.new((pos.x-opos.x)/0.1, (pos.y-opos.y)/0.1,(pos.z-opos.z)/0.1))
					else
						ob:set_velocity({x=(pos.x-opos.x)/0.9, y=(pos.y-opos.y)/0.9, z=(pos.z-opos.z)/0.9})
					end
				end
			end

			if self.power<5 then
				if self.sound then
					minetest.sound_fade(self.sound,2,0)
				end
				minetest.sound_fade(self.sound2,2,0)
				self.object:remove()
				return
			elseif self.power>100 then
				self.object:set_velocity(vector.new(0,0,0))
			end

			self.object:set_properties({visual_size = {x=0.2+(self.power*0.02), y=0.2+(self.power*0.02)}})
			if os.clock() - self.time > 0.025 and self.power > 150 then
				self.time = os.clock()
				local np = minetest.find_node_near(pos, math.floor(self.power/10),self.pick_nodes,true)
				if np and not minetest.is_protected(np,"") then
					minetest.spawn_falling_node(np)
					local nn = minetest.get_node(np).name
					if nn and nn ~= "air" then
						local e = minetest.add_item(np, nn)
						if e then
							e:get_luaentity().age=890
						end
						minetest.remove_node(np)
					end
				end
			end
		end
	end,
	static_save = false,
	blackhole=1,
	power=100,
	time=0,
	postimer=0,
	pick_nodes={
		"group:plant",
		"group:dig_immediate",
		"group:snappy",
		"group:leaves",
		"group:wood",
		"group:oddly_breakable_by_hand",
		"group:choppy",
		"group:tree",
		"group:sand",
		"group:crumbly",
		"group:soil",
		"group:level",
	},
})