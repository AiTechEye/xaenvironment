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
	--mesh = "examobs_cube.obj",
	--visual_size={x=1,y=1,z=1},
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
	physical = true,
	collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1,},
	visual = "cube",
	visual_size={x=0.1,y=0.1,z=0.1},
	textures={"default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png","default_wood.png"},
	on_activate=function(self, staticdata)
		self.object:set_acceleration({x=0,y=-5,z=0})
		self.string = minetest.add_entity(self.object:get_pos(), "examobs:fishing_string")
		self.string:get_luaentity().float = self.object
	end,
	on_step=function(self,dtime)
		if not (self.user and self.string and self.user:get_wielded_item():get_name() == "examobs:fishing_rod") or examobs.distance(self.object,self.user) > 30 or not (examobs.visiable(self.object,self.user)) then
			if self.string then
				self.string:remove()
			end
			self.object:remove()
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

		if not self.water and minetest.get_item_group(minetest.get_node(pos1).name,"water") > 0 then
			self.object:set_acceleration({x=0,y=1,z=0})
			self.object:set_velocity({x=0,y=0,z=0})
			self.water = true
		elseif self.water and minetest.get_item_group(minetest.get_node(apos(pos1,0,-1)).name,"water") then
			self.object:set_acceleration({x=0,y=0,z=0})
			self.object:set_velocity({x=0,y=0,z=0})
			if not self.floating then
				self.floating = true
				self.object:set_pos({x=pos1.x,y=math.floor(pos1.y+0.5)+0.5,z=pos1.z})
			end
		else
			self.object:set_acceleration({x=0,y=-5,z=0})
		end
	end
})

minetest.register_tool("examobs:fishing_rod", {
	description = "Fishing rod (WIP)",
	inventory_image = "examobs_fishing_rod.png",
	sound=default.tool_breaks_defaults(),
	on_use=function(itemstack, user, pointed_thing)
		local f = minetest.add_entity(user:get_pos(), "examobs:fishing_float")
		f:set_rotation({x=90.,y=0,z=0})
		f:get_luaentity().user = user
		local d=user:get_look_dir()
		f:set_velocity({x=d.x*10,y=d.y*10,z=d.z*10})
	end
})

minetest.register_craft({
	output = "examobs:fishing_rod",
	recipe = {
		{"","materials:string","default:stick"},
		{"materials:piece_of_wood","materials:string","default:stick"},
		{"default:iron_ingot","materials:string","default:stick"}
	}
})