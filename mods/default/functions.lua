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

--||||||||||||||||
-- ======================= Trees
--||||||||||||||||