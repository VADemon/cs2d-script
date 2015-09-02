menus = {
	[1] = {
		title = "Weapon Shop",
		items = {
			{"AK-47","$2500",function(id)
				if player(id,"money")>=2500 then
					parse("equip "..id.." 30")
					parse("setmoney "..id.." "..player(id,"money")-2500)
				else
					msg2(id,"You don't have enough money!") 
				end
			end},
			{"AWP","$3000",function(id)
				if player(id,"money")>=3000 then
					parse("equip "..id.." 35")
					parse("setmoney "..id.." "..player(id,"money")-3000)
				else
					msg2(id,"You don't have enough money!")
				end
			end},
			{"M4A1","$2600",function(id)
				if player(id,"money")>=2600 then
					parse("equip "..id.." 32")
					parse("setmoney "..id.." "..player(id,"money")-2600)
				else
					msg2(id,"You don't have enough money!")
				end
			end}
		},
	}
}

spages={{}}
pmenu={}

function unimenu(id,construct,m,p)
	if not spages[id] then spages[id]={} end
	if m~="current" then
		if construct then
			local custom
			if type(m)=="table" then
				custom=true
			else
				custom=false
			end
			pmenu[id]=m
			local paget
			if not custom then
				paget=math.ceil(#menus[m].items/7)
			else
				paget=math.ceil(#m.items/7)
			end
			for i=1,paget do
				if not custom then
					spages[id][i]=menus[m].title.." Page "..i.."@b,"
				else
					spages[id][i]=m.title.." Page "..i.."@b,"
				end
				for ii=1,7 do
					local sid = ii+(7*(i-1))
					if not custom then
						if menus[m].items[sid] then
							spages[id][i]=spages[id][i]..menus[m].items[sid][1].."|"..menus[m].items[sid][2]..","
						else
							spages[id][i]=spages[id][i]..","
						end
					else
						if m.items[sid] then
							spages[id][i]=spages[id][i]..m.items[sid][1].."|"..m.items[sid][2]..","
						else
							spages[id][i]=spages[id][i]..","
						end
					end
				end
				if i<paget then spages[id][i]=spages[id][i].."Next" end
				if i>1 then spages[id][i]=spages[id][i]..",Back" end
			end
		end
	end
	menu(id,spages[id][p])
end

addhook("menu","unimenuhook")
function unimenuhook(id,menu,sel)
	local p=tonumber(menu:sub(-1))
	if sel<8 and sel>0 then
		local s=sel+(7*(p-1))
		if type(pmenu[id])=="table" then
			pmenu[id].items[s][3](id)
		else
			menus[pmenu[id]].items[s][3](id)
		end
	else
		if sel==8 then
			unimenu(id,true,"current",p+1)
		elseif sel==9 then
			unimenu(id,true,"current",p-1)
		end
	end
end
