rnd = {
	ores = {
		unknowna = {
			tiles = {"materials_granite.png^[colorize:#dfe72872"},
			drop = "materials:unknownacylinder",
			ore = {
				clust_scarcity = 30 * 30 * 30,
				clust_size = 1,
				y_min = -20,
				y_max = -21,
			}
		},
		unknownacylinder = {
			description = "Unknown cylinder",
			tiles = {"materials_granite.png^[colorize:#dfe72872"},
			drawtype = "mesh",
			paramtype = "light",
			paramtype2 = "facedir",
			mesh = "materials_cylinder.obj",
			on_place = minetest.rotate_node,
			alpha = 0.5,
		},
		unknowns = {
			tiles = {"default_amberblock.png^[colorize:#f9a38c03^[invert:rg"},
			drop = "materials:unknownsorb",
			ore = {
				clust_scarcity = 30 * 30 * 30,
				clust_size = 1,
				y_min = -18,
				y_max = -19,
			}
		},
		unknownsorb = {
			description = "Unknown orb",
			tiles = {"default_amberblock.png^[colorize:#f9a38c03^[invert:rg"},
			drawtype = "mesh",
			paramtype = "light",
			paramtype2 = "facedir",
			mesh = "materials_orb.obj",
			on_place = minetest.rotate_node,
			alpha = 0.5,
		},
		asdasdasdore = {
			tiles = {"materials_granite.png^[colorize:#22cc7755"},
			drop = "materials:asdasdasd",
			ore = {
				clust_scarcity = 30 * 30 * 30,
				clust_size = 1,
				y_min = -18,
				y_max = -19,
			}
		},
		asdasdasd = {
			description = "Unknown thing",
			tiles = {"materials_granite.png^[colorize:#22cc7755"},
			paramtype = "light",
			paramtype2 = "facedir",
			on_place = minetest.rotate_node,
			alpha = 0.2,
			use_texture_alpha = "clip",
			drawtype = "nodebox",
			node_box = {
			type = "fixed",
				fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0, 0},
					{-0.5, -0.5, 0, 0.5, 0.5, 0.5}
				}
			}
		}
	}
}

for i,v in pairs(rnd.ores) do
	def = v
	def.description = v.description or "Unknown"
	def.tiles = v.tiles or {"default_stone.png"}
	def.groups = v.groups or {cracky=2,not_in_creative_inventory=1}
	def.sounds = v.sounds or default.node_sound_stone_defaults()

	ore = def.ore and table.copy(def.ore) or nil
	def.ore = nil

	minetest.register_node("materials:"..i,def)
	if ore then
		minetest.register_ore({
			ore_type = "blob",
			clust_scarcity = ore.clust_scarcity or 30 * 30 * 30,
			ore= "materials:"..i,
			wherein = ore.wherein or "default:coal_ore",
			clust_size = ore.clust_size or 15,
			y_min = ore.y_min or -100,
			y_max = ore.y_max or -10,
			noise_params = default.ore_noise_params()
		})
	end
end