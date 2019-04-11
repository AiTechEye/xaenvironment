player_style={
	players={},
	registered_profiles={},
	player_attached={},
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
		animation = 	def.animation or {
					stand={x=1,y=39,speed=30},
					walk={x=41,y=61,speed=30},
					sneak={x=41,y=61,speed=15},
					mine={x=65,y=75,speed=30},
					hugwalk={x=80,y=99,speed=30},
					lay={x=113,y=123,speed=0},
					sit={x=101,y=111,speed=0},
				},
		eye_height =	def.eye_height or 1.6,
		step_height =	def.step_height or 0.7,
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
		stepheight =	profile.step_height
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
			player_style.players[name]=nil
	end, name)
end)

local attached_players = player_style.player_attached

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name=player:get_player_name()

		if not attached_players[name] then
			local user=player_style.players[name]
			local key=player:get_player_control()
			local a="stand"

			if key.up or key.down or key.left or key.right then
				a="walk"
				if key.sneak then
					a="sneak"
				end
			elseif key.LMB or key.RMB then
				a="mine"
			elseif player:get_hp()<=0 then
				a="lay"
			end
			player_style.set_animation(name,a)
		end
	end
end)