scene = {
	user = {}
}

minetest.register_chatcommand("fade", {
	params = "",
	description = "",
	--privs = {teleport=true},
	func = function(name, param)
		local p = minetest.get_player_by_name(name)

		if param == "1" then
			scene.fade(p,true)
		elseif param == "0" then
			scene.fade(p,false)
		else
			scene.fade(p)
		end
	end
})

minetest.register_chatcommand("film", {
	params = "",
	description = "",
	--privs = {teleport=true},
	func = function(name, param)
		local p = minetest.get_player_by_name(name)
		if param ~= "" then
			scene.film(p,true)
		else
			scene.film(p)
		end
	end
})

scene.film=function(player,toggle,n)
	local p = scene.user[player:get_player_name()]

--player_style.survive_thirst = false
--player_style.survive_hunger = true

	if toggle and not p.film then
		player:hud_set_flags({hotbar=false,healthbar=false,crosshair=false,wielditem=false,breathbar=false,minimap=false})
		player_style.set_hunger_thirst_hud(player,true)
		p.film={
			id1 = player:hud_add({
				hud_elem_type="image",
				scale = {x=-100, y=-15},
				name="fade1",
				position={x=0,y=0},
				text="player_style_black.png",
				alignment = {x=1, y=1},
			}),
			id2 = player:hud_add({
				hud_elem_type="image",
				scale = {x=-100, y=-15},
				name="fade2",
				position={x=0,y=0.85},
				text="player_style_black.png",
				alignment = {x=1, y=1},
			})
		}
	elseif not toggle and p.film then
		player:hud_set_flags({hotbar=true,healthbar=true,crosshair=true,wielditem=true,breathbar=true,minimap=true})
		player_style.set_hunger_thirst_hud(player)
		player:hud_remove(p.film.id1)
		player:hud_remove(p.film.id2)
		p.film = nil
	end
end

scene.fade=function(player,fade,remove)
	local p = scene.user[player:get_player_name()]
	local l = {"00","11","22","33","44","55","66","77","88","99","aa","bb","cc","dd","ee","ff"}
	if fade == nil then
		if p.fade then
			player:hud_remove(p.fade.id)
			p.fade = nil
		end
		return
	elseif p.fade and (fade == false or p.fade and p.fade.opacity < #l) then
		p.fade.opacity = p.fade.opacity + (fade and 1 or -1)
		player:hud_change(p.fade.id, "text","scene_fade.png^[colorize:#000000".. l[p.fade.opacity])
		if fade and p.fade.opacity >= #l or fade == false and p.fade.opacity <= 1 then
			if fade == false and p.fade.opacity <= 1 then
				player:hud_remove(p.fade.id)
				p.fade = nil
			end
			return
		end
	else
		if not fade or fade and p.fade and p.fade.opacity == #l then
			return
		end
		p.fade={
			id = player:hud_add({
				hud_elem_type="image",
				scale = {x=-100, y=-100},
				name="fade",
				position={x=0,y=0},
				text="scene_fade.png",
				alignment = {x=1, y=1},
			}),
			opacity=fade and 1 or #l
		}
	end
	minetest.after(0.05, function(player,fade)
		scene.fade(player,fade,remove)
	end,player,fade)
end

minetest.register_on_joinplayer(function(player)
	scene.user[player:get_player_name()] = {}
end)


--[[
player:get_meta():get_int("scene")
minetest.register_on_player_receive_fields(function(player, form, pressed)
end)

minetest.register_on_mods_loaded(function()
end)



maps.set_exit_player=function(player)
end

minetest.register_on_respawnplayer(function(player)
end)

minetest.register_on_dieplayer(function(player)
end)
--]]