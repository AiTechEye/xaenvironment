player_style={
	players={},
	buttons={text="",num=0,num_of_buttons=0,action={}},
	registered_profiles={},
	manual_pages = {},
	player_attached={},
	player_dive = {},
	player_running = {},
	player_tired = {},
	sounds = {},
	creative = minetest.settings:get_bool("creative_mode") == true,
	damage = minetest.settings:get_bool("enable_damage") == true,
	survive_thirst = minetest.settings:get_bool("xaenvironment_thirst") ~= false,
	survive_hunger = minetest.settings:get_bool("xaenvironment_hunger") ~= false,
	survive_fall_damage = minetest.settings:get_bool("xaenvironment_quadruplet_fall_damage") ~= false,
	survive_black_death = minetest.settings:get_bool("xaenvironment_black_death") ~= false,
	survive_far_respawn = minetest.settings:get_bool("xaenvironment_far_respawn") ~= false,
	bloom_effects = minetest.settings:get_bool("xaenvironment_singleplayer_bloom"),
	static_spawnpoint = minetest.settings:get("static_spawnpoint"),
	bloom = {
		status="",
		last="",
		air={radius=16,intensity=0.05},
		liquid={radius=16,intensity=0.6},
		damage={radius=16,intensity=2},
	},
}

if player_style.damage == false then
	player_style.survive_thirst = false
	player_style.survive_hunger = false
end

dofile(minetest.get_modpath("player_style") .. "/inv.lua")
dofile(minetest.get_modpath("player_style") .. "/stuff.lua")
dofile(minetest.get_modpath("player_style") .. "/store.lua")
dofile(minetest.get_modpath("player_style") .. "/special.lua")
dofile(minetest.get_modpath("player_style") .. "/skins.lua")
dofile(minetest.get_modpath("player_style") .. "/craftguide.lua")

player_style.set_bloom=function(stat)
	if minetest.is_singleplayer() and player_style.bloom_effects then
		if stat == "setup" then
			local i = minetest.settings:get("bloom_intensity") or 0.05
			local r = minetest.settings:get("bloom_radius") or 16
			local storage = true
			for ii, v in pairs(player_style.bloom) do
				if type(v) == "table" and v.radius == r and i == v.intensity then
					storage = false
					break
				end
			end
			if storage then
				default.storage:set_int("bloom_radius",r)
				default.storage:set_float("bloom_intensity",i)
			end
			return
		elseif stat == "reset" then
			minetest.settings:set("bloom_intensity",default.storage:get_float("bloom_intensity"))
			minetest.settings:set("bloom_radius",default.storage:get_int("bloom_radius"))
			return
		elseif player_style.bloom.status ~= stat then
			if stat == "last" then
				stat = player_style.bloom.last
				player_style.bloom.last = ""
			else
				player_style.bloom.last = player_style.bloom.status
			end
			local s = player_style.bloom[stat]
			if s then
				player_style.bloom.status = stat
				minetest.settings:set("bloom_intensity",s.intensity)
				minetest.settings:set("bloom_radius",s.radius)
			end
		end
	end
end

minetest.register_on_mods_loaded(function(player)
	player_style.set_bloom("setup")
end)

minetest.register_on_shutdown(function(player)
	player_style.set_bloom("reset")
end)

player_style.drinkable=function(pos,player)
	return minetest.get_item_group(minetest.get_node(pos).name,"drinkable") > 0 and not minetest.is_protected(pos,player and player:get_player_name() or "") 
end

minetest.register_on_craft(function(itemstack,player,old_craft_grid,craft_inv)
	player_style.thirst(player,-0.05)
	player_style.hunger(player,-0.05)
end)

minetest.register_on_punchnode(function(pos,node,puncher,pointed_thing)
	if player_style.survive_thirst and (player_style.drinkable(pointed_thing.above,puncher) or player_style.drinkable(pointed_thing.under,puncher)) then
		player_style.thirst(puncher,1)
	else
		player_style.hunger(puncher,-0.01)
	end
end)

minetest.register_on_item_eat(function(hp_change,replace_with_item,itemstack,user,pointed_thing)
	player_style.hunger(user,hp_change)
	local wet = minetest.get_item_group(itemstack:get_name(),"wet") - minetest.get_item_group(itemstack:get_name(),"dry")
	if wet ~= 0 then
		player_style.thirst(user,wet)
	end
end)

minetest.register_on_player_hpchange(function(player,hp_change,modifer)
	if player and modifer.type == "fall" and player_style.survive_fall_damage == true then
		local key = player:get_player_control()
		if key.sneak then
			local name = player:get_player_name()
			local d = player:get_look_dir()
			local ppr = player_style.players[name]
			ppr.flip = ppr.flip or {time=0.4,flips=0,y=player:get_pos().y,type=""}
			player_style.set_animation(name,"roll")
			player:add_velocity({x=d.x*20,y=0,z=d.z*20})
			hp_change = hp_change >= -5 and 0 or hp_change*2
		else
			hp_change = hp_change*4
			if hp_change < 0 then
				player_style.hunger(player,-1)
			end
		end
	end
	if player and hp_change < 0 then
		minetest.sound_play("default_hurt", {to_player=player:get_player_name(), gain = 2})
		if minetest.is_singleplayer() and player_style.bloom_effects then
			player_style.set_bloom("damage")
			minetest.after(0.2,function()
				player_style.set_bloom("last")
			end)
		end
	end
	return hp_change
end,true)

minetest.register_on_dieplayer(function(player)
	local p = player_style.players[player:get_player_name()]
	if player_style.survive_black_death and not p.black_death_id then
		p.black_death_id = player:hud_add({
			hud_elem_type="image",
			scale = {x=-100, y=-100},
			name="black_death",
			position={x=0,y=0},
			text="player_style_black.png",
			alignment = {x=1, y=1},
		})
	end
end)

minetest.register_on_respawnplayer(function(player)
	local size = default.mapgen_limit-1100
	local rpos = vector.new(math.random(-size,size),math.random(1,30),math.random(-size,-size))
	local ppr = player_style.players[player:get_player_name()]
	local timeout = 0

	if player_style.survive_far_respawn == false or player_style.static_spawnpoint then
		player_style.respawn(player)
		return
	elseif ppr.respawn then
		return true
	end

	if not ppr.black_death_id then
		ppr.black_death_id = player:hud_add({
			hud_elem_type="image",
			scale = {x=-100, y=-100},
			name="black_death",
			position={x=0,y=0},
			text="player_style_black.png",
			alignment = {x=1, y=1},
		})
	end

	ppr.respawn = {
		hud = player:hud_add({
			hud_elem_type = "statbar",
			text ="quads_petrolbar.png",
			text2 ="quads_backbar.png",
			number = 1,
			item = 40,
			size = {x=10,y=50},
			position = {x=0.5,y=0.5},
			offset = {x=-40*2.5,y=-20},
		}),
		text = player:hud_add({
			hud_elem_type="text",
			scale = {x=1,y=1},
			text="Respawning...",
			number=0xFFFFFF,
			offset={x=0,y=0},
			position={x=0.5,y=0.5},
			alignment=0,
		})
	}

	minetest.after(2,function()
		if timeout == 0 and ppr then
			timeout = 1
			player_style.respawn(player,rpos)
		end
	end)

	minetest.emerge_area(vector.add(rpos,50),vector.subtract(rpos,50),function(pos, action, calls_remaining, param)
		if not ppr or not ppr.respawn or timeout == 1 then
			return
		elseif not ppr.respawn.load then
			timeout = 2
			ppr.respawn.load = calls_remaining
			player:hud_change(ppr.respawn.hud, "number", 0)
		end
		local r = ppr.respawn.load-calls_remaining
		player:hud_change(ppr.respawn.hud, "number", (r/ppr.respawn.load)*40)
		if calls_remaining == 0 then
			player_style.respawn(player,rpos)
		end
	end)
end)

player_style.respawn=function(player,pos)
	local name = player:get_player_name()
	local ppr = player_style.players[name]

	if not ppr then
		return
	end

	player_style.player_attached[name] = nil
	player_style.set_animation(name,"stand")
	player_style.hunger(player,0,true)
	player_style.thirst(player,0,true)

	for i, v in pairs(player_style.players[name].sounds) do
		minetest.sound_stop(v)
	end

	if player_style.players[name].black_death_id then
		player:hud_remove(player_style.players[name].black_death_id)
		player_style.players[name].black_death_id = nil
	end

	if player_style.survive_far_respawn == false then
		return
	elseif player_style.players[name].respawn then
		player:hud_remove(ppr.respawn.hud)
		player:hud_remove(ppr.respawn.text)
		ppr.respawn = nil
	end

	pos = pos or vector.new()

	local zone = 20
	local spots = {}
	local nodes = {}
	local ground_groups = {}
	local ground_groups_allow = {water=true,stone=true,spreading_dirt_type=true,sand=true,snow=true,ice=true}
	local vox = minetest.get_voxel_manip()
	local min, max = vox:read_from_map(vector.add(pos,zone), vector.subtract(pos,zone))
	local area = VoxelArea:new({MinEdge = min, MaxEdge = max})
	local data = vox:get_data()
	local air = minetest.get_content_id("air")

	for x=-zone,zone do
	for y=-zone,zone do
	for z=-zone,zone do
		local id = area:index(pos.x+x,pos.y+y,pos.z+z)
		local ground = data[id-area.ystride]
		local spot = data[id]
		local spos = vector.new(pos.x+x,pos.y+y,pos.z+z)

		nodes[ground] = nodes[ground] or default.def(minetest.get_name_from_content_id(ground)).walkable
		nodes[spot] = nodes[spot] or default.def(minetest.get_name_from_content_id(spot)).walkable

		if data[id+area.ystride] == air
		and not nodes[spot]
		and nodes[ground] and minetest.get_node_light(spos,0.5) >= 10 then
			local allow = ground_groups[ground]
			if allow == nil then
				local g = default.def(minetest.get_name_from_content_id(ground)).groups or {}
				for i,v in pairs(ground_groups_allow) do
					if g[i] then
						ground_groups[ground] = true
						table.insert(spots,spos)
						break
					end
				end
			elseif allow == true then
				table.insert(spots,spos)
			end
		end
	end
	end
	end

	if #spots > 0 then
		player:set_pos(spots[math.random(1,#spots)])
		return true
	--elseif not builtin then
	--	player:respawn()
	end
end

minetest.register_on_newplayer(function(player)
	minetest.after(0,function(player)
		if player and player:get_pos() then
			player_style.thirst(player,0,true)
			player_style.hunger(player,0,true)
		end
	end,player)
end)

minetest.register_on_leaveplayer(function(player)
	local name=player:get_player_name()
	player_style.player_attached[name] = nil
	minetest.after(0, function(name)
			player_style.players[name] = nil
			player_style.player_dive[name] = nil
	end, name)
end)

minetest.register_on_joinplayer(function(player)
	player_style.set_profile(player,"default")
	player_style.set_bloom("air")

end)

player_style.set_profile=function(player,pr)
	player:set_eye_offset({x=0,y=0,z=0},{x=5,y=0,z=5})
	local profile=player_style.registered_profiles[pr]
	local name=player:get_player_name()

	player_style.players[name] = {sounds={},dive_sound={dive=false,time=0}}
	player_style.players[name].profile = "default"
	player_style.players[name].player = player
	player_style.players[name].wield_item = {}
	player_style.players[name].skin = {}

	if minetest.check_player_privs(name,{ability2d=true}) then
		player_style.players[name].ability2d = {joining=0}
	end

	player_style.inventory(player)

	player:set_properties({
		textures =	profile.texture,
		visual =		profile.visual,
		visual_size =	profile.visual_size,
		collisionbox =	profile.collisionbox,
		mesh =		profile.mesh,
		eye_height =	profile.eye_height,
		stepheight =	profile.stepheight
	})

	player_style.set_animation(name,"stand")

	player:hud_set_hotbar_image(profile.hotbar)
	player:hud_set_hotbar_selected_image(profile.hotbar_selected)

	player_style.set_hunger_thirst_hud(player)

	local skin = player:get_meta():get_string("skin")
	if skin ~= "" then
		local skin_prop
		local ppr = player_style.players[name]
		ppr.skin_self = {}
		for i,v in ipairs(player_style.skins.skins) do
			if v.skin == skin then
				skin_prop = v
				break
			end
		end
		if skin_prop then

			local textures = player:get_properties().textures
			textures[1]=skin
			player:set_properties({textures = textures})
			if skin_prop.on_join then
				skin_prop.on_join(ppr.skin_self,player)
			end
			if skin_prop.on_use_join then
				skin_prop.on_use_join(ppr.skin_self,player)
			end
			if skin_prop.on_step then
				player_style.players[name].on_step_skin = skin_prop.on_step
			end
		else
			player:get_meta():set_string("skin","")
			minetest.chat_send_player(name,"Your skin where removed, your are reset to the default")
		end
	end
end

player_style.set_hunger_thirst_hud=function(player,remove)
	local name = player:get_player_name()
	local p = player_style.players[name]
	if remove then
		if p.thirst then
			player:hud_remove(p.thirst.back)
			player:hud_remove(p.thirst.bar)
			p.thirst = nil
		end
		if p.hunger then
			player:hud_remove(p.hunger.back)
			player:hud_remove(p.hunger.bar)
			p.hunger = nil
		end
		return
	elseif player_style.survive_hunger == true then
		player_style.players[name].hunger={
			level = player:get_meta():get_int("hunger"),
			step = 0,
			num = 0,
			back=player:hud_add({
				hud_elem_type="statbar",
				position={x=0.5,y=1},
				text="player_style_hunger_bar_back.png",
				number=20,
				direction = 0,
				size={x=24,y=24},
				direction=0,
				offset={x=25,y=-120},
			}),
			bar=player:hud_add({
				hud_elem_type="statbar",
				position={x=0.5,y=1},
				text="player_style_hunger_bar.png",
				number=player:get_meta():get_int("hunger"),
				direction = 0,
				size={x=24,y=24},
				direction=0,
				offset={x=25,y=-120},
			})
		}
	end

	if player_style.survive_thirst == true then
		player_style.players[name].thirst = {
			level = player:get_meta():get_int("thirst"),
			step = 0,
			num = 0,
			back=player:hud_add({
				hud_elem_type="statbar",
				position={x=0.5,y=1},
				text="player_style_thirst_bar_back.png",
				number=20,
				size={x=24,y=24},
				direction=0,
				offset={x=25,y=-150},
			}),
			bar=player:hud_add({
				hud_elem_type="statbar",
				position={x=0.5,y=1},
				text="player_style_thirst_bar.png",
				number=player:get_meta():get_int("thirst"),
				direction = 0,
				size={x=24,y=24},
				offset={x=25,y=-150},
			})
		}
	end
end

player_style.register_environment_sound=function(def)
	if not def.node then
		error("Register_environment_sound: node required")
	elseif not def.sound then
		error("Register_environment_sound: sound required")
	end
	player_style.sounds[def.node] = {
		sound = def.sound,
		timeloop = def.timeloop or 1,
		time = 0,
		gain = def.gain or 0.5,
		distance = def.distance or 10,
		play = false,
		min_y = def.min_y or -31000,
		max_y = def.max_y or 31000,
		count = def.count or 1,
	}
end

player_style.hunger=function(player,add,reset)

	if player_style.survive_hunger == false then
		return
	end

	local name = player:get_player_name()
	local p = player_style.players[name]

	if reset then
		player:get_meta():set_int("hunger",20)
		if p and p.hunger then
			p.hunger.level = 20
		end
	end

	if not (p and p.hunger) then
		return
	elseif p.hunger.num == math.ceil(p.hunger.level+add) then
		p.hunger.level = p.hunger.level + add
		if p.hunger.level <= 5  then
			local step = math.floor(p.hunger.level*100)/100
			if p.hunger.step ~= step then
				p.hunger.step = step
				player:set_hp(player:get_hp()-1)
			end
		end
		return
	end

	local a = p.hunger.level+add

	if special.have_ability(player,"no_hunger") and special.use_ability(player,"no_hunger") then
		a = math.ceil(p.hunger.level)+1
		p.hunger.level = a
	end

	if a < 0 then
		a = 0
		player:set_hp(0)
	elseif a > 20 then
		a = 20
	end

	p.hunger.num = math.ceil(a)
	p.hunger.level = a

	player:get_meta():set_int("hunger",p.hunger.num)
	player:hud_change(p.hunger.bar, "number", p.hunger.num)
end

player_style.thirst=function(player,add,reset)
	if player_style.survive_thirst == false then
		return
	end

	local name = player:get_player_name()
	local p = player_style.players[name]

	if not (p and p.thirst) then
		return
	elseif reset then
		player:get_meta():set_int("thirst",20)
		p.thirst.level = 20
	elseif p.thirst.num == math.ceil(p.thirst.level+add) then
		p.thirst.level = p.thirst.level + add
		return
	end

	local a = p.thirst.level+add

	if special.have_ability(player,"no_hunger") and special.use_ability(player,"no_hunger") then
		a = math.ceil(p.thirst.level)+1
		p.thirst.level = a
	end

	if a <= 0 then
		a = 0
		minetest.after(0,function(player)
			player:set_hp(0)
		end,player)
	elseif a > 20 then
		a = 20
	elseif a <= 5 and add <= 0 then
		minetest.after(0,function(player)
			player:set_hp(player:get_hp()-1)
		end,player)
	end

	p.thirst.num = math.ceil(a)
	p.thirst.level = a

	player:get_meta():set_int("thirst",p.thirst.num)
	player:hud_change(p.thirst.bar, "number", p.thirst.num)

	if p.thirst.num <= 4 and not p.thirst.to_death then
		p.thirst.to_death = true
		player_style.thirst_to_death(player)
	end
end

player_style.thirst_to_death=function(player)
	local name = player:get_player_name()
	local p = player_style.players[name]

	if player:get_pos() and p and p.thirst then
		if p.thirst.num <= 9 then
			player_style.thirst(player,-1)
			minetest.after(10,function(player)
				player_style.thirst_to_death(player)
			end,player)
		elseif p.thirst.to_death then
			p.thirst.to_death = nil
		end
	end
end

player_style.register_profile=function(def)
	def=def or {}
	player_style.registered_profiles[def.name or "default"]={
		texture =		def.texture or {"character.png"},
		visual =		def.visual or "mesh",
		visual_size =	def.visual_size or {x=1,y=1},
		collisionbox =	def.collisionbox or {-0.35,0,-0.35,0.35,1.8,0.35},
		mesh =		def.mesh or "character.b3d",
		diving =		def.dive or true,
		flying =		def.flying or true,
		flip =		def.flip or true,
		animation = 	def.animation or {
					stand={x=1,y=39,speed=30},
					walk={x=41,y=60,speed=30},
					run={x=41,y=61,speed=60},
					sneak={x=41,y=61,speed=15},
					mine={x=65,y=75,speed=30},
					hugwalk={x=80,y=99,speed=30},
					lay={x=113,y=123,speed=0},
					sit={x=101,y=111,speed=0},
					fly={x=125,y=135,speed=0},
					dive={x=136,y=155,speed=30},
					backflip={x=157,y=170,speed=30,loop=false},
					frontflip={x=170,y=180,speed=30,loop=false},
					right_sideflip={x=181,y=192,speed=30,loop=false},
					left_sideflip={x=192,y=204,speed=30,loop=false},
					roll={x=204,y=215,speed=30,loop=false},
				},
		eye_height =	def.eye_height or 1.6,
		stepheight =	def.stepheight or 0.7,
		hotbar =		def.hotbar or "player_api_hotbar.png",
		hotbar_selected =	def.hotbar_selected or "player_api_hotbar_selected.png",
	}
end

player_style.register_profile()

player_style.set_animation=function(name,typ,n,loop)
	local user=player_style.players[name]

	if not user and type(name) =="userdata" then
		name = name:get_player_name()
		user=player_style.players[name]
	end

	if user and user.current ~= typ and player_style.registered_profiles[user.profile].visual=="mesh" then
		user.current = typ
		local a=player_style.registered_profiles[user.profile].animation[typ]
		user.player:set_animation({x=a.x,y=a.y},n or a.speed,a.blend or 0,(loop ~= nil and loop) or a.loop)
	end
end

player_style.get_airlike=function(pos)
	local name = minetest.get_node(pos).name
	return name == "air" or name == "default:vacuum" or name == "default:gas" or minetest.get_item_group(name,"climbalespace") > 0 -- and d.liquid_renewable and d.drawtype == "airlike"
end

local attached_players = player_style.player_attached

minetest.register_globalstep(function(dtime)
	for i,v in pairs(player_style.sounds) do
		v.time = v.time + dtime
		if v.time >= v.timeloop then
			v.time = 0
			v.play = true
		else
			v.play = false
		end
	end

	for _, player in pairs(minetest.get_connected_players()) do
		local name=player:get_player_name()
		local p = player:get_pos()
		local ppr = player_style.players[name]

-- Environment sounds ===========

		if minetest.get_item_group(minetest.get_node({x=p.x,y=p.y+0.6,z=p.z}).name,"water") > 0 then
			if not ppr.dive_sound.dive then
				player_style.set_bloom("liquid")
				ppr.dive_sound.dive = true
				ppr.dive_sound.time = 4
			end
			ppr.dive_sound.time = ppr.dive_sound.time + dtime
			if ppr.dive_sound.time >= 4 then
				ppr.dive_sound.time = 0
				ppr.sounds["default_underwater"] = minetest.sound_play("default_underwater", {to_player=name, gain = 1})

			end
		elseif ppr.dive_sound.dive then
			player_style.set_bloom("air")
			ppr.dive_sound.dive = false
			minetest.sound_stop(ppr.sounds["default_underwater"])
		end

		local nodes_s_list = {}
		local nodes_s_list_sounds = {}
		for i,v in pairs(player_style.sounds) do
			if v.play and v.min_y <= p.y and v.max_y >= p.y then
				table.insert(nodes_s_list,i)
				nodes_s_list_sounds[i] = {sound=v.sound,pos=vector.new()}
			end
		end

		if #nodes_s_list > 0 then
			local nstp = minetest.find_nodes_in_area(vector.subtract(p,7),vector.add(p,7),nodes_s_list)
			if #nstp > 0 then
				for i,v in pairs(nstp) do
					local n = minetest.get_node(v).name


					if nodes_s_list_sounds[n] then
						local nsl = nodes_s_list_sounds[n]
						local sp = nsl.pos
						sp.x = sp.x + v.x
						sp.y = sp.y + v.y
						sp.z = sp.z + v.z
						nsl.count = (nsl.count or 0) + 1
					end

				end
				for i,v in pairs(nodes_s_list_sounds) do
					if v.count then
						local sp = player_style.sounds[i]
						if v.count >= sp.count then
							local vs = vector.divide(v.pos,v.count)
							local s = minetest.sound_play(v.sound, {to_player=name,pos=vs, gain = math.min(0.05 + v.count * 0.005,0.5)*sp.gain, max_hear_distance = sp.distance})
							table.insert(player_style.players[name].sounds,s)
						end
					end
				end
			end
		end

-- ========

		local witem = player:get_wielded_item():get_name()

		if ppr.wield_item.item ~= witem then
			ppr.wield_item.item = witem
			local ob = ppr.wield_item.object
			local node = minetest.registered_nodes[witem]
			if ob and (witem == "" or node ~= ppr.wield_item.node) then
				ob:remove()
				ob = nil
			end
			ppr.wield_item.node = node
			if witem ~= "" then
				if not (ob and ob:get_luaentity()) then
					ob = minetest.add_entity(p,"default:wielditem")
					ppr.wield_item.object = ob
				end
				if node then
					ob:set_attach(player, "rarm2",{x=0, y=3, z=3}, {x=90, y=0,z=270})
					ob:set_properties({textures={witem},visual_size = {x=0.3,y=0.3}})
				else
					ob:set_attach(player, "rarm2",{x=0, y=0, z=3}, {x=90, y=0,z=270})
					ob:set_properties({textures={witem},visual_size = {x=0.4,y=0.4}})
				end
			end
			player_style.inventory(player)
		end
-- ========

		if not attached_players[name] then
			local key=player:get_player_control()
			local a="stand"
			local hunger = -0.0001

			if key.jump and player:get_look_vertical() <= -1.5 and not player:get_attach() and special.have_ability(player,"fly_as_a_bird") and special.use_ability(player,"fly_as_a_bird") then
				local ob = minetest.add_entity(apos(p,0,1), "examobs:hawk")
				local en = ob:get_luaentity()
				en.target = player
				en.playerskin = player:get_properties().textures
				en.aggressivity = 0
				player:set_properties({textures = {"default_air.png","default_air.png","default_air.png"}})
				ob:set_properties({pointable=false})
				player:set_attach(ob, "", {x=0,y=0,z=0},{x=0,y=0,z=100})
				player:set_eye_offset({x=0, y=-15, z=-20}, {x=0, y=0, z=0})
				player:set_look_vertical(0)
				player:hud_set_flags({wielditem=false})
				en.on_abs_step=function(self)
					local target = self.target
					if not target and target:get_pos() then
						self.object:remove()
						return self
					end

					local key = target:get_player_control()
					self.flee = nil
					self.fight = nil
					if not key.jump or not target:get_attach() or target:get_hp() <= 0 or self.dead or self.dying then
						target:set_detach()
						target:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
						target:set_properties({textures = en.playerskin})
						target:hud_set_flags({wielditem=true})
						self.object:remove()
						return self
					elseif self.timer2 >= self.updatetime then
						if not special.use_ability(target,"fly_as_a_bird") then
							target:set_detach()
							target:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
							target:set_properties({textures = en.playerskin})
							target:hud_set_flags({wielditem=true})
							self.object:remove()
							return self
						end
						self.timer2 = 0
					end
					examobs.walk(self,true)
					local v = self.object:get_velocity()
					local y = key.up and -25 or -5
					local s = key.up and 5 or 1
					self.object:set_velocity({x=v.x*s,y=target:get_look_vertical()*y,z=v.z*s})
					self.object:set_yaw(target:get_look_horizontal())
					return true
				end
			end

--flips
			if ppr.flip or key.jump and key.RMB and (key.down or key.up or key.left or key.right) and not default.defpos(apos(p,0,-0.5),"walkable") then
				if ppr.flip then
					ppr.flip.time = ppr.flip.time -dtime
					if ppr.flip.time <= 0 then
						if key.jump and key.RMB and not ppr.flip.lay and minetest.get_item_group(minetest.get_node(p).name,"liquid") == 0 and ppr.flip.type ~= "" then
							ppr.flip.time = 0.4
							ppr.flip.flips = ppr.flip.flips + 1
							ppr.current = ""
							player_style.set_animation(name,ppr.flip.type.."flip",nil,true)
						else
							local f = ppr.flip.type:sub(1,1):upper()..ppr.flip.type:sub(2,-1):gsub("_"," ")
							local lab = {f.."flip","Double "..f.."flip","Triple "..f.."flip","Quadruple "..f.."flip"}
							if not ppr.flip.lay and ppr.flip.type ~= "" then
								minetest.chat_send_player(name,lab[ppr.flip.flips] or (ppr.flip.flips.."x "..f.."flips"))
								if ppr.flip.type == "front" then
									exaachievements.customize(player,"Freerunner")
								elseif ppr.flip.type == "back" then
									exaachievements.customize(player,"Circus artist")									
								elseif ppr.flip.type == "right_side" then
									exaachievements.customize(player,"Parkour!")
								elseif ppr.flip.type == "left_side" then
									exaachievements.customize(player,"Tricker")
								end

								if default.defpos(p,"walkable") then
									player:move_to(apos(p,0,1))
									player_style.player_diveing(name,player,true)
								else
									player_style.set_animation(name,"stand")
									local profile=player_style.registered_profiles[player_style.players[name].profile]
									player:set_properties({collisionbox = profile.collisionbox})
								end
								for i,v in ipairs({{x=0.5},{x=-0.5},{z=0.5},{z=-0.5}}) do
									if default.defpos(apos(p,v.x,0,v.z),"walkable") then
										player:move_to(vector.round(p))
										break
									end
								end
							end
							if default.defpos(p,"walkable") then
								player:move_to(apos(p,0,1))
							end
							ppr.flip = nil
						end
					elseif not ppr.flip.lay and (not ppr.flip.side or ppr.flip.side and p.y <= ppr.flip.y) and default.defpos(p,"walkable") then
						local r = ((ppr.flip.type == "right_side" or ppr.flip.type == "left_side") and 1) or math.random(1,10)
						player:set_hp(player:get_hp()-(r < 10 and 1 or r*3))
						player_style.set_animation(name,"lay")
						ppr.flip.time = 0.5
						ppr.flip.lay = true
						ppr.flip.flips = 0
						player_style.player_diveing(name,player,true,minetest.get_item_group(minetest.get_node(p).name,"liquid"))
					end
				else
					ppr.flip = {time=0.4,flips=1,y=p.y,type=key.down and "back" or key.up and "front" or key.right and "right_side" or key.left and "left_side",side = key.right or key.left}
					player_style.set_animation(name,ppr.flip.type.."flip")
					player:set_properties({collisionbox = {-0.35,0.6,-0.35,0.35,1,0.35}})
				end
				goto setp
			elseif key.up or key.down or key.left or key.right then
				a="walk"
				hunger = -0.0002
				local p = player:get_pos()
				local pr = player_style.player_dive[name]
				local v = player:get_velocity()

				ppr.rolltimer = ppr.rolltimer and ppr.rolltimer > 0 and ppr.rolltimer - dtime or nil
				if pr and pr.kong then
					if default.defpos({x=p.x,y=p.y-0.1,z=p.z},"walkable") then
						pr.kong = nil
						player_style.player_diveing(name,player)
					else
						a="dive"
					end
				elseif not ppr.rolltimer and key.up and key.RMB and not ppr.flip and minetest.get_item_group(minetest.get_node(p).name,"liquid") == 0 and v.x^2 + v.y^2 + v.z^2 < 100 and witem == "" then
					local name = player:get_player_name()
					local d = player:get_look_dir()
					ppr.flip = ppr.flip or {time=0.4,flips=0,y=player:get_pos().y,type=""}
					ppr.rolltimer = 1
					player_style.set_animation(name,"roll")
					local n = default.defpos(apos(p,0,-0.5),"walkable") and 20 or 10
					player:add_velocity({x=d.x*n,y=0,z=d.z*n})
					player_style.player_diveing(name,player,true)
					hunger = -0.1
					goto setp
				elseif key.sneak or minetest.get_item_group(minetest.get_node(p).name,"liquid") > 0 then
					hunger = -0.0005
					a="dive"
					player_style.player_diveing(name,player,true,minetest.get_item_group(minetest.get_node(p).name,"liquid"))
				elseif key.aux1 then
					a="run"
					player_style.player_run(name,player,true)
					local run = player_style.player_running[name]
					if run then
						hunger = -0.0005
					end
					if run and run.wallrun then
						local d = player:get_look_dir()
						local walkable = default.defpos({x=p.x+(d.x*2),y=p.y,z=p.z+(d.z*2)},"walkable")
						local v = player:get_velocity()
						hunger = -0.002
						if key.jump then
							run.wallrun = nil
							player:set_physics_override({jump=1.25})
							hunger = -0.05
						elseif run.wallrun == 1 and walkable and v.y == 0 and math.abs(v.x+v.z) > 1.5 then
							player:set_physics_override({jump=1.8})
							run.wallrun = 2
							hunger = -0.05
						elseif run.wallrun == 2 and not walkable then
							player:set_physics_override({jump=1.25})
							run.wallrun = 1
							hunger = -0.05
						elseif key.up and not (key.down or key.left or key.right)
						and default.defpos({x=p.x,y=p.y-1,z=p.z},"walkable") 
						and default.defpos({x=p.x+(d.x*2),y=p.y,z=p.z+(d.z*2)},"walkable")
						and not default.defpos({x=p.x+(d.x*2),y=p.y+1,z=p.z+(d.z*2)},"walkable")
						and default.surfaceheight({x=p.x+(d.x*2),y=p.y,z=p.z+(d.z*2)}) > p.y+0.5 then
							player:set_pos(apos(p,0,1,0))
							a="dive"
							player_style.player_diveing(name,player,true,nil,{x=p.x+(d.x*2),y=p.y,z=p.z+(d.z*2)})
							player:add_velocity({x=d.x*20,y=5,z=d.z*20})
						end
					end
				end

				if v.y < 0 and not default.defpos(apos(p,0,-0.5),"walkable") then
					local d = player:get_look_dir()
					local w = vector.add(apos(p,0),{x=d.x,y=0,z=d.z})
					if default.defpos(apos(w,0,1),"walkable") and not default.defpos(apos(w,0,2),"walkable") then
						if player_style.get_airlike(p) and player_style.get_airlike(apos(p,0,1)) then
							if default.defpos(apos(p,0,1),"drowning") == 1 then
								minetest.set_node(p,{name="player_style:edgehook2"})
								minetest.set_node(apos(p,0,1),{name="player_style:edgehook2"})
							else
								minetest.set_node(p,{name="player_style:edgehook"})
								minetest.set_node(apos(p,0,1),{name="player_style:edgehook"})
							end
						end
					elseif default.defpos(apos(w,0,0),"walkable") and not default.defpos(apos(w,0,1),"walkable") then
						if player_style.get_airlike(p) then
							if default.defpos(p,"drowning") == 1 then
								minetest.set_node(p,{name="player_style:edgehook2"})
							else
								minetest.set_node(p,{name="player_style:edgehook"})
							end
						end
					end
				elseif key.aux1 and key.jump and vector.distance(vector.new(),v) < 9 then
--walljump
					local ly = player:get_look_horizontal()
					local x1 =math.sin(ly) * -1
					local z1 =math.cos(ly)
					local x2 =math.sin(ly)
					local z2 =math.cos(ly) * -1
					local l = default.defpos({x=p.x+x1,y=p.y,z=p.z+z1},"walkable")
					local r = default.defpos({x=p.x+x2,y=p.y,z=p.z+z2},"walkable")

					if l then
						local d = player:get_look_dir()
						player:add_velocity({x=d.x+(x2*4),y=1,z=d.z+(z2*4)})
					elseif r then
						local d = player:get_look_dir()
						player:add_velocity({x=d.x+(x1*4),y=1,z=d.z+(z1*4)})
					end
				end
				if key.left and key.right then
					local x1 = default.defpos({x=p.x+1,y=p.y,z=p.z},"walkable")
					local x2 = default.defpos({x=p.x-1,y=p.y,z=p.z},"walkable")
					local z1 = default.defpos({x=p.x,y=p.y,z=p.z+1},"walkable")
					local z2 = default.defpos({x=p.x,y=p.y,z=p.z-1},"walkable")
					if x1 and x2 or z1 and z2 then
						if default.defpos(apos(p,0,1),"drowning") == 1 then
							minetest.set_node(p,{name="player_style:edgehook2"})
							minetest.set_node(apos(p,0,1),{name="player_style:edgehook2"})
						else
							minetest.set_node(p,{name="player_style:edgehook"})
							minetest.set_node(apos(p,0,1),{name="player_style:edgehook"})
						end
					end
				end
			elseif key.sneak or minetest.get_item_group(minetest.get_node(player:get_pos()).name,"liquid") > 0 then
				a = "fly"
				player_style.player_diveing(name,player,true)
			elseif key.LMB or key.RMB then
				a="mine"
				if key.RMB and ppr.ability2d and player:get_meta():get_int("special_disabled") == 0 and not exa2d.user[name] and player:get_wielded_item():get_name() == "" then
					local d = player:get_look_dir()
					local p1 = {x=p.x+(d.x*2),y=p.y+2+(d.y*2),z=p.z+(d.z*2)}
					local p2 = {x=p.x,y=p.y+2,z=p.z}
					local f
					for v in minetest.raycast(p1,p2) do
						if v.type == "node" and (v.intersection_normal.x ~=0 or v.intersection_normal.y ~=0 or v.intersection_normal.z ~= 0) and default.defpos(v.under,"walkable") then
							ppr.ability2d.joining = true
							ppr.ability2d.time = ppr.ability2d.time +dtime
							if ppr.ability2d.time > 1 then
								ppr.ability2d.joining = nil
								ppr.ability2d.time = 0
								exa2d.join(player,{x=v.above.x-v.intersection_normal.x*2,y=v.above.y-v.intersection_normal.y*2,z=v.above.z-v.intersection_normal.z*2})
							else
								local tl =math.floor(ppr.ability2d.time*10)*0.1
								if tl ~= ppr.ability2d.time then
									minetest.chat_send_player(name,"Stand close to the wall and Hold for "..(1-tl).."s more")
								end
							end
							f = true
							break
						end
					end
					if not f then
						ppr.ability2d.time = 0
					end
				end
			elseif ppr.ability2d and ppr.ability2d.joining then
				ppr.ability2d.joining = nil
				ppr.ability2d.time = 0
			elseif player:get_hp()<=0 then
				a="lay"
			end

			if ppr.inv.itemmagnet == 1 then
				local p = apos(player:get_pos(),0,1)
				for _, ob in pairs(minetest.get_objects_inside_radius(p, 2)) do
					local en = ob:get_luaentity()
					if en and en.name == "__builtin:item" then
						en.moveto_object = player
					end
				end
			end

			if player_style.player_dive[name] and not (a == "fly" or a == "dive") then
				local p = player:get_pos()
				 if default.defpos({x=p.x,y=p.y+1.5,z=p.z},"walkable") then
					if key.up or key.down or key.left or key.right then
						a="dive"
					else
						a = "fly"
					end
					if not player_style.player_dive[name].blocking then
						player_style.player_dive[name].blocking = true
						player:set_physics_override({speed=0.5})
					end
				else
					player_style.player_diveing(name,player)
				end

			elseif player_style.player_running[name] and not key.aux1 then
				player_style.player_run(name,player)

			end

			player_style.set_animation(name,a)
			::setp::
			player_style.hunger(player,hunger)
			player_style.thirst(player,hunger*2)
			player_style.tired(name,player)

			if ppr.on_step_skin then
				ppr.on_step_skin(ppr.skin_self,player,dtime)
			else
				ppr.on_step_skin = nil
			end
		end
	end
end)

player_style.tired=function(name,player)
	local hunger = player_style.players[name].hunger
	local h = (hunger and hunger.level or 20)
	if player_style.player_dive[name] or player_style.player_running[name] then
		player_style.player_tired[name] = nil
	elseif not player_style.player_tired[name] and h <= 8 then
		player_style.player_tired[name] = true
		player:set_physics_override({
			jump=0.7,
			speed = 0.7,
		})
	elseif h > 8 and player_style.player_tired[name] then
		player_style.player_tired[name] = nil
		player:set_physics_override({
			jump=1,
			speed = 1,
		})
	end
end

player_style.player_run=function(name,player,a)
	local hunger = player_style.players[name].hunger
	local h = (hunger and hunger.level or 20)
	if player_style.player_dive[name] then
	elseif a and not player_style.player_running[name] and h > 10 then
		player_style.player_running[name] = {wallrun=1}
		player:set_physics_override({
			jump=1.25,
			speed = 2,
		})
	elseif (not a or h <= 10) and player_style.player_running[name] then
		player_style.player_running[name] = nil
		player:set_physics_override({
			jump=1,
			speed = 1,
		})
	end
end

player_style.player_diveing=function(name,player,a,water,kong)
	local pos = player:get_pos()

	if a and not player_style.player_dive[name] then
		player_style.player_run(name,player)
		player_style.player_dive[name] = {kong = kong}
		player:set_properties({
			eye_height = 0.6,
			collisionbox = {-0.35,0,-0.35,0.35,0.49,0.35},
			stepheight=1.1,
		})
		player:set_physics_override({
			jump= water == 0 and 0 or 1,
		})

		local nod = minetest.get_node(pos).name

		if player:get_velocity().y < 0 then
			if minetest.get_item_group(nod,"water") > 0 then
				local d = default.def(nod)
				default.watersplash(pos,d.drawtype and d.drawtype == "flowingliquid")
			elseif minetest.get_item_group(nod,"lava") > 0 then
				minetest.sound_play("default_clay_step", {object=player, gain = 4,max_hear_distance = 10})
			end
		end
	else

		local pr =  player_style.player_dive[name]
		local b = player:get_breath()

		if b < 10 and minetest.get_item_group(minetest.get_node(pos).name,"water") > 0 and special.have_ability(player,"no_water_drowning") and special.use_ability(player,"no_water_drowning") then
			player:set_breath(b+1)
		end

		if not a and pr and (pr.kong == nil or player:get_velocity().y == 0) then --default.defpos({x=pos.x,y=pos.y-1,z=pos.z},"walkable") ~= true
			local profile=player_style.registered_profiles[player_style.players[name].profile]
			player_style.player_dive[name] = nil
			player:set_properties({
				eye_height = profile.eye_height,
				collisionbox = profile.collisionbox,
				stepheight = profile.stepheight,
			})
			player:set_physics_override({
				jump=1,
				speed = 1,
			})
		end
	end

	if default.def(minetest.get_node(pos).name).drawtype == "flowingliquid" then
		default.flowing(player)
	end
end