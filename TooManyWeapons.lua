if TMW then print("©255000000[Warning] TooManyWeapons was loaded before!") end
TMW = {}

-- reqcld2 by EnderCrypt :: http://unrealsoftware.de/files_show.php?file=15156
TMW.reqcld3_data = {}
TMW.reqcld3_data.requests = {}
-- VADemon > Updated 18.11.2014 to support reqcld optional parameters
function TMW.reqcld3(id, mode, reqcld_parameter, func, custom_parameter) -- custom_parameter is optional, func gets called with that parameter
	if not (type(func) == "function") then
		print("©255000000error in TMW.reqcld3: MISSING ARGUMENT: callback function (TMW.reqcld3(id, mode, reqcld data parameter, func [,custom parameter]))")
		return 1
	end

	TMW.reqcld3_data.requests[#TMW.reqcld3_data.requests+1] = {
		["id"]	 = id,
		["mode"] = mode,
		["func"] = func,
		["reqcld_parameter"] = reqcld_parameter,
		["custom_parameter"] = custom_parameter
	}
	
	reqcld(id, mode, reqcld_parameter)
end

function TMW.reqcld3_data.clientdata(id,mode,x,y)
	i = 0
	while (i < #TMW.reqcld3_data.requests) do
		i = i + 1
		if (id == TMW.reqcld3_data.requests[i].id) and (mode == TMW.reqcld3_data.requests[i].mode) then
			TMW.reqcld3_data.requests[i].func(id,x,y,TMW.reqcld3_data.requests[i].custom_parameter)
			TMW.reqcld3_data.requests[i] = TMW.reqcld3_data.requests[#TMW.reqcld3_data.requests]
			TMW.reqcld3_data.requests[#TMW.reqcld3_data.requests] = nil
			break
		end
	end
end
--- END

-- TooManyWeapons
addhook("say", "TMW.say")
addhook("sayteam", "TMW.say")
addhook("startround_prespawn", "TMW.startround_prespawn")
-- See TMW.enableHooks() which are only enabled when needed

TMW.wpnList = {}
TMW.unequipable = 	{-- items that can't be given via equip command
--	[item ID] = unequipable?
}

TMW.highlightImageRes = "gfx/sprites/block.bmp"
TMW.wpnListImageRes = "gfx/toomanyweapons/weaponlist_v2.png"

TMW.WPNLIST_X1 = 1
TMW.WPNLIST_Y1 = 2
TMW.WPNLIST_X2 = 3
TMW.WPNLIST_Y2 = 4
TMW.WPNLIST_NAME = 5
TMW.WPNLIST_ENABLED = 6
TMW.WPNLIST_ITEMS = 7

TMW.PNODE_OPENMENU = -1
TMW.PNODE_EQUIPOTHER = -2

do
	local list = {}
			--	x1,y1	x2,y2	name	enabled		{equip IDs}
	list[1] = { 2, 4, 126, 22,	"Pistols",	true, {1, 2, 3, 4, 5, 6}}
	list[2] = { 20, 28, 113, 41,	"USP",	true, {1}}
	list[3] = { 20, 42, 113, 56,	"Glock",	true, {2}}
	list[4] = { 20, 57, 113, 69,	"Deagle",	true, {3}}
	list[5] = { 20, 70, 113, 82,	"P228",		true, {4}}
	list[6] = { 20, 83, 113, 96,	"Elite",	true, {5}}
	list[7] = { 20, 97, 113, 110,	"Five-Seven",	true, {6}}
	
	list[8] = { 2, 120, 126, 139,	"Rifles",	true, {30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 91}}
	list[9] = { 7, 145, 120, 158,	"AK-47",	true, {30}}
	list[10] = { 7, 159, 120, 172,	"SG552",	true, {31}}
	list[11] = { 7, 173, 120, 186, 	"M4A1",		true, {32}}
	list[12] = { 7, 187, 120, 200, 	"AUG",		true, {33}}
	list[13] = { 7, 201, 120, 214, 	"Scout",	true, {34}}
	list[14] = { 2, 215, 120, 228, 	"AWP",		true, {35}}
	list[15] = { 7, 229, 120, 242,	"G3SG1",	true, {36}}
	list[16] = { 7, 243, 120, 256,	"SG550",	true, {37}}
	list[17] = { 7, 257, 120, 270,	"Galil",	true, {38}}
	list[18] = { 7, 271, 120, 284,	"Famas",	true, {39}}
	list[19] = { 7, 285, 120, 300,	"FN F2000",	true, {91}}
	
	list[20] = { 145, 5, 271, 24,	"Shotguns",	true, {10, 11}}
	list[21] = { 142, 28, 255, 41,	"M3",		true, {10}}
	list[22] = { 142, 42, 255, 55,	"XM1014",	true, {11}}
	
	list[23] = { 152, 62, 271, 80,	"Submachine Guns",	true, {20, 21, 22, 23, 24}}
	list[24] = { 149, 82, 245, 97,	"MP5",	true,	{20}}
	list[25] = { 149, 98, 245, 111,	"TMP",	true,	{21}}
	list[26] = { 149, 112, 245, 125,	"P90",	true,	{22}}
	list[27] = { 149, 126, 245, 139,	"MAC-10",	true,	{23}}
	list[28] = { 149, 140, 245, 153,	"UMP-45",	true,	{24}}
	
	list[29] = { 157, 162, 271, 183,	"Explosives",	true,	{51, 52, 53, 54, 72, 73, 75, 76, 77, 86, 87, 89}}
	list[30] = { 161, 185, 274, 199,	"HE",	true, {51}}
	list[31] = { 161, 200, 274, 213,	"Flashbang",	true, {52}}
	list[32] = { 161, 214, 283, 227,	"Smoke Grenade",	true, {53}}
	list[33] = { 161, 228, 267, 240,	"Flare",	true, {54}}
	list[34] = { 161, 241, 267, 254,	"Gas Grenade",	true, {72}}
	list[35] = { 156, 255, 283, 271,	"Molotov Cocktail",	true, {73}}
	list[36] = { 161, 272, 272, 285,	"Snowball",	true, {75}}
	list[37] = { 161, 286, 272, 299,	"Air Strike",	true, {76}}
	list[38] = { 161, 300, 272, 313,	"Mine",	true, {77}}
	list[39] = { 161, 314, 272, 327,	"Gut Bomb",	true, {86}}
	list[40] = { 155, 328, 272, 341,	"Laser Mine",	true, {87}}
	list[41] = { 157, 342, 272, 362,	"Satchel Charge",	true, {89}}
	
	list[42] = { 305, 4, 443, 23,	"Equipment",	true,	{41, 56, 59, 60, 61, 62}}
	list[43] = { 305, 24, 438, 48,	"Tactical Shield",	true, {41}}
	list[44] = { 315, 50, 438, 63,	"Defuse Kit",	true,	{56}}
	list[45] = { 305, 64, 438, 77,	"Night Vision",	true,	{59}}
	list[46] = { 305, 76, 438, 94,	"Gas Mask",	true,	{60}}
	list[47] = { 305, 95, 445, 108,	"Primary Ammo",	true,	{61}}
	list[48] = { 305, 109, 451, 122,	"Secondary Ammo",	true,	{62}}
	
	list[49] = { 309, 133, 443, 151,	"Melee",	true,	{50, 69, 74, 78, 85}}
	list[50] = { 315, 155, 417, 168,	"Knife",	true,	{50}}
	list[51] = { 315, 169, 417, 185,	"Machete",	true,	{69}}
	list[52] = { 315, 186, 417, 201,	"Wrench",	true,	{74}}
	list[53] = { 315, 202, 417, 220,	"Claw",	true,	{78}}
	list[54] = { 307, 221, 417, 238,	"Chainsaw",	true,	{85}}
	
	list[55] = { 303, 250, 443, 270,	"Heavy",	true,	{40, 45, 46, 47, 48, 49, 88, 90}}
	list[56] = { 301, 271, 417, 288,	"M249",	true,	{40}}
	list[57] = { 303, 289, 417, 303,	"Laser",	true,	{45}}
	list[58] = { 303, 304, 431, 328,	"Flamethrower",	true,	{46}}
	list[59] = { 283, 329, 431, 345,	"RPG Launcher", true,	{47}}
	list[60] = { 303, 345, 442, 360,	"Rocket Launcher",	true,	{48}}
	list[61] = { 303, 361, 451, 375,	"Grenade Launcher",	true,	{49}}
	list[62] = { 303, 376, 435, 394,	"Portal Gun",	true,	{88}}
	list[63] = { 291, 395, 435, 411,	"M134",	true,	{90}}
	
	list[64] = { 480, 3, 608, 22,	"Miscellaneous",	true,	{--[[55, 63,]] 64, 65, 66, 67, 68, --[[70, 71]] }}
	list[65] = { 474, 23, 605, 43,	"Bomb",	false,	{55}}
	list[66] = { 474, 44, 610, 62,	"Planted Bomb",	false,	{63}}	-- cannot be equipped under any circumstances!
	list[67] = { 474, 64, 605, 83,	"Medikit",	true,	{64}}
	list[68] = { 474, 84, 605, 102,	"Bandage",	true,	{65}}
	list[69] = { 474, 103, 605, 121,	"Coins",	true,	{66}}
	list[70] = { 474, 122, 605, 139,	"Money",	true,	{67}}
	list[71] = { 474, 140, 605, 156,	"Gold",	true,	{68}}
	list[72] = { 474, 157, 595, 172,	"Red Flag",	false,	{70}}
	list[73] = { 474, 173, 595, 188,	"Blue Flag",	false,	{71}}
	
	list[74] = { 480 , 198, 591, 217,	"Armor",	false, {57, 58, 79, 80, 81, 82, 83, 84}}
	list[75] = { 474, 218, 605, 238,	"Kevlar",	true,	{57}}
	list[76] = { 474, 239, 605, 262,	"Kevlar & Helm",	true, {58}}
	list[77] = { 474, 263, 605, 283,	"Light Armor",	true, {79}}
	list[78] = { 474, 284, 605, 305,	"Armor",	true,	{80}}
	list[79] = { 474, 306, 605, 329,	"Heavy Armor",	true,	{81}}
	list[80] = { 474, 330, 605, 352,	"Medic Armor",	true,	{82}}
	list[81] = { 474, 353, 605, 377,	"Super Armor",	true,	{83}}
	list[82] = { 474, 378, 605, 401,	"Stealth Suit",	true,	{84}}
	
	
	TMW.wpnList = list
	
	TMW.unequipable[56] = true
	TMW.unequipable[59] = true
	TMW.unequipable[60] = true
	TMW.unequipable[63] = true
	TMW.unequipable[70] = true
	TMW.unequipable[71] = true
	
end

function TMW.INIT_tables()
	TMW.enabledPlayersCount = 0
	TMW.enabledPlayers = {
		-- [k] = bool
	}
	
	TMW.equipTarget = {
		-- [initiator playerID] = [target PlayerID]	-- nil if (key == value)
	}
	
	TMW.selectedAction = {
		-- [id] = number	| -1 = exit, >0 = give item
	}
	
	TMW.images = {
		highlight = {
			-- [id] = imageID
		},
		wpnList = {},
		close = {}
	}
end
TMW.INIT_tables()

if permissions then	-- Permissions plugin installed?
	TMW.permission_check = function (id, wpnListNumber, hidePermissionDeniedMessage)
		if wpnListNumber == TMW.PNODE_OPENMENU then	-- check general TMW permission
			return permissions.check(id, "toomanyweapons.menu")
		
		elseif wpnListNumber == TMW.PNODE_EQUIPOTHER then
			return permissions.check(id, "toomanyweapons.equipother")
		end
		--print("Checking for ", "toomanyweapons.weapon." .. string.lower(TMW.wpnList[wpnListNumber][5]))
		return permissions.check(id, "toomanyweapons.weapon." .. string.lower( TMW.wpnList[wpnListNumber][5]:gsub("%s", "_") ), hidePermissionDeniedMessage)
	end
else
	TMW.permission_check = function (id, wpnListNumber)
		local adminList = {1, 7844}		-- ADD YOUR ADMIN USGN HERE
		
		for _, usgn in pairs(adminList) do
			if player(id, "usgn") == usgn then
				return true
			end
		end
		
		msg2(id, "©255255255[TooManyWeapons] You aren't allowed to either use TMW or equip this item!")
		return false
	end
end

function TMW.enablePlayer(id)
	if not TMW.enabledPlayers[ id ] then	-- is GUI for this player disabled?
	
		TMW.enabledPlayersCount = TMW.enabledPlayersCount + 1
		TMW.enabledPlayers[ id ] = true
		
		if TMW.enabledPlayersCount == 1 then	-- enable only once; once there's at least 1 player
			TMW.enableHooks()
		end
		
		return true
	end
end

function TMW.disablePlayer(id)
	if TMW.enabledPlayers[ id ] then	-- is GUI for this player enabled?
		
		TMW.enabledPlayersCount = TMW.enabledPlayersCount - 1
		TMW.enabledPlayers[ id ] = nil
		
		if TMW.enabledPlayersCount == 0 then
			TMW.disableHooks()
		end
		
		return true
	end
end

function TMW.enableHooks()
	addhook("ms100", "TMW.GUI_update")
	addhook("attack", "TMW.execute")
	addhook("leave", "TMW.leave")
	addhook("clientdata","TMW.reqcld3_data.clientdata")
	addhook("die", "TMW.death")
end

function TMW.disableHooks()
	freehook("ms100", "TMW.GUI_update")
	freehook("attack", "TMW.execute")
	freehook("leave", "TMW.leave")
	freehook("clientdata","TMW.reqcld3_data.clientdata")
	freehook("die", "TMW.death")
end

function TMW.GUI_open(id, targetID)
	if not TMW.enablePlayer(id) then return end
	if targetID and targetID ~= id then
		TMW.equipTarget[id] = targetID
	end
	
	TMW.images.wpnList[ id ] = image(TMW.wpnListImageRes, 320, 240, 2, id)
	TMW.selectedAction[ id ] = 0
end

function TMW.GUI_close(id)

	if not TMW.disablePlayer(id) then return end
	TMW.equipTarget[id] = nil
	TMW.selectedAction[ id ] = 0
	
	if TMW.images.wpnList[ id ] then
		freeimage(TMW.images.wpnList[ id ])
		TMW.images.wpnList[ id ] = nil
	end
		
	if TMW.images.highlight[ id ] then
		freeimage(TMW.images.highlight[ id ])
		TMW.images.highlight[ id ] = nil
	end
	
	if TMW.images.close[ id ] then
		freeimage(TMW.images.close[ id ])
		TMW.images.close[ id ] = nil
	end
end

function TMW.GUI_update()
	for id, _ in pairs(TMW.enabledPlayers) do
		TMW.reqcld3(id, 0, "", TMW.GUI)
	end
end

function TMW.GUI(id, mouseX, mouseY)

	if mouseX >= 624 and mouseY <= 16 and TMW.images.close[ id ] == nil then
		--print("mouse at close")
		TMW.images.close[ id ] = image(TMW.highlightImageRes, 632, 8, 2, id)
			imagescale(TMW.images.close[ id ], 0.5, 0.5)
			imagealpha(TMW.images.close[ id ], 0.3)
		--print("Close image ID:", TMW.images.close[ id ])
		TMW.selectedAction[ id ] = -1
		
	elseif (mouseX < 624 or mouseY > 16) and TMW.images.close[ id ] then
		--print("mouse outside close")
		freeimage(TMW.images.close[ id ])
			TMW.images.close[ id ] = nil
		
	end
	
	local list = TMW.wpnList
	local selectionFound = false
	for i = 1, #list do
		if (mouseX >= list[i][1] and mouseX <= list[i][3]) and (mouseY >= list[i][2] and mouseY <= list[i][4]) then
		
			if TMW.selectedAction[ id ] == i then
				return -- same selection, nothing changed
			end
			
			if TMW.images.highlight[id] then
				--print("Removing previous Highlight image")
				freeimage(TMW.images.highlight[id])
			end
			
			-- highlight selected weapon
			TMW.images.highlight[ id ] = image(TMW.highlightImageRes, list[i][1] + (list[i][3] - list[i][1]) / 2, list[i][2] + (list[i][4] - list[i][2]) / 2, 2, id)
			TMW.selectedAction[ id ] = i
			--print("Highlight image ID:", TMW.images.highlight[ id ])
			
			--	(x2 - x1) / highlightImageWidth = scale
			imagescale(TMW.images.highlight[id], (list[i][3] - list[i][1]) / 32, (list[i][4] - list[i][2]) / 32)
			imagealpha(TMW.images.highlight[id], 0.3)
			
			if list[ i ][ 6 ] == false or TMW.permission_check(id, i, true) == false then	-- unavailable to the player
				imagecolor(TMW.images.highlight[id], 255, 64, 64)
			end
			
			selectionFound = true
			break
		end
	end
	
	-- nothing found
	-- !> remove the highlight image
	if selectionFound == false and TMW.images.highlight[ id ] then
		--print("Removing previous Highlight image, no highlighting")
		--print("Highlight ID:", TMW.images.highlight[ id ])
		freeimage(TMW.images.highlight[id])
		TMW.images.highlight[ id ] = nil
		if TMW.selectedAction[ id ] ~= -1 then
			TMW.selectedAction[ id ] = 0
		end
	end
	--parse("hudtxt 1 \"" .. TMW.selectedAction[ id ] .. "\" 320 240 0")
end

-- > Startround_prespawn hook
function TMW.startround_prespawn()
	TMW.INIT_tables()
	TMW.disableHooks()
end

-- > Leave hook
function TMW.leave(id)
	TMW.GUI_close(id)
end

-- > Die hook
function TMW.death(id)
	TMW.GUI_close(id)
end

-- > Say & Sayteam hook
function TMW.say(id, text)
	if text :sub(1, 4) :lower() == "!tmw" and TMW.permission_check(id, TMW.PNODE_OPENMENU) then
		
		local from, to, targetID = text:find(" ?(%d+)", 5)	-- returns 3 values: from, to, string
		targetID = tonumber(targetID)
		-- Improved Print Script required: print(targetID, text:find(" ?(%d+)", 5))
		if not targetID then	-- equip himself
		
			if player(id, "health") ~= 0 then
				TMW.GUI_open(id)
			else
				msg2(id,"©255255255[TooManyWeapons] You can't equip yourself, you're D E A D!")
			end
			
		elseif TMW.permission_check(id, TMW.PNODE_EQUIPOTHER) then	-- equip other player
		
			if TMW.validPlayerID(targetID) and player(targetID, "exists") then
				if player(targetID, "health") ~= 0 then
					TMW.GUI_open(id, targetID)
					
					msg2(id, "©170170255[TMW] Opened menu to equip player (".. targetID ..") ".. player(targetID, "name") ..", #".. player(targetID, "usgn"))
				end
			else
				msg2(id, "©255255255[TooManyWeapons] Player with ID ".. targetID .." doesn't exist!")
			end
			
		end
		
		return 1
	end
end

-- > Attack hook
function TMW.execute(id)
	if TMW.enabledPlayers[ id ] and TMW.selectedAction[ id ] then
		
		if TMW.selectedAction[ id ] > 0 then
			TMW.equipList(id, TMW.selectedAction[ id ])
		elseif TMW.selectedAction[ id ] == -1 then
			TMW.GUI_close(id)
		end
		
	end
end

function TMW.equipList(id, listNumber)
	if TMW.wpnList[listNumber][6] == false then
		msg2(id, "©255255255[TooManyWeapons] This item is disabled!")
		return false
	end
	
	if TMW.permission_check(id, listNumber) == false then
		return false	-- no permission
	end
	
	local targetID = TMW.equipTarget[id] or id
	
	for i = 1, #TMW.wpnList[listNumber][ 7 ] do
		TMW.equip(targetID, TMW.wpnList[listNumber][ 7 ][ i ])
	end
	
	if id == targetID then
		msg2(id, "©255255255[TooManyWeapons] Equipped you with " ..TMW.wpnList[listNumber][ 5 ])
		print("[TMW] Equipped ID ".. id ..", #".. player(id, "usgn") .." with item " ..TMW.wpnList[listNumber][ 5 ])
		
	else
		msg2(id, "©255255255[TooManyWeapons] Equipped player ".. player(targetID, "name") .." #".. player(targetID, "usgn") .." with " ..TMW.wpnList[listNumber][ 5 ])
		msg2(targetID, "©255255255[TooManyWeapons] ".. player(id, "name") .." equipped you with " ..TMW.wpnList[listNumber][ 5 ])
		
		print("[TMW] User ID ".. id ..", #".. player(id, "usgn") .." equipped ID ".. targetID ..", #".. player(targetID, "usgn") .." with item " ..TMW.wpnList[listNumber][ 5 ])
	end
	
	return true
end

function TMW.equip(id, itemID)
	if not TMW.unequipable[itemID] then
		parse("equip " .. id .. " " ..itemID)
	else
		TMW.equipUnequipable(id, itemID)
	end
end

function TMW.equipUnequipable(id, itemID)
	local playerTileX, playerTileY = player(id, "tilex"), player(id, "tiley")
	parse("spawnitem ".. itemID .." ".. playerTileX .." ".. playerTileY)
	
	local minX, maxX = -1, 1
	local minY, maxY = -1, 1
	
	repeat
		for x = minX, maxX, 1 do
			for y = minY, maxY, 1 do
				if tile(x, y, "deadly") == false and (x ~= playerTileY and y ~= playerTileY) then
					--tp
					parse("setpos ".. id .." ".. (playerTileX + x) * 32 + 16 .." ".. (playerTileY + y) * 32 + 16)
					parse("setpos ".. id .." ".. (playerTileX) * 32 + 16 .." ".. (playerTileY) * 32 + 16)
					
					return true
				end
			end
		end
		
		minX, maxX = minX - 1, maxX - 1
		mixY, maxY = minY - 1, maxY - 1
	until maxX >= 10
	
	return false
end

function TMW.validPlayerID(id)
	if id > 0 and id < 33 then
		return true
	end
	
	return false
end
