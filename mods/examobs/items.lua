default.register_eatable("craftitem","examobs:flesh",1,4,{
	description = "Flesh",
	groups={meat=1},
	inventory_image = "examobs_flesh.png^examobs_alpha_fleshpiece.png^[makealpha:0,255,0"
})
default.register_eatable("craftitem","examobs:meat",3,4,{
	description = "Cooked meat",
	groups={meat=1},
	inventory_image = "examobs_meat.png^examobs_alpha_fleshpiece.png^[makealpha:0,255,0"
})

minetest.register_tool("examobs:hiding_poison", {
	description = "Hiding poison",
	inventory_image = "materials_plant_extracts.png",
	sound=default.tool_breaks_defaults(),
	on_use=function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if examobs.hiding[name] then
			examobs.hiding[name] = nil
			minetest.chat_send_player(name,"off")
		else
			examobs.hiding[name] = true
			minetest.chat_send_player(name,"on")
		end
	end,
})


-- ================ Wolf ================

minetest.register_craftitem("examobs:pelt",{
	description = "Pelt",
	groups = {flammable=3},
	inventory_image = "examobs_pelt.png",
	wield_scale={x=2,y=2,z=1},
})
minetest.register_craftitem("examobs:tooth",{
	description = "Tooth",
	inventory_image = "examobs_tooth.png",
	wield_scale={x=0.3,y=0.3,z=0.4},
})
minetest.register_craft({
	type = "cooking",
	output = "examobs:meat",
	recipe = "examobs:flesh",
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
})
minetest.register_craftitem("examobs:feather",{
	description = "Feather",
	groups = {flammable=3},
	inventory_image = "examobs_feather.png",
	wield_scale={x=0.5,y=0.5,z=0.2},
})
-- ================ sheep ================
minetest.register_tool("examobs:shears",{
	description = "Shears",
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
		local item = self.user:get_wielded_item()
		local i = self.user:get_wield_index()
		if item:get_wear() < 60000 then
			item:add_wear(3000)
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
})

minetest.register_tool("examobs:fishing_rod_with_string", {
	description = "Fishing rod with string",
	inventory_image = "examobs_fishing_rod_with_string.png",
	sound=default.tool_breaks_defaults(),
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