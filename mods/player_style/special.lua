special={
	user={},
	blocks = {
		"default:qblock_FF0000",
		"default:qblock_1c7800",
		"default:qblock_e29f00",
		"default:qblock_800080",
		"default:qblock_0000FF",
	},
	abilities = {

	}
}

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
	local name = player:get_player_name()
	minetest.after(0.2, function(name)
		local inv = special.user[name].inv
		local slots = ""
		local x = 1.5
		for i,v in pairs(special.blocks) do
			slots = slots .. "item_image["..x..",0;1,1;"..v.."]"
			if inv:get_stack("main",i):get_count() > 0 then
				if special.abilities[i] then
					slots = slots .. "image_button["..x..",1;1,1;player_style_coin.png;specialbut_"..i..";100]"
				else
					slots = slots .. "label["..x..",1;unable]"
				end
			end
			x = x +1
		end
		return minetest.show_formspec(name, "special",
		"size[8,6]" ..
		"listcolors[#77777777;#777777aa;#000000ff]"..
		"list[detached:special;main;1.5,0;"..#special.blocks..",1;]" ..
		"list[current_player;main;0,2.3;8,4;]" ..
		slots)
	end, name)
end

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
			return special.blocks[index] == stack:get_name() and inv:get_stack("main",index):get_count() == 0 and 1 or 0
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
	special.user[name].inv:set_size("main", #special.blocks)
	local list = {}
	for i,v in pairs(minetest.deserialize(player:get_meta():get_string("special") or "") or {}) do
		list[i] = v.name--ItemStack(v)
	end
	special.user[name].inv:set_list("main", list)
	special.update(player)
end)