-- Tasermod for darijs1 :: http://unrealsoftware.de/profile.php?userid=92580
-- Requested in thread http://unrealsoftware.de/forum_posts.php?post=385648

-- STUN SCRIPT
if tasermod then
	print("WARNING: taserMod is already running!")
end

tasermod = {}
tasermod.player = {}
tasermod.timeMultiplier = {}
tasermod.damageMultiplier = {}

-- CONFIG
tasermod.taserWeapon = 34
tasermod.maxDistance = 96	-- NOT IMPLEMENTED in pixels, the effective distance of taser; doesn't work beyond this point
tasermod.stunDuration = 2000	-- duration of the stun in ms
tasermod.slownessDuration = 8500	-- total duration of slowness effect AFTER the stun

tasermod.minDamage = 1
tasermod.maxDamage = 25

tasermod.victimCanDie = true
tasermod.customkillMessage = "Taser" -- possible to add an image, check out http://www.cs2d.com/help.php?cat=server&cmd=customkill#cmd

tasermod.timeMultiplier[0] = 1.25	-- No Armor and Zombie Armor
tasermod.timeMultiplier[100] = 1	-- Kevlar
tasermod.timeMultiplier[201] = 0.95	-- LightArmor
tasermod.timeMultiplier[202] = 0.9	-- Armor
tasermod.timeMultiplier[203] = 0.80	-- HeavyArmor
tasermod.timeMultiplier[204] = 0.50	-- MedicArmor
tasermod.timeMultiplier[205] = 0.75	-- SuperArmor
tasermod.timeMultiplier[206] = 1	-- StealthSuit

tasermod.damageMultiplier[0] = 1	-- No Armor and Zombie Armor
tasermod.damageMultiplier[100] = 1	-- Kevlar
tasermod.damageMultiplier[201] = 1	-- LightArmor
tasermod.damageMultiplier[202] = 0.9	-- Armor
tasermod.damageMultiplier[203] = 0.85	-- HeavyArmor
tasermod.damageMultiplier[204] = 0.30	-- MedicArmor
tasermod.damageMultiplier[205] = 0.8	-- SuperArmor
tasermod.damageMultiplier[206] = 1.3	-- StealthSuit

-- END OF CONFIG
tasermod.stunSpeedmod = -30
tasermod.stepDuration = 60 --ms, duration between speedmod calculations. 3 Frames is a decent number, because CS2D doesn't support decimal places: eg 12.75 is 12

addhook("hit", "tasermod.hitPlayer")

function tasermod.hitPlayer(victimID, attackerID, weapon, hpdmg, armordmg, rawdmg)
	if weapon == tasermod.taserWeapon then
		if player(victimID, "team") == 1 and player(attackerID, "team") == 2 then	-- 1=T, 2=CT
			
			if tasermod.processDamage(victimID, attackerID) then
				msg("©040150210" .. player(attackerID, "name") .. " used his taser on ".. player(victimID, "name"))
				tasermod.setStun(victimID)
				
			end
			
			return 1	-- don't deal cs2d damage
		end
	end
end

function tasermod.getArmorTimeMultiplier(id)
	local armor = player(id, "armor")
	
	if tasermod.timeMultiplier[armor] then
		return tasermod.timeMultiplier[armor]
		
	elseif armor > 0 and armor < 100 then	-- for damaged kevlar and kevlar&helm
		return tasermod.timeMultiplier[100]
		
	else
		print("[TASERMOD] ERROR: (.getArmorTimeMultiplier): Unknown armor value of ".. armor)
	end
end

function tasermod.getArmorDamageMultiplier(id)
	local armor = player(id, "armor")
	
	if tasermod.damageMultiplier[armor] then
		return tasermod.damageMultiplier[armor]
		
	elseif armor > 0 and armor < 100 then	-- for damaged kevlar and kevlar&helm
		return tasermod.damageMultiplier[100]
		
	else
		print("[TASERMOD] ERROR: (.getArmorDamageMultiplier): Unknown armor value of ".. armor)
	end
end

function tasermod.processDamage(id, attackerID)
	local randomDamage = math.random(tasermod.minDamage, tasermod.maxDamage)
	local damage = tasermod.math_round(randomDamage * tasermod.getArmorDamageMultiplier(id))
	local victimHealth = player(id, "health")
	
	if victimHealth <= damage then	-- is the damage unacceptably high?
	
		if tasermod.victimCanDie then
			parse("customkill ".. attackerID .." ".. tasermod.customkillMessage .. " ".. id)
			
			return false
			
		else
			parse("sethealth ".. id .." ".. 1)	-- leave 1 hp
			
			return true
		end
		
	else
		parse("sethealth ".. id .." ".. victimHealth - damage)
		return true
	end
end

function tasermod.math_round(a)
     return math.floor(a+0.5)
end

function tasermod.setStun(id)
	if tasermod.player[id] == nil then
	
		tasermod.player[ id ] = {
			isStunned = true,
			originalSpeedmod = player(id, "speedmod"),
			currentSpeedmod = tasermod.stunSpeedmod,
			slownessTimeLeft = tasermod.slownessDuration,
			stepSize = math.abs((player(id, "speedmod") - tasermod.stunSpeedmod) / (tasermod.slownessDuration / tasermod.stepDuration))
		}
	
	elseif tasermod.player[id] and tasermod.player[id].isStunned then	-- @> protection against multiple shots
	
		freetimer("tasermod.onStunEnd", tostring(id))	-- remove timer for the previous shot, we'll start at time point 0 below
		freetimer("tasermod.slownessDecay", tostring(id))
		
		tasermod.player[ id ].	currentSpeedmod = tasermod.stunSpeedmod
		tasermod.player[ id ].	slownessTimeLeft = tasermod.slownessDuration
		tasermod.player[ id ].	stepSize = math.abs((tasermod.player[ id ].originalSpeedmod - tasermod.stunSpeedmod) / (tasermod.slownessDuration / tasermod.stepDuration))
	end
	
	parse("speedmod ".. id .." ".. tasermod.stunSpeedmod)
	timer(tasermod.stunDuration, "tasermod.onStunEnd", tostring(id))
end

function tasermod.onStunEnd(id)
	tasermod.slownessDecay(id)
end

-- Removes the stun effect
function tasermod.slownessDecay(id)
	local id = tonumber(id)
	
	if not player(id, "exists") then return nil end	-- player isn't on the server
	
	tasermod.player[id].currentSpeedmod = (tasermod.player[id].currentSpeedmod + tasermod.player[id].stepSize)
	
	if tasermod.player[id].currentSpeedmod >= tasermod.player[id].originalSpeedmod then	-- is the slowness over?
	
		parse("speedmod ".. id .." ".. tasermod.player[id].originalSpeedmod)
		msg2(id, "©040150210[TASERMOD] You have now fully recovered from the taser shot")
		
		tasermod.player[id] = nil
		
	else
		parse("speedmod ".. id .." ".. tasermod.math_round(tasermod.player[id].currentSpeedmod))
		
		timer(tasermod.stepDuration, "tasermod.slownessDecay", tostring(id))
	end
end