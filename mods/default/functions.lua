--||||||||||||||||
-- ======================= Sounds
--||||||||||||||||

default.node_sound_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "", gain = 1}
	a.dig =		a.dig or {name = "", gain = 1}
	a.dug =		a.dig or {name = "", gain = 1}
	a.place =		a.place or {name = "default_place", gain = 1}
	return a
end

default.node_sound_stone_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_stone_step", gain = 1}
	a.dig =		a.dig or {name = "default_stone_dig", gain = 1}
	a.dug =		a.dug or {name = "default_stone_dug", gain = 1}
	a.place =		a.place or {name = "default_place_hard", gain = 1}
	return a
end

default.node_sound_wood_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_wood_step", gain = 1}
	a.dig =		a.dig or {name = "default_wood_dig", gain = 1}
	a.dug =		a.dug or {name = "default_wood_dug", gain = 1}
	a.place =		a.place or {name = "default_place_hard", gain = 1}
	return a
end

default.node_sound_water_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_water_step", gain = 1}
	return a
end

default.node_sound_metal_defaults=function(a)
	a = a or {}
	a.dig =		a.dig or {name = "default_metal_dig", gain = 1}
	a.dug =		a.dug or {name = "default_metal_dug", gain = 1}
	a.place =		a.place or {name = "default_metal_place", gain = 1}
	return default.node_sound_stone_defaults(a)
end

default.node_sound_dirt_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_leaves_step", gain = 1}
	a.dig =	a.footstep or {name = "default_leaves_step", gain = 1}
	a.dug =		a.dug or {name = "default_leaves_dug", gain = 1}
	a.place =		a.place or {name = "default_place", gain = 1}
	return a
end


default.node_sound_leaves_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_leaves_step", gain = 1}
	a.dig =		a.footstep or {name = "default_leaves_step", gain = 1}
	a.dug =		a.dug or {name = "default_leaves_dug", gain = 1}
	a.place =		a.place or {name = "default_place", gain = 1}
	return a
end

default.node_sound_gravel_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_gravel_step", gain = 1}
	a.dig =		a.dig or {name = "default_gravel_step", gain = 1}
	a.dug =		a.dug or {name = "default_gravel_place", gain = 1}
	a.place =		a.place or {name = "default_gravel_place", gain = 1}
	return a
end

default.node_sound_glass_defaults=function(a)
	a = a or {}
	a.footstep =	a.footstep or {name = "default_stone_step", gain = 1}
	a.dig =		a.dig or {name = "default_glass_dig", gain = 1}
	a.dug =		a.dug or {name = "default_break_glass", gain = 1}
	a.place =		a.place or {name = "default_place_hard", gain = 1}
	return a
end

default.tool_breaks_defaults=function(a)
	a = a or {}
	a.breaks =	"default_tool_breaks"
	return a
end

default.workbench.get_craft_result=function(list)

	local a = minetest.get_craft_result({method = "normal",width = 3, items = list})
	local regcraft = a.item:get_name()
	if regcraft~="" then
		return a.item
	end

	for _,i1 in pairs(default.workbench.registered_crafts) do
		local i = 0
		local s = 0
		local br
		for _,i2 in pairs(i1.recipe) do
		for _,i3 in pairs(i2) do
			i = i +1
			if i3 ~= list[i]:get_name() and not (string.sub(i3,1,6) == "group:" and minetest.get_item_group(list[i]:get_name(),string.sub(i3,7,-1)) > 0) then
				br = true
				break
			end
			s = s + 1

		end
			if br then
				break
			end
		end

		if s == i then
			return i1.output
		end
	end
	return ""
end

default.workbench.take_from_craftgreed=function(inv,name)
	local list = inv:get_list(name)
	for i,item in ipairs(list) do
		inv:remove_item(name,item:get_name() .." 1")
	end
end

default.workbench.register_craft=function(c)
	if not c.output and type(c.output) == "string" then
		error("efault.workbench.register_craft: output string expected")
		return
	elseif not (c.recipe and type(c.recipe) == "table") then
		error("efault.workbench.register_craft: recipe table expected")
		return
	end
	table.insert(default.workbench.registered_crafts,c)
end

default.date=function(a,c)
	if a=="get" then
		return os.time()
	else
		if a=="s" then
			return os.difftime(os.time(), c)
		elseif a=="m" then
			return os.difftime(os.time(), c) / 60
		elseif a=="h" then
			return os.difftime(os.time(), c) / (60 * 60)
		elseif a=="d" then
			return os.difftime(os.time(), c) / (24 * 60 * 60)
		end
	end
end

default.register_eatable=function(kind,name,hp,gaps,def)
	def.groups = def.groups or {}
	def.groups.eatable=hp
	def.groups.gaps=gaps
	def.on_use=function(itemstack, user, pointed_thing)
		local eat = 65536/gaps
		minetest.sound_play("default_eat", {to_player=user:get_player_name(), gain = 1})

		if not minetest.registered_tools[itemstack:get_name()] then
			local item = ItemStack(itemstack:get_name() .."_eaten")
			item = item:to_table()
			item.metadata = minetest.serialize({eat = eat})
			item.wear = eat
			user:get_inventory():add_item("main",item)
			minetest.do_item_eat(hp,nil,itemstack,user,pointed_thing)
			return itemstack
		else
			local item = itemstack:to_table()
			local meta = minetest.deserialize(item.metadata)
			if not meta then
				meta = {eat = eat}
				item.metadata = minetest.serialize({eat = eat})
				itemstack:replace(item)
			end
			minetest.do_item_eat(hp,nil,ItemStack(itemstack:get_name()),user,pointed_thing)
			itemstack:add_wear(meta.eat)
			return itemstack
		end
	end

	minetest["register_" .. kind](name, def)

	if kind ~= "tool" then
		local groups = table.copy(def.groups)
		groups.not_in_creative_inventory = 1
		minetest.register_tool(def.name .. "_eaten", {
			description = def.description,
			inventory_image = def.inventory_image or def.tiles[1],
			groups = groups,
			on_use = def.on_use
		})	
	end
end

default.registry_mineral=function(def)
	local uname = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
	local mod = minetest.get_current_modname() ..":"
	if not def.not_lump then
		def.lump = def.lump or {}
		def.drop = mod .. def.name .. "_lump"
		def.lump.description = def.lump.description or 		uname .." lump"
		def.lump.inventory_image = def.lump.inventory_image or def.texture .. "^default_alpha_lump.png^[makealpha:0,255,0"
		def.lump.groups = def.lump.groups
		minetest.register_craftitem(mod .. def.name .. "_lump", def.lump)
	elseif def.drop then
		if def.drop.name then
			def.drop.name = mod .. def.drop.name
		else
			def.drop.name =  mod .. def.name
		end
		if not def.drop.inventory_image:find(".png") then
			def.drop.inventory_image = def.texture .. "^default_alpha_gem_" .. def.drop.inventory_image ..".png^[makealpha:0,255,0"
		end
		def.dropingot = def.drop.name
		def.drop.groups = def.drop.groups
		def.drop.description = def.drop.description or 		uname
		minetest.register_craftitem(def.drop.name, def.drop)
		def.drop = def.drop.name
	end
--ingot
	if not def.not_ingot then
		def.ingot = def.ingot or {}
		def.dropingot = mod .. def.name .. "_ingot"
		def.ingot.description = def.ingot.description or 		uname .." ingot"
		def.ingot.inventory_image = def.texture .. "^default_alpha_ingot.png^[makealpha:0,255,0"
		minetest.register_craftitem(mod .. def.name .. "_ingot", def.ingot)
		if def.lump then
			minetest.register_craft({
				type = "cooking",
				output = mod .. def.name .. "_ingot",
				recipe = mod .. def.name .. "_lump",
				cooktime = 10,
			})
		end
	end
--block
	if not def.not_block then
		def.block = def.block or {}
		def.block.tiles =	def.block.tiles or	{def.texture}
		def.block.description =	def.block.description or	uname .. "block"
		def.block.sounds =	def.block.sounds or	default.node_sound_metal_defaults()
		def.block.groups =	def.block.groups or	{cracky=2}
		minetest.register_node(mod .. def.name .."block", def.block)
		if def.dropingot then
			minetest.register_craft({
				output=mod .. def.name .."block",
				recipe={
					{def.dropingot,def.dropingot,def.dropingot},
					{def.dropingot,def.dropingot,def.dropingot},
					{def.dropingot,def.dropingot,def.dropingot},
				},
			})
			minetest.register_craft({
				output=def.dropingot .. " 9",
				recipe={{mod .. def.name .."block"},},
			})
		end
	end
--ore
	if not def.not_ore then
		def.ore = def.ore or {}
		def.ore.drop = def.drop
		def.ore.tiles =	def.ore.tiles or			{def.texture .. "^default_alpha_ore.png"}
		def.ore.description =	def.ore.description or	uname .. " ore"
		def.ore.sounds =	def.ore.sounds or	default.node_sound_stone_defaults()
		def.ore.groups =	def.ore.groups or	{cracky=2}

		minetest.register_node(mod .. def.name .. "_ore", def.ore)

		def.ore_settings = def.ore_settings or {}
		minetest.register_ore({
			ore_type		=	"scatter",
			ore		=	mod .. def.name .. "_ore",
			wherein		=	def.ore_settings.wherein or		"default:stone",
			clust_scarcity	=	def.ore_settings.clust_scarcity or	8 * 8 * 8,
			clust_num_ores	=	def.ore_settings.clust_num_ores or	2,
			clust_size		=	def.ore_settings.clust_size	or	3,
			y_min		=	def.ore_settings.y_min	or	-31000,
			y_max		=	def.ore_settings.y_max	or	-50,
		})
	end
--pick
	if not def.not_pick then
		def.pick = def.pick or {}
		def.pick.sound = default.tool_breaks_defaults()
		def.pick.description = def.pick.description or 		 uname .." pickaxe"
		def.pick.inventory_image = def.pick.inventory_image or	def.texture .. "^default_alpha_pick.png^[makealpha:0,255,0"
		def.pick.groups = def.pick.groups
		def.pick.tool_capabilities = def.pick.tool_capabilities or		{
			full_punch_interval = 1,
			max_drop_level = 0,
			groupcaps = {
				cracky={times={[3]=1.5},uses=20,maxlevel=1}
			},
			damage_groups={fleshy=2}
		}
		minetest.register_tool(mod .. def.name .. "_pick", def.pick)
		default.workbench.register_craft({
			output=mod .. def.name .. "_pick",
			recipe={
				{def.dropingot,def.dropingot,def.dropingot},
				{"","group:stick",""},
				{"","group:stick",""},
			},
		})
	end
--shovel
	if not def.not_shovel then
		def.shovel = def.shovel or {}
		def.shovel.description = def.shovel.description or 			uname .." shovel"
		def.shovel.inventory_image = def.shovel.inventory_image or	def.texture .. "^default_alpha_shovel.png^[makealpha:0,255,0"
		def.shovel.sound = default.tool_breaks_defaults()
		def.shovel.groups = def.shovel.groups
		def.shovel.tool_capabilities = def.shovel.tool_capabilities or		{
			full_punch_interval = 1.1,
			max_drop_level = 0,
			groupcaps = {
				crumbly={times={[1]=1.9,[2]=1.4,[3]=0.6},uses=20,maxlevel=1},
			},
			damage_groups={fleshy=1},
		}
		minetest.register_tool(mod .. def.name .. "_shovel", def.shovel)
		default.workbench.register_craft({
			output=mod .. def.name .. "_shovel",
			recipe={
				{"",def.dropingot,""},
				{"","group:stick",""},
				{"","group:stick",""},
			},
		})
	end
--axe
	if not def.not_axe then
		def.axe = def.axe or {}
		def.axe.sound = default.tool_breaks_defaults()
		def.axe.description = def.axe.description or 			uname .." axe"
		def.axe.inventory_image = def.axe.inventory_image or	def.texture .. "^default_alpha_axe.png^[makealpha:0,255,0"
		def.axe.groups = def.axe.groups
		def.axe.tool_capabilities = def.axe.tool_capabilities or		{
			full_punch_interval = 1,
			max_drop_level = 0,
			groupcaps = {
				choppy={times={[1]=2,[2]=1.9,[3]=1.2},uses=20,maxlevel=1},
			},
			damage_groups={fleshy=2},
		}
		minetest.register_tool(mod .. def.name .. "_axe", def.axe)
		default.workbench.register_craft({
			output=mod .. def.name .. "_axe",
			recipe={
				{def.dropingot,def.dropingot,""},
				{def.dropingot,"group:stick",""},
				{"","group:stick",""},
			},
		})
	end
--vineyardknife
	if not def.not_vineyardknife then
		def.vineyardknife = def.vineyardknife or {}
		def.vineyardknife.sound = default.tool_breaks_defaults()
		def.vineyardknife.description = def.vineyardknife.description or 		uname .." vineyardknife"
		def.vineyardknife.inventory_image = def.vineyardknife.inventory_image or	def.texture .. "^default_alpha_vineyardknife.png^[makealpha:0,255,0"
		def.vineyardknife.groups = def.vineyardknife.groups
		def.vineyardknife.tool_capabilities = def.vineyardknife.tool_capabilities or		{
			full_punch_interval = 0.5,
			max_drop_level = 0,
			groupcaps = {
				snappy={times={[1]=0.5,[2]=1.1,[3]=0.5},uses=20,maxlevel=1},
			},
			damage_groups={fleshy=2},
		}
		minetest.register_tool(mod .. def.name .. "_vineyardknife", def.vineyardknife)
		default.workbench.register_craft({
			output=mod .. def.name .. "_vineyardknife",
			recipe={
				{"",def.dropingot,def.dropingot},
				{"","",def.dropingot},
				{"","group:stick",""},
			},
		} )
	end
--hoe
	if not def.not_hoe then
		def.hoe = def.hoe or {}
		def.hoe.sound = default.tool_breaks_defaults()
		def.hoe.description = def.hoe.description or 		uname .." hoe"
		def.hoe.inventory_image = def.hoe.inventory_image or	def.texture .. "^default_alpha_hoe.png^[makealpha:0,255,0"
		def.hoe.groups = def.hoe.group
		def.hoe.tool_capabilities = def.tool_capabilities or		{
			full_punch_interval = 2,
			damage_groups={fleshy=5},
		}
		minetest.register_tool(mod .. def.name .. "_hoe", def.hoe)
		default.workbench.register_craft({
			output=mod .. def.name .. "_hoe",
			recipe={
				{def.dropingot,def.dropingot,""},
				{"","group:stick",""},
				{"","group:stick",""},
			},
		})
	end
	if def.regular_additional_craft then
		for _,c in pairs(def.regular_additional_craft) do
			minetest.register_craft(c)
		end
	end
	if def.workbench_additional_craft then 
		for _,c in pairs(def.workbench_additional_craft) do
			default.workbench.register_craft(c)
		end
	end
end