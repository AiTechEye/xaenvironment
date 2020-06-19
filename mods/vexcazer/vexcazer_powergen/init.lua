minetest.register_craft({
	output = "vexcazer_powergen:gen",
	recipe = {
	{"default:titanium_ingot","default:emerald","default:titanium_ingot"},
	{"default:titanium_ingot","default:electric_lump","default:titanium_ingot"},
	{"default:titanium_ingot","default:titanium_ingot","default:titanium_ingot"}
}})

minetest.register_node("vexcazer_powergen:gen", {
	description = "Power generator",
	paramtype2 = "facedir",
	tiles = {
		"vexcazer_powergen_top.png",
		"vexcazer_powergen_side.png",
		"vexcazer_powergen_side2.png",
		"vexcazer_powergen_side.png",
		"vexcazer_powergen_side.png",
		"vexcazer_powergen_panel.png"},
	groups = {dig_immediate = 3},
	sounds = default.node_sound_stone_defaults(),
after_place_node = function(pos, placer, itemstack)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		meta:set_string("owner", placer:get_player_name())
		meta:set_int("power", 0)
		inv:set_size("burn", 16)
		inv:set_size("tool", 1)
		meta:set_string("infotext", "vex power generator (" .. placer:get_player_name() .. ")")
		meta:set_string("formspec",
		"size[8,9]" ..
		"list[context;tool;3.5,1;1,1;]" ..
		--"list[context;burn;3.5,3;6,1;]" ..
		"list[context;burn;0,2.5;8,2;]" ..
		"list[current_player;main;0,5;8,4;]" ..
		"listring[current_player;main]" ..
		"listring[current_name;burn]"
		)
		end,
allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local item=stack:get_name()
		if player:get_player_name()~=meta:get_string("owner") then return 0 end
		if listname=="tool" and (item=="vexcazer:default" or item=="vexcazer:controler") then
			minetest.get_node_timer(pos):start(0.1)
			return 1
		end
		local name=stack:get_name()
		if listname=="burn" and (name~="vexcazer:default" and name~="vexcazer:mod" and name~="vexcazer:admin" and name~="default:mese") then
			minetest.get_node_timer(pos):start(0.1)
			return stack:get_count()
		end
		return 0
	end,
allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		if player:get_player_name()~=meta:get_string("owner") then return 0 end
		return stack:get_count()
	end,
can_dig = function(pos, player)
		local meta=minetest.get_meta(pos)
		local owner=meta:get_string("owner")
		local inv=meta:get_inventory()
		return ((player:get_player_name()==owner or owner=="") and inv:is_empty("burn") and inv:is_empty("tool"))
	end,
on_timer = function (pos, elapsed)
	local meta=minetest.get_meta(pos)
	local inv=meta:get_inventory()
	local burn=inv:get_stack("burn",16)
	local tool=inv:get_stack("tool",1)
	local inx=16
	for i=1,15,1 do
		if inv:get_stack("burn",i):get_count()>0 then
			burn=inv:get_stack("burn",i)
			inx=i
			break
		end
	end

	if burn:get_count()>0 and tool:get_count()==1 then
		local wear=tool:get_wear()
		if wear==0 then
			meta:set_string("infotext", "vex power generator (" .. meta:get_string("owner") .. ")")
			return false
		end 

		if burn:get_name()=="vexcazer:controler" then
			local wear2=65535-wear
			local cwear=burn:get_wear()
			local cwear2=65535-cwear
			if cwear>=65534 then return false end
			local w1=wear-cwear2
			local w2=cwear+wear
			if w1<0 then w1=0 end
			if w2>=65534 then w2=65534 end
			tool:set_wear(w1)
			inv:set_stack("tool",1,tool)
			inv:set_stack("burn",inx,burn:get_name() .." 1 " .. w2)
			return false
		end

		meta:set_string("infotext", "vex power generator [Loading]")
		local power=0
		local count=burn:get_count()
		local time=minetest.get_craft_result({method="fuel", width=1, items={burn}}).time

		if burn:get_name()=="default:mese_crystal" then time=10000 end
		if burn:get_name()=="default:meselamp" then time=10000 end
		if burn:get_name()=="default:mese_crystal_fragment" then time=660 end


		if time==0 then time=1 end

		if count>=99 and time*99<=wear then
			power=time*99
			inv:set_stack("burn",inx,burn:get_name() .." ".. (count-99))
		elseif count>=24 and time*24<=wear then
			power=time*24
			inv:set_stack("burn",inx,burn:get_name() .." ".. (count-24))
		elseif count>=10 and time*10<=wear then
			power=time*10
			inv:set_stack("burn",inx,burn:get_name() .." ".. (count-10))
		elseif count>=5 and time*5<=wear then
			power=time*5
			inv:set_stack("burn",inx,burn:get_name() .." ".. (count-5))
		elseif count>=2 and time*2<=wear then
			power=time*2
			inv:set_stack("burn",inx,burn:get_name() .." ".. (count-2))
		elseif count>=1 then
			power=time
			inv:set_stack("burn",inx,burn:get_name() .." ".. (count-1))
		end

		local use=wear-((power)*10)
		if use<0 then
			use=0
		end
		tool:set_wear(use)
		inv:set_stack("tool",1,tool)
		return true
	else
		meta:set_string("infotext", "vex power generator (" .. meta:get_string("owner") .. ")")
		return false
	end
end,
})
