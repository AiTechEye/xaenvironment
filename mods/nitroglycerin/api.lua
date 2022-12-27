nitroglycerin.cons=function(a)
	a.max=a.max or 9
	a.distance=a.distance or 1
	a.name=a.name or math.random(1,999)
	a.on_replace=a.on_replace or function() end
	if not a.replace or type(a.replace)~="table" then return end
	if not a.pos or type(a.pos)~="table" then return end
	for i, no in pairs(a.replace) do
		if type(no)~="string" and type(no)~="function" then
			return
		end
	end
	nitroglycerin.con_user[a.name]={time=os.clock(),
		count=a.max,
		dis=a.distance,
		name=a.name,
		jobs={[a.pos.x .."." .. a.pos.y .."." .. a.pos.z]=a.pos},
		replace=a.replace,
		on_replace=a.on_replace,
		on_runout=a.on_runout,
		on_out_of_nodes=a.on_out_of_nodes,

	}

	if nitroglycerin.counter(nitroglycerin.con_user)<2 then
		nitroglycerin.con()
	end
end


nitroglycerin.counter=function(a)
	local b=0
	for i, a in pairs(a) do
		b=b+1
	end
	return b
end

nitroglycerin.con=function()
	for i, a in pairs(nitroglycerin.con_user) do
		if not (nitroglycerin.con_user[a.name] and a.name and a.count>1 and nitroglycerin.counter(a.jobs)>0) then
			nitroglycerin.con_user[a.name]=nil
			nitroglycerin.con()
			return
		end
		local nend
		for xyz, pos in pairs(a.jobs) do
			if os.clock()-a.time>5 then
				nitroglycerin.con_user[a.name]=nil
				nitroglycerin.con()
				return
			end
			local n3=minetest.get_node(pos).name
			for i3, no in pairs(a.replace) do
				if n3==i3 or minetest.get_item_group(n3,i3)>0 then
					if type(no)=="string" then
						minetest.set_node(pos,{name=no})
						if a.on_replace(pos) then
							nitroglycerin.con_user[a.name]=nil
							nitroglycerin.con()
							return
						end
					elseif no(pos) then
						nitroglycerin.con_user[a.name]=nil
						nitroglycerin.con()
						return
					end
				end
			end

			if not nitroglycerin.con_user[a.name] then
				return
			end

			nitroglycerin.con_user[a.name].count=nitroglycerin.con_user[a.name].count-1
			if nitroglycerin.con_user[a.name].count<1 then
				if nend and nitroglycerin.con_user[a.name].on_runout then
					nitroglycerin.con_user[a.name].on_runout(nend)
				end
				nitroglycerin.con_user[a.name]=nil
				nitroglycerin.con()
				return
			end
			for x=-a.dis,a.dis,1 do
			for y=-a.dis,a.dis,1 do
			for z=-a.dis,a.dis,1 do
				local n={x=pos.x+x,y=pos.y+y,z=pos.z+z}
				nend=n

				if not minetest.is_protected(n,"") then
					local n2=minetest.get_node(n).name
					for i3, no in pairs(a.replace) do
						if n2==i3 or minetest.get_item_group(n2,i3)>0 then
							local new=n.x .. "." .. n.y .."." ..n.z
							if new~=xyz and not nitroglycerin.con_user[a.name].jobs[new] then
								nitroglycerin.con_user[a.name].jobs[new]=n
							end
						end
					end
				end
			end
			end
			end

			nitroglycerin.con_user[a.name].jobs[xyz]=nil
		end

		if nitroglycerin.counter(nitroglycerin.con_user[a.name].jobs)<1 then
			if nend and nitroglycerin.con_user[a.name].on_out_of_nodes then
				nitroglycerin.con_user[a.name].on_out_of_nodes(nend)
			end
			nitroglycerin.con_user[a.name]=nil
			nitroglycerin.con()
			return
		end
	end
	if nitroglycerin.counter(nitroglycerin.con_user)>0 then
		minetest.after((0.1), function()
			nitroglycerin.con()
			return
		end)
	end
end

nitroglycerin.explode=function(pos,node)
	if not (pos and pos.x and pos.y and pos.z) then return end

	if os.time()-nitroglycerin.exploding_overflow.time>0.001 then
		nitroglycerin.exploding_overflow.time=os.time()
		nitroglycerin.exploding_overflow.active=0
	elseif nitroglycerin.exploding_overflow.active<11 then
		nitroglycerin.exploding_overflow.active=nitroglycerin.exploding_overflow.active+1
	else
		if nitroglycerin.exploding_overflow.waiting>100 then
			return
		end
		nitroglycerin.exploding_overflow.waiting=nitroglycerin.exploding_overflow.waiting+1
		minetest.after((math.random(1,10)*0.01), function(pos, node)
			nitroglycerin.exploding_overflow.waiting=nitroglycerin.exploding_overflow.waiting-1
			nitroglycerin.explode(pos,node)
		end, pos, node)
		return
	end

	if not node then node={} end
	node.radius= node.radius or 3
	node.set= node.set or ""
	node.place= node.place or {"fire:not_igniter","air","air","air","air"}
	node.place_chance=node.place_chance or 5
	node.user_name=node.user_name or ""
	node.drops=node.drops or 1
	node.velocity=node.velocity or 1
	node.hurt=node.hurt or 1
	node.blow_nodes=node.blow_nodes or 1

	local d=vector.distance(nitroglycerin.exploding_overflow.last_pos,pos)

	if d/2<=node.radius then
		nitroglycerin.exploding_overflow.last_radius=nitroglycerin.exploding_overflow.last_radius+1
		node.drop=0
		if nitroglycerin.exploding_overflow.last_radius>node.radius then nitroglycerin.exploding_overflow.last_radius=node.radius end
		node.radius=node.radius+nitroglycerin.exploding_overflow.last_radius
	else
		nitroglycerin.exploding_overflow.last_radius=0
	end
	nitroglycerin.exploding_overflow.last_pos=pos


if node.blow_nodes==1 then
	local nodes={}
	if node.set~="" then node.set=minetest.get_content_id(node.set) end

	local nodes_n=0
	for i, v in pairs(node.place) do
		nodes_n=i
		nodes[i]=minetest.get_content_id(v)
	end

	if node.place_chance<=1 then node.place_chance=2 end
	if nodes_n<=1 then nodes_n=2 end

	local air=minetest.get_content_id("air")
	pos=vector.round(pos)
	local pos1 = vector.subtract(pos, node.radius)
	local pos2 = vector.add(pos, node.radius)
	local vox = minetest.get_voxel_manip()
	local min, max = vox:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	local data = vox:get_data()
	local affected_nodes = {}


	for z = -node.radius, node.radius do
	for y = -node.radius, node.radius do
	for x = -node.radius, node.radius do
		local rad = vector.length(vector.new(x,y,z))
		local v = area:index(pos.x+x,pos.y+y,pos.z+z)
		local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}

		if data[v]~=air and node.radius/rad>=1 and minetest.is_protected(p, node.user_name)==false then
			local nname = minetest.get_node(p).name
			local no=minetest.registered_nodes[nname] or {}
			table.insert(affected_nodes,{pos=p,name=nname})

			if not (no.on_blast and nitroglycerin.exploding_overflow.last_radius<node.radius and no.on_blast(p,node.radius) == true) then
				if node.set~="" and not (no.groups and no.groups.unbreakable) then
					data[v]=node.set
				end
				if math.random(1,node.place_chance)==1 and not (no.groups and no.groups.unbreakable)  then
					data[v]=nodes[math.random(1,nodes_n)]
				end
			end

			if node.drops==1 and data[v]==air and math.random(1,4)==1 then
				local n=minetest.get_node(p)

				if no.walkable and math.random(1,2)==1 then
					nitroglycerin.spawn_dust(p)
				else
					for _, item in pairs(minetest.get_node_drops(n.name, "")) do
						if p and item then minetest.add_item(p, item) end
					end
				end
			end
		end
	end
	end
	end
	vox:set_data(data)
	vox:write_to_map()
	vox:update_map()
	vox:update_liquids()

	for z = -node.radius, node.radius,node.radius do
	for y = -node.radius, node.radius,node.radius do
	for x = -node.radius, node.radius,node.radius do
		local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
		default.update_nodes(p)
	end
	end
	end

	for i,v in pairs(affected_nodes) do
		local no = minetest.registered_nodes[v.name]
		local img
		if i < 200 and no then
			local tiles = no.tiles or no.special_tiles or {}
			if type(tiles[1]) == "table" and tiles[1].name then
				img = tiles[1].name
			elseif type(tiles[1]) == "string" then
				img = tiles[math.random(1,#tiles)]
			end

			if type(img) == "string" then
				local d=math.max(1,vector.distance(pos,v.pos))
				local dmg=(4/d)*node.radius
				local vl = {x=(v.pos.x-pos.x)*dmg, y=(v.pos.y-pos.y)*dmg, z=(v.pos.z-pos.z)*dmg}

				minetest.add_particle({
					pos=v.pos,
					velocity=vl,
					acceleration={x=0,y=-10,z=0},
					expirationtime=5,
					size=math.random(5,10),
					collisiondetection=true,
					collision_removal=true,
					texture="[combine:16x16:"..math.random(-16,0)..","..math.random(-16,0).."="..img,
				})
			end
		end
	end
end
if node.hurt==1 then
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, node.radius*2)) do
		if not (ob:get_luaentity() and (ob:get_luaentity().itemstring or ob:get_luaentity().nitroglycerine_dust)) then
			local pos2=ob:get_pos()
			local d=math.max(1,vector.distance(pos,pos2 or pos))
			local dmg=(8/d)*node.radius
			if ob:get_luaentity() and ob:get_luaentity().on_blow then
				ob:get_luaentity().on_blow(ob:get_luaentity())
			end
			ob:punch(ob,1,{full_punch_interval=1,damage_groups={fleshy=dmg}})
		elseif ob:get_luaentity() and ob:get_luaentity().itemstring then
			ob:get_luaentity().age=890
		end
	end
end
if node.velocity==1 then
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, node.radius*2)) do
		local pos2=ob:get_pos()
		local d=math.max(1,vector.distance(pos,pos2 or pos))
		local dmg=(8/d)*node.radius
		if ob:get_luaentity() and not (ob:get_luaentity().nitroglycerine_dust and ob:get_luaentity().nitroglycerine_dust==2) then
			ob:set_velocity({x=(pos2.x-pos.x)*dmg, y=(pos2.y-pos.y)*dmg, z=(pos2.z-pos.z)*dmg})
			if ob:get_luaentity() and ob:get_luaentity().nitroglycerine_dust then ob:get_luaentity().nitroglycerine_dust=2 end
		elseif ob:is_player() then
			ob:add_velocity({x=(pos2.x-pos.x)*dmg, y=(pos2.y-pos.y)*dmg, z=(pos2.z-pos.z)*dmg})
		end
	end
end
	minetest.sound_play("nitroglycerin_explode4", {pos=pos, gain = 20, max_hear_distance = node.radius*8})
	if node.radius>9 then
		minetest.sound_play("nitroglycerin_nuke", {pos=pos, gain = 0.5, max_hear_distance = node.radius*30})
	end


	default.smoke(pos,{
		amount = 20,
		time = 0.1,
		minpos = {x=pos.x-1, y=pos.y, z=pos.z-1},
		maxpos = {x=pos.x+1, y=pos.y, z=pos.z+1},
		minvel = {x=-5, y=0, z=-5},
		maxvel = {x=5, y=5, z=5},
		minacc = {x=0, y=2, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 1,
		maxexptime = 2,
		minsize = 5,
		maxsize = 10,
	})

	default.lighteffect(pos,{time=0.1,minexptime=0.1,maxexptime=0.2,color="f90a",size=node.radius*2})
end


nitroglycerin.freeze=function(ob)
	local p=ob:get_properties()
	local pos=ob:get_pos()
	if ob:is_player() then
		pos=vector.round(pos)
		local node=minetest.get_node(pos)
		if node==nil or node.name==nil or minetest.registered_nodes[node.name].buildable_to==false then return end
		minetest.set_node(pos, {name = "nitroglycerin:icebox"})
		minetest.after(0.5, function(pos, ob) 
			pos.y=pos.y-0.5
			ob:move_to(pos,false)
		end, pos, ob)
		return
	end
	if not ob:get_luaentity() then return end
	if p.visual=="mesh" and p.mesh~="" and p.mesh~=nil and ob:get_luaentity().name~="nitroglycerin:ice" then
		nitroglycerin.newice=true
		local m=minetest.add_entity(pos, "nitroglycerin:ice")
		m:set_yaw(ob:get_yaw())
		m:set_properties({
			visual_size=p.visual_size,
			visual="mesh",
			mesh=p.mesh,
			textures={"default_ice.png","default_ice.png","default_ice.png","default_ice.png","default_ice.png","default_ice.png"},
			collisionbox=p.collisionbox
		})
	elseif ob:get_luaentity().name~="nitroglycerin:ice" then
		minetest.add_item(pos,"default:ice"):get_luaentity().age=890
	end
	ob:remove()
end


nitroglycerin.spawn_dust=function(pos)
		if not pos then return end
		local drop=minetest.get_node_drops(minetest.get_node(pos).name)[1]
		local n=minetest.registered_nodes[minetest.get_node(pos).name]
		if not (n and n.walkable) or drop=="" or type(drop)~="string" then return end
		local t=n.tiles
		if not (t and t[1]) then return end
		local tx={}
		local tt={}
		tt.t1=t[1]
		tt.t2=t[1]
		tt.t3=t[1]
		if t[2] then tt.t2=t[2] tt.t3=t[2] end
		if t[3] and t[3].name then tt.t3=t[3].name
		elseif t[3] then tt.t3=t[3]
		end
		if type(tt.t3)=="table" then return end
		tx[1]=tt.t1
		tx[2]=tt.t2
		tx[3]=tt.t3
		tx[4]=tt.t3
		tx[5]=tt.t3
		tx[6]=tt.t3

	nitroglycerin.new_dust={t=tx,drop=drop}
	minetest.add_entity(pos, "nitroglycerin:dust")

	nitroglycerin.new_dust=nil
	return true
end

minetest.register_entity("nitroglycerin:ice",{
	hp_max = 1,
	physical = true,
	weight = 5,
	collisionbox = {-0.3,-0.3,-0.3, 0.3,0.3,0.3},
	visual = "sprite",
	visual_size = {x=0.7, y=0.7},
	textures = {}, 
	colors = {}, 
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = true,
	automatic_rotate = false,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
			local pos=self.object:get_pos()
			minetest.sound_play("default_break_glass", {pos=pos, gain = 1.0, max_hear_distance = 10,})
			nitroglycerin.crush(pos)
	end,
	on_activate=function(self, staticdata)
		if nitroglycerin.newice then
			nitroglycerin.newice=nil
		else
			self.object:remove()
		end
		self.object:set_acceleration({x = 0, y = -10, z = 0})
	end,
	on_step = function(self, dtime)
		self.timer=self.timer+dtime

		if not self.falling and self.object:get_velocity().y < 0 then
			self.falling=true
		elseif self.falling and self.object:get_velocity().y >= 0 then
			self.timer2=1
			self.timer=1
		end

		if self.timer<1 then return true end
		self.timer=0
		self.timer2=self.timer2+dtime
		if self.timer2>0.8 then
			minetest.sound_play("default_break_glass", {pos=self.object:get_pos(), gain = 1.0, max_hear_distance = 10,})
			self.object:remove()
			nitroglycerin.crush(self.object:get_pos())
			return true
		end
	end,
	timer = 0,
	timer2 = 0,

})

minetest.register_entity("nitroglycerin:dust",{
	hp_max = 1000,
	physical =true,
	weight = 0,
	collisionbox = {-0.5,-0.5,-0.5,0.5,0.5,0.5},
	visual = "cube",
	visual_size = {x=1,y=1},
	textures ={"default_air.png"},
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = true,
	on_punch2=function(self)
		minetest.add_item(self.object:get_pos(),self.drop)
		self.object:remove()
		return self
	end,
	on_activate=function(self, staticdata)
		if not nitroglycerin.new_dust then self.object:remove() return self end
		self.drop=nitroglycerin.new_dust.drop
		self.object:set_properties({textures = nitroglycerin.new_dust.t})
		self.object:set_acceleration({x=0,y=-10,z=0})
		return self
	end,
	on_step=function(self, dtime)
		self.time=self.time+dtime
		if self.time<self.timer then return self end
		self.time=0
		self.timer2=self.timer2-1

		local v=self.object:get_velocity()
		local x,y,z=math.abs(v.x),math.abs(v.y),math.abs(v.z)
		local pos=self.object:get_pos()
		
		if not self.rounded and x+y+z<1 then
			self.object:set_pos({x=math.floor(pos.x),y=math.floor(pos.y),z=math.floor(pos.z)})
			self.rounded=1
		end

		local u=minetest.registered_nodes[minetest.get_node({x=pos.x,y=pos.y-1,z=pos.z}).name]
		if u and u.walkable then
			local n=minetest.registered_nodes[minetest.get_node(pos).name]
			if n and n.buildable_to and minetest.registered_nodes[self.drop] then
				minetest.set_node(pos,{name=self.drop})
				self.object:remove()
			else
				self.on_punch2(self)
			end
			return self
		elseif self.timer2<0 then
			self.on_punch2(self)
		end
		return self
	end,
	time=0,
	timer=2,
	timer2=10,
	nitroglycerine_dust=1,
})

minetest.register_node("nitroglycerin:icebox", {
	description = "Ice box",
	wield_scale = {x=2, y=2, z=2},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4375},
			{-0.5, -0.5, 0.4375, 0.5, 1.5, 0.5},
			{0.4375, -0.5, -0.4375, 0.5, 1.5, 0.4375},
			{-0.5, -0.5, -0.4375, -0.4375, 1.5, 0.4375},
			{-0.5, 1.5, -0.5, 0.5, 1.4375, 0.5},
		}
	},
	drop="default:ice",
	tiles = {"default_ice.png"},
	groups = {cracky = 1, level = 2, not_in_creative_inventory=1},
	sounds = default.node_sound_glass_defaults(),
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	drowning = 1,
	damage_per_second = 2,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(20)
	end,
	on_timer = function (pos, elapsed)
		for i, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			return true
		end
		minetest.sound_play("default_break_glass", {pos=pos, gain = 1.0, max_hear_distance = 10,})
		minetest.set_node(pos, {name = "air"})
		nitroglycerin.crush(pos)
		return false
	end,
	type="",
})

nitroglycerin.crush=function(pos)
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
	texture = "default_ice.png",
	collisiondetection = true,
})
end