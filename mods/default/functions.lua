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
	--a.footstep =	a.footstep or {name = "", gain = 1}
	--a.dig =		a.dig or {name = "", gain = 1}
	--a.dug =		a.dug or {name = "default_break_glass", gain = 1}
	--a.place =		a.place or {name = "", gain = 1}
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
		return regcraft
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

default.registry_mineral=function(def)
	local uname = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
	local mod = minetest.get_current_modname() ..":"

	if not def.not_drop_and_ingot then
		def.lump = def.lump or {}
		def.drop = mod .. def.name .. "_lump"
		def.lump.description = def.lump.description or 		uname .." lump"
		def.lump.inventory_image = def.block_texture .. "^default_alpha_lump.png^[makealpha:0,255,0"
		minetest.register_craftitem(mod .. def.name .. "_lump", def.lump)
	elseif def.drop then
		if def.drop.name then
			def.drop.name = mod .. def.drop.name
		else
			def.drop.name =  mod .. def.name
		end
		if not def.drop.inventory_image:find(".png") then
			def.drop.inventory_image = def.block_texture .. "^default_alpha_gem_" .. def.drop.inventory_image ..".png^[makealpha:0,255,0"
		end
		def.dropingot = def.drop.name
		def.drop.description = def.drop.description or 		uname
		minetest.register_craftitem(def.drop.name, def.drop)
	end
--ingot
	if not def.not_drop_and_ingot then
		def.ingot = def.ingot or {}
		def.dropingot = mod .. def.name .. "_ingot"
		def.ingot.description = def.ingot.description or 		uname .." ingot"
		def.ingot.inventory_image = def.block_texture .. "^default_alpha_ingot.png^[makealpha:0,255,0"
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
		def.blocknode = def.blocknode or {}
		def.blocknode.tiles =	def.blocknode.tiles or	{def.block_texture}
		def.blocknode.description =	def.blocknode.description or	uname .. "block"
		def.blocknode.sounds =	def.blocknode.sounds or	default.node_sound_metal_defaults()
		def.blocknode.groups =	def.blocknode.groups or	{cracky=1}
		minetest.register_node(mod .. def.name .."block", def.blocknode)
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
		def.orenode = def.orenode or {}
		def.orenode.drop = def.drop
		def.orenode.tiles =	def.orenode.tiles or			{def.block_texture .. "^default_alpha_ore.png"}
		def.orenode.description =	def.orenode.description or	uname .. " ore"
		def.orenode.sounds =	def.orenode.sounds or	default.node_sound_stone_defaults()
		def.orenode.groups =	def.orenode.groups or	{cracky=2}
		minetest.register_node(mod .. def.name .. "_ore", def.orenode)
	end
--pick
	if not def.not_pick then
		def.pick = def.pick or {}
		def.pick.sound = default.tool_breaks_defaults()
		def.pick.description = def.pick.description or 		 uname .." pickaxe"
		def.pick.inventory_image = def.pick.inventory_image or	def.block_texture .. "^default_alpha_pick.png^[makealpha:0,255,0"
		def.pick.tool_capabilities = def.pick.tool_capabilities or		{
			full_punch_interval = 1,
			max_drop_level = 0,
			groupcaps = {
				cracky={times={[2]=1,[3]=1.5},uses=20,maxlevel=1},
			},
			damage_groups={fleshy=2}
		},
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
		def.shovel.inventory_image = def.shovel.inventory_image or	def.block_texture .. "^default_alpha_shovel.png^[makealpha:0,255,0"
		def.shovel.sound = default.tool_breaks_defaults()
		def.shovel.tool_capabilities = def.shovel.tool_capabilities or		{
			full_punch_interval = 1.1,
			max_drop_level = 0,
			groupcaps = {
				crumbly={times={[1]=1.9,[2]=1.4,[3]=0.6},uses=20,maxlevel=1},
			},
			damage_groups={fleshy=1},
		},
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
		def.axe.inventory_image = def.axe.inventory_image or	def.block_texture .. "^default_alpha_axe.png^[makealpha:0,255,0"
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
		def.vineyardknife.inventory_image = def.vineyardknife.inventory_image or	def.block_texture .. "^default_alpha_vineyardknife.png^[makealpha:0,255,0"
		def.vineyardknife.tool_capabilities = def.vineyardknife.tool_capabilities or		{
			full_punch_interval = 0.5,
			max_drop_level = 0,
			groupcaps = {
				snappy={times={[1]=0.5,[2]=1.1,[3]=0.5},uses=20,maxlevel=1},
			},
			damage_groups={fleshy=2},
		},
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
		def.hoe.inventory_image = def.hoe.inventory_image or	def.block_texture .. "^default_alpha_hoe.png^[makealpha:0,255,0"
		def.hoe.tool_capabilities = def.tool_capabilities or		{
			full_punch_interval = 2,
			damage_groups={fleshy=5},
		},
		minetest.register_tool(mod .. def.name .. "_hoe", def.hoe)

		default.workbench.register_craft({
			output=mod .. def.name .. "_hoe",
			recipe={
				{def.dropingot,def.dropingot,""},
				{"","group:stick",""},
				{"","group:stick",""},
			},
		})
--[[
		minetest.register_craft({
			output=mod .. def.name .. "_hoe",
			recipe={
				{def.dropingot,def.dropingot,""},
				{"","group:stick",""},
				{"","group:stick",""},
			},
		})
--]]
	end
end
default.registry_mineral({
	name="diamond",
	block_texture="default_diamondblock.png",
	drop={inventory_image="diamond"},
	not_drop_and_ingot = true

})



