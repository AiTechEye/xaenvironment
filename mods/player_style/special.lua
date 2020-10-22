special={
	user={},
	num = 5,
	blocks = {
		["default:qblock_FF0000"]={i=1},
		["default:qblock_1c7800"]={i=2},
		["default:qblock_e29f00"]={i=3,ability="Fire resistance",
			trigger=function(player)
				local m = player:get_meta()
				m:set_int("fire_resistance",m:get_int("fire_resistance")+100)
			end,
			use=function(player)
				local m = player:get_meta()
				local f  = m:get_int("fire_resistance")
				if f > 0 then
					m:set_int("fire_resistance",f-1)
					return true
				end
			end,
			count = function(player)
				return player:get_meta():get_int("fire_resistance")
			end
		},
		["default:qblock_800080"]={i=4},
		["default:qblock_0000FF"]={i=5},
	}
}

special.use_ability=function(player,ab)
	for i,v in pairs(special.blocks) do
		if v.ability == ab then
			return v.use(player)
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
			slots = slots .. "item_image["..(v.i+0.5)..",0.2;1,1;"..i.."]"
			if inv:get_stack("main",v.i):get_count() > 0 then
				if v.trigger then
					slots = slots .. "label["..(v.i+0.5)..",-0.3;"..v.count(player).."]" ..
					"image_button["..(v.i+0.5)..",1.2;1,1;player_style_coin.png;specialbut_"..i..";100]"
				else
					slots = slots .. "label["..(v.i+0.5)..",1;yet\nunable]"
				end
			end
		end
		return minetest.show_formspec(name, "special",
		"size[8,6]" ..
		"listcolors[#77777777;#777777aa;#000000ff]"..
		"list[detached:special;main;1.5,0.2;"..special.num..",1;]" ..
		"list[current_player;main;0,2.3;8,4;]" ..
		slots)
	end, player)
end

minetest.register_on_player_receive_fields(function(player, form, pressed)
	if form == "special" then
		for i,v in pairs(pressed) do
			if string.sub(i,1,11) == "specialbut_" then
				special.blocks[string.sub(i,12,-1)].trigger(player)
				special.show(player)
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
			return stack:get_count()
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
		list[i] = v.name
	end
	special.user[name].inv:set_list("main", list)
	special.update(player)
end)