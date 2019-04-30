player_style={
	players={},
	registered_profiles={},
	player_attached={},
	player_dive = {},
	player_running = {},
}

minetest.register_on_player_hpchange(function(player,hp_change,modifer)
	if player and modifer.type == "fall" then
		hp_change = hp_change*4
	end
	return hp_change
end,true)

minetest.register_on_respawnplayer(function(player)
	player_style.player_attached[player:get_player_name()] = nil
end)

minetest.register_on_leaveplayer(function(player)
	player_style.player_attached[player:get_player_name()] = nil
end)

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
end)

minetest.register_on_respawnplayer(function(player)
	player_style.set_animation(player:get_player_name(),"stand")
end)

minetest.register_on_leaveplayer(function(player)
	local name=player:get_player_name()

	minetest.after(0, function(name)
			player_style.players[name] = nil
			player_style.player_dive[name] = nil
	end, name)
end)

local attached_players = player_style.player_attached

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name=player:get_player_name()
		if not attached_players[name] then
			local key=player:get_player_control()
			local a="stand"
			if key.up or key.down or key.left or key.right then
				a="walk"
				local p = player:get_pos()
				if key.sneak or minetest.get_item_group(minetest.get_node(p).name,"liquid") > 0 then
					a="dive"
					player_style.player_diveing(name,player,true,key.sneak)
				elseif key.aux1 then
					a="run"
					player_style.player_run(name,player,true,pos)
					local run = player_style.player_running[name]

					if run and run.wallrun then
						local d=player:get_look_dir()
						local walkable = default.defpos({x=p.x+(d.x*2),y=p.y,z=p.z+(d.z*2)},"walkable")
						local v = player:get_player_velocity()

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
				 if default.defpos({x=p.x,y=p.y+1,z=p.z},"walkable") then
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
		end
	end
end)

player_style.player_run=function(name,player,a)
	if player_style.player_dive[name] then
	elseif a and not player_style.player_running[name] then
		player_style.player_running[name] = {wallrun=1}
		player:set_physics_override({
			jump=1.25,
			speed = 2,
		})
	elseif not a and player_style.player_running[name] then
		player_style.player_running[name] = nil
		player:set_physics_override({
			jump=1,
			speed = 1,
		})
	end
end

player_style.player_diveing=function(name,player,a,sneak)
	--if player_style.player_running[name] then
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