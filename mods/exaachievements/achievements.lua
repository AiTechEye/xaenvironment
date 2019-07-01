
--================ Eat ==================
exaachievements.register({
	type="eat",
	name="Pears",
	item="plants:pear",
	count=1,
	description="Eat a pear",
	min=3
})

exaachievements.register({
	type="eat",
	name="Apples",
	item="plants:apple",
	count=1,
	description="Eat an apple",
})
--================ Customize ==================
exaachievements.register({
	type="customize",
	name="Hunter",
	count=100,
	description="Kill 100 animals",
	skills=10,
})
--================ Dig ==================
exaachievements.register({
	type="dig",
	count=25,
	name="Sand_treasures",
	item="default:sand",
	description="Dig sand under water",
	skills=1,
	approve=function(user,item,pos)
		return minetest.get_item_group(minetest.get_node(apos(pos,0,1)).name,"water") > 0
	end
})
exaachievements.register({
	type="dig",
	count=25,
	name="Mud_dive",
	item="spreading_dirt_type",
	description="Dig 25 dirts",
	skills=1,
	image="default:dirt_with_grass",
})

exaachievements.register({
	type="dig",
	count=25,
	name="Tree_cutter",
	item="tree",
	description="Dig 25 tree",
	skills=2,
	image="plants:apple_tree",
})

--================ Place ==================

exaachievements.register({
	type="place",
	count=25,
	name="Dirt_house",
	item="default:dirt",
	description="Place 25 dirts",
	skills=1,
})

--================ Craft ==================

exaachievements.register({
	type="craft",
	count=50,
	name="Carpenter",
	item="wood",
	description="Craft 50 wood",
	skills=2,
	image="plants:apple_wood",
})

exaachievements.register({
	type="craft",
	count=10,
	name="Item_maker",
	item="stick",
	description="Craft 10 sticks",
	skills=2,
	image="default:stick",
})