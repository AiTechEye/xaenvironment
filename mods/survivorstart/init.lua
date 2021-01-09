if minetest.settings:get_bool("xaenvironment_survivorstart") == true then
	local items = {
		"player_style:backpack",
		"hook:pchest",
		"hook:pchest",
		"default:arrow_arrow 99",
		"default:bow_steel",
		"default:furnace",
		"default:torch 99",
		"beds:tent",
		"player_style:matel_bottle 1 1",
		"plants:cabbage 40",
		"default:recycling_mill",
		"default:telescopic",
		"default:knuckles",
		"default:bucket_with_water_source",
		"default:flint 20",
		"default:iron_ingot 20",
		"default:wool 5",
		"hook:climb_rope",
		"hook:mba",
		"clock:clock1",
	}
	minetest.register_on_newplayer(function(player)
		local inv = player:get_inventory()
		for i,v in pairs(items) do
			inv:add_item("main",ItemStack(v))
		end
	end)
end