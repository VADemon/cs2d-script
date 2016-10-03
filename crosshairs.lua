crosshairs = {}
crosshairs.tick = 0
crosshairs.pingboundary = 200	-- players with 200+ ping are considered slow
crosshairs.slowplayersticks = 5	-- how often to draw for slow players? 5 = every 5th frame
crosshairs.data = {
	player = {
		--[[
		[id] = {
			images = {
				[key] = {id, isvisible, lastx, lasty}
			}
		}
		]]
	}
}

-- Calculate a truth table for this. Only works with current teams: Spec+T+CT+VIP.
-- Spectators are "neutral"
function crosshairs.isfriendlyneutral(team1, team2)
	local product = team1 * team2
	--if product ~= 3 and product ~= 2 then
	if game("sv_gamemode")~= 1 and (product < 2 or product > 3) then	-- is not deathmatch
		return true
	end
end

function crosshairs.isfriendly(team1, team2)
	local product = team1 * team2
	--if product ~= 3 and product ~= 2 then
	if game("sv_gamemode")~= 1 and (product == 1 or product > 3) then	-- is not deathmatch
		return true
	end
end

addhook("leave", "crosshairs.leave")
function crosshairs.leave(id)
	-- own images
	if crosshairs.data.player[id] and crosshairs.data.player[id].images then
		for k, imgdata in pairs(crosshairs.data.player[id].images) do
			freeimage(imgdata[1])
		end
		
		crosshairs.clearown(id)	
		
		crosshairs.data.player[id] = nil
	end
end

addhook("team", "crosshairs.teamchange")	-- all previously shown images must be removed
function crosshairs.teamchange(id)
	if crosshairs.data.player[id] and crosshairs.data.player[id].images then
		for k, imgdata in pairs(crosshairs.data.player[id].images) do
			freeimage(imgdata[1])
			crosshairs.data.player[id].images[k] = nil
		end
	end
end

addhook("team", "crosshairs.clearown")
-- clear own crosshair for other players
function crosshairs.clearown(id)
	for i = 1, 32 do
		if crosshairs.data.player[i] and crosshairs.data.player[i].images[id] then
			freeimage(crosshairs.data.player[i].images[id][1])
			crosshairs.data.player[i].images[id] = nil
		end
	end
end

addhook("die", "crosshairs.die")
function crosshairs.die(id)
	-- clear ghost image because we cannot retrieve spectator's position for calculations
	if crosshairs.data.player[id].images.ghost then
		freeimage(crosshairs.data.player[id].images.ghost[1])
		crosshairs.data.player[id].images.ghost = nil
	end
	
	crosshairs.clearown(id)
end

addhook("say", "crosshairs.say")
addhook("sayteam", "crosshairs.say")
function crosshairs.say(id, txt)
	txt = string.lower(txt)
	
	if txt == "!crosshairs ghost" then
		crosshairs.data.player[id].settings.ghost = not crosshairs.data.player[id].settings.ghost
		msg2(id, "©240240240Crosshair ghost was toggled!")
		
		if crosshairs.data.player[id].images.ghost then
			freeimage(crosshairs.data.player[id].images.ghost[1])
			crosshairs.data.player[id].images.ghost = nil
		end
	
	elseif txt == "!crosshairs seeteam" then
		crosshairs.data.player[id].settings.seeteam = not crosshairs.data.player[id].settings.seeteam
		msg2(id, "©240240240Team crosshairs were toggled!")
		
		for k, imgdata in pairs(crosshairs.data.player[id].images) do	--dirty, it removes ALL shown images instead of only team images
			freeimage(imgdata[1])
			crosshairs.data.player[id].images[k] = nil
		end
	
	elseif txt=="!crosshairs" or txt=="!crosshairs help" or txt=="!crosshair" or txt=="!pointer" then
		msg2(id, "©240240240!crosshairs ghost  -  toggles your cursor ghost")
		msg2(id, "©240240240!crosshairs seeteam  -  show your team's cursors?")
	end
end

--[[addhook("always", "temphud")
function temphud()
	local living = player(0, "table")
	for i = 1, #living do
		parse('hudtxt '.. (40 + i) ..' "'.. living[i] ..': '..player(living[i], 'x')..'|'..player(living[i], 'y')..'" 320 '.. (100+i*15) ..' 0')
	end
end]]

addhook("always", "crosshairs.always")
function crosshairs.always()
	if crosshairs.tick == crosshairs.slowplayersticks then	-- 5 ticks = ms100
		crosshairs.tick = 0
	else
		crosshairs.tick = crosshairs.tick + 1
	end
	
	local living = player(0, "tableliving")
	for i = 1, #living do
		-- if player's ping is bad, draw only every 5th frame (100ms)
		if player(living[i], "ping") < crosshairs.pingboundary or crosshairs.tick == crosshairs.slowplayersticks then
			reqcld(living[i], 2)
		end
	end
end

addhook("clientdata", "crosshairs.clientdata")
function crosshairs.clientdata(id, mode, x, y)
	if id==0 then	-- well, that happened. and does so probably more often on real servers
		return
	end
	
	if not crosshairs.data.player[id] then
		crosshairs.data.player[id] = {
			images = {},
			settings = {
				ghost = false,		-- Ghost of your own cursor?
				showtoteam = true,	-- Show own cursor to team?
				seeteam = true		-- See own team's cursors?
			}
		}
	end
	
	-- position on map
	if mode == 2 and player(id, "team")~=0 and player(id, "health")~=0 then
		if crosshairs.data.player[id].settings.ghost then
			local relx, rely = math.ceil(x - player(id, "x") + 322), math.ceil(y - player(id, "y") + 242)
			crosshairs.draw(id, 1, relx, rely)
		end
		
		if crosshairs.data.player[id].settings.showtoteam then
			-- NIY
			crosshairs.draw(id, 2, x, y)
		end
	end
end


function crosshairs.draw(id, crtype, x, y)
	
	-- shadow
	if crtype == 1 then
		if not crosshairs.data.player[id].images.ghost then
			crosshairs.data.player[id].images.ghost = {nil, true, x, y}
			crosshairs.data.player[id].images.ghost[1] = image("<spritesheet:gfx/pointer.bmp:23:23:<m>", x, y, 2, id)	-- <spritesheet:gfx/pointer/pointer.bmp:23:23:<m>
			
			imagecolor(crosshairs.data.player[id].images.ghost[1], 150, 200, 150)
			imagealpha(crosshairs.data.player[id].images.ghost[1], 0.5)
			imageblend(crosshairs.data.player[id].images.ghost[1], 1)
			
		elseif (crosshairs.data.player[id].images.ghost[3] ~= x) or (crosshairs.data.player[id].images.ghost[4] ~= y) then
			imagepos(crosshairs.data.player[id].images.ghost[1], x, y, 0)
		end
		
		crosshairs.data.player[id].images.ghost[3], crosshairs.data.player[id].images.ghost[4] = x, y
	
	-- friendly crosshair, only draw to team
	elseif crtype == 2 then
		local team = player(id, "team") 
		
		local playertable = player(0, "table")
		
		for i = 1, #playertable do
			local tid = playertable[i]
			
			if id~=tid and crosshairs.isfriendlyneutral(team, player(tid, "team")) and crosshairs.data.player[tid] and crosshairs.data.player[tid].settings.seeteam --[[and 
				(player(tid, "ping") < crosshairs.pingboundary or crosshairs.tick == crosshairs.slowplayersticks)]] then
				
				local relx, rely = math.ceil(x - player(tid, "x") + 320), math.ceil(y - player(tid, "y") + 240)
				
				-- Is not outside of screen? Then draw
				if not (relx < -20 or relx > 660 or rely < -20 or rely > 500) then 
					if not crosshairs.data.player[tid].images[id] then
						crosshairs.data.player[tid].images[id] = {nil, true, relx, rely}
						crosshairs.data.player[tid].images[id][1] = image("<spritesheet:gfx/pointer.bmp:23:23:<m>", relx, rely, 2, tid)	-- <spritesheet:gfx/pointer/pointer.bmp:23:23:<m>
						imageframe(crosshairs.data.player[tid].images[id][1], 3)
						--imagecolor(crosshairs.data.player[tid].images[id][1], 255, 255, 255)
						imagealpha(crosshairs.data.player[tid].images[id][1], 0.8)
						--imageblend(crosshairs.data.player[tid].images[id][1], 1)
						crosshairs.data.player[tid].images[id][3], crosshairs.data.player[tid].images[id][4] = relx, rely
						
					elseif (crosshairs.data.player[tid].images[id][3] ~= relx) or (crosshairs.data.player[tid].images[id][4] ~= rely) then
						imagepos(crosshairs.data.player[tid].images[id][1], relx, rely, 0)	-- set rot to 90 for debuggingdd
						crosshairs.data.player[tid].images[id][3], crosshairs.data.player[tid].images[id][4] = relx, rely
						--tween_rotate(crosshairs.data.player[tid].images[id][1], 100, 0)
					end
					
					
					
					-- make visible again (if it was previously hidden)
					if crosshairs.data.player[tid].images[id][2] == false then
						imagealpha(crosshairs.data.player[tid].images[id][1], 0.8)
						crosshairs.data.player[tid].images[id][2] = true
					end
					
				-- make invisible
				elseif crosshairs.data.player[tid].images[id] and crosshairs.data.player[tid].images[id][2] == true then
					imagealpha(crosshairs.data.player[tid].images[id][1], 0)
					crosshairs.data.player[tid].images[id][2] = false		
				end
			end
		end
	end
end