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

default.registry_mineral=function(def)
	local uname = def.name.upper(string.sub(def.name,1,1)) .. string.sub(def.name,2,string.len(def.name))
	local mod = minetest.get_current_modname() ..":"

--This is test, the diamond stuff is the result
--creating a full toolset, ore & block from 1 texture + name... maybe ingots / lumps ill see how it works


--[[
	def.name = "diamound"
	def.block_texture = "default_diamondblock.png"

--]]

--block
	if not def.not_block then
		def.blocknode = def.blocknode or {}
		def.blocknode.tiles =	def.blocknode.tiles or	{def.block_texture}
		def.blocknode.description =	def.blocknode.description or	uname .. "block"
		def.blocknode.sounds =	def.blocknode.sounds or	default.node_sound_metal_defaults()
		def.blocknode.groups =	def.blocknode.groups or	{cracky=1}
		minetest.register_node(mod .. def.name .."block", def.blocknode)
	end
--ore
	if not def.not_ore then
		def.orenode = def.orenode or {}
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
	end

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
	end



--[[


	item_texture1 or nil
	item_texture1 or nil
	item_name1 or nil
	item_name2 or nil

	def.ingot_texture or nil
	def.lump_texture or nil

	def.craft_ingots_to_block = def.craft_ingots_to_block or true
	def.craft_block_to_ingots = def.craft_block_to_ingots or true
	def.smelt_lump_to_ingot = def.smelt_lump_to_ingot or true




minetest.register_craft({
	output="default:block",
	recipe={
		{"default:_ingot","default:_ingot","default:_ingot"},
		{"default:_ingot","default:_ingot","default:_ingot"},
		{"default:_ingot","default:_ingot","default:_ingot"},
	},
})
minetest.register_craft({
	output="default:ingot 9",
	recipe={{"default:block"}}
})

minetest.register_craft({
	type = "cooking",
	output = "default:_ingot",
	recipe = "default:_ingot",
	cooktime = 10,
})
minetest.register_craftitem("default:_ingot", {
	description = "ingot",
	inventory_image = "default_ingot_.png",
	groups = {metal=1},
})
minetest.register_craftitem("_lump", {
	description = " lump",
	inventory_image = "default_lump_.png",
})
--]]

end
default.registry_mineral({name="diamond",block_texture="default_diamondblock.png"})