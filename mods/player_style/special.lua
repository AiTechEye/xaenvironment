special={
	user={},
	num = 6,
	blocks = {
		["default:qblock_FF0000"]={i=1,
			info="\nWont be hungry or thirsty",
			image="player_style_hunger_bar.png",
			meta = "no_hunger",
			amount=50,
			trigger=function(player)
				local m = player:get_meta()
				m:set_int("no_hunger",m:get_int("no_hunger")+50)
				special.hud(player,"default:qblock_FF0000")
			end,
			use=function(player)
				local m = player:get_meta()
				local f  = m:get_int("no_hunger")
				if f > 0 then
					m:set_int("no_hunger",f-1)
					special.hud(player,"default:qblock_FF0000")
					return true
				end
			end,
			count=function(player)
				return player:get_meta():get_int("no_hunger")
			end
		},
		["default:qblock_1c7800"]={i=2,
			info="\nLook up and jump to fly, walk forward to fly fast",
			image="examobs_feather.png",
			meta = "fly_as_a_bird",
			amount=20,
			trigger=function(player)
				local m = player:get_meta()
				m:set_int("fly_as_a_bird",m:get_int("fly_as_a_bird")+50)
				special.hud(player,"default:qblock_1c7800")
			end,
			use=function(player)
				local m = player:get_meta()
				local f  = m:get_int("fly_as_a_bird")
				if f > 0 then
					m:set_int("fly_as_a_bird",f-1)
					special.hud(player,"default:qblock_1c7800")
					return true
				end
			end,
			count=function(player)
				return player:get_meta():get_int("fly_as_a_bird")
			end
		},
		["default:qblock_e29f00"]={i=3,
			info="\nImmortal to fire & lava",
			image="fire_basic_flame.png",
			meta = "fire_resistance",
			amount=50,
			trigger=function(player)
				local m = player:get_meta()
				m:set_int("fire_resistance",m:get_int("fire_resistance")+50)
				special.hud(player,"default:qblock_e29f00")
			end,
			use=function(player,c)
				c = c or -1
				local m = player:get_meta()
				local f  = m:get_int("fire_resistance")
				local hp  = f+c
				if f > 0 then
					m:set_int("fire_resistance",hp > 0 and hp or 0)
					special.hud(player,"default:qblock_e29f00")
				end
				return hp > 0 and 0 or hp
			end,
			count=function(player)
				return player:get_meta():get_int("fire_resistance")
			end
		},
		["default:qblock_800080"]={i=4,
			info="\nImmortal to everything except lava & fire",
			image="default_steelblock.png^armor_alpha_chestplate_item.png^[makealpha:0,255,0",
			meta = "immortal",
			amount=20,
			trigger=function(player)
				local m = player:get_meta()
				m:set_int("immortal",m:get_int("immortal")+20)
				special.hud(player,"default:qblock_800080")
			end,
			use=function(player,c)
				local m = player:get_meta()
				local f = m:get_int("immortal")
				local hp  = f+c
				if f > 0 then
					m:set_int("immortal",hp > 0 and hp or 0)
					special.hud(player,"default:qblock_800080")
				end
				return hp > 0 and 0 or hp
			end,
			count=function(player)
				return player:get_meta():get_int("immortal")
			end
		},
		["default:qblock_0000FF"]={i=5,
			info="\nYou wont drown in water",
			image="bubble.png",
			meta = "no_water_drowning",
			amount=50,
			trigger=function(player)
				local m = player:get_meta()
				m:set_int("no_water_drowning",m:get_int("no_water_drowning")+50)
				special.hud(player,"default:qblock_0000FF")
			end,
			use=function(player)
				local m = player:get_meta()
				local f = m:get_int("no_water_drowning")
				if f > 0 then
					m:set_int("no_water_drowning",f-1)
					special.hud(player,"default:qblock_0000FF")
					return true
				end
			end,
			count=function(player)
				return player:get_meta():get_int("no_water_drowning")
			end
		},
		["default:qblock_FFFFFF"]={i=6,
			info="\nAutomatic light in darkness",
			image="default_cloud.png^default_alpha_gem_round.png^[makealpha:0,255,0",
			meta = "light_in_darkness",
			amount=1000,
			trigger=function(player)
				local m = player:get_meta()
				m:set_int("light_in_darkness",m:get_int("light_in_darkness")+1000)
				special.hud(player,"default:qblock_FFFFFF")
				special.blocks["default:qblock_FFFFFF"].on_load(player)
			end,
			use=function(player)
				local m = player:get_meta()
				local f = m:get_int("light_in_darkness")
				if f > 0 then
					m:set_int("light_in_darkness",f-1)
					special.hud(player,"default:qblock_FFFFFF")
					return true
				end
				return false
			end,
			count=function(player)
				return player:get_meta():get_int("light_in_darkness")
			end,
			on_load=function(player)
				local name = player:get_player_name()
				if not player then
					return
				end
				local p = player:get_pos()
				if not p then
					return
				end
				p = apos(p,0,0.1)
				local n = minetest.get_node(p).name
				local l = minetest.get_node_light(p) or 14

				print(l , n)

				if l < 11 or n == "vexcazer_flashlight:flht" or n == "vexcazer_flashlight:flhtw" then
					local v
					local s
					if minetest.get_node_group(n, "water") > 0 then
						minetest.set_node(p, {name="vexcazer_flashlight:flhtw"})
						v = special.blocks["default:qblock_FFFFFF"].use(player)
					elseif (n == "air" or n == "vexcazer_flashlight:flht") then
						minetest.set_node(p, {name="vexcazer_flashlight:flht"})
						v = special.blocks["default:qblock_FFFFFF"].use(player)
					end
					if v ~= false then
						minetest.after(0.5,function(player)
							special.blocks["default:qblock_FFFFFF"].on_load(player)
						end,player)
					end
				else
					minetest.after(1,function(player)
						special.blocks["default:qblock_FFFFFF"].on_load(player)
					end,player)
				end
			end
		},
	}
}

special.hud=function(player,n)
	local b = special.blocks[n]

	if not b.trigger then
		return
	end

	local u = special.user[player:get_player_name()]
	local c = b.count(player)
	if u[n] then
		if c <= 0 then
			player:hud_remove(u[n].text)
			player:hud_remove(u[n].image)
			u[n] = nil
		else
			player:hud_change(u[n].text, "text", c)
		end
	elseif c > 0 then
		u[n] = {
		text = player:hud_add({
			hud_elem_type="text",
			scale = {x=200,y=60},
			text=b.count(player),
			number=0xFFFFFF,
			offset={x=32,y=8},
			position={x=0,y=0.5+(b.i*0.05)},
			alignment={x=1,y=1},
		}),
		image = player:hud_add({
			hud_elem_type="image",
			scale = {x=2,y=2},
			position={x=0,y=0.5+(b.i*0.05)},
			text=b.image,
			offset={x=16,y=8},
		})}
	end	
end

special.use_ability=function(player,ab,c)
	for i,v in pairs(special.blocks) do
		if v.meta == ab then
			return v.use(player,c)
		end
	end
end

player_style.register_button({
	name="special",
	image="default:qblock_FF0000",
	type="item_image",
	info="Abilities",
	action=function(user)
		special.show(user)
	end
})

special.show=function(player)
	minetest.after(0.2, function(player)
		local name = player:get_player_name()
		local inv = special.user[name].inv
		local slots = ""
		for i,v in pairs(special.blocks) do
			slots = slots .. "item_image["..(v.i)..",0.2;1,1;"..i.."]"
			if inv:get_stack("main",v.i):get_count() > 0 then
				slots = slots .. "label["..(v.i)..",-0.3;"..v.count(player).."]" ..
				"image_button["..(v.i)..",1.2;1,1;player_style_coin.png;specialbut_"..i..";100]tooltip[specialbut_"..i..";Adds value: "..v.amount..v.info.."]"
			end
		end
		return minetest.show_formspec(name, "special",
		"size[8,6]" ..
		"listcolors[#77777777;#777777aa;#000000ff]"..
		"list[detached:special;main;1,0.2;"..special.num..",1;]" ..
		"list[current_player;main;0,2.3;8,4;]" ..
		"label[0,-0.35;"..minetest.colorize("#FFFF00",player:get_meta():get_int("coins")).."]" ..
		slots)
	end, player)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "special" then
		for i,v in pairs(pressed) do
			if string.sub(i,1,11) == "specialbut_" then
				local m = player:get_meta()
				local b = special.blocks[string.sub(i,12,-1)]
				local c = m:get_int("coins")
				if c >= 100 and m:get_int(b.meta)+b.amount <= 10000 then
					m:set_int("coins",c-100)
					b.trigger(player)
					special.show(player)
				end
				return
			end
		end
	end
end)

special.update=function(player)
	local name = player:get_player_name()
	local inv = special.user[name].inv:get_list("main")
	local d = {}
	for i,v in pairs(inv) do
		table.insert(d, v:to_table())
	end
	player:get_meta():set_string("special",minetest.serialize(d))
end

minetest.register_on_leaveplayer(function(player)
	special.user[player:get_player_name()] = nil
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	special.user[name]={}
	special.user[name].inv=minetest.create_detached_inventory("special", {
		allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			return 0
		end,
		allow_put = function(inv, listname, index, stack, player)
			local b = special.blocks[stack:get_name()]
			return b and b.i == index and inv:get_stack("main",b.i):get_count() == 0 and 1 or 0
		end,
		allow_take = function(inv, listname, index, stack, player)
			for i,v in pairs(special.blocks) do
				if index == v.i then
					return v.count(player) == 0 and stack:get_count() or 0
				end
			end
			return 0
		end,
		on_put = function(inv, listname, index, stack, player)
			special.update(player)
			special.show(player)
		end,
		on_take = function(inv, listname, index, stack, player)
			special.update(player)
			special.show(player)
		end,
	})
	special.user[name].inv:set_size("main", special.num)
	local list = {}
	for i,v in pairs(minetest.deserialize(player:get_meta():get_string("special") or "") or {}) do
		list[special.blocks[v.name].i] = v.name
	end
	special.user[name].inv:set_list("main", list)
	special.update(player)
	local m = player:get_meta()
	for i,v in pairs(special.blocks) do
		if m:get_int(v.meta) > 0 then
			special.hud(player,i)
			if v.on_load then
				v.on_load(player)
			end
		end
	end
end)