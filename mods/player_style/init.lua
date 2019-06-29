player_style={
	players={},
	registered_profiles={},
	player_attached={},
	player_dive = {},
	player_running = {},
	survive_thirst = minetest.settings:get_bool("xaenvironment_thirst"),
	survive_hunger = minetest.settings:get_bool("xaenvironment_hunger"),
	survive_fall_damage = minetest.settings:get_bool("xaenvironment_quadruplet_fall_damage"),
}
dofile(minetest.get_modpath("player_style") .. "/stuff.lua")

player_style.drinkable=function(pos,player)
	return minetest.get_item_group(minetest.get_node(pos).name,"drinkable") > 0 and not minetest.is_protected(pos,player and player:get_player_name() or "") 
end

minetest.register_on_punchnode(function(pos,node,puncher,pointed_thing)
	if player_style.survive_thirst and player_style.drinkable(pointed_thing.above,puncher) then
		 player_style.thirst(puncher,1)
		minetest.remove_node(pointed_thing.above)
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
		hp_change = hp_change*4
		if hp_change < 0 then
			player_style.hunger(player,-1)
		end
	end
	return hp_change
end,true)

minetest.register_on_respawnplayer(function(player)
	local name = player:get_player_name()
	player_style.player_attached[name] = nil
	player_style.set_animation(name,"stand")
	player_style.hunger(player,0,true)
	player_style.thirst(player,0,true)
end)

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
	local profile=player_style.registered_profiles["default"]
	local name=player:get_player_name()

	player_style.players[name] = {}
	player_style.players[name].profile = "default"
	player_style.players[name].player = player

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

	if player_style.survive_hunger == true then
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
				direction = 0,
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
				direction=0,
				offset={x=25,y=-150},
			})
		}
	end
end)

player_style.hunger=function(player,add,reset)

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

	if a <= 0 then
		a = 0
		minetest.after(0,function(player)
			player:set_hp(0)
		end,player)
	elseif a > 20 then
		a = 20
	elseif a <= 10 and add <= 0 then
		minetest.after(0,function(player)
			player:set_hp(player:get_hp()-1)
		end,player)
	end

	p.thirst.num = math.ceil(a)
	p.thirst.level = a

	player:get_meta():set_int("thirst",p.thirst.num)
	player:hud_change(p.thirst.bar, "number", p.thirst.num)

	if p.thirst.num <= 9 and not p.thirst.to_death then
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
		animation = 	def.animation or {
					stand={x=1,y=39,speed=30},
					walk={x=41,y=61,speed=30},
					run={x=41,y=61,speed=60},
					sneak={x=41,y=61,speed=15},
					mine={x=65,y=75,speed=30},
					hugwalk={x=80,y=99,speed=30},
					lay={x=113,y=123,speed=0},
					sit={x=101,y=111,speed=0},
					fly={x=125,y=135,speed=0},
					dive={x=136,y=156,speed=30},
				},
		eye_height =	def.eye_height or 1.6,
		stepheight =	def.stepheight or 0.7,
		hotbar =		def.hotbar or "player_api_hotbar.png",
		hotbar_selected =	def.hotbar_selected or "player_api_hotbar_selected.png",
	}
end

player_style.register_profile()

player_style.set_animation=function(name,typ,n)
	local user=player_style.players[name]

	if not user and type(name) =="userdata" then
		name = name:get_player_name()
		user=player_style.players[name]
	end

	if user and user.current ~= typ and player_style.registered_profiles[user.profile].visual=="mesh" then
		user.current = typ
		local a=player_style.registered_profiles[user.profile].animation[typ]
		user.player:set_animation({x=a.x,y=a.y},n or a.speed,0)
	end
end

local attached_players = player_style.player_attached

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name=player:get_player_name()
		if not attached_players[name] then
			local key=player:get_player_control()
			local a="stand"
			local hunger = -0.0001
			if key.up or key.down or key.left or key.right then
				hunger = -0.0002
				a="walk"
				local p = player:get_pos()
				if key.sneak or minetest.get_item_group(minetest.get_node(p).name,"liquid") > 0 then
					hunger = -0.002
					a="dive"
					player_style.player_diveing(name,player,true,key.sneak)
				elseif key.aux1 then
					a="run"
					player_style.player_run(name,player,true)
					local run = player_style.player_running[name]
					if run and run.wallrun then
						local d=player:get_look_dir()
						local walkable = default.defpos({x=p.x+(d.x*2),y=p.y,z=p.z+(d.z*2)},"walkable")
						local v = player:get_player_velocity()
						hunger = -0.01
						if key.jump then
							run.wallrun = nil
							player:set_physics_override({jump=1.25})
						elseif run.wallrun == 1 and walkable and v.y == 0 and math.abs(v.x+v.z) > 1.5 then
							player:set_physics_override({jump=1.8})
							run.wallrun = 2
						elseif run.wallrun == 2 and not walkable then
							player:set_physics_override({jump=1.25})
							run.wallrun = 1
						end
					end
				end
			elseif key.sneak or minetest.get_item_group(minetest.get_node(player:get_pos()).name,"liquid") > 0 then
				a = "fly"
				player_style.player_diveing(name,player,true)
			elseif key.LMB or key.RMB then
				a="mine"
			elseif player:get_hp()<=0 then
				a="lay"
			end

			if player_style.player_dive[name] and not (a == "fly" or a == "dive") then
				local p = player:get_pos()
				hunger = -0.01
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
			player_style.hunger(player,hunger)
			player_style.thirst(player,hunger*2)
		end
	end
end)

player_style.player_run=function(name,player,a)
	player_style.hunger(player,-0.001)
	if player_style.player_dive[name] then
	elseif a and not player_style.player_running[name] and player_style.players[name].hunger.level > 15 then
		player_style.player_running[name] = {wallrun=1}
		player:set_physics_override({
			jump=1.25,
			speed = 2,
		})
	elseif  (not a or player_style.players[name].hunger.level < 15) and player_style.player_running[name] then
		player_style.player_running[name] = nil
		player:set_physics_override({
			jump=1,
			speed = 1,
		})
	end
end

player_style.player_diveing=function(name,player,a)
	if a and not player_style.player_dive[name] then
		player_style.player_run(name,player)
		player_style.player_dive[name] = {}
		player:set_properties({
			eye_height = 0.6,
			collisionbox = {-0.35,0,-0.35,0.35,0.49,0.35},
			stepheight=1.1,
		})
		player:set_physics_override({
			jump=0,
		})
	elseif not a and player_style.player_dive[name] then
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