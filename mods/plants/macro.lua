plants.piece_of_plant = {"004400","005500","006600","007700","008800","009900"}
plants.queue = nil
plants.mineral_colors = {
	"default:rubyblock",
	"default:taaffeiteblock",
	"default:taaffeiteblock",
	"default:amethystblock",
	"default:amethystblock",
	"default:electricblock",
	"default:diamondblock",
	"default:opalblock",
	"default:opalblock",
	"default:jadeiteblock",
	"default:jadeiteblock" ,
	"default:jadeiteblock",
	"default:peridotblock",
	"default:peridotblock",
	"default:amberblock",
	"default:zirconiablock",
}



plants.mineral_colors[0] = "default:rubyblock"

plants.rnd_piece_of_plant=function(color,r)
	r = r or 6
	color = color or math.random(1,r)
	local c = math.random(-1,1)
	if c == -1 and color > 1 or c == 1 and color < r then
			color = color + c
	end
	return color,"plants:macro_piece_of_plant" .. color
end

plants.rnd_color=function(color,r1,r2)
	r1 = r1 or 0
	r2 = r2 or 4
	local rc = math.random(-1,1)
	if rc == -1 and color+rc > r1 or rc == 1 and color+rc < r2 then
		color = color + rc
	end
	return color
end

for i,v in pairs(plants.piece_of_plant) do
minetest.register_node("plants:macro_piece_of_plant"..i, {
	description = "Piece of plant",
	tiles={"plants_oak_tree.png^[colorize:#"..v.."99"},
	groups = {choppy = 3, flammable=1,not_in_creative_inventory=1,macroplant=1},
	sunlight_propagates = true,
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
})
end

minetest.register_node("plants:macro_piece_of_plant0", {
	description = "Piece of plant",
	tiles={"plants_oak_tree.png"},
	groups = {choppy = 3, flammable=1,not_in_creative_inventory=1,macroplant=2},
	sunlight_propagates = true,
	paramtype = "light",
	palette = "default_palette.png",
	paramtype2 = "color",
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("plants:macro_piece_of_plant01", {
	description = "Piece of plant",
	tiles={"plants_hazel_tree.png"},
	groups = {choppy = 3, flammable=1,not_in_creative_inventory=1,macroplant=3},
	sunlight_propagates = true,
	paramtype = "light",
	palette = "default_palette.png",
	paramtype2 = "color",
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_node("plants:macro_tree", {
	description = "Macro tree",
	tiles={"plants_hazel_tree.png"},
	groups = {choppy = 1,tree=1,flammable=1,not_in_creative_inventory=1,macrotree=1},
	sunlight_propagates = true,
	palette = "default_palette.png",
	paramtype2 = "color",
	sounds = default.node_sound_wood_defaults(),
})

minetest.register_craft({
	output="materials:mixed_wood",
	recipe={{"plants:macro_tree"}},
})

minetest.register_node("plants:macro_grass", {
	description = "Grass",
	tiles={"plants_oak_tree.png^[colorize:#00ff0099"},
	groups = {flammable=1,on_load=1,not_in_creative_inventory=1,unbreakable=1},
	sunlight_propagates = true,
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		minetest.registered_nodes["plants:macro_grass"].on_load(pos)
	end,
	on_load=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer =  function (pos, elapsed)
		if plants.queue then
			return true
		end
		plants.queue = true
		local l = math.random(5,50)
		local color,node
		for y=0,l do
			color,node = plants.rnd_piece_of_plant(color)
			minetest.set_node(apos(pos,0,y),{name=node})
			if math.random(0,3) == 0 then
				pos = apos(pos,math.random(-1,1),0,math.random(-1,1))
				minetest.set_node(apos(pos,0,y),{name=node})
			end
		end
		plants.queue = false
	end
})

minetest.register_node("plants:macro_lilypad", {
	description = "Lily pad",
	tiles={"plants_oak_tree.png^[colorize:#00ff0099"},
	groups = {flammable=1,on_load=1,not_in_creative_inventory=1,unbreakable=1},
	sunlight_propagates = true,
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		minetest.registered_nodes["plants:macro_lilypad"].on_load(pos)
	end,
	on_load=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer =  function (pos, elapsed)
		if plants.queue then
			return true
		end
		plants.queue = true
		minetest.remove_node(pos)
		local color,node
		local s = math.random(4,9)
		for x=-s,s,1 do
		for z=-s,s,1 do
			if vector.length(vector.new({x=x,y=0,z=z}))/s<=1 then
				color,node = plants.rnd_piece_of_plant(color)
				minetest.set_node(apos(pos,x,1,z),{name=node})
			end
		end
		end
		plants.queue = false
	end
})

minetest.register_node("plants:macro_flower", {
	description = "Flower",
	tiles={"plants_oak_tree.png^[colorize:#ff0000"},
	groups = {flammable=1,on_load=1,not_in_creative_inventory=1,unbreakable=1},
	sunlight_propagates = true,
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		minetest.registered_nodes["plants:macro_flower"].on_load(pos)
	end,
	on_load=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer =  function (pos, elapsed)
		if plants.queue then
			return true
		end
		plants.queue = true
		local p = apos(pos,0,-1)
		local l = math.random(30,100)
		local s = math.random(4,9)
		local r = math.random(1,4)
		local color,node
		for y=0,l do
			color,node = plants.rnd_piece_of_plant(color,3)
			p = apos(p,0,1)
			if r > 1 and y <= l-s then
				for x=-1,1 do
				for z=-1,1 do
					minetest.set_node(apos(p,x,0,z),{name=node})
				end
				end
			else
				minetest.set_node(p,{name=node})
			end
			if math.random(0,3) == 0 then
				p = apos(p,math.random(-1,1),-1,math.random(-1,1))
			end
		end
		local color = math.random(0,16)
		local mineral = plants.mineral_colors[color]
		color = color*8
		local colorg = math.random(0,4)
		local a,b,c = 1,1,1

		if r == 1 then
			b = 0
			p = apos(p,0,1)
		elseif r == 2 then
			a = 0
			c = 1
		elseif r == 3 then
			a = 1
			c = 0
		end
		for x=-s,s do
		for y=-s,s do
		for z=-s,s do
			if vector.length(vector.new({x=x*a,y=y*b,z=z*c}))/s<=1 then
				if math.random(1,30) == 1 then 
					minetest.set_node(apos(p,x*a,y*b,z*c),{name=mineral})
				else
					local rc = math.random(-1,1)
					if rc == -1 and colorg > 1 or rc == 1 and colorg < 4 then
						colorg = colorg + rc
					end
					minetest.set_node(apos(p,x*a,y*b,z*c),{name="plants:macro_piece_of_plant0",param2=color+colorg})
				end
			end
		end
		end
		end
		plants.queue = false
	end
})

minetest.register_node("plants:macro_mushroom", {
	description = "Mushroom",
	tiles={"plants_hazel_tree.png^[colorize:#ffffff99"},
	groups = {flammable=1,on_load=1,not_in_creative_inventory=1,unbreakable=1},
	sunlight_propagates = true,
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		minetest.registered_nodes["plants:macro_mushroom"].on_load(pos)
	end,
	on_load=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer =  function (pos, elapsed)
		if plants.queue then
			return true
		end
		plants.queue = true
		minetest.remove_node(pos)
		local color,colorg = 131,3
		local r = math.random(1,4)
		local s = math.random(4,9)
		local stem = math.random(3,9)
		local p = apos(pos,0,-1)
		local l = math.random(20,50)

		if r == 4 then
			l = l *1.5
		end

		for y=0,l do
			p = apos(p,0,1)
			for x=-stem,stem do
			for z=-stem,stem do
				if vector.length(vector.new({x=x,y=stem/2.5,z=z}))/s < 1 then
					colorg = plants.rnd_color(colorg,0,5)
					minetest.set_node(apos(p,x,0,z),{name="plants:macro_piece_of_plant01",param2 = colorg+131})
				end
			end
			end
			if math.random(0,3) == 0 then
				p = apos(p,math.random(-1,1),-1,math.random(-1,1))
			end
		end

		local s = math.random(15,30)
		local color = {0,1,14,15,16}
		local rr = math.random(1,5)
		color = color[rr]*8
		local colorg = math.random(0,4)
		local l1,l2

		minetest.emerge_area(vector.subtract(pos,stem+s),vector.add(pos,stem+s))

		if rr == 16 then
			color = 132
		end
		if r == 1 or r == 3 then
				l1 = 1
				l2 = 0
		elseif r == 2 then
				l1 = 0
				l2 = 0
		elseif r == 4 then
				l1 = 1
				l2 = 0
				p.y = p.y-s+5
		end

		for y=0,s do
			if r == 1 then
				l1 = l1 -0.1
				l2 = l1-0.3
			elseif r == 2 then
				l1 = l1 +0.1
				l2 = l1-0.1
			elseif r == 3 then
				l1 = l1 -0.2
				l2 = l1-0.3
			elseif r == 4 then
				l2 = l1-0.1
			end
		for x=-s,s do
		for z=-s,s do
			local d = vector.length(vector.new({x=x,y=y,z=z}))/s
			if d<=l1 and d >= l2 then
				local rc = math.random(-1,1)
				if rc == -1 and colorg > 1 or rc == 1 and colorg < 4 then
					colorg = colorg + rc
				end
				local c = color+colorg
				if math.random(1,10) == 1 then
						c = math.random(1,2) == 1 and math.random(131,136) or math.random(15*8,(15*8)+4)
				end
				minetest.set_node(apos(p,x,y,z),{name="plants:macro_piece_of_plant0",param2=c})
			end
		end
		end
		end
		plants.queue = false
	end
})

plants.macro_branch=function(p,size)
	local dir = vector.new(math.random(-1,1),0,math.random(-1,1))
	local stem = size or math.random(3,6)
	local colort = 3
	local colorg = 3
	local branch = math.random(10,30)
	local leafc = 1
	local leaf

	minetest.emerge_area(vector.subtract(p,branch+stem),vector.add(p,branch+stem))

	for w=0,branch do
		p = apos(p,dir.x*stem,0,dir.z*stem)
		p = apos(p,math.random(-1,1),-1,math.random(-1,1))
	for y=-stem,stem do
	for x=-stem,stem do
	for z=-stem,stem do
			if math.abs(y) == stem or math.abs(x) == stem or math.abs(z) == stem then
				colort = plants.rnd_color(colort,4,8)
				minetest.set_node(apos(p,x,y,z),{name="plants:macro_tree",param2 = colort+160})
			else
				colorg = plants.rnd_color(colorg,0,5)
				minetest.set_node(apos(p,x,y,z),{name="plants:macro_tree",param2 = colorg+112})
			end
	end
	end
	end
		if math.random(1,2) == 1 then
			local ls = math.random(1,4)
			local lp = vector.new(math.random(-1,1)*stem,math.random(-1,1)*stem,math.random(-1,1)*stem)
			if math.random(1,4) == 1 and size == nil then
				plants.macro_branch(apos(p,lp.x,lp.y,lp.z),3)
			else
				for yy=-ls,ls do
				for xx=-ls,ls do
				for zz=-ls,ls do
					leafc,leaf = plants.rnd_piece_of_plant(leafc)
					minetest.set_node(apos(p,xx+lp.x,yy+lp.y,zz+lp.z),{name=leaf})
				end
				end
				end
			end
		end
	end
end

minetest.register_node("plants:macro_trees", {
	description = "Tree",
	tiles={"default_tree.png"},
	groups = {flammable=1,on_load=1,not_in_creative_inventory=1,unbreakable=1},
	sunlight_propagates = true,
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
	on_construct=function(pos)
		minetest.registered_nodes["plants:macro_trees"].on_load(pos)
	end,
	on_load=function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_timer =  function (pos, elapsed)
		if plants.queue then
			return true
		end
		plants.queue = true
		minetest.remove_node(pos)
		local color,colorg,colort = 112,3,5
		local s = math.random(10,20)
		local stem = math.random(6,16)
		local p = apos(pos,0,-1)
		local l = math.random(20,120)

		minetest.emerge_area(vector.subtract(pos,stem),vector.add(pos,stem))

		for y=0,l do
			p = apos(p,0,1)
			for x=-stem,stem do
			for z=-stem,stem do
				local d = vector.length(vector.new({x=x,y=stem/2.5,z=z}))/s
				if d >= 1 or math.abs(x) == stem or math.abs(z) == stem then
					colort = plants.rnd_color(colort,4,8)
					minetest.set_node(apos(p,x,0,z),{name="plants:macro_tree",param2 = colort+160})

				elseif d < 1 then
					colorg = plants.rnd_color(colorg,0,5)
					minetest.set_node(apos(p,x,0,z),{name="plants:macro_tree",param2 = colorg+112})
				end
			end
			end
			if math.random(0,30) == 0 then
				p = apos(p,math.random(-1,1),-1,math.random(-1,1))
			end
			if math.random(0,30) == 0 and l > 40 then
					plants.macro_branch(apos(p,math.random(-stem/2,stem/2),math.random(-stem/2,stem/2),math.random(-stem/2,stem/2)))
			end
		end
		plants.queue = false
	end
})