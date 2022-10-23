minetest.register_chatcommand("fade", {
	params = "",
	description = "",
	privs = {server=true},
	func = function(name, param)
		local p = minetest.get_player_by_name(name)

		if param == "1" then
			scene.fade(p,true)
		elseif param == "0" then
			scene.fade(p,false)
		elseif param == "2" then
			scene.fade(p,true,true)
		else
			scene.fade(p)
		end
	end
})

minetest.register_chatcommand("film", {
	params = "",
	description = "",
	privs = {server=true},
	func = function(name, param)
		local p = minetest.get_player_by_name(name)
		if param == "1" then
			scene.film(p,true)
		elseif param ~= "" then
			scene.filmtext(p,param)
		else
			scene.film(p)
		end
	end
})

scene.play_scene=function(name)
	scene.scenes[name]()
end

scene.add_scene=function(name,func)
	scene.scenes[name] = func
end

scene.add_anim=function(time,func)
	table.insert(scene.animjobs,{time=time,func=func})
end

minetest.register_globalstep(function(dtime)
	if #scene.animjobs > 0 then
		scene.animtime = scene.animtime + dtime
		for i,v in ipairs(scene.animjobs) do
			if scene.animtime >= v.time then
				v.func()
				table.remove(scene.animjobs,i)
				if #scene.animjobs == 0 then
					scene.animtime = 0
				end
			end
		end
	end
end)

scene.filmtext=function(player,text)
	local p = scene.user[player:get_player_name()]
	if p.film then
		text = text or ""
		if text:len() > 100 then
			local t = 0
			local text2 = text
			for i=1,text:len() do
				t = t + 1
				if t >= 100 and text:sub(i,i) == " " then
					text = text:sub(1,i) .. "\n" .. text:sub(i+1,text:len())
					t = 0
				end
			end
		end
		player:hud_change(p.film.text, "text",text)
	end
end

scene.film=function(player,toggle,n)
	local p = scene.user[player:get_player_name()]
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
			}),
			text = player:hud_add({
				hud_elem_type="text",
				name="text",
				position={x=0.5,y=0.9},
				text="text",
				number=0xFFFFFF,
				offset={x=0,y=10},
				alignment=0,
			})
		}
	elseif not toggle and p.film then
		player:hud_set_flags({hotbar=true,healthbar=true,crosshair=true,wielditem=true,breathbar=true,minimap=true})
		player_style.set_hunger_thirst_hud(player)
		player:hud_remove(p.film.id1)
		player:hud_remove(p.film.id2)
		player:hud_remove(p.film.text)
		p.film = nil
	end
end

scene.fade=function(player,fade,black)
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
		if p.fade and p.fade.opacity == #l then
			return
		end
		p.fade={
			id = player:hud_add({
				hud_elem_type="image",
				scale = {x=-100, y=-100},
				name="fade",
				position={x=0,y=0},
				text="scene_fade.png" .. (black and "^[colorize:#000000".. l[16] or ""),
				alignment = {x=1, y=1},
			}),
			opacity = fade == true and 1 or #l
		}
		if black then
			p.fade.opacity = 16
			return
		end
	end
	minetest.after(0.05, function(player,fade)
		scene.fade(player,fade)
	end,player,fade)
end

minetest.register_on_joinplayer(function(player)
	if minetest.is_singleplayer() then
		scene.user[player:get_player_name()] = {}
	end
end)

scene.spawn_camera=function(pos,attachplayer)
	local c = minetest.add_entity(pos, "scene:camera")
	c:get_luaentity().user = attachplayer
	attachplayer:set_attach(c, "",{x=0, y=0, z=0}, {x=0, y=0,z=0})
	return c
end

minetest.register_entity("scene:camera",{
	physical = false,
	is_visible = false,
	static_save = false,
	lookat=function(self,pos2)
		local pos1 = self.object:get_pos()
		local vec = {x=pos1.x-pos2.x, y=pos1.y-pos2.y, z=pos1.z-pos2.z}
		local y = math.atan(vec.z/vec.x)
		local z = math.atan(vec.y/math.sqrt(vec.x^2+vec.z^2))
		if pos1.x >= pos2.x then y = y+math.pi end
		self.object:set_rotation({x=0,y=y-math.pi/2,z=z})
	end,
	on_step=function(self, dtime)
		if self.user then
			local r = self.object:get_rotation()
			self.user:set_look_vertical(r.z)
			self.user:set_look_horizontal(r.y)
		end
	end
})