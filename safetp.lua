-- Godmode after teleporting with Entity Teleporter
-- http://unrealsoftware.de/forum_posts.php?post=407125

safetp_data = {
	duration = 3,
	cooldown = 10,
	indicatorimg = "gfx/safetp_indicator2.png",
	invincible = {},	-- true or false, if the godmode is ON/OFF
	timeon = {},	-- used to calculate cooldown
	timeoff = {},	-- used to disable effect
	image = {},	-- used for indication image
	
}



addhook("hit", "safetp_ondmg")
function safetp_ondmg(victim, attacker)
	if safetp_data.invincible[victim] and attacker~=0 then	-- lets not neutralize damage from non-players
		--msg("os clock= ".. os.clock() .." -- timeoff: ".. safetp_data.timeoff[victim])
		if safetp_data.timeoff[victim] > os.clock() then
			msg2(attacker, player(victim, "name").. " is still in godmode after teleport!")
			return 1	-- dont do damage
		else
			safetp_data.invincible[victim] = false	-- disable godmode
			--msg("Player :".. player(victim, "name").. " disabled godmode!")
		end
	end
end

addhook("movetile", "safetp_movetile")

function safetp_movetile(id, tilex, tiley)
	-- teleport id = 70, typename: "Func_Teleport"
	--msg(id .. ": ".. tilex ..", ".. tiley .." (".. tostring(entity(tilex, tiley, "typename")) ..")")
	if entity(tilex, tiley, "type") == 70 then
		local clock = os.clock()
		
		if safetp_data.timeon[id] == nil or (clock - safetp_data.timeon[id] >= safetp_data.cooldown) then
			safetp_data.invincible[id] = true
			
			safetp_data.timeon[id] = clock	-- last invincibility started at
			safetp_data.timeoff[id] = clock + safetp_data.duration	-- should end after this time
			
			-- rotate with player, dont draw under fog of war, draw above player
			safetp_data.image[id] = image(safetp_data.indicatorimg, 1, 0, id+200)
			tween_alpha(safetp_data.image[id], safetp_data.duration * 0.875 * 1000, 0.4)
			timer(safetp_data.duration * 1000, "freeimage", safetp_data.image[id])
		end
	end
end