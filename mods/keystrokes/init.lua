keystrokes = {enabled=minetest.settings:get_bool("xaenvironment_keystrokes")}

if not keystrokes.enabled then
	return
end

keys = {{"Up","up"},{"Down","down"},{"Left","left"},{"Right","right"},{"Sneak","sneak"},{"Special","aux1"},{"Jump","jump"},{"RMB","RMB"},{"LMB","LMB"}}
minetest.register_on_joinplayer(function(player)
	if not minetest.is_singleplayer() then
		return
	end
	local x = 0
	local y = 0
	local b = {}
	b.Up={
		scale = {x=3,y=3},
		position={x=x+0.1,y=y+0.7}
	}
	b.Down={
		scale = {x=3,y=3},
		position={x=x+0.1,y=y+0.79}
	}
	b.Left={
		scale = {x=3,y=3},
		position={x=x+0.05,y=y+0.79}
	}
	b.Right={
		scale = {x=3,y=3},
		position={x=x+0.15,y=y+0.79}
	}
	b.Sneak={
		scale = {x=4.8,y=3},
		position={x=x+0.062,y=y+0.88},
	}
	b.Special={
		scale = {x=4.8,y=3},
		position={x=x+0.138,y=y+0.88}
	}
	b.Jump={
		scale = {x=8,y=3},
		position={x=x+0.237,y=y+0.88}
	}
	b.LMB={
		scale = {x=3,y=3},
		position={x=x+0.05,y=y+0.7}
	}
	b.RMB={
		scale = {x=3,y=3},
		position={x=x+0.15,y=y+0.7}
	}


	for i, v in pairs(b) do
		b[i].text = "default_cloud.png^[colorize:#333a"
		b[i].offset = {x=0,y=0}
		b[i].hud_elem_type="image"
		b[i].z_index = 0
		player:hud_add(b[i])

		player:hud_add({
			hud_elem_type="text",
			scale = {x=1,y=1},
			text=i,
			number=0x000000,
			offset={x=0,y=0},
			position=b[i].position,
			alignment=0,
			z_index = 2,
		})

		b[i].text = "default_cloud.png^[colorize:#fffa"
		b[i].z_index = 1

		keystrokes[i] = {
			hud = b[i],
			key = false
		}
	end
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name=player:get_player_name()
		local k=player:get_player_control()
		for _,key in pairs(keys) do
			local a = key[1]
			local b = key[2]
			if k[b] and keystrokes[a].key == false then
				keystrokes[a].key = true
				keystrokes[a].id = player:hud_add(keystrokes[a].hud)
			elseif k[b] == false and keystrokes[a].key then
				keystrokes[a].key = false
				player:hud_remove(keystrokes[a].id)
			end
		end
	end
end)