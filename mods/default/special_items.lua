
-- XE ============
local ncinv
for i=1,6 do
minetest.register_node("default:xe"..i, {
	description = "XE",
	drop = "default:xe1",
	tiles= {"default_xe.png"},
	groups = {cracky=3,xe=1, not_in_creative_inventory= ncinv,radioactive=15},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	paramtype = "light",
	damage_per_second = 5,
	light_source = i+8,
	sounds = default.node_sound_stone_defaults(),
	manual_page = not ncinv and "default:xe1 Please don't carry this alien ore home." or nil,
	on_timer = function(pos, elapsed)
		local m = minetest.get_meta(pos)
		local s = m:get_int("state") 
		local l = m:get_int("level")

		if s == 0 and l > 1 then
			l = l - 1
		elseif s == 1 and l < 5 then
			
			l = l + 1
		else
			s = s == 0 and 1 or 0
		end

		minetest.swap_node(pos,{name="default:xe"..l+1}) 
		m:set_int("state",s) 
		m:set_int("level",l)
		return true
	end,
	on_punch = function(pos, node, player, itemstack, pointed_0thing)
		local dir = {[0]={y=-1},[1]={y=1},[2]={x=-1},[3]={x=1},[4]={z=-1},[5]={z=1}}
		for i,v in pairs(dir) do
			local p = vector.offset(pos,v.x or 0,v.y or 0, v.z or 0)
			if default.defpos(p,"buildable_to") then
				minetest.set_node(p,{name="default:xe_spike",param2=i}) 
				minetest.get_node_timer(p):start(math.random(2,5))
			end
		end
		default.punch(player,player,3)
		minetest.get_node_timer(pos):start(0.5)
	end,
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.5)
		default.set_radioactivity(pos,15)
	end,
	on_destruct = function(pos)
		default.remove_radioactivity(pos)
	end,
})
ncinv = 1
end

minetest.register_node("default:xe_spike", {
	description = "XE Spike",
	drop = "",
	tiles = {"default_xe.png"},
	groups = {cracky=1,level=3,not_in_creative_inventory=1,igniter=3,radioactive=5},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	damage_per_second = 5,
	walkable = false,
	light_source = 8,
	on_timer = function(pos, elapsed)
		minetest.remove_node(pos)
	end,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.25, 0.1875},
			{-0.125, -0.25, -0.125, 0.125, 0.0625, 0.125},
			{-0.0625, 0.0625, -0.0625, 0.0625, 0.3125, 0.0625},
			{-0.025, 0.3125, -0.025, 0.025, 0.5, 0.025},
		}
	},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		default.set_radioactivity(pos,5)
	end,
	on_destruct = function(pos)
		default.remove_radioactivity(pos)
	end,
})

minetest.register_node("default:xe_crystal", {
	description = "XE Crystal",
	tiles = {"default_xe.png"},
	groups = {cracky=1,level=3,igniter=3,radioactive=10},
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	damage_per_second = 5,
	light_source = 8,
	drawtype = "mesh",
	mesh="default_crystal.obj",
	visual_scale = 0.3,
	collision_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0, 0.3}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3}
	},
	sounds = default.node_sound_glass_defaults(),
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(0.5)
		default.set_radioactivity(pos,15)
	end,
	on_destruct = function(pos)
		default.remove_radioactivity(pos)
	end,
})

--[[
not yet

minetest.register_ore({
	ore_type = "blob",
	ore="default:xe1",
	wherein= "default:stone",
	clust_scarcity = 20 * 20 * 20,
	clust_size = 2,
	y_min= -31000,
	y_max= -100,
	noise_params = default.ore_noise_params()
})
]]

-- atom core ============

minetest.register_node("default:core_orbit", {
	tiles = {"default_xe.png"},
	groups = {not_in_creative_inventory=1},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.05, -0.05, 0.5, 0.05, 0.05, 0.6},
		}
	},
})

minetest.register_entity("default:core_orbit",{
	physical = false,
	pointable = false,
	glow=1,
	visual = "wielditem",
	textures = {"default:core_orbit"},
	static_save = false,
	decoration=true,
	on_activate=function(self, staticdata)
		self.dir = vector.new()
		self.dim = 1
	end,
	on_step=function(self,dtime)
		if self.dim == 1 then
			self.dir.x = self.dir.x + dtime*10
		elseif self.dim == 2 then
			self.dir.y = self.dir.y + dtime*9
		else
			self.dir.x = self.dir.x + dtime*8
			self.dir.y = self.dir.y + dtime*7
		end
		self.object:set_rotation(self.dir)
	end
})

minetest.register_node("default:atom_core", {
	description = "Atom core",
	tiles= {
		{
			name = "default_xe.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 1,
				length = 1,
			}
		}
	},
	drawtype="mesh",
	mesh = "default_atomcore.obj",
	groups = {cracky=3,on_load=1,radioactive=50},
	sounds = default.node_sound_stone_defaults(),
	sunlight_propagates = true,
	paramtype = "light",
	light_source = 14,
	sounds = default.node_sound_stone_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.31, -0.31, -0.31, 0.31, 0.31, 0.31}
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3}
	},
	on_construct=function(pos)
		minetest.registered_nodes["default:atom_core"].on_load(pos)
		default.set_radioactivity(pos,50)
	end,
	on_destruct = function(pos)
		default.remove_radioactivity(pos)
	end,
	on_load = function(pos)
		minetest.add_entity(pos,"default:core_orbit")
		local y = minetest.add_entity(pos,"default:core_orbit")
		local z = minetest.add_entity(pos,"default:core_orbit")
		y:get_luaentity().dim = 2
		z:get_luaentity().dim = 3
	end,
	after_destruct=function(pos)
		for _, ob in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			local en = ob:get_luaentity()
			if en and en.name == "default:core_orbit" then
				ob:remove()
			end
		end
	end
})

-- chest spawner ============

minetest.register_node("default:treasure_chest_spawner", {
	description = "Treasure chest spawner",
	tiles = {
		"default_goldblock.png^default_chest_top.png",
		"default_goldblock.png^default_chest_top.png",
		"default_goldblock.png^default_chest_side.png",
		"default_goldblock.png^default_chest_side.png",
		"default_goldblock.png^default_chest_side.png",
		"default_goldblock.png^default_chest_front.png",
	},
	paramtype2 = "facedir",
	groups = {choppy=3,on_load=1,not_in_craftguide=1},
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		local m = minetest.get_meta(pos)
		m:set_int("level",1)
		m:set_int("chance",8)
		m:set_string("formspec","size[2,1]button[0,0;2,1;setup;Setup]")
	end,
	on_receive_fields=function(pos, formname, pressed, sender)
		if formname == "" then
			local m = minetest.get_meta(pos)

			if not pressed.set then
				local level = pressed.level or m:get_int("level")
				local chance = pressed.chance or m:get_int("chance")

				m:set_int("level",level)
				m:set_int("chance",chance)
				m:get_inventory():set_size("main", 32)
				m:get_inventory():set_size("setchest", 1)
				m:set_string("infotext","Setup")
				m:set_string("formspec",
					"size[8,9]listcolors[#77777777;#777777aa;#000000ff]"
					.. "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";setchest;0,0;1,1;]"
					.. "dropdown[1,0;1,1;level;1,2,3;"..level.."]"
					.. "dropdown[2,0;1,1;chance;1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32;"..chance.."]"
					.. "button_exit[3,0;2,1;set;Set]"
					.. "list[current_player;main;0,5;8,4;]"
					.. "list[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main;0,1;8,4;]"
					.. "tooltip[level;Treasure level]"
					.. "tooltip[set;Ready for spawning on next load]"
					.. "tooltip[0,0;1,1;Chest to place]"
					.. "tooltip[chance;Chance to spawn items]"
					.. "tooltip[1,5;8,4;Items to set or leave empty for random items]"
					.. "listring[current_player;main]"
					.. "listring[nodemeta:" .. pos.x .. "," .. pos.y .. "," .. pos.z  .. ";main]"
				)
			else
				local n = minetest.get_node(pos)
				local item = m:get_inventory():get_stack("setchest",1)
				local level = m:get_int("level")
				local chance = m:get_int("chance")
				local items = ""

				if not m:get_inventory():is_empty("main") then
					for i,v in ipairs(m:get_inventory():get_list("main")) do
						items = items .. v:get_name() .. ","
					end
				end

				minetest.set_node(pos, n)
				minetest.after(0.1,function()
					local m = minetest.get_meta(pos)
					m:set_string("formspec","")
					m:set_int("set",1)
					m:set_int("level",level)
					m:set_int("chance",chance)
					m:set_string("item",item:get_name())
					m:set_string("items",items)
				end)
			end
		end
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return minetest.registered_nodes[stack:get_name()] and 1 or 0
	end,
	on_load = function(pos)
		local m = minetest.get_meta(pos)
		local item = m:get_string("item")
		local items = m:get_string("items")
		local level = m:get_int("level")
		local chance = m:get_int("chance")
		local node = minetest.get_node(pos)
		if m:get_int("set") == 1 then
			node.name = item
			default.treasure({
				pos = pos,
				node = item ~= "" and minetest.registered_nodes[item] and node or nil,
				level = level,
				chance = chance,
				items = items ~= "" and items:split(",") or nil
			})
			local node2 = minetest.get_node(pos)
			node2.param2 = node.param2
			minetest.after(0,function()
				minetest.swap_node(pos, node2)
			end)

		end
	end
})

-- qblock ============

local qblock = function(def)
	minetest.register_node(minetest.get_current_modname() ..":qblock_".. (def.name or def.color), {
		description = def.description or "!",
		manual_page = def.manual_page,
		on_load=def.on_load,
		after_place_node = def.after_place_node,
		tiles={
			"[combine:1x1:0,0=default_cloud.png^[colorize:#"..def.color.."FF^[resize:21x21^([combine:21x21:0,-21=default_qblock.png)",
			"[combine:1x1:0,0=default_cloud.png^[colorize:#"..def.color.."FF^[resize:21x21^([combine:21x21:0,-21=default_qblock.png)",
			"[combine:1x1:0,0=default_cloud.png^[colorize:#"..def.color.."FF^[resize:21x21^([combine:21x21:0,0=default_qblock.png)",
		},
		groups = def.groups or {dig_immediate = 2,not_in_creative_inventory=1, store=def.store},
		sounds = default.node_sound_wood_defaults(),
	})
end

qblock({color="FF0000",store=20000,description="No hunger",manual_page="default:qblock_FF0000 default:qblock_1c7800 default:qblock_e29f00 default:qblock_800080 default:qblock_0000FF default:qblock_FFFFFF This kind of special blocks gives you abilities.\nPut in the abilities manu, and pay as you go\n\nThe abilities is:\n\n- No hunger/thirst.\n- Fly as a bird: transform you to a bird, look up & jump to transform, release jump to transform back, press up to speed up.\n- Fire resistance: resistance to fire/lava.\n- Immortal: immortal to to everything except fire/lava.\n- No drowning in water.\n- Light in darkness: gives you some light in darkness."})
qblock({color="1c7800",store=50000,description="Fly as a bird"})
qblock({color="e29f00",store=30000,description="Fire resistance"})
qblock({color="800080",store=50000,description="Immortal"})
qblock({color="0000FF",store=20000,description="No water drowning"})
qblock({color="FFFFFF",store=10000,description="Light in darkness"})