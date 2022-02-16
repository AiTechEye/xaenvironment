plants.piece_of_plant = {"004400","005500","006600","007700","008800","009900"}

plants.rnd_piece_of_plant=function(color,r)
	r = r or 6
	color = color or math.random(1,r)
	local c = math.random(-1,1)
	if c == -1 and color > 1 or c == 1 and color < r then
			color = color + c
	end
	return color,"plants:macro_piece_of_plant" .. color
end

for i,v in pairs(plants.piece_of_plant) do
minetest.register_node("plants:macro_piece_of_plant"..i, {
	description = "Piece of plant",
	tiles={"plants_oak_tree.png^[colorize:#"..v.."99"},
	groups = {choppy = 3, flammable=1,not_in_creative_inventory=0},
	sunlight_propagates = true,
	paramtype = "light",
	sounds = default.node_sound_wood_defaults(),
})
end

minetest.register_node("plants:macro_piece_of_plant0", {
	description = "Piece of plant",
	tiles={"plants_oak_tree.png"},
	groups = {choppy = 3, flammable=1,not_in_creative_inventory=0},
	sunlight_propagates = true,
	paramtype = "light",
	palette = "default_palette.png",
	paramtype2 = "color",
	sounds = default.node_sound_wood_defaults(),
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
		local color = math.random(0,16)*8
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
})