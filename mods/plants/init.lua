default.register_tree({
	name="pear",
	fruit={
		hp=1,
		gaps=4,
		description = "Pear",
		tiles={"plants_pear.png"},
		inventory_image="plants_pear.png",
	},
	tree={tiles={"plants_pear_tree_top.png","plants_pear_tree_top.png","plants_pear_tree.png"}},
	sapling={tiles={"plants_pear_tree_sapling.png"}},
	wood={tiles={"plants_pear_wood.png"}},
	leaves={tiles={"plants_pear_leaves.png"}},
	schematic=minetest.get_modpath("plants").."/schematics/plants_pear_tree.mts",
	sapling_place_schematic=function(pos)
		minetest.place_schematic({x=pos.x-3,y=pos.y,z=pos.z-3}, minetest.get_modpath("plants").."/schematics/plants_pear_tree.mts", "random", nil, false)
	end
})

default.register_door({
	name="pear_wood_door",
	description = "Pear wood door",
	texture="plants_pear_wood.png",
	burnable = true,
	craft={
		{"plants:pear_wood","plants:pear_wood",""},
		{"plants:pear_wood","plants:pear_wood",""},
		{"plants:pear_wood","plants:pear_wood",""}
	}
})

default.register_chair({
	name = "pear_wood",
	description = "Pear wood chair",
	burnable = true,
	texture = "plants_pear_wood.png",
	craft={{"group:stick","",""},{"plants:pear_wood","",""},{"group:stick","",""}}
})

for i,c in pairs({"d8e41d","b21db5","601db5","bb91f0","e4d9f3","fd0084","6f86ff","ff3030","ff4d00","ffb047","ffb0c5","a6421f"}) do
	default.register_plant({
		name="daisybush" .. i,
		description = "Daisy bush",
		tiles={"plants_pear_tree_top.png^[colorize:#"..c.."ff^plants_daisybushflower.png^[makealpha:0,255,0"},
		decoration={noise_params={
			offset=-0.001,
			scale=0.003,
			seed=80*i,
		}},
	})
end

default.register_eatable("craftitem","plants:lonicera_tatarica_berries",-2,0,{inventory_image="plats_berries.png^[colorize:#ff5b19ff"})
default.register_plant({
	name="lonicera_tatarica",
	tiles={"plants_lonicera_tatarica.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.003,
	}},
	drop={max_items = 1,items = {
		{items = {"plants:lonicera_tatarica_berries"}, rarity = 3},
		{items = {"plants:lonicera_tatarica"}}
	}}
})

default.register_plant({
	name="verbena",
	tiles={"plants_verbena.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.003,
		seed=545,
	}}
})

default.register_plant({
	name="lantana",
	tiles={"plants_lantana.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.003,
		seed=8745,
	}}
})

default.register_eatable("craftitem","plants:dolls_eyes_berries",2,6,{
	inventory_image="plats_dolls_eyes_berries.png",
	on_eat=function(itemstack, user, pointed_thing)
		local r = math.random(30,60)
		local s = math.random(1,9999)
		local name = user:get_player_name()
		default.set_on_player_death(name,"dolls_eyes" .. s,true)
		for i=0,math.random(3,10) do
			minetest.after(r+i*0.1,function(name,user,s)
				if default.get_on_player_death(name,"dolls_eyes" .. s) then
					default.punch(user,user,2)
				end
			end,name,user,s)
		end
	end
})

default.register_plant({
	name="dolls_eyes",
	tiles={"plants_dolls_eyes.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.005,
		seed=3454365,
	}},
	drop={max_items = 1,items = {
		{items = {"plants:dolls_eyes_berries 3"}, rarity = 2},
		{items = {"plants:dolls_eyes"}}
	}}
})

default.register_plant({
	name="cow_parsnip",
	tiles={"plants_cow_parsnip.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.015,
		seed=3365,
	}},
	damage_per_second=4,
	groups={dig_immediate=1},
	on_punch=function(pos,node,player,pointed_thing)
		if player:get_wielded_item():get_name() == "" then
			default.punch(player,player,4)
		end
	end,
	visual_scale=2.5,
	selection_box ={type="fixed",fixed={-0.25,-0.5,-0.25,0.25,2,0.25}}
})
default.register_plant({
	name="cow_parsnip_big",
	tiles={"plants_cow_parsnip.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.015,
		seed=3365,
	}},
	damage_per_second=4,
	groups={dig_immediate=1},
	on_punch=function(pos,node,player,pointed_thing)
		if player:get_wielded_item():get_name() == "" then
			default.punch(player,player,4)
		end
	end,
	visual_scale=3.5,
	selection_box ={type="fixed",fixed={-0.25,-0.5,-0.25,0.25,3,0.25}}
})


default.register_plant({
	name="anthriscus_sylvestris_big",
	tiles={"plants_cow_parsnip.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.015,
		seed=3365,
	}},
	visual_scale=1.3,
	selection_box ={type="fixed",fixed={-0.25,-0.5,-0.25,0.25,0.8,0.25}}
})

default.register_plant({
	name="anthriscus_sylvestris",
	tiles={"plants_cow_parsnip.png"},
	decoration={noise_params={
		offset=-0.0015,
		scale=0.015,
		seed=3365,
	}},
	visual_scale=1.1,
})