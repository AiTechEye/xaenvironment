dofile(minetest.get_modpath("chakram") .. "/wood.lua")
dofile(minetest.get_modpath("chakram") .. "/steel.lua")
dofile(minetest.get_modpath("chakram") .. "/electric.lua")
pvp=minetest.settings:get_bool("enable_pvp")
chakramshot_user=""
chakramshot_user_name=""
chakram_shot_chakram={}
chakram_max_number=10

function chakram_max(add)
	local c=0
	for i in pairs(chakram_shot_chakram) do
		c=c+1
		if chakram_shot_chakram[i]:get_pos()==nil then
			table.remove(chakram_shot_chakram,c)
			c=c-1
		end
	end
	if c+1>chakram_max_number  then return false end
	if add then
		table.insert(chakram_shot_chakram,add)
		return true
	end
	return true
end

function chakram_def(pos,def)
	local n=minetest.registered_nodes[minetest.get_node(pos).name]
	return n and n[def]
end

minetest.register_craft({
	output = "chakram:chakram",
	recipe = {
		{"default:steel_ingot","","default:steel_ingot"},
		{"","default:iron_ingot",""},
		{"default:steel_ingot","","default:steel_ingot"},
	}
})

minetest.register_craft({
	output = "chakram:chakram_electric",
	recipe = {
		{"default:electric_lump","","default:electric_lump"},
		{"","default:electric_lump",""},
		{"default:electric_lump","","default:electric_lump"},
	}
})

minetest.register_craft({
	output = "chakram:chakram_wood",
	recipe = {
		{"default:stick","","default:stick"},
		{"","group:wood",""},
		{"default:stick","","default:stick"},
	}
})
function chakram_drops(name)
	local d=minetest.registered_nodes[name].drop
	if d=="" or d==nil then return name end
	if d.items then
		if d.items[1].items and d.items[2] and d.items[2].items then
			return d.items[math.random(1,2)].items[1]
		end
		if d.items[1].items then
			return d.items[1].items[1]
		end
		return name
	end
	return d
end