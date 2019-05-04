-- npc monster animal predator

examobs.register_mob({
	name = "wolf",
	textures = {"examobs_wolf.png"},
	mesh = "examobs_wolf.b3d",
	dmg = 2,
	aggressivity = 1,
	run_speed = 8,
	updatetime=0.5,
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		run = {x=32,y=52,speed=60},
		lay = {x=66,y=75},
		attack = {x=53,y=65},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
	spawn_on={"default:dirt_with_snow","default:dirt_with_coniferous_grass"},
})

examobs.register_mob({
	name = "arctic_wolf",
	textures = {"examobs_arctic_wolf.png"},
	mesh = "examobs_wolf.b3d",
	dmg = 2,
	aggressivity = 1,
	run_speed = 8,
	updatetime=0.5,
	team = "arctic_wolf",
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		run = {x=32,y=52,speed=60},
		lay = {x=66,y=75},
		attack = {x=53,y=65},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
	spawn_on={"group:snowy"},
})

examobs.register_mob({
	name = "golden_wolf",
	textures = {"examobs_golden_wolf.png"},
	mesh = "examobs_wolf.b3d",
	dmg = 2,
	aggressivity = 1,
	run_speed = 8,
	updatetime=0.5,
	team = "golden_wolf",
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		run = {x=32,y=52,speed=60},
		lay = {x=66,y=75},
		attack = {x=53,y=65},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
	spawn_on={"default:dirt_with_dry_grass"},
})

examobs.register_mob({
	name = "underground_wolf",
	textures = {"uexamobs_underground_wolf.png"},
	mesh = "examobs_wolf.b3d",
	type = "monster",
	team = "stone",
	dmg = 4,
	aggressivity = 2,
	swiming = 0,
	run_speed = 10,
	updatetime=0.5,
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		run = {x=32,y=52,speed=60},
		lay = {x=66,y=75},
		attack = {x=53,y=65},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
	spawn_on={"default:stone","default:cobble"},
})