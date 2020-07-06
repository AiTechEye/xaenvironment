minetest.register_tool("default:wrench", {
	description = "Wrench",
	groups = {treasure=1},
	inventory_image = "default_wrench.png",
	on_place=function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local n = minetest.get_node(pointed_thing.under)
			if n.param2 >= 3 then
				n.param2 = 0
			else
				n.param2 = n.param2 + 1
			end
			minetest.swap_node(pointed_thing.under,n)
			itemstack:add_wear(600)
			return itemstack
		end
	end,
	on_use=function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local n = minetest.get_node(pointed_thing.under)
			n.param2 = n.param2 == 4 and 6 or 4
			minetest.swap_node(pointed_thing.under,n)
			itemstack:add_wear(600)
			return itemstack
		end
	end
})

minetest.register_tool("default:telescopic", {
	description = "Telescopic (zoom key, sneak)",
	groups = {treasure=1,store=800},
	inventory_image = "default_telescopic.png",
	on_use=function(itemstack, user, pointed_thing)
		local z = user:get_fov()
		local key=user:get_player_control()

		if z == 0 and key.sneak == false then
			z = 30
		elseif z == 0 and key.sneak then
			z = 5
		elseif z <= 5 and key.sneak == false then
			z = 0
		elseif z <= 30 and key.sneak == false then
			z = z - 5
		elseif z >= 30 and key.sneak then
			z = 0
		elseif z >= 5 and key.sneak then
			z = z + 5
		end
		user:set_fov(z,false,0.1)
		default.telescopic_check(user)
	end
})

default.telescopic_check=function(user)
	minetest.after(0.1,function(user)
		if user and user:get_pos() and user:get_wielded_item():get_name() ~= "default:telescopic" then
			user:set_fov(0,false,0.01)
		else
			default.telescopic_check(user)
		end
	end,user)
end

minetest.register_craftitem("default:gold_flake", {
	description = "Gold flake",
	inventory_image = "default_goldblock.png^default_alpha_gem_round.png^[makealpha:0,255,0",
	wield_scale={x=0.3,y=0.3,z=0.3},
	groups={treasure=1},
})

minetest.register_craftitem("default:micro_gold_flake", {
	description = "Micro gold flake",
	inventory_image = "default_goldblock.png^default_alpha_gem_round.png^[makealpha:0,255,0",
	wield_scale={x=0.1,y=0.1,z=0.1},
	groups={treasure=1},
})

default.registry_mineral({
	name="amber",
	texture="default_amberblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_ore=true,
	not_ingot=true,
	not_bow=true,
	not_arrow=true,
	not_vineyardknife=true,
	block={
		groups={cracky=3,store=1000},
		sounds=default.node_sound_stone_defaults(),
	},
	additional_craft={
		{output="default:amberblock",recipe={
			{"default:amber_lump","default:amber_lump","default:amber_lump"},
			{"default:amber_lump","default:amber_lump","default:amber_lump"},
			{"default:amber_lump","default:amber_lump","default:amber_lump"},
		}},
		{output="default:amber_lump 9",recipe={
			{"default:amberblock"},
		}}
	}
})

minetest.register_tool(":", {
	type = "none",
	wield_image = "wieldhand.png",
	wield_scale={x=1,y=1,z=2},
	groups={not_in_creative_inventory=1},
	range = not default.creative and 4 or 15,
	tool_capabilities = not default.creative and {
		full_punch_interval = 1,
		max_drop_level = 0,
		groupcaps={
			crumbly = {times={[2]=3, [3]=0.7}, uses=0, maxlevel=1},
			snappy = {times={[2]=2,[3]=0.7}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=5,[2]=4,[3]=3}, uses=0},
			dig_immediate={times={[1]=2,[2]=1,[3]=0}, uses=0}
		},
		damage_groups = {fleshy=1},
	} or {
		full_punch_interval = 0.1,
		max_drop_level = 0,
		groupcaps = {
			fleshy={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
			choppy={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
			bendy={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
			cracky={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
			crumbly={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
			snappy={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
			dig_immediate={times={[1]=0.2,[2]=0.2,[3]=0.2},uses=0},
		},
		damage_groups={fleshy=10},
	}
})

minetest.register_tool("default:knuckles", {
	description ="Knuckles",
	inventory_image = "default_knuckles.png",
	tool_capabilities = not default.creative and {
		full_punch_interval = 1,
		max_drop_level = 0,
		groupcaps={
			no_break = {},
			crumbly = {times={[2]=2.5, [3]=0.5}, uses=0, maxlevel=1},
			snappy = {times={[2]=1.7,[3]=0.5}, uses=0, maxlevel=1},
			oddly_breakable_by_hand = {times={[1]=4,[2]=3,[3]=2}, uses=0},
			dig_immediate={times={[1]=1.5,[2]=1,[3]=0}, uses=0}
		},
		damage_groups = {fleshy=4},
	}
})

minetest.register_tool("default:admin_pickaxe", {
	description ="Admin pickaxe",
	range = 15,
	inventory_image = "default_admin_pickaxe.png",
	groups = {admin_tool=1,not_in_creative_inventory=1},
	tool_capabilities = {
		full_punch_interval = 0.20,
		max_drop_level = 3,
		groupcaps = {
			no_break = {},
			unbreakable={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			fleshy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			choppy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			bendy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			cracky={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			crumbly={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			snappy={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
			dig_immediate={times={[1]=0,[2]=0,[3]=0},uses=0,maxlevel=3},
		},
		damage_groups={fleshy=9000},
	},
})

minetest.register_tool("default:quantum_pick", {
	description ="Quantum pick",
	inventory_image = "default_quantumblock.png^default_alpha_pick.png^[makealpha:0,255,0",
	tool_capabilities = {
		full_punch_interval = 0.20,
		max_drop_level = 3,
		groupcaps = {
			fleshy={times={[1]=0,[2]=0,[3]=0},uses=30,maxlevel=3},
			choppy={times={[1]=0,[2]=0,[3]=0},uses=30,maxlevel=3},
			bendy={times={[1]=0,[2]=0,[3]=0},uses=30,maxlevel=3},
			cracky={times={[1]=0,[2]=0,[3]=0},uses=30,maxlevel=3},
			crumbly={times={[1]=0,[2]=0,[3]=0},uses=30,maxlevel=3},
			snappy={times={[1]=0,[2]=0,[3]=0},uses=30,maxlevel=3},
		},
		damage_groups={fleshy=10},
	},
	groups={treasure=3},
})

minetest.register_tool("default:cudgel", {
	description = "Wooden cudgel",
	inventory_image = "default_stick.png",
	tool_capabilities = {
		full_punch_interval = 0.5,
		max_drop_level=0,
		groupcaps={
			snappy={times={[2]=1.4, [3]=0.3}, uses=105, maxlevel=0},
			cracky = {times={[3]=10}, uses=2, maxlevel=1},
			oddly_breakable_by_hand = {times={[3]=3.5,[2]=2,[3]=0.7}, uses=0},
			choppy = {times={[3]=3.5}, uses=0}
		},
		damage_groups = {fleshy=3,treasure=1},
	},
	groups = {flammable = 2,stick=1},
	sound=default.tool_breaks_defaults()
})

minetest.register_craftitem("default:paper", {
	description = "Paper",
	inventory_image = "default_paper.png",
	groups = {flammable = 1,treasure=1,store=50},
})

default.registry_bucket("default:water_source")
default.registry_bucket("default:lava_source")
default.registry_bucket("default:salt_water_source")
default.registry_bucket("default:oil_source")

minetest.register_craftitem("default:bucket", {
	description = "Bucket",
	inventory_image = "default_bucket.png",
	groups = {bucket=1,treasure=1,store=1000},
	liquids_pointable = true,
	on_use = function(itemstack, user, pointed_thing)
		local p = pointed_thing
		local n = user:get_player_name()
		local no = p.under and default.bucket[minetest.get_node(p.under).name]
		if p.type == "node" and not minetest.is_protected(n,p.under) then
			local item
			local nn = minetest.get_node(p.under)
			if minetest.get_item_group(nn.name,"tankstorage") == 2 and nn.param2 > 0  then
				item = ItemStack(minetest.get_meta(p.under):get_string("bucket"))
				if nn.param2-8 > 0 then
					minetest.swap_node(p.under,{name=nn.name,param2=nn.param2-7})
				else
					minetest.set_node(p.under,{name="default:tankstorage"})
				end
			elseif no then
				item = ItemStack(no)
				minetest.remove_node(p.under)
			end

			if item and item:get_name() ~= "" and itemstack:get_count() == 1 then
				itemstack:replace(item)
			elseif item and item:get_name() ~= "" then

				user:get_inventory():add_item("main",item)
				itemstack:take_item()
			end
			return itemstack
		end
	end
})

minetest.register_node("default:tankstorage", {
	description = "Tankstorage",
	tiles={"default_glass_with_frame.png"},
	groups = {glass=1,cracky=3,oddly_breakable_by_hand=3,tankstorage=1,treasure=1},
	sounds = default.node_sound_glass_defaults(),
	drawtype = "glasslike_framed",
	sunlight_propagates = true,
	paramtype = "light",
})

minetest.register_craftitem("default:stick", {
	description = "Wooden stick",
	inventory_image = "default_stick.png",
	groups = {flammable = 1,stick=1,treasure=1},
})

minetest.register_craftitem("default:unknown", {
	description = "Unknown item",
	inventory_image = "default_unknown.png",
	groups = {not_in_creative_inventory=1,store=10000},
})

default.register_chest({
	name = "chest",
	description = "Chest",
	burnable = true,
	texture="default_wood.png",
	craft={
		{"group:wood","group:wood","group:wood"},
		{"group:wood","","group:wood"},
		{"group:wood","group:wood","group:wood"}
	}
})

default.register_chest({
	name = "locked_chest",
	description = "Locked chest",
	locked = true,
	burnable = true,
	texture="default_wood.png",
	craft={{"default:chest","default:steel_ingot"}},
})

--||||||||||||||||
-- ======================= minerals
--||||||||||||||||

default.registry_mineral({
	name="clay",
	texture="default_snow.png^[colorize:#5556",
	not_ingot=true,
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
	not_bow=true,
	not_arrow=true,
	not_block=true,
	lump={groups={treasure=1,store=100},inventory_image = "default_snow.png^[colorize:#5556^default_alpha_lump.png^[makealpha:0,255,0"},
	ore={tiles={"default_snow.png^[colorize:#5556"},description="Clay block",groups={crumbly=3},sounds = default.node_sound_clay_defaults(),drop="default:clay_lump 4",},
	ore_settings={
		ore_type = "blob",
		wherein = "default:sand",
		clust_scarcity= 30 * 30 * 30,
		clust_num_ores=7,
		clust_size=9,
		y_max=-2,
	},
	additional_craft={
	{output="default:clay_ore",
	recipe={
		{"default:clay_lump","default:clay_lump",""},
		{"default:clay_lump","default:clay_lump",""},
	}}}
})

default.registry_mineral({
	name="carbon",
	texture="default_carbon.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_ore=true,
	not_vineyardknife=true,
	not_bow=true,
	not_arrow=true,
	block={
		groups={cracky=3,flammable=1,treasure=1},
		sounds=default.node_sound_stone_defaults(),
		drop="default:carbon_lump 3",
	},
	ore={groups={cracky=3,store=200}},
	lump={groups={flammable=1,treasure=1}},
	additional_craft={
		{output="default:carbonblock",recipe={
			{"default:carbon_lump","default:carbon_lump","default:carbon_lump"},
			{"default:carbon_lump","default:carbon_lump","default:carbon_lump"},
			{"default:carbon_lump","default:carbon_lump","default:carbon_lump"},
		}},
		{
			type = "fuel",
			recipe = "default:carbon_lump",
			burntime = 10,
		},
		{
			type = "fuel",
			recipe = "default:carbonblock",
			burntime = 50,
		},
		{
		type = "cooking",
		output = "default:carbon_lump",
		recipe = "group:tree",
		cooktime = 10
		},
		{output="default:steel_lump",recipe={{"default:carbon_ingot","default:iron_ingot"}}}
	},
	ore_settings={
		ore="default:carbonblock",
		clust_scarcity = 26*26*26,
		ore_type="blob",
		clust_num_ores=10,
		clust_size=4,
		y_max=20,
		y_min=-20,
		wherein="default:dirt",
	}
})


default.registry_mineral({
	name="coal",
	texture="default_coalblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_ingot=true,
	not_vineyardknife=true,
	not_bow=true,
	not_arrow=true,
	block={
		groups={cracky=3,flammable=1},
		sounds=default.node_sound_stone_defaults(),
	},
	ore={groups={cracky=3}},
	lump={groups={flammable=1,treasure=1,store=100}},
	additional_craft={
		{
			type = "fuel",
			recipe = "default:coal_lump",
			burntime = 40,
		},
		{
			type = "fuel",
			recipe = "default:coalblock",
			burntime = 360,
		},
		{output="default:coalblock",recipe={
			{"default:coal_lump","default:coal_lump","default:coal_lump"},
			{"default:coal_lump","default:coal_lump","default:coal_lump"},
			{"default:coal_lump","default:coal_lump","default:coal_lump"},
		}},
		{output="default:coal_lump 9",recipe={
			{"default:coalblock"},
		}},
	},
	ore_settings={
		clust_num_ores=5,
		clust_size=5,
		y_max=50,
	}
})

default.registry_mineral({
	name="flint",
	texture="default_flintblock.png",
	not_ore=true,
	not_lump=true,
	not_ingot=true,
	drop={inventory_image="flint",groups={tip=1}},
	not_bow=true,
	not_arrow=true,
	block={
		groups={cracky=3,stone=1,treasure=1,store=500},
		sounds=default.node_sound_stone_defaults()
	},
	pick={groups={not_regular_craft=0,treasure=1}},
	axe={groups={not_regular_craft=0,treasure=1}},
	shovel={groups={not_regular_craft=0,treasure=1}},
	pick={groups={not_regular_craft=0,treasure=1}},
	vineyardknife={groups={not_regular_craft=0,treasure=1}},
	hoe={groups={not_regular_craft=0,treasure=1}},
	additional_craft={
		{output="default:flint",
			recipe={
				{"default:gravel","default:gravel","default:gravel"},
			}
		}
	}
})

default.registry_mineral({
	name="copper",
	texture="default_copperblock.png",
	ingot={groups={treasure=1,store=500}},
	ore_settings={
		clust_scarcity= 10 * 10 * 10,
		clust_num_ores=4,
		clust_size=6,
		y_max=-50,
	},
	pick={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.2,
		max_drop_level = 1,
		groupcaps = {
			cracky={times={[1]=10,[2]=3,[3]=1.4},uses=17,maxlevel=1}
		},
		damage_groups={fleshy=2},

	}},
	shovel={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			crumbly={times={[1]=2,[2]=1},uses=17,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	axe={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			choppy={times={[1]=3,[2]=1.8,[3]=1.1},uses=17,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	vineyardknife={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			snappy={times={[1]=2,[2]=1,[3]=0.5},uses=30,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	hoe={uses=100},
	arrow={damage=3,groups={treasure=1}},
	bow={uses=300,level=5,groups={treasure=1}},
})

default.registry_mineral({
	name="tin",
	texture="default_tinblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
	not_bow=true,
	not_arrow=true,
	ingot={groups={treasure=1,store=400}},
	ore_settings={
		clust_scarcity= 10 * 10 * 10,
		clust_num_ores=4,
		clust_size=6,
		y_max=-50,
	}
})

default.registry_mineral({
	name="bronze",
	texture="default_bronzeblock.png",
	not_ore = true,
	arrow={damage=4,groups={treasure=1}},
	bow={uses=500,level=7,groups={treasure=1}},
	ingot={groups={treasure=1,store=500}},
	additional_craft={{
		output="default:bronze_lump 8",
		recipe={
			{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
			{"default:copper_ingot","default:tin_ingot","default:copper_ingot"},
			{"default:copper_ingot","default:copper_ingot","default:copper_ingot"},
		}
	}},
	pick={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.2,
		max_drop_level = 1,
		groupcaps = {
			cracky={times={[1]=10,[2]=3,[3]=1.4},uses=20,maxlevel=1}
		},
		damage_groups={fleshy=2}
	}},
	shovel={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			crumbly={times={[1]=2,[2]=1},uses=20,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	axe={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			choppy={times={[1]=3,[2]=1.8,[3]=1.1},uses=20,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	vineyardknife={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			snappy={times={[1]=2,[2]=1,[3]=0.5},uses=40,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	hoe={uses=200},
})

default.registry_mineral({
	name="iron",
	texture="default_ironblock.png",
	lump={inventory_image="default_lump_iron.png"},
	ore={tiles={"default_stone.png^default_ore_iron.png"},groups={cracky=3}},
	ingot={groups={treasure=1,store=500}},
	ore_settings={
		clust_scarcity= 10 * 10 * 10,
		clust_num_ores=4,
		clust_size=7,
		y_max=5,
	},
	pick={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.1,
		max_drop_level = 1,
		groupcaps = {
			cracky={times={[1]=8,[2]=2.5,[3]=1.2},uses=22,maxlevel=2}
		},
		damage_groups={fleshy=3}
	}},
	shovel={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			crumbly={times={[1]=10,[2]=1.8,[3]=1.2},uses=22,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	axe={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			choppy={times={[1]=2.7,[2]=1.5,[3]=1},uses=22,maxlevel=2}
		},
		damage_groups={fleshy=4}
	}},
	vineyardknife={	groups={treasure=1},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			snappy={times={[1]=2,[2]=1,[3]=0.5},uses=70,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	hoe={uses=400},
	arrow={damage=7,groups={treasure=1}},
	bow={uses=700,level=9,groups={treasure=1}},
})

default.registry_mineral({
	name="cloud",
	texture="default_cloud.png",
	not_lump=true,
	not_ore=true,
	not_ingot=true,
	not_block=true,
	craftitem="default:cloud",
	
	pick={	groups={treasure=2},
		tool_capabilities={
		full_punch_interval = 1.1,
		max_drop_level = 1,
		groupcaps = {
			cracky={times={[1]=7,[2]=2.3,[3]=1.1},uses=25,maxlevel=2}
		},
		damage_groups={fleshy=4}
	}},
	shovel={groups={treasure=2},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			crumbly={times={[1]=9,[2]=1.6,[3]=1.1},uses=25,maxlevel=2}
		},
		damage_groups={fleshy=3}
	}},
	axe={	groups={treasure=2},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			choppy={times={[1]=2.5,[2]=1.3,[3]=0.9},uses=25,maxlevel=2}
		},
		damage_groups={fleshy=5}
	}},
	vineyardknife={	groups={treasure=2},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			snappy={times={[1]=2,[2]=1,[3]=0.5},uses=100,maxlevel=2}
		},
		damage_groups={fleshy=3}
	}},
	arrow={damage=8,groups={treasure=2}},
	bow={uses=1500,level=17,groups={treasure=2}},
})

default.registry_mineral({
	name="steel",
	texture="default_steelblock.png",
	not_ore = true,
	block={groups={cracky=1}},
	ingot={groups={treasure=2,store=800}},
	pick={	groups={treasure=2},
		tool_capabilities={
		full_punch_interval = 1,
		max_drop_level = 3,
		groupcaps = {
			cracky={times={[1]=2,[2]=1,[3]=0.5},uses=30,maxlevel=2}
		},
		damage_groups={fleshy=3}
	}},
	lump={groups={not_regular_craft=1}},
	shovel={	groups={treasure=2},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			crumbly={times={[1]=5,[2]=1.6,[3]=1},uses=25,maxlevel=3}
		},
		damage_groups={fleshy=2}
	}},
	axe={	groups={treasure=2},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			choppy={times={[1]=2.5,[2]=1.2,[3]=0.9},uses=25,maxlevel=2}
		},
		damage_groups={fleshy=4}
	}},
	vineyardknife={	groups={treasure=2},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			snappy={times={[1]=2,[2]=1,[3]=0.5},uses=150,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	hoe={uses=800},
	arrow={damage=10,groups={treasure=2}},
	bow={uses=900,level=12,groups={treasure=2}},
})

default.registry_mineral({
	name="gold",
	texture="default_goldblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
	ingot={groups={treasure=3,store=800}},
	ore_settings={
		clust_scarcity= 8 * 8 * 8,
		clust_num_ores=10,
		clust_size=7,
		y_max=-70,
	},
	arrow={damage=6,groups={treasure=3}},
	bow={uses=800,level=10,shots=3,groups={treasure=3}},
	hoe={uses=600,groups={treasure=3}},
})

default.registry_mineral({
	name="silver",
	texture="default_silverblock.png",
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
	ingot={groups={treasure=3,store=700}},
	ore_settings={
		clust_scarcity= 8 * 8 * 8,
		clust_num_ores=9,
		clust_size=7,
		y_max=-70,
	},
	arrow={damage=5,groups={treasure=3}},
	bow={uses=750,level=10,shots=2,groups={treasure=3}},
	hoe={uses=500,groups={treasure=3}},
})

default.registry_mineral({
	name="diamond",
	texture="default_diamondblock.png",
	drop={inventory_image="diamond",groups={treasure=3,store=900}},
	block={groups={cracky=1}},
	not_lump = true,
	not_ingot = true,
	block={sounds=default.node_sound_stone_defaults()},
	ore_settings={
		clust_scarcity= 9 * 9 * 9,
		clust_num_ores=8,
		clust_size=8,
		y_max=-90,
	},
	pick={	groups={treasure=3},
		tool_capabilities={
		full_punch_interval = 1,
		max_drop_level = 2,
		groupcaps = {
			cracky={times={[1]=2,[2]=1,[3]=0.5},uses=30,maxlevel=3}
		},
		damage_groups={fleshy=4}
	}},
	shovel={	groups={treasure=3},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			crumbly={times={[1]=3,[2]=0.7,[3]=0.5},uses=30,maxlevel=3}
		},
		damage_groups={fleshy=3}
	}},
	axe={	groups={treasure=3},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 2,
		groupcaps = {
			choppy={times={[1]=2,[2]=1,[3]=0.6},uses=30,maxlevel=2}
		},
		damage_groups={fleshy=5}
	}},
	vineyardknife={	groups={treasure=3},
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			snappy={times={[1]=1,[2]=0.5,[3]=0.1},uses=500,maxlevel=2}
		},
		damage_groups={fleshy=3}
	}},
	hoe={uses=1000,groups={treasure=3}},
	arrow={damage=20,groups={treasure=3}},
	bow={uses=1000,level=15,groups={treasure=3}},
})

default.registry_mineral({
	name="titanium",
	texture="default_steelblock.png^[colorize:#5555",
	wherein="default:moon_space",
	not_ore = true,
	ore={tiles={"default_space_stone.png^(default_steelblock.png^[colorize:#5555^default_alpha_ore.png^[colorize:#fff4^default_ore_mineral.png^[makealpha:0,255,0)"}},
	block={groups={cracky=1}},
	pick={
		range = 5,
		tool_capabilities={
		full_punch_interval = 1,
		max_drop_level = 3,
		groupcaps = {
			cracky={times={[1]=0.4,[2]=0.2,[3]=0.1},uses=60,maxlevel=3}
		},
		damage_groups={fleshy=3}
	}},
	shovel={
		range = 5,
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			crumbly={times={[1]=1,[2]=0.3,[3]=0.2},uses=35,maxlevel=3}
		},
		damage_groups={fleshy=2}
	}},
	axe={
		range = 5,
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 3,
		groupcaps = {
			choppy={times={[1]=0.3,[2]=0.3,[3]=0.2},uses=35,maxlevel=2}
		},
		damage_groups={fleshy=4}
	}},
	vineyardknife={
		range = 5,
		tool_capabilities={
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			snappy={times={[1]=0.4,[2]=0.2,[3]=0.1},uses=600,maxlevel=2}
		},
		damage_groups={fleshy=2}
	}},
	hoe={uses=1100},
	arrow={damage=13,treasure=0},
	bow={uses=1100,level=18,treasure=0},
})

default.registry_mineral({
	name="electric",
	texture="default_electricblock.png",
	not_ingot=true,
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
	lump={groups={treasure=2,store=900}},
	ore_settings={
		clust_scarcity= 10 * 10 * 10,
		clust_num_ores=7,
		clust_size=9,
		y_max=-100,
	},
	additional_craft={
	{output="default:electricblock",
	recipe={
		{"default:electric_lump","default:electric_lump","default:electric_lump"},
		{"default:electric_lump","default:electric_lump","default:electric_lump"},
		{"default:electric_lump","default:electric_lump","default:electric_lump"},
	}}},
	hoe={uses=1500},
	arrow={
		groups={treasure=3},
		damage=10,
		on_hit_object=function(self,target,hp,usee,lastpos)
			local name = target:is_player() and target:get_player_name() or nil
			if name then
				default.set_on_player_death(name,"electric_arrow",name,true)
			end
			for i=1,math.random(7,15) do
				minetest.after(math.random(i*0.1,(i*0.1)+0.2),function(target,name,user)
					if not (name and not default.get_on_player_death(name,"electric_arrow")) and target:get_pos() then
						user = user and user:get_pos() and user or target
						default.punch(target,user,3)
					end
				end,target,name,user)
			end
			if self then
				bows.arrow_remove(self)
			end
		end

	},
	bow={uses=1300,level=17,shots=5,groups={treasure=3}},
})

default.registry_mineral({
	name="uranium",
	texture="default_uraniumblock.png",
	lump={groups={treasure=2}},
	ore_settings={
		clust_scarcity= 10 * 10 * 10,
		clust_num_ores=7,
		clust_size=9,
		y_max=-100,
	},
	not_ingot=true,
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_vineyardknife=true,
	not_bow=true,
	not_arrow=true,
	additional_craft={
	{output="default:uraniumblock",
	recipe={
		{"default:uranium_lump","default:uranium_lump","default:uranium_lump"},
		{"default:uranium_lump","default:uranium_lump","default:uranium_lump"},
		{"default:uranium_lump","default:uranium_lump","default:uranium_lump"},
	}}},
})

default.registry_mineral({
	name="uraniumactive",
	texture="default_uraniumactiveblock.png",
	not_lump=true,
	not_ore=true,
	not_pick=true,
	not_axe=true,
	not_shovel=true,
	not_hoe=true,
	not_bow=true,
	not_arrow=true,
	not_vineyardknife=true,
	ingot={groups={store=1000}},
	additional_craft={{
		type = "cooking",
		output = "default:uraniumactive_ingot",
		recipe = "default:uranium_lump",
		cooktime = 100
	}}
})