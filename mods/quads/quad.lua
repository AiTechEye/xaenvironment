minetest.register_craft({
	output="quads:quad",
	recipe={
		{"default:copper_ingot","default:electric_lump","quads:petrol_tank_empty"},
		{"default:steel_ingot","quads:engine","default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
	},
})

minetest.register_node("quads:quad", {
	stack_max=1,
	description="Quad",
	drawtype="mesh",
	groups = {treasure=3,store=4000},
	mesh="quads_quad.b3d",
	tiles={"quads_quad1.png","quads_quad1.png"},
	wield_scale={x=0.1,y=0.1,z=0.1},
	visual_scale = 0.1,
	walkable=false,
	pointable=false,
	paramtype = "light",
	buildable_to=true,
	on_place = function(itemstack, user, pointed_thing)
		if pointed_thing.type=="node" and not minetest.is_protected(pointed_thing.above,user:get_player_name()) then
			local pos = pointed_thing.above
			pos.y=pos.y+0.5
			local en = minetest.add_entity(pos, "quads:quad")
			en:set_yaw(user:get_look_horizontal() - math.pi/2)
			en:get_luaentity().user_name = user:get_player_name()
			itemstack:take_item()
		end
		return itemstack
	end,
})

minetest.register_entity("quads:quad",{
	hp_max = 100,
	physical = true,
	collisionbox = {-0.75,-0.45,-0.75,0.75,0.4,0.75},
	visual="mesh",
	mesh="quads_quad.b3d",
	textures={"quads_quad1.png","quads_quad1.png"},
	visual_size = {x=1,y=1},
	makes_footstep_sound = true,
	stepheight = 1.5,
	type="npc",
	speed = 0,
	jump = 0,
	timer = 0,
	manual_page = "quads:quad quads:petrol_tank quads:petrol_tank_empty Quads is small vehicles that easily can travel through the most terrains.\nTo make it drivable you have to fill it with petrol (4x fills the tank).\nYou can aslo change its color by right click with a dye.\nControls:\n\nUp/down = drive\nLeft/right = turn\nShift + left/right = turn slowly\nUse + up/down in air = flip\n\n- Hurts from fall over 7 blocks\n- Explodes when it dies\n- You dies if you fails in a flip",
	get_staticdata = function(self)
		return minetest.serialize({petrol=self.petrol,user_name=self.user_name,palette_index=self.palette_index})
	end,
	anim=function(self,s)
		if self.an ~= s then
			self.an = s
			self.object:set_animation({x=0,y=40},s*10,0)
		end
	end,
	on_activate=function(self, staticdata)
		self.object:set_acceleration({x=0,y=-10,z =0})
		local s = minetest.deserialize(staticdata) or {}
		self.quad = math.random(1,9999)
		self.petrol = s.petrol or 0
		self.palette_index = s.palette_index
		self.user_name = s.user_name or ""
		self:color(self)
	end,
	color=function(self)
		if self.palette_index then
			local color = "^"..default.dye_texturing(self.palette_index,{opacity=200,image_w=8,image_h=8})
			self.object:set_properties({textures={
				"quads_quad1.png" .. color,
				"quads_quad1.png" .. color
			}})
		end
	end,
	on_punch=function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if puncher:is_player() and not self.user and (self.user_name =="" or puncher:get_player_name() == self.user_name) then
			if self.petrol > 0 then
				minetest.chat_send_player(puncher:get_player_name(),"Empty the tank before pick up the quad ("..math.ceil(self.petrol).." left)")
			else
				local inv = puncher:get_inventory()
				if inv:room_for_item("main","quads:quad") then
					inv:add_item("main","quads:quad")
					self.object:remove()
				end
			end
		end
		minetest.after(0,function(self)
			self:hurt()
		end, self)
	end,
	on_rightclick=function(self, clicker)
		if not self.leave and clicker:get_player_name() == self.user_name and clicker:get_wielded_item():get_name() == "quads:petrol_tank" then
			if self.petrol+25 <= 100 then
				self.petrol = self.petrol + 25
				local item = clicker:get_wielded_item():to_table()
				item.name = "quads:petrol_tank_empty"
				clicker:set_wielded_item(item)
				self:hud_update()
			end
		elseif not self.leave and clicker:get_player_name() == self.user_name and clicker:get_wielded_item():get_name() == "default:dye" then
			local color = clicker:get_wielded_item():to_table()
			self.palette_index = color.meta and color.meta.palette_index
			default.take_item(clicker)
			self:color(self)
		elseif self.user and clicker:get_player_name() == self.user_name then
			self.user:set_detach()
			self.user:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
			player_style.player_attached[self.user_name] = nil
			self.user = nil
			clicker:hud_remove(self.hud.hp)
			clicker:hud_remove(self.hud.hp_back)
			clicker:hud_remove(self.hud.petrol)
			clicker:hud_remove(self.hud.petrol_back)
		elseif (self.user_name =="" or self.user_name == clicker:get_player_name()) and not player_style.player_attached[clicker:get_player_name()] then
			self.user = clicker
			self.user_name = clicker:get_player_name()
			local user=player_style.players[self.user_name]

			self.user:set_attach(self.object, "",{x=0, y=0, z=-5}, {x=0, y=0,z=0})
			if minetest.get_item_group(minetest.get_node(clicker:get_pos()).name,"liquid") == 0 and user and user.current == "stand" then
				self.user:set_eye_offset({x=0, y=-3, z=-3}, {x=0, y=0, z=0})
			else
				self.user:set_eye_offset({x=0, y=5, z=-3}, {x=0, y=0, z=0})
			end
			player_style.player_attached[self.user_name] = true
			player_style.set_animation(self.user_name,"sit")
			self.hud={
				hp_back=clicker:hud_add({
					type="statbar",
					position={x=1,y=0},
					text="quads_backbar.png",
					number=100,
					size={x=10,y=10},
					direction=1,
				}),
				hp=clicker:hud_add({
					type="statbar",
					position={x=1,y=0},
					text="quads_hpbar.png",
					number=self.object:get_hp(),
					size={x=10,y=10},
					direction=1,
				}),
				petrol_back=clicker:hud_add({
					type="statbar",
					position={x=1,y=-2},
					text="quads_backbar.png",
					number=100,
					size={x=10,y=10},
					direction=1,
					offset={x=0,y=15},
				}),
				petrol=clicker:hud_add({
					type="statbar",
					position={x=1,y=0},
					text="quads_petrolbar.png",
					number=self.petrol,
					size={x=10,y=10},
					direction=1,
					offset={x=0,y=15},
				})
			}
			self:hud_update()
		end
		return self
	end,
	hud_update=function(self)
		if self.user and self.user:get_pos() then
			self.user:hud_change(self.hud.hp, "number", self.object:get_hp())
			self.user:hud_change(self.hud.petrol, "number", self.petrol)
		end
	end,
	node_timer=function(self,dtime)
		self.timer = self.timer + dtime
		if self.timer > 1 then
			self.timer = 0
			local n = default.def(minetest.get_node(self:pos()).name)
			if (n.damage_per_second or 0) > 0 then
				self:hurt(n.damage_per_second)
			elseif not self.viscosity and (n.liquid_viscosity or 0) > 0 then
				self.viscosity = true
				self.object:set_acceleration({x=0,y=-10/(n.liquid_viscosity*2),z =0})
			elseif self.viscosity and n.liquid_viscosity == 0 then
				self.viscosity = nil
				self.object:set_acceleration({x=0,y=-10,z =0})
			end
		end
	end,
	showtext=function(self,text,color)
		self.delstatus=math.random(0,1000) 
		local del=self.delstatus
		color=color or "ff0000"
		self.object:set_properties({nametag=text,nametag_color="#" ..  color})
		minetest.after(1, function(self,del)
			if self and self.object and self.delstatus==del then
				self.delstatus = nil
				self.object:set_properties({nametag="",nametag_color=""})
			end
		end, self,del)
		return self
	end,
	hurt=function(self,d)
		local hp = self.object:get_hp()
		if d then
			hp = hp - d
			self.object:set_hp(hp - d)
		end
		self:showtext(hp .. "/" .. self.hp_max,"F00")
		local pos = self:pos() or self.oldpos
		if minetest.get_item_group(minetest.get_node(pos).name, "igniter") > 0 then
			minetest.add_particlespawner({
				amount = 5,
				time =0.2,
				minpos = {x=pos.x-0.5, y=pos.y, z=pos.z-0.5},
				maxpos = {x=pos.x+0.5, y=pos.y, z=pos.z+0.5},
				minvel = {x=0, y=0, z=0},
				maxvel = {x=0, y=math.random(3,6), z=0},
				minacc = {x=0, y=2, z=0},
				maxacc = {x=0, y=0, z=0},
				minexptime = 1,
				maxexptime = 3,
				minsize = 5,
				maxsize = 10,
				texture = "default_item_smoke.png",
				collisiondetection = true,
			})
		end
		self:hud_update()
	end,
	on_death=function(self,killer)
		if self.user then
			self.leave = true
			self:on_rightclick(self.user)
		end
		self.object:remove()
		nitroglycerin.explode(self:pos(),{radius=3,set="fire:basic_flame"})
	end,
	pos=function(self)
		self.lastpos = self.object:get_pos() or self.lastpos
		return self.lastpos
	end,
	yaw=function(self)
		local a = self.object:get_yaw()
		return (a == math.huge or a == -math.huge or a ~= a) == false and a or 0
	end,
	on_step=function(self,dtime)
		local v = self.object:get_velocity()
		local p = self:pos()
		self.oldpos = p
		if not self.user and self.speed == 0 and v.y == 0 then
			self:node_timer(dtime)
			return
		end

		local key = self.user and self.user:get_player_control() or {}

		if key.left and self.speed ~= 0 then
			local r = self.object:get_rotation()
			if key.sneak then
				self.object:set_rotation({x=r.x,y=r.y+0.05,z=r.z})
			else
				self.object:set_rotation({x=r.x,y=r.y+0.1,z=r.z})
			end
		elseif key.right and  self.speed ~= 0 then
			local r = self.object:get_rotation()
			if key.sneak then
				self.object:set_rotation({x=r.x,y=r.y-0.05,z=r.z})
			else
				self.object:set_rotation({x=r.x,y=r.y-0.1,z=r.z})
			end
		end

		if self.user and self.user:get_hp() <=0 then
			self:on_rightclick(self.user)
		elseif key.up and self.speed < 20 and self.petrol > 0 then
			self.speed = self.speed + 0.2
		elseif key.down and self.speed > -5 and not self.falling and self.petrol > 0 then
			self.speed = self.speed - 0.2
		elseif key.sneak and not self.falling  then
			self.speed = math.abs(self.speed) > 1 and self.speed * 0.95 or 0
		elseif self.speed ~= 0 then
			self.speed = math.abs(self.speed) > 1 and self.speed * 0.99 or 0
		end

		self.speed = math.abs(self.speed) > 0.1 and math.floor(self.speed*1000)*0.001 or 0

		self:anim(self.speed)

		local yaw = self:yaw()
		local X = (math.sin(yaw) * -1)
		local Z = (math.cos(yaw) * 1)
		local x = X * self.speed
		local z = Z * self.speed
		local ap = apos(p,X,0,Z)
		local walku = walkable(apos(p,0,-1,0))

		if not walku then
			local r = self.object:get_rotation()
			if key.down and key.aux1 then
				self.object:set_rotation({x=r.x-0.1,y=r.y,z=r.z})
				self.rotation = true
			elseif key.up and key.aux1 then
				self.object:set_rotation({x=r.x+0.1,y=r.y,z=r.z})
				self.rotation = true
			end
		end

		if walku or v.y >= -0.1 then
			local r = self.object:get_rotation()
			if self.falling then
				local dmg = math.floor(self.falling-p.y)*10
				if self.user and math.abs(r.x) > 1.3 and math.abs(r.x) < 5 then
					dmg = dmg*10
					default.punch(self.user,self.object,dmg)
				end
				if self.falling-p.y > 7 then
					self:hurt(dmg)
				end
				self.falling = nil
			end
			if walku and self.rotation and v.y <= 0.1 then
				self.rotation = nil
				self.object:set_rotation({x=0,y=r.y,z=r.z})
			end
		end

		if self.speed > 0 and walkable(ap) then
			if walkable(apos(p,X,1,Z)) then
				x = 0
				z = 0
				self.speed = 0
			else
				self.rotation = true
				local r = self.object:get_rotation()
				self.object:set_rotation({x=0.785,y=r.y,z=r.z})
				self.jump = self.jump + self.jump< 3 and self.speed*0.1 or 0
			end
		elseif self.speed < 0 and walkable(apos(p,-X,0,-Z)) then
			if walkable(apos(p,-X,1,-Z)) then
				x = 0
				z = 0
				self.speed = 0
			else
				self.rotation = true
				local r = self.object:get_rotation()
				self.object:set_rotation({x=-0.785,y=r.y,z=r.z})
			end
		else
			self.jump =  0
		end

		if not self.falling and (v.y < 0 or not walku) then
			self.falling = p.y
		elseif self.falling and v.y > -10 then
			self.falling = nil
		end

		local r = self.object:get_rotation() or {x=0,y=0,z=0}

		if self.falling and math.abs(r.x) >=6.28 then
			local x = r.x
			if x < 0 then
				exaachievements.customize(self.user,"Quad_frontflip_stunt")
			elseif x > 0 then
				exaachievements.customize(self.user,"Quad_backflip_stunt")
			end

			local r = self.object:get_rotation()
			self.object:set_rotation({x=0,y=r.y,z=r.z})
		end

		self:node_timer(dtime)

		self.object:set_velocity({
			x=x,
			y=v.y + self.jump,
			z=z,
		})

		if x+z ~= 0 and self.petrol > 0 then
			if self.petrol ~= math.ceil(self.petrol+0.001) then
				self.petrol = self.petrol -0.001
				self:hud_update()
			else
				self.petrol = self.petrol -0.001
			end
		end

		if self.speed > 4 then
			for _, ob in ipairs(minetest.get_objects_inside_radius(ap, 1)) do
				local en = ob:get_luaentity()
				if not (self.user_name and ob:is_player() and ob:get_player_name() == self.user_name or en and (en.quad == self.quad or en.item_string)) then
					if en then
						ob:set_velocity({x=x*2,y=ob:get_velocity().y,z=z*2})
						if not en.dead then
							default.punch(ob,self.object,self.speed)
						end
					else
						default.punch(ob,self.object,self.speed)
					end
				end
			end
		end
	end
})