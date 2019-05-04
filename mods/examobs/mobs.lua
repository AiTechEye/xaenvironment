-- npc monster animal predator

examobs.register_mob({
	name = "wolf",
	textures = {"examobs_wolf.png"},
	mesh = "examobs_wolf.b3d",
	type = "animal",
	dmg = 2,
	aggressivity = 2,
	run_speed = 10,
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		lay = {x=41,y=50},
		attack = {x=32,y=36},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
})

examobs.register_mob({
	name = "underground_wolf",
	textures = {"uexamobs_underground_wolf.png"},
	mesh = "examobs_wolf.b3d",
	type = "animal",
	team = "stone",
	dmg = 4,
	aggressivity = 2,
	swiming = 0,
	run_speed = 10,
	animation = {
		stand = {x=0,y=9},
		walk = {x=11,y=31},
		lay = {x=41,y=50},
		attack = {x=32,y=36},
	},
	collisionbox={-0.6,-0.8,-0.6,0.6,0.3,0.6,},
})