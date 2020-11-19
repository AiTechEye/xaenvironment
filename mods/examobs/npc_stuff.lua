examobs.npc = {
	conversations = {
		{keywords={"sorry","sry","my wrong"},
			response={"no problem"}},
		{random=true,keywords={"what is ","how old are "," you"," your"," age"},
			response={"i dont know"}},
		{random=true,keywords={"what are you","who are you","your name"},
			on_conversation=function(self,speaker,tex)
				if math.random(1,3) == 1 then
					self:say("you cant see my nametag?")
				else
					self:say("im "..self.storage.npcname .." and you?")
				end
			end},
		{keywords={"what","why"},
			dresponse={"yes","yeah","because i think so","as i said","because you said it"}},
		{keywords={"call you"},
			response={"?"}},
		{keywords={"i"," am","my"," me","im ","my"," me"},
			response={"not me","me too","ok","i dont think so","thats cool"}},
		{keywords={"?"},
			response={"what?"}},
		{keywords={"with what?"},
			response={"this"}},
		{keywords={"go to the spawn"},
			response={"whare is that?","where are spawn?","what spawn?","what is that?"}},
		{min_chat_found=2,keywords={"tp","teleport"},
			response={"im not a taxi!","admin, @ want teleport"}},
		{keywords={"grant","grant me","grantme","all privs"},
			response={"admin, @ asks for privs!","no im not admin","no i will be moderator next time, me!!","no","ban him!"},
			on_conversation=function(self,speaker,text)
				local pos = speaker:get_pos()
				if math.random(1,2)==1 then minetest.chat_send_all("*** " .. examobs.get_name(speaker) .. " has been granted the privilege: Noob") end
			end},
		{keywords={"can you help me","i will build a house, any help?"},
			response={"with?","with what?"}},
		{random=true,keywords={"hi","hello"},
			response={"hi","hello","hey"}},
		{min_chat_found=3,keywords={"you","like","color"},
			response={"what is color","give me that","i want it","i want to taste that","i dont know, but can you give me one?"}},
		{keywords={"team"},
			on_conversation=function(self,speaker,text)
				self:say(self.team)
			end},
		{keywords={"what are you doing"},
			response={"what do think it locks like","im not a technological support"}},
		{keywords={"where are you"},
			on_conversation=function(self,speaker,tex)
				self:say(minetest.pos_to_string(self.object:get_pos()))
			end},
		{max_chat_length=1,keywords={"him","run","ahh","no","aaa","hey","help"},response={"who?","what?"}},
		{random=true,keywords={"can i live with you?","friends?","folow me","come"},
			response={"ok"},
			on_conversation=function(self,speaker,text)
				self.folow=speaker
			end},
		{random=true,keywords={"do you","want"},
			response={"yes","yeah","just give me it"}},
		{keywords={"who want to mine with me?"},response={"yes","ok","where are you?","no","why?"}},
	},
	expressions = {
		folow = {"ok","what?","ok, but then?","so?"},
		flee = {"AHHH NOOB","im sorry!!!!","run","RUN!!","AHH!!","nooo","help!","HELP MEEE","ohh no","you again","hey be cool!","need something?","i dont have enough","STOP HIM!!!","plz stop him!"},
		punched = {"ow","ah","ahhh","ohha","it hurts","A","stop it!","aaaa"},
		hurt = {"it hurts","ow","ah","help","im dieing","save me!","help plz!???","HELLLLLLP","NOOO"},
		fight = {"@ stay!","ohh your litle","ohh your litle @","hey you, come here","come here @","please come here... i will give you a surprise!","wait","stay","you are dead","i want to talk to you","one by one","i will kick your","ya r stinking","ban","please ban him!","this is your end of life!","i will kick your and chew bubblegum!"},
		eat = {"i needed that","are here some more? ","thats nice","cool","nice","lovely"},
		kill = {"eliminated","feel good, and stay there!","HA HA!","XD","I got him","Got ya!", "c ya","see ya","loser","u r 2 bad","lol","yeah","..."},
		nagging = {"no way!","stop it!","go away","shut up","stop nagging"},
		too_near = {"what are you staring at?","what are you looking for?","waiting for something??","you are disgust me","you are interferes me","turn away your face!","???","?","-_-","what are you doing?","what you want?"},
		seen_death = {"murder!","criminal!","stop him","get him!","killer","betrayer!","hey look that","what r u doing?"},
		fall = {"AHHH","aaaaaaaaa","ooooo","hhaaaaa","waaaaa","njaaaaa","?","?????","!??","DOH","Hey im flying!","WEEEE"},
		floating = {"Hey, im flying!","Hej, hey im flying!","whoo!?","weeeee","look at me, im flying!","cool","help!","plz let me down!","aaaa","i want to fly!","this guy is flying!"},
		leave = {"LAAAAAAAAG!","lag and goodbye","borring server, bye","nothing to mine","can't find a place to mine here i'm leaving!","this is too laggy for me! bye"},
		raining = {"not again :´(","just hate rain","i cant see anything!","im wet!","sure again DX"},
		monster = {"ahh a @!","a @ run!","get it!","just another @","grant me privs so i can ban it","kill it"},
		mob = {"look that @","is that a @?","move it away","can some one take the @ away?","hello litle @","@"},
		random = {"i can't believe you just touched that!","pizza","you guys looks stuped as i used to be, oh wait..","we all are kings of nothing","folow me","just another noob","its not safe here","lol this is so much","look in the chest","me want blocks","hi guys","back","i have skills in buildning","go to the spawn","tp to me","tp me to","grant me eveything","i want be admin","go to the spawn","can you help me","i will build a house, any help?","yumm","go to the spawn","plz protect this to me","this is hard!","borring","who are you","im hungry","what are you doing?","i need a.. cant find it","thats cool","what are your name","hey, can someone give me?","this is creepy",":D","how are you",":)",":(","what are this",".","hey you","k","no","zzz","did someone hear that?","i want a pet","lag","afk","folow me"},
	},

	list = {},
}

examobs.on_chat=function(pos,name,msg,self,object)
	local m = #msg.split(msg," ")

	for index,ob in pairs(examobs.npc.list) do
		local en = ob:get_luaentity()

		if not en then
			table.remove(examobs.npc.list,index)
			goto continue
		elseif self and self.examob == en.examob then
			goto continue
		end

		for i,v in pairs(examobs.npc.conversations) do
			local c = v.chance or 3
			if math.random(1,c) == 1 and (not v.max_chat_length or m <= v.max_chat_length) then
				local words = 0
				local min_words = v.min_chat_found or 0
				for k,w in pairs(v.keywords) do
					if msg:find(w) then
						words = words + 1
						if words >= min_words then
							break
						end
					end
				end

				if words > 0 then
					if v.response then
						local r = math.random(1,#v.response)
						local res = v.response[r]:gsub("@",name)
						en:say(res)
					end
					if v.on_conversation then
						v.on_conversation(en,object,msg)
					end
					return
				end
			end
		end
		::continue::
	end
end

examobs.npc_setup=function(self)
	if not self.storage.npcname then
		examobs.genname(self)
	end
	self.last_spoken = ""

	if not (self.dying or self.dead) then
		self.object:set_properties({nametag=self.storage.npcname,nametag_color="#FFF"})
	end

	self.say=function(self,text,addressed)
		local pos=self:pos()
		examobs.last_spoken=text
		addressed = addressed or ""
		for _,player in ipairs(minetest.get_connected_players()) do
			if vector.distance(player:get_pos(),pos) < 50 then
				minetest.chat_send_player(player:get_player_name(), "<" .. self.storage.npcname .."> " .. text:gsub("@",addressed))
			end
		end
		examobs.on_chat(pos,self.storage.npcname,text,self,self.object)
	end

	local s = self.step
	self.step=function(self)
		if s(self) then
			return
		end

		local p = self:pos()
		local addressed
		if math.random(1,100) == 1 then
			local exp

			if self.folow or self.folow_jset then
				if self.folow and not self.folow_jset then
					self.folow_jset = true
					exp = "folow"
				elseif not self.folow then
					self.folow_jset = nil
				end
			end
			if self.flee then
				exp = "flee"
			elseif self.fight then
				exp = "fight"
				addressed = examobs.get_name(self.fight)
			elseif self.object:get_velocity().y < -5 then
				exp = "fall"
			elseif default.defpos(apos(p,-1),"walkable") == false and self.object:get_velocity().y == 0 then
				exp = "floating"
			else
				self.nagging = (self.nagging or math.random(1,100)) -1
				if self.nagging < 1 then
					self.nagging = nil
					exp = "nagging"
					return
				end
				if math.random(1,3) == 1 then
					for _, ob in pairs(minetest.get_objects_inside_radius(p, 30)) do
						local en = ob:get_luaentity()
						local d = vector.distance(p,ob:get_pos())
						if en and en.examob and en.type == "npc" and en.examob ~= self.examob and examobs.visiable(self,ob) then
							if d <= 7 and examobs.gethp(ob) > 0 then
								self.too_near = (self.too_near or math.random(1,100)) -1
								if self.too_near < 1 then
									self.too_near = nil
									exp = "too_near"
									examobs.lookat(self,ob)
									break
								end
							elseif examobs.gethp(ob) < 1 then
								exp = "seen_corpse"
								examobs.lookat(self,ob)
								break
							elseif en.dying and en.last_punched_by then
								self.fight = self.last_punched_by
								exp = "seen_death"
								examobs.lookat(self,ob)
								break
							end
						elseif en and en.examob then
							addressed = examobs.get_name(ob)
							if en.type == "monster" then
								exp = "monster"
								if en.hp_max > 25 then
									self.flee = ob
								end
							else
								exp = "mob"
							end
							examobs.lookat(self,ob)
							break
						end
					end
				end

				if exp == nil and math.random(1,10) == 1 then
					local pos = self:pos()
					for i, w in pairs(weather.currweather) do
						if vector.distance(pos,w.pos) <= w.size and w.bio == 1 then
							exp = "raining"
							break
						end
					end
				end
				exp = exp or "random"
			end
			examobs.on_expression(self,exp,addressed)
		end
	end

	self.on_spawn=function(self)
		table.insert(examobs.npc.list,self.object)
	end
	self.on_load=function(self)
		table.insert(examobs.npc.list,self.object)
	end
end

examobs.on_expression=function(self,key,addressed)
	local e = examobs.npc.expressions[key]
	local x = e[math.random(1,#e)]:gsub("@",(addressed or ""))
	self:say(x)
end

examobs.get_name=function(ob)
	local en = ob:get_luaentity()
	return ob and ob:is_player() and ob:get_player_name() or en and en.npcname or en and en.name:sub(en.name:find(":")+1,-1):gsub("_"," ") or "guy"
end

examobs.genname=function(self)
	local r=math.random(3,15)
	local s=""
	local rnd
	for i=1, r do
		rnd=math.random(1, 4)
		if rnd==1 then
			s=s .. string.char(math.random(97, 122))
		elseif rnd==2 then
			s=s .. string.char(math.random(48, 57))
		else
			s=s .. string.char(math.random(65, 90))
		end
	end
	self.storage.npcname = s
end

examobs.chat_find_item=function(self,msg)
	local it=msg.split(msg," ")
	for i, s in pairs(it) do
		local it=minetest.registered_items[s]
		if it then
			return it
		end
	end
end

minetest.register_on_chat_message(function(name, message)
	local p = minetest.get_player_by_name(name)
	minetest.after(0,function(p,name,message)
		if p then
			examobs.on_chat(p:get_pos(),name,message,nil,p)
		end
	end,p,name,message)
end)