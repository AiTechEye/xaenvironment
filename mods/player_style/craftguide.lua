player_style.craftguide = {
	items = {},
	groups = {},
	user = {},
}

minetest.register_on_mods_loaded(function()
	for i,def in pairs(minetest.registered_items) do
		local g = def.groups
		if not g or not (g.not_in_creative_inventory or g.not_in_craftguide) then
			table.insert(player_style.craftguide.items,def.name)
		end
		if g and not g.not_in_creative_inventory then
			for g2,v in pairs(g) do
				player_style.craftguide.groups["group:" .. g2] = player_style.craftguide.groups["group:" .. g2] or {}
				table.insert(player_style.craftguide.groups["group:" .. g2],def.name)
			end
		end
	end
	table.sort(player_style.craftguide.items)
end)

player_style.craftguide.show=function(player)
	local name = player:get_player_name()
	return minetest.show_formspec(name, "craftguide",
		"formspec_version[2]" -- MT 5.1+
		.."size[8,5]"
		.. "style_type[label;font_size=+10]"
		.. "label[1,2;Coming soon...]"
		)
end

player_style.craftguide.show2=function(player)

	local name = player:get_player_name()
	player_style.players[name].craftguide = player_style.players[name].craftguide or {}

	local user = player_style.players[name].craftguide
	local search_text = ""
	local search
	local x=0
	local y=0
	local w = 8
	local h = 4
	local search = ""--meta:get_string("search")
	local list = search or player_style.craftguide.items
--	local craftr = add ~= ""

	local items = ""

	local size = w * h
	local page = 1
	local index1 = page <= 1 and 1 or size*page
	local index2 = page <= 1 and size or size*page+1

	for i=1,size*page do
		local item = list[i]
		if not item then
			break
		end
		items = items .. "item_image_button[" .. x .. "," .. y .. ";1;1;guide_item#" .. item .. ";]"
		x = x + 1
		if x >= w then
			x = 0
			y = y + 1
		end
	end

	return minetest.show_formspec(name, "craftguide",
		"size[8,5]"
		.. "listcolors[#77777777;#777777aa;#000000ff]"
		--"size[8,"..(craftr and 12 or 9).. "]"
		.. items
		--.. "list[current_player;main;0,"..(craftr and 8 or 5)..".4;8,4;]"
		.. "image_button[3.6,4.5;5;default_crafting_arrowleft.png;guideback;]"
		.. "image_button[4.3,4.5;5;default_crafting_arrowright.png;guidefront;]"
		.. "field[0,4.8;2.5,1;searchbox;;"..search_text.."]"
		.. "field_close_on_enter[searchbox;false]"
		.. "image_button[2,4.5;5;player_style_search.png;search;]"
		.. "image_button[2.8,4.5;5;synth_repeat.png;reset;]"
		.. "image_button[5.3,4.5;5;default_craftgreed.png;add2c;]tooltip[add2c;Add to craft grid]"
		)
end