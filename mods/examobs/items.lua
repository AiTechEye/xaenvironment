default.register_eatable("craftitem","examobs:crab_claw",1,2,{
	description = "Crab claw",
	groups={meat=1,store=100},
	inventory_image = "examobs_crab_claw.png",
	wet = 0.5
})
default.register_eatable("craftitem","examobs:flesh",1,4,{
	description = "Flesh",
	groups={meat=1},
	inventory_image = "examobs_flesh.png^examobs_alpha_fleshpiece.png^[makealpha:0,255,0"
})
default.register_eatable("craftitem","examobs:meat",3,4,{
	description = "Cooked meat",
	groups={meat=1,store=50},
	inventory_image = "examobs_meat.png^examobs_alpha_fleshpiece.png^[makealpha:0,255,0"
})

default.register_eatable("craftitem","examobs:flesh_piece",1,2,{
	description = "Flesh piece",
	groups={meat=1},
	inventory_image = "examobs_flesh.png^default_alpha_lump.png^[makealpha:0,255,0"
})
default.register_eatable("craftitem","examobs:meat_piece",1,2,{
	description = "Cooked meat piece",
	groups={meat=1},
	inventory_image = "examobs_meat.png^default_alpha_lump.png^[makealpha:0,255,0"
})


minetest.register_tool("examobs:hiding_poison", {
	description = "Hiding poison from mobs",
	inventory_image = "materials_plant_extracts.png",
	sound=default.tool_breaks_defaults(),
	groups={treasure=1,store=250},
	on_use=function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if examobs.hiding[name] then
			examobs.hiding[name] = nil
			minetest.chat_send_player(name,"off")
		else
			examobs.hiding[name] = user:get_wield_index()
			for _, ob in pairs(minetest.get_objects_inside_radius(user:get_pos(),30)) do
				local en = ob:get_luaentity()
				if en and en.examob then
					local target = en.fight or en.flee or en.target
					if target and target:is_player() and target:get_player_name() == name then
						en.fight = nil
						en.fight = nil
						en.flee = nil
					end
				end
			end
			minetest.chat_send_player(name,"on")
		end
	end
})

minetest.register_craft({
	output = "examobs:hiding_poison",
	replacements={{"group:bucket_water","default:bucket"}},
	recipe = {
		{"plants:lonicera_tatarica_berries","materials:glass_bottle","plants:dolls_eyes_berries"},
		{"plants:lonicera_tatarica_berries","group:bucket_water","plants:dolls_eyes_berries"},
		{"plants:lonicera_tatarica_berries","","plants:dolls_eyes_berries"}
	}
})

-- ================ Wolf ================

minetest.register_craftitem("examobs:pelt",{
	description = "Pelt",
	groups = {flammable=3,treasure=1},
	inventory_image = "examobs_pelt.png",
	wield_scale={x=2,y=2,z=1},
})
minetest.register_craftitem("examobs:tooth",{
	description = "Tooth",
	groups = {treasure=1,tip=1},
	inventory_image = "examobs_tooth.png",
	wield_scale={x=0.3,y=0.3,z=0.4},
})
minetest.register_craft({
	type = "cooking",
	output = "examobs:meat",
	recipe = "examobs:flesh",
})

minetest.register_craft({
	type = "cooking",
	output = "examobs:meat_piece",
	recipe = "examobs:flesh_piece",
})

minetest.register_node("examobs:meat_block", {
	description = "Meat block",
	tiles={"examobs_meat.png"},
	groups = {crumbly=3,meat=2,store=100},
	sounds = default.node_sound_clay_defaults(),
})
minetest.register_node("examobs:flesh_block", {
	description = "Flesh block",
	tiles={"examobs_flesh.png"},
	groups = {crumbly=3,meat=2},
	sounds = default.node_sound_clay_defaults(),
})

minetest.register_craft({
	output = "examobs:flesh",
	recipe = {
		{"examobs:flesh_piece","examobs:flesh_piece"},
	}
})
minetest.register_craft({
	output = "examobs:meat",
	recipe = {
		{"examobs:meat_piece","examobs:meat_piece"},
	}
})

minetest.register_craft({
	output = "examobs:flesh_block",
	recipe = {
		{"examobs:flesh","examobs:flesh"},
		{"examobs:flesh","examobs:flesh"},
	}
})

minetest.register_craft({
	output = "examobs:meat_block",
	recipe = {
		{"examobs:meat","examobs:meat"},
		{"examobs:meat","examobs:meat"},
	}
})

minetest.register_craft({
	output = "examobs:flesh_block",
	recipe = {
		{"examobs:flesh","examobs:flesh"},
		{"examobs:flesh","examobs:flesh"},
	}
})

minetest.register_craft({
	output = "examobs:meat 4",
	recipe = {
		{"examobs:meat_block"},
	}
})
minetest.register_craft({
	output = "examobs:flesh 4",
	recipe = {
		{"examobs:flesh_block"},
	}
})

-- ================ mud ================

minetest.register_node("examobs:mud", {
	description = "Mud",
	tiles={"default_dirt.png^default_stonemoss.png"},
	groups = {dirt=1,soil=1,crumbly=3},
	sounds = default.node_sound_dirt_defaults(),
})

-- ================ chicken ================

default.register_eatable("craftitem","examobs:chickenleg",1,2,{
	description = "Chicken leg",
	groups={meat=1},
	inventory_image = "examobs_skin.png^examobs_alpha_chickenleg.png^[makealpha:0,255,0"
})
default.register_eatable("craftitem","examobs:chickenleg_fried",2,3,{
	description = "Fried chicken leg",
	groups={meat=1},
	inventory_image = "examobs_meat.png^examobs_alpha_chickenleg.png^[makealpha:0,255,0"
})
minetest.register_craft({
	type = "cooking",
	output = "examobs:chickenleg_fried",
	recipe = "examobs:chickenleg",
})

default.register_eatable("craftitem","examobs:fried_egg",1,2,{
	description = "Fried egg",
	groups={meat=1},
	inventory_image = "examobs_fried_egg.png"
})
minetest.register_craft({
	type = "cooking",
	output = "examobs:fried_egg",
	recipe = "examobs:egg",
})

minetest.register_node("examobs:egg", {
	description = "Egg",
	drawtype = "plantlike",
	inventory_image = "default_snowball.png^[colorize:#ffffff^examobs_alpha_egg.png^[makealpha:0,255,0",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	visual_scale = 0.3,
	groups = {dig_immediate=3},
	selection_box = {
		type = "fixed",
		fixed = {-0.1, -0.5, -0.1, 0.1, -0.2, 0.1}
	},
	tiles={"default_snowball.png^[colorize:#ffffff^examobs_alpha_egg.png^[makealpha:0,255,0"},
	sounds = default.node_sound_dirt_defaults(),
	on_timer = function (pos, elapsed)
		local meta = minetest.get_meta(pos)
		if default.date("h",meta:get_int("date")) > meta:get_int("hours") then
			minetest.remove_node(pos)
			return false
		end
		return true
	end
})
minetest.register_craftitem("examobs:feather",{
	description = "Feather",
	groups = {flammable=3,treasure=1},
	inventory_image = "examobs_feather.png",
	wield_scale={x=0.5,y=0.5,z=0.2},
	on_use=function(itemstack, user, pointed_thing)
		if special.have_ability(user,"fly_as_a_bird") then
			local c = itemstack:get_count()
			special.add(user,"fly_as_a_bird",c)
			itemstack:take_item(c)
			minetest.sound_play("default_eat", {to_player=user:get_player_name(), gain = 1})
			return itemstack
		end
	end
})
-- ================ sheep ================
minetest.register_tool("examobs:shears",{
	description = "Shears",
	groups={treasure=1},
	inventory_image = "examobs_shears.png",
})
minetest.register_craft({
	output = "examobs:shears",
	recipe = {
		{"","default:iron_ingot",""},
		{"","default:iron_ingot","default:iron_ingot"},
		{"","",""}
	}
})
-- ================ fishs ================

minetest.register_entity("examobs:fishing_string",{
	physical = false,
	visual = "cube",
	pointable = false,
	decoration = true,
	textures={"examobs_wool.png","examobs_wool.png","examobs_wool.png","examobs_wool.png","examobs_wool.png","examobs_wool.png"},
	on_activate=function(self, staticdata)
		for _, ob in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 1)) do
			local en = ob:get_luaentity()
			if en and en.name == "examobs:fishing_float" then
				return
			end
		end
		self.object:remove()
	end,
	on_step=function(self,dtime)
		self.t = self.t - dtime
		if self.t < 0 then
			self.t = 1
			if not (self.float and self.float:get_pos()) then
				self.object:remove()
			end
		end
	end,
	t=1
})

minetest.register_entity("examobs:fishing_float",{
	physical = false,
	decoration = true,
	collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1,},
	visual = "cube",
	visual_size={x=0.1,y=0.1,z=0.1},
	pointable = false,
	textures={"default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png"},
	examobs_fishing_target = true,
	on_activate=function(self, staticdata)
		self.object:set_acceleration({x=0,y=-5,z=0})
		self.string = minetest.add_entity(self.object:get_pos(), "examobs:fishing_string")
		self.string:get_luaentity().float = self.object
	end,
	on_trigger=function(self,catch)
		self.object:set_acceleration({x=0,y=0,z=0})
		self.catch = catch
		self:wear()
	end,
	wear=function(self)
		local item = self.user:get_wielded_item()
		local i = self.user:get_wield_index()
		if item:get_wear() < 60000 then
			item:add_wear(1500)
		else
			item = ItemStack("examobs:fishing_rod")
		end
		self.user:get_inventory():set_stack("main",i,item)
	end,
	delete=function(self)
		if self.string then
			self.string:remove()
		end
		self.object:remove()
	end,
	on_step=function(self,dtime)
		if not (self.user and self.string and self.user:get_wielded_item():get_name() == "examobs:fishing_rod_with_string") or examobs.distance(self.object,self.user) > 30 or not (examobs.visiable(self.object,self.user)) then
			self:delete()
			return
		end
		local pos1 = self.object:get_pos()
		local pos2 = self.user:get_pos()
		pos2.y = pos2.y + 1.4

		local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local y = math.atan(vec.z/vec.x)
		local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))
		if pos1.x >= pos2.x then y = y+math.pi end

		self.string:set_rotation({x=0,y=y,z=z})
		self.string:set_pos({x=pos1.x+(pos2.x-pos1.x)/2,y=pos1.y+(pos2.y-pos1.y)/2,z=pos1.z+(pos2.z-pos1.z)/2})
		self.string:set_properties({visual_size={x=examobs.distance(pos1,pos2),y=0.01,z=0.01}})

		if examobs.distance(pos1,pos2) > 25 then
			self.object:set_velocity({x=vec.x*-1,y=self.object:get_velocity().y,z=vec.z*-1})
		elseif self.catch then
			if examobs.distance(pos1,pos2) < 1 then
				local pos3 = self.catch:get_pos()
				examobs.punch(self.user,self.catch,examobs.gethp(self.catch))
				for _, ob in pairs(minetest.get_objects_inside_radius(pos3, 2)) do
					local en = ob:get_luaentity()
					if en and en.name == "__builtin:item" then
						examobs.punch(self.user,ob,1)
					end
				end
				self:wear()
				self:delete()
				return
			end
			pos2 = self.catch:get_pos()
			if not pos2 then
				self:delete()
			end
			self.object:set_velocity({x=vec.x*-2,y=vec.y*-2,z=vec.z*-2})
			self.catch:set_velocity({x=(pos2.x-pos1.x)*-2, y=(pos2.y-pos1.y)*-2, z=(pos2.z-pos1.z)*-2})
			return
		elseif minetest.get_item_group(minetest.get_node(pos1).name,"water") > 0 then
			self.object:set_velocity({x=0,y=1,z=0})
		else
			self.object:set_acceleration({x=0,y=-5,z=0})
			if walkable(pos1) then
				self:delete()
			end
		end
	end
})

minetest.register_craftitem("examobs:fishing_rod", {
	description = "Fishing rod",
	inventory_image = "examobs_fishing_rod.png",
	groups={flammable=3,treasure=1},
})

minetest.register_tool("examobs:fishing_rod_with_string", {
	description = "Fishing rod with string",
	inventory_image = "examobs_fishing_rod_with_string.png",
	groups={flammable=3,treasure=2,store=500},
	on_use=function(itemstack, user, pointed_thing)
		local pos = user:get_pos()
		local name = user:get_player_name()
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, 30)) do
			local en = ob:get_luaentity()
			if en and en.name == "examobs:fishing_float" and en.user_name == name then
				en:delete()
				return itemstack
			end
		end
		local f = minetest.add_entity(apos(pos,0,1.5), "examobs:fishing_float")
		f:set_rotation({x=90.,y=0,z=0})
		f:get_luaentity().user = user
		f:get_luaentity().user_name = name
		local d=user:get_look_dir()
		f:set_velocity({x=d.x*10,y=d.y*10,z=d.z*10})
		return itemstack
	end
})

default.register_eatable("craftitem","examobs:fried_fish",1,3, {
	description = "Fried fish",
	inventory_image="examobs_fried_fish.png",
	groups = {meat=1,store=100},
})

minetest.register_craft({
	type = "cooking",
	output = "examobs:fried_fish",
	recipe = "group:fish",
})

minetest.register_craft({
	output = "examobs:fishing_rod_with_string",
	recipe = {
		{"","materials:string",""},
		{"","materials:string","examobs:fishing_rod"},
		{"","materials:string",""}
	}
})

minetest.register_craft({
	output = "examobs:fishing_rod_with_string",
	recipe = {
		{"","materials:string",""},
		{"","materials:string","examobs:fishing_rod"},
		{"","materials:string",""}
	}
})

minetest.register_craft({
	output = "examobs:fishing_rod",
	recipe = {
		{"","materials:string","default:stick"},
		{"","materials:piece_of_wood","default:stick"},
		{"","default:iron_ingot","default:stick"}
	}
})

minetest.register_node("examobs:woodbox", {
	description = "Wooden box",
	tiles={"examobs_woodbox.png"},
	groups = {choppy=3,oddly_breakable_by_hand=3,flammable=1,treasure=1,used_by_npc=1,exatec_tube_connected=1},
	sounds = default.node_sound_wood_defaults(),
	exatec={
		input_list="main",
		output_list="main",
	},
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:get_inventory():set_size("main", 32)
		m:set_string("infotext","Wooden box")
		m:set_string("formspec",
			"size[8,8]" ..
			"list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,0;8,4;]" ..
			"list[current_player;main;0,4.2;8,4;]" ..
			"listring[current_player;main]" ..
			"listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
		)
	end,
	can_dig = function(pos, player)
		return minetest.get_meta(pos):get_inventory():is_empty("main")
	end,
})
minetest.register_craft({
	output = "examobs:woodbox",
	recipe = {
		{"group:wood","group:stick","group:wood"},
		{"group:wood","","group:wood"},
		{"group:wood","group:wood","group:wood"}
	}
})
minetest.register_tool("examobs:icecreamball", {
	description = "Icecream ball",
	range = 1,
	inventory_image = "examobs_icecreamball.png",
	on_use = function(itemstack, user, pointed_thing)
		local dir=user:get_look_dir()
		local pos=user:get_pos()
		pos.y=pos.y+1.5
		local d={x=dir.x*15,y=dir.y*15,z=dir.z*15}
		local e=minetest.add_entity({x=pos.x+(dir.x*3),y=pos.y+(dir.y*3),z=pos.z+(dir.z*3)}, "examobs:icecreamball")
		e:set_velocity(d)
		itemstack:add_wear(65536)
		return itemstack
	end,
	groups = {store=100}
})


minetest.register_entity("examobs:icecreamball",{
	hp_max = 10,
	decoration = true,
	physical =false,
	visual = "mesh",
	mesh="examobs_icecreamball.b3d",
	textures ={"examobs_icecreammonstermaster.png"},
	on_activate=function(self, staticdata)
		self.object:set_animation({x=1,y=80,},30,0)
		self.object:set_acceleration({x=0,y=-10,z =0})
		self.att={}
	end,
	on_step=function(self, dtime)
		local pos=self.object:get_pos()
		local p
		for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 2.5)) do
			local en = ob:get_luaentity()
			if not (en and en.name == "examobs:icecreamball") and examobs.team(ob)~="candy" and not ob:get_attach() and examobs.visiable(self.object,ob:get_pos()) then
				if examobs.gethp(ob) < 100 then
					table.insert(self.att,ob)
					ob:set_attach(self.object, "", {x=0,y=0,z=0}, {x=0,y=0,z=0})
					examobs.punch(ob,ob,10)
				else
					examobs.punch(ob,ob,10)
					self.object:remove()
					return
				end
			end
		end

		if default.defpos(pos,"walkable") then
			for _, ob in pairs(self.att) do
				if ob then
					ob:set_detach()
				end
			end
			self.object:remove()
		end
		return self
	end,
})

default.register_eatable("craftitem","examobs:gingerbread_piece1",1,2,{
	description = "Gingerbread piece",
	inventory_image = "examobs_gingerbread_piece1.png",
	groups={store=100},
})
default.register_eatable("craftitem","examobs:gingerbread_piece2",1,2,{
	description = "Gingerbread piece",
	inventory_image = "examobs_gingerbread_piece2.png",
	groups={store=100}
})
default.register_eatable("craftitem","examobs:lollipop_piece",1,4,{
	description = "Lollipop piece",
	inventory_image = "examobs_lollipop_piece.png",
	groups={store=100},
})
default.register_eatable("craftitem","examobs:candycane_piece",1,5,{
	description = "Candycane piece",
	inventory_image = "examobs_candycane_piece.png",
	groups={store=100},
})

minetest.register_craft({
	output = "examobs:infection_poison",
	recipe = {
		{"plants:dolls_eyes_berries","plants:dolls_eyes_berries","plants:dolls_eyes_berries"},
		{"plants:dolls_eyes_berries","materials:glass_bottle","plants:dolls_eyes_berries"},
		{"plants:dolls_eyes_berries","plants:dolls_eyes_berries","plants:dolls_eyes_berries"}
	}
})

minetest.register_tool("examobs:infection_poison", {
	description = "Infection poison",
	inventory_image = "materials_plant_extracts_gas.png^[colorize:#ff00ff^materials_plant_extracts.png",
	tiles={"materials_plant_extracts.png"},
	groups = {flammable=1,used_by_npc=1,treasure=1,store=500},
	on_use = function(itemstack, user, pointed_thing)
		local item = user:get_wielded_item()
		if pointed_thing.type == "object" then
			local en = pointed_thing.ref:get_luaentity()
			if en.examob and en.storage.infected == nil then
				en.team = "infection_poison"
				en.aggressivity = 2
				en.type = "monster"
				en.storage.infected = 101
				local i = user:get_wield_index()
				if item:get_wear() < 60000 then
					item:add_wear(6000)
				else
					item = ItemStack("materials:glass_bottle")
				end
				user:get_inventory():set_stack("main",i,item)
			end
		end
		return item
	end
})

minetest.register_node("examobs:titan_core", {
	description = "Titan core",
	tiles={
		{
			name = "default_lava_animated.png^[invert:b",
			backface_culling = true,
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 0.5,
			}
		},

	},
	groups = {igniter=2,not_in_craftguide=1,cracky = 3,store=3000},
	sounds = default.node_sound_stone_defaults(),
	paramtype = "light",
	light_source=14,
	damage_per_second = 9,
})

-- ================ torpedo ================
minetest.register_craft({
	output = "examobs:torpedo 5",
	recipe = {
		{"","default:uranium_lump",""},
		{"materials:fanblade_metal","materials:diode","default:iron_ingot"},
		{"","materials:gear_metal",""}
	}
})

minetest.register_craftitem("examobs:torpedo",{
	description = "Torpedo (aim to a mob & use, works best in water)",
	groups = {treasure=1,store=300},
	inventory_image = "examobs_torpedo.png",
	wield_scale={x=1,y=1,z=0.5},
	on_use=function(itemstack, user, pointed_thing)
		local p1 = user:get_pos()
		local d = user:get_look_dir()
		local dir = {x=d.x*2,y=(d.y*2)+1.5,z=d.z*2}
		local p = {x=p1.x+(d.x*2),y=p1.y+(d.y*2)+1.5,z=p1.z+(d.z*2)}
		local pd = {x=d.x*50,y=d.y*50,z=d.z*50}
		local hit = {}
		for i=1,20 do
			local e = minetest.add_entity({x=p1.x+(d.x*(i*1.1)),y=p1.y+(d.y*(i*1.1))+1.5,z=p1.z+(d.z*(i*1.1))},"examobs:torpedo_ray")
			e:get_luaentity().user = user
			e:get_luaentity().hit = hit
			e:set_velocity(pd)
		end
	end
})

minetest.register_entity("examobs:torpedo",{
	hp_max = 1,
	visual = "wielditem",
	visual_size={x=0.4,y=0.4,z=2},
	pointable = false,
	textures={"examobs:torpedo"},
	collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
	physical=true,
	on_activate=function(self, staticdata)
		self.torpedo = math.random(1,9999)
		self.object:set_acceleration({x=0,y=-10,z=0})
	end,
	blow=function(self)
		if not self.blowed then
			self.target = nil
			self.blowed = true
			nitroglycerin.explode(self.object:get_pos(),{radius=5,set="air"})
			self.object:remove()
		end
	end,
	on_blow=function(self)
		if not self.blowed then
			self.target = nil
			self.blowed = true
			local p = self.object:get_pos()
			minetest.after(0,function(p)
				nitroglycerin.explode(p,{radius=3,set="air"})
				self.object:remove()
			end,p)
		end
	end,
	on_step=function(self,dtime, moveresult)
		if self.target and moveresult then
			self.timer = (self.timer or 0) + dtime
			local pos1 = self.object:get_pos()
			local pos2 = self.target:get_pos()
			if not (pos2 and pos2.y) then
				self:blow()
				return
			end
			local v = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
			local y = math.atan(v.z/v.x)
			local z = math.atan(v.y/math.sqrt(v.x^2+v.z^2))
			if pos1.x >= pos2.x then y = y+math.pi end
			self.object:set_rotation({x=0,y=y,z=z+(math.pi/4)})

			local def = default.def(minetest.get_node(pos1).name)

			if def.liquidtype == "none" then
				local vy = self.object:get_velocity() or {x=0,y=0,z=0}
				self.object:set_velocity({x=math.cos(y)*10,y=vy.y,z=math.sin(y)*10})
				if self.splash then
					self.splash = nil
					self.object:set_acceleration({x=0,y=-10,z=0})
				end
			else
				if not self.splash then
					self.splash = true
					if self.timer > 0.1 then
						default.watersplash(pos1)
					end
				end
				self.object:set_acceleration({x=0,y=0,z=0})
				self.object:set_velocity({x=math.cos(y)*10,y=-math.tan(z)*10,z=math.sin(y)*10})
			end

			if self.timer < 0.5 then
				return self
			elseif def.walkable then
				self:blow()
				return self
			end

			if moveresult.collides then
				self:blow()
			end
		elseif not self.blowed then
			self:blow()
		end
	end,
})

minetest.register_entity("examobs:torpedo_ray",{
	collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
	visual_size={x=1,y=0.1,z=0.1},
	visual = "cube",
	physical=true,
	textures={"default_stone.png^[colorize:#f00","default_stone.png^[colorize:#f00","default_stone.png^[colorize:#f00","default_stone.png^[colorize:#f00","default_stone.png^[colorize:#f00","default_stone.png^[colorize:#f00"},
	static_save = false,
	decoration = true,
	pointable = false,
	on_step=function(self, dtime, moveresult)
		if self.hit and self.hit.hit then
			self.object:remove()
		elseif moveresult and moveresult.collides and self.hit then
			for i,v in pairs(moveresult.collisions) do
				if v.type == "object" and self.user and v.object ~= self.user and not default.is_decoration(v.object,true) then
					if self.user:is_player() then
						local inv = self.user:get_inventory()
						if inv then
							local item = inv:remove_item("main",ItemStack("examobs:torpedo"))
							if item:get_count() == 0 then
								break
							end
						end
					end
					self.hit.hit = true
					local pos=self.user:get_pos()
					local e = minetest.add_entity(pos,"examobs:torpedo")
					e:get_luaentity().target = v.object
					break
				end
			end
			self.object:remove()
		elseif not self.rot then
			local pos1=self.object:get_pos()
			local dir = self.user:get_look_dir()
			local pos2={x=pos1.x+(dir.x*100),y=pos1.y+(dir.y*100),z=pos1.z+(dir.z*100)}
			local v = {x=pos1.x-pos2.x, y=(pos1.y+1.4)-pos2.y, z=pos1.z-pos2.z}
			local y = math.atan(v.z/v.x)
			local z = math.atan(v.y/math.sqrt(v.x^2+v.z^2))
			if pos1.x >= pos2.x then y = y+math.pi end
			self.object:set_rotation({x=0,y=y,z=z})
			self.rot = true
		end
	end
})