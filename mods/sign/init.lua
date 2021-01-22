sign={
	characters = {
		[" "]={s=4},
		["\n"]={s=0},
		["a"]={tex="sign_a1.png",s=5},
		["A"]={tex="sign_a2.png",s=6},
		["b"]={tex="sign_b1.png",s=5},
		["B"]={tex="sign_b2.png",s=5},
		["c"]={tex="sign_c1.png",s=5},
		["C"]={tex="sign_c2.png",s=7},
		["d"]={tex="sign_d1.png",s=6},
		["D"]={tex="sign_d2.png",s=6},
		["e"]={tex="sign_e1.png",s=6},
		["E"]={tex="sign_e2.png",s=4},
		["f"]={tex="sign_f1.png",s=4},
		["F"]={tex="sign_f2.png",s=4},
		["g"]={tex="sign_g1.png",s=6},
		["G"]={tex="sign_g2.png",s=7},
		["h"]={tex="sign_h1.png",s=5},
		["H"]={tex="sign_h2.png",s=6},
		["i"]={tex="sign_i1.png",s=1},
		["I"]={tex="sign_i2.png",s=1},
		["j"]={tex="sign_j1.png",s=3},
		["J"]={tex="sign_j2.png",s=3},
		["k"]={tex="sign_k1.png",s=4},
		["K"]={tex="sign_k2.png",s=5},
		["l"]={tex="sign_l1.png",s=1},
		["L"]={tex="sign_l2.png",s=4},
		["m"]={tex="sign_m1.png",s=8},
		["M"]={tex="sign_m2.png",s=8},
		["n"]={tex="sign_n1.png",s=5},
		["N"]={tex="sign_n2.png",s=7},
		["o"]={tex="sign_o1.png",s=5},
		["O"]={tex="sign_o2.png",s=9},
		["p"]={tex="sign_p1.png",s=6},
		["P"]={tex="sign_p2.png",s=6},
		["q"]={tex="sign_q1.png",s=6},
		["Q"]={tex="sign_q2.png",s=9},
		["r"]={tex="sign_r1.png",s=3},
		["R"]={tex="sign_r2.png",s=5},
		["s"]={tex="sign_s1.png",s=4},
		["S"]={tex="sign_s2.png",s=4},
		["t"]={tex="sign_t1.png",s=3},
		["T"]={tex="sign_t2.png",s=6},
		["u"]={tex="sign_u1.png",s=5},
		["U"]={tex="sign_u2.png",s=6},
		["v"]={tex="sign_v1.png",s=5},
		["V"]={tex="sign_v2.png",s=7},
		["w"]={tex="sign_w1.png",s=9},
		["W"]={tex="sign_w2.png",s=9},
		["x"]={tex="sign_x1.png",s=5},
		["X"]={tex="sign_x2.png",s=5},
		["y"]={tex="sign_y1.png",s=5},
		["Y"]={tex="sign_y2.png",s=6},
		["z"]={tex="sign_z1.png",s=4},
		["Z"]={tex="sign_z2.png",s=5},
		["_"]={tex="sign__.png",s=5},
		["("]={tex="sign_abra.png",s=3},
		[")"]={tex="sign_abra2.png.png",s=3},
		["&"]={tex="sign_and.png",s=7},
		["'"]={tex="sign_apostrof.png",s=1},
		["*"]={tex="sign_asterisk.png",s=5},
		["@"]={tex="sign_at.png",s=10},
		[":"]={tex="sign_colon.png",s=1},
		[","]={tex="sign_comma.png",s=2},
		["."]={tex="sign_dot.png",s=1},
		["="]={tex="sign_equal.png",s=6},
		["!"]={tex="sign_ex.png",s=1},
		[">"]={tex="sign_great.png",s=5},
		["#"]={tex="sign_hashtag.png",s=6},
		["<"]={tex="sign_less.png",s=5},
		["-"]={tex="sign_minus.png",s=3},
		["+"]={tex="sign_plus.png",s=5},
		["%"]={tex="sign_proc.png",s=8},
		["?"]={tex="sign_question.png",s=5},
		['"']={tex="sign_quotes.png",s=3},
		["/"]={tex="sign_slash.png",s=5},
		["0"]={tex="sign_0.png",s=6},
		["1"]={tex="sign_1.png",s=2},
		["2"]={tex="sign_2.png",s=6},
		["3"]={tex="sign_3.png",s=4},
		["4"]={tex="sign_4.png",s=6},
		["5"]={tex="sign_5.png",s=4},
		["6"]={tex="sign_6.png",s=5},
		["7"]={tex="sign_7.png",s=5},
		["8"]={tex="sign_8.png",s=4},
		["9"]={tex="sign_9.png",s=6},
	},
	param2 = {
		wallmounted = {
			[0] = {x=1.57,y=0},
			[1] = {x=4.71,y=0},
			[2] = {x=0,y=4.71},
			[5] = {x=0,y=3.14},
			[3] = {x=0,y=1.57},
			[4] = {x=0,y=0},
		},
	},
}

asd = 0
minetest.register_chatcommand("a", {
	func = function(name, param)
		asd = tonumber(param)
	end
})

sign.to_texture=function(def)
	if not def and def.s then
		return ""
	end

	def.x = def.x or 100
	def.y = def.y or 50
	local x = 0
	local y = 0
	local text = "[combine:"..def.x.."x"..def.y

	for i=1,#def.s do
		local a = def.s:sub(i,i)
		local p = sign.characters[a]
		if p then
			if x >= def.x or a == "\n" then
				x = 0
				y = y +12
				if y >= def.y then
					break
				end
			end
			if p.tex then
				text = text ..":"..x..","..y.."="..p.tex
			end
			x = x + p.s + 1
		end
	end
	local c = ""
	if def.color and def.color ~= "" then
		local n = #def.color
		local color = def.color:lower()	
		if n == 3 or n == 4 or n == 6 or n == 8 then
			local chr = "0123456789abcdef"
			for i=1,n do
				if not chr:find(color:sub(i,i)) then
					goto nocolor
					break
				end
			end
			c = "^[colorize:#"..color
		end
		::nocolor::
	end

	text = (def.background and def.background.."^" or "") .. text .. c
	return #text > 1 and text or ""
end

--asd = {x=0,y=0,z=0}
--minetest.register_chatcommand("a", {
--	func = function(name, param)
--		local a = param.split(param," ")
--		asd = {x=tonumber(a[1]) or 0,y=tonumber(a[2]) or 0,z=tonumber(a[3]) or 0}
--	end
--})

minetest.register_entity("sign:text",{
	physical = false,
	pointable = false,
	--collisionbox = {0,0,0,0,0,0},
	visual = "mesh",
	mesh="map_map.obj",
	visual_size = {x=1,y=1},
	textures = {""},
	decoration=true,
	static_save = false,
	text=function(self,def)
		local t = sign.to_texture(def)
		self.object:set_properties({
			textures={t},
			visual_size = {x=def.size_x or 1,y=def.size_y or 1,z=1},
		})
		local x = 0
		local y = 0
		local pos = self.object:get_pos()
		local n = minetest.get_node(pos)
		local typ = default.def(n.name).paramtype2
		local p = sign.param2[typ]
		if not p then
			minetest.log("warning","Signs do not support "..typ.." nodes")
			return
		end
		local r = p[n.param2] or {x=0,y=0,z=0}
		local d = def.pos or 0


		self.object:set_rotation({x=r.x,y=r.y,z=0})
		local w = minetest.wallmounted_to_dir(n.param2)
		self.object:set_pos({x=pos.x+(w.x*d),y=pos.y+(w.y*d),z=pos.z+(w.z*d)})
	end,
	on_activate=function(self, staticdata)

	end,

})