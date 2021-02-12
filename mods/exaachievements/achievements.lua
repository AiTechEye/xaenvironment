--================ Noob ==================
exaachievements.register({
	type="dig",
	count=25,
	name="Sand_treasures",
	item="default:sand",
	description="Dig sand under water to find flint",
	skills=1,
	approve=function(user,item,pos)
		return minetest.get_item_group(minetest.get_node(apos(pos,0,1)).name,"water") > 0
	end
})
exaachievements.register({
	type="craft",
	count=10,
	name="Gravel_to_flint",
	item="default:flint",
	image="default:gravel",
	description="Craft flint from gravel",
})

exaachievements.register({
	type="dig",
	count=25,
	name="Sukkah",
	item="leaves",
	image="plants:apple_leaves",
	description="Dig 25 leaves and find sticks",
})
exaachievements.register({
	type="craft",
	count=1,
	name="Axeman",
	item="default:flint_axe",
	description="Craft a flint axe",
})
exaachievements.register({
	type="craft",
	count=1,
	name="Pickman",
	item="default:flint_pick",
	description="Craft a flint pick",
})

exaachievements.register({
	type="craft",
	count=1,
	name="Drink",
	item="player_style:bottle",
	description="Craft a bottle",
})

--================ Dirty ==================

exaachievements.register({
	type="dig",
	count=25,
	name="Mud_dive",
	item="spreading_dirt_type",
	description="Dig 25 grass",
	skills=1,
	image="default:dirt_with_grass",
	hide_until=4,
})
exaachievements.register({
	type="dig",
	count=25,
	name="Tree_cutter",
	item="tree",
	description="Dig 25 tree",
	skills=2,
	image="plants:apple_tree",
	hide_until=4,
})


exaachievements.register({
	type="craft",
	count=50,
	name="Carpenter",
	item="wood",
	description="Craft 50 wood",
	skills=2,
	image="plants:apple_wood",
	hide_until=4,
})

exaachievements.register({
	type="craft",
	count=10,
	name="Item_maker",
	item="stick",
	description="Craft 10 sticks",
	image="default:stick",
	hide_until=4,
})
exaachievements.register({
	type="place",
	count=25,
	name="Dirt_house",
	item="default:dirt",
	description="Place 25 dirts",
	hide_until=4,
})
exaachievements.register({
	type="dig",
	count=100,
	name="Caveman",
	item="default:stone",
	description="Dig 100 stones",
	skills=2,
	hide_until=4,
})
exaachievements.register({
	type="dig",
	count=100,
	name="Desertwalker",
	item="default:pebble_desert_stone",
	description="Pick up 100 desert pebbles",
	skills=2,
	hide_until=5,
})

--================ Average ==================

exaachievements.register({
	type="customize",
	name="Circus artist",
	count=20,
	description="Do 20 backflips",
	skills=10,
	hide_until=10,
})

exaachievements.register({
	type="customize",
	name="Freerunner",
	count=20,
	description="Do 20 frontflips",
	skills=10,
	hide_until=10,
})

exaachievements.register({
	type="customize",
	name="Parkour!",
	count=20,
	description="Do 20 right sideflips",
	skills=10,
	hide_until=10,
})
exaachievements.register({
	type="customize",
	name="Tricker",
	count=20,
	description="Do 20 left sideflips",
	skills=10,
	hide_until=10,
})

exaachievements.register({
	type="customize",
	name="artist",
	count=#player_style.skins.skins,
	description="buy all skins",
	skills=1000,
	hide_until=10,
	completed=function(player)
		Coin(player,10000)
	end
})

exaachievements.register({
	type="customize",
	name="Mob_book_completely",
	count=1,
	description="Completely a mob book",
	skills=1000,
	hide_until=10,
	completed=function(player)
		Coin(player,10000)
	end
})

exaachievements.register({
	type="eat",
	name="Pears",
	item="plants:pear",
	count=1,
	description="Eat a pear",
	hide_until=7,
})
exaachievements.register({
	type="eat",
	name="Apples",
	item="plants:apple",
	count=1,
	description="Eat an apple",
	hide_until=7,
})

exaachievements.do_a({type="dig",item="default:obsidian",skills=2})
exaachievements.do_a({type="dig",item="default:bedrock",skills=2})
exaachievements.do_a({type="dig",item="default:cobble_porous"})
exaachievements.do_a({type="dig",item="default:stone_hot"})
exaachievements.do_a({type="dig",item="default:cooledlava"})
exaachievements.do_a({type="dig",item="default:ice"})
exaachievements.do_a({item="default:snowblock"})
exaachievements.do_a({item="default:workbench",skills=4})
exaachievements.do_a({item="default:torch"})
exaachievements.do_a({item="default:ladder"})
exaachievements.do_a({item="default:paper_compressor"})
exaachievements.do_a({item="default:dye_workbench"})
exaachievements.do_a({item="default:furnace"})
exaachievements.do_a({item="default:chest"})
exaachievements.do_a({item="default:locked_chest"})
exaachievements.do_a({item="default:cudgel"})
exaachievements.do_a({item="default:bucket"})
exaachievements.do_a({item="default:amberblock",skills=2})
exaachievements.do_a({item="default:flintblock",skills=2})
exaachievements.do_a({item="default:tinblock",skills=2})
exaachievements.do_a({item="default:copperblock",skills=2})
exaachievements.do_a({item="default:bronzeblock",skills=3})
exaachievements.do_a({item="default:ironblock",skills=3})
exaachievements.do_a({item="default:goldblock",skills=3})
exaachievements.do_a({item="default:silverblock",skills=3})
exaachievements.do_a({item="default:steelblock",skills=5})
exaachievements.do_a({item="air_balloons:balloon",skills=7})
exaachievements.do_a({item="beds:bed",skills=2})
exaachievements.do_a({item="beds:tent",skills=3})
exaachievements.do_a({item="clock:clock1"})
exaachievements.do_a({item="hook:climb_rope_locked",skills=5})
exaachievements.do_a({item="nitroglycerin:timed_bomb",skills=7})
exaachievements.do_a({item="synth:synth",skills=10})
exaachievements.do_a({item="default:diamondblock",skills=7})
exaachievements.do_a({item="default:electricblock",skills=10})
exaachievements.do_a({item="default:uraniumblock",skills=15})
exaachievements.do_a({item="default:uraniumactiveblock",skills=20})
exaachievements.do_a({item="default:quantum_pick",skills=20})


minetest.register_on_mods_loaded(function()
	local traveler=0
	for i,v in pairs(minetest.registered_nodes) do
		if v.groups and  v.groups.spreading_dirt_type then
			exaachievements.do_a({
				type="dig",
				item=i,
				completed=function(user)
					exaachievements.customize(user,"Traveler")
				end
			})
			traveler=traveler+1
		end
	end
	exaachievements.register({
		type="customize",
		name="Traveler",
		count=traveler,
		description="Dig all " ..traveler .." kinds of grass",
		skills=10,
		hide_until=20,
	})
end)

--================ Special ==================

exaachievements.register({
	type="dig",
	count=100,
	name="Cloudlands",
	item="default:cloud",
	description="Dig 100 cloud",
	skills=50,
	hide_until=100,
})

exaachievements.do_a({item="quads:quad",skills=5})
exaachievements.register({
	type="customize",
	name="Quad_frontflip_stunt",
	count=1,
	description="Do a full frontflip with a quad (down+use in air)",
	skills=20,
	hide_until=100,
})
exaachievements.register({
	type="customize",
	name="Quad_backflip_stunt",
	count=1,
	description="Do a full backflip with a quad (up+use in air)",
	skills=20,
	hide_until=100,
})
exaachievements.register({
	type="customize",
	name="100% Clean",
	count=1,
	description="Blow a fully charged plasma orb",
	skills=50,
	hide_until=200,
})
exaachievements.register({
	type="dig",
	count=100,
	name="Moon cleaner",
	item="default:space_dust",
	description="Dig 100 space dust",
	skills=10,
	hide_until=20,
})

exaachievements.register({
	type="dig",
	count=100,
	name="Crystals",
	item="crystal",
	image="plants:pebble_crystal4",
	description="Dig 100 crystals",
	skills=10,
	hide_until=20,
	approve=function(user,item,pos)
		return minetest.get_item_group(item:get_name(),"crystal") > 0
	end
})
exaachievements.register({
	type="dig",
	count=100,
	name="Pro diver",
	item="materials:granite_orb",
	description="Dig 100 granite orbs in deep oceans",
	skills=100,
	hide_until=20,
	approve=function(user,item,pos)
		return minetest.get_item_group(minetest.get_node(apos(pos,0,1)).name,"water") > 0 and pos.y < 20
	end
})

exaachievements.register({
	type="dig",
	count=100,
	name="Moon caveman",
	item="default:space_stone",
	description="Dig 100 space stone",
	skills=10,
	hide_until=20,
})

exaachievements.register({
	type="customize",
	count=10,
	name="Space guy",
	item="spacestuff:spacesuit",
	description="Empty 10 air bottles in vacuum",
	skills=100,
	hide_until=50,
})

exaachievements.do_a({item="multidimensions:teleporter_candyland",skills=100})
exaachievements.do_a({item="multidimensions:teleporter_moon",skills=100})