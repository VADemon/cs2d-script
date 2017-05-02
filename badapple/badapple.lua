--package.path = package.path .. ";".. "./sys/lua/autorun/?.lua"
--require("bitmap-gamedev")

--horizontal tile resolution:	20
--vertical tile resolution:		15
msg("Badapple.lua loaded")

SCREENS_H, SCREENS_V = 4, 3	-- 5x5 games = 100x75 tiles/pixels
IMAGES_PATH = "badapple/ffmpeg/images/%04d.bmp"
generateTileMapping("badapple/ffmpeg/rgb-palette24.bmp")

--
parse("mp_hud 0")
parse("mp_floodprot 0")
parse("mp_maxclientsip 32")
parse("mp_idlekick 0")
--

addhook("clientdata", "onCurpos")
hudid = 0	-- hudid 0-5 occupied
playerAdminId = 1	-- show HUDs for this player
function onCurpos(id, mode, x, y)
	local x,y = x or 0, y or 0
	parse("hudtxt2 ".. id .." ".. hudid .." \"Pixel".. x ..",".. y .."\" 0 110 0")
	parse("hudtxt2 ".. id .." ".. hudid+1 .." \"Tile".. tostring(math.floor(x/32)) ..",".. tostring(math.floor(y/32)) .."\" 0 125 0")
	parse("hudtxt2 ".. id .." ".. hudid+2 .." \"TileFrame: ".. tostring(tile(math.floor(x/32), math.floor(y/32), "frame")) .."\" 0 140 0")
	parse("hudtxt2 ".. id .." ".. hudid+3 .." \"PlayerPos: ".. tostring(player(id, "tilex")) ..",".. tostring(player(id, "tiley")) .. " || ".. tostring(player(id, "x")) ..",".. tostring(player(id, "y")).."\" 0 155 0")
end

addhook("always", "reqCurpos")

function reqCurpos()
	for k, id in pairs(player(0, "table")) do 
		if id == 1 then
			reqcld(id, 2)
		end
	end
end

--[[
addhook("log", "apple_fps")
function apple_fps(line)
	if line:match("RANDOMLINE") then
		return 1
	end
	
	local fps, frametime = line:match("Current FPS: (%d+).-(%d+ ms)")
	local linex = line --:sub(2)
	
	if fps and frametime then
		parse("hudtxt2 ".. playerAdminId .." ".. hudid+4 .." \"[" .. os.clock() .."] FPS: ".. fps .. " || Frametime: ".. frametime .."\" 0 170 0")
	
		return 1
	else
		parse("hudtxt2 ".. playerAdminId .." ".. hudid+4 .." \"[" .. os.clock() .."] ".. linex .."\" 0 170 0")
	end
end

addhook("ms100", "apple_requestfps")
function apple_requestfps()
	print("RANDOMLINE ".. os.clock())
	parse("fps")
end]]

addhook("say", "apple_say")
function apple_say(id, txt)
	if txt == "!center" then
		local x,y = player(id, "x") , player(id, "y")
		
		local newx, newy = x + (320 - x % 320), y + (240 - y % 240)
		parse("setpos ".. id .." ".. newx .." ".. newy)
	end
	
	if txt:sub(1, 10) == "!centerpos" then
		local posx, posy = txt:match("(%d+) (%d+)")	-- full displays as positions
		
		if posx and posy then
			centerpos(id, posx, posy)
		end
	end
	
	if txt:sub(1, 12) == "!settilesize" then
		local num = txt:match("%d+") or 1
		
		msg("Setting Bench Tile size to " .. num)
		settileBenchRadius = num
	end
	
	if txt:sub(1,11) == "!screentest" then
		local state = txt:match("%d")
		
		if state == "0" then
			freehook("second", "drawScreen")
			freehook("ms100", "drawScreen")
			freehook("always", "drawScreen")
		elseif state == "1" then
			--addhook("second", "drawScreen")
			addhook("always", "drawScreen")
		end
	end
end

addhook("parse", "apple_parse")
function apple_parse(txt)
	-- syntax: "seqstart <name or "nil"> <number>"
	if txt:sub(1, 8) == "seqstart" then
		local name, num = txt:match(" (.-) (%d+)")
		if name == "nil" then name = nil end
		num = num or 1
		
		print("Starting sequence ".. tostring(name) .. " with #".. num)
		drawSequence(name, num)
	end
	
	if txt:sub(1, 9) == "drawframe" then
		local name, num = txt:match(" (.-) (%d+)")
		if name == "nil" then name = nil end
		num = num or 1
		
		print("Drawing frame ".. tostring(name) .. " with #".. num)
		drawFrame(name, num)
	end
	
	if txt == "seqstop" then
		print("Stopping sequence...")
		drawSequenceStatus = false
		freehook("always", "drawProceedHook")
		freehook("always", "drawSequenceHook")
	end
	
	if txt == "applereload" then
		print("Reloading apple...")
		dofile("sys/lua/autorun/badapple-delayed-start.lua")
	end
	
	return 1
end

function centerpos(id, x,y)
	local newx, newy = (x-1) * 640 + 320, (y-1) * 480 + 240
	parse("setpos ".. id .." ".. newx .." ".. newy)
	print("©240240240Position of ".. id .." is: ".. newx/32 .. "|".. math.floor(newy/32))
end

addhook("spawn", "apple_setSpawnpos")
function apple_setSpawnpos(id)
	id = tonumber(id)
	
	if id ~= 1 then
		if player(id, "team") == 0 then
			parse("maket ".. id)
		end
		if player(id, "health") == 0 then
			parse("spawnplayer ".. id .." 0 0")
		end
		
		local calcid = id - 1
		
		local screenx = math.abs((calcid - 1) % SCREENS_H + 1)
		local screeny = math.ceil(calcid / SCREENS_H)
		
		centerpos(id, screenx, screeny)
		
		drawFill(id*2+3, math.floor(((screenx-1) * 640)/32), math.floor(((screeny-1) * 480)/32), 20, 15)
		drawText(id, math.floor(((screenx-1) * 640 + 160)/32), math.floor(((screeny-1) * 480 + 120)/32))
	end
end

addhook("join", "apple_forcespawn")
function apple_forcespawn(id)
	timer(3000, "apple_setSpawnpos", tostring(id))
end

figureList = {}
figureList["1"] = { width = 5,
0,0,1,0,0,
0,0,1,0,0,
0,0,1,0,0,
0,0,1,0,0,
0,0,1,0,0,
}

figureList["2"] = { width = 5,
1,1,1,1,1,
0,0,0,0,1,
1,1,1,1,1,
1,0,0,0,0,
1,1,1,1,1,
}
figureList["3"] = { width = 5,
1,1,1,1,1,
0,0,0,0,1,
1,1,1,1,1,
0,0,0,0,1,
1,1,1,1,1,
}

figureList["4"] = { width = 5,
1,0,0,0,1,
1,0,0,0,1,
1,1,1,1,1,
0,0,0,0,1,
0,0,0,0,1,
}

figureList["5"] = { width = 5,
1,1,1,1,1,
1,0,0,0,0,
1,1,1,1,1,
0,0,0,0,1,
1,1,1,1,1,
}

figureList["6"] = { width = 5,
1,1,1,1,1,
1,0,0,0,0,
1,1,1,1,1,
1,0,0,0,1,
1,1,1,1,1,
}

figureList["7"] = { width = 5,
1,1,1,1,1,
0,0,0,0,1,
0,0,0,0,1,
0,0,0,1,0,
0,0,1,0,0,
}

figureList["8"] = { width = 5,
1,1,1,1,1,
1,0,0,0,1,
1,1,1,1,1,
1,0,0,0,1,
1,1,1,1,1,
}
figureList["9"] = { width = 5,
1,1,1,1,1,
1,0,0,0,1,
1,1,1,1,1,
0,0,0,0,1,
1,1,1,1,1,
}
figureList["0"] = { width = 5,
1,1,1,1,1,
1,0,0,0,1,
1,0,0,0,1,
1,0,0,0,1,
1,1,1,1,1,
}

function drawFigure(key, posx, posy)
	if not posx then
		print("TileDrawer: posx not specified, drawing at X=0")
		posx = 0
	end
	if not posy then
		print("TileDrawer: posy not specified, drawing at Y=0")
		posy = 0
	end
	
	if figureList[key] then
		if not figureList[key].width then
			print("TileDrawer: Width for key ".. key .." not found, using approximated value")
		end
		
		local width = figureList[key].width or getFigureWidth(key)
		
		for i = 1, #figureList[key] do
			if figureList[key][i] ~= 0 then
				local tilex, tiley = posx + math.abs((i - 1) % width + 1), posy + math.ceil(i / width)
				--msg("Drawing at: ".. tilex .."|".. tiley)
				parse("settile ".. tilex .." ".. tiley .." 6")
			end
		end
	else
		print("TileDrawer: key ".. tostring(key) .. " was not found")
		return false
	end
end

function getFigureWidth(key)
	if figureList[key] then
		return math.floor(math.sqrt(#figureList[key]))
	else
		return -1
	end
end

function drawText(str, posx, posy)
	local str = tostring(str)
	local posx, posy = posx or 0, posy or 0
	
	local shiftx, shifty = 0, 0
	
	for i = 1, #str do
		local char = str:sub(i,i)
		
		if figureList[char] then
			drawFigure(char, posx + shiftx, posy + shifty)
			shiftx = shiftx + getFigureWidth(char) + 1
		else
			print("TileDrawer: drawText - char ".. tostring(char) .. " not found!")
		end
	end
end

function drawFill(tile, posx, posy, sizex, sizey)
	local tile = tile or 0
	local posx, posy = posx or 0, posy or 0
	local sizex, sizey = sizex or 3, sizey or 3
	
	for x = 0, sizex-1 do
		for y = 0, sizey-1 do
			parse("settile ".. x+posx .." ".. y+posy .." ".. tile)
		end
	end
end

screenid = 0
screentile = 0

function drawScreen2()
	drawScreen()
	drawScreen()
end

-- Addhook in say function
function drawScreen()
	screentile = screentile + 2
	if screentile > 40 then
		screentile = 1
	end
	
	screenid = screenid + 1
	if screenid > (SCREENS_H * SCREENS_V) then
		screenid = 1
	end
	
	local screenx = math.abs((screenid - 1) % SCREENS_H + 1) - 1
	local screeny = math.ceil(screenid / SCREENS_H) - 1
	
	drawFill(screentile, screenx * 20, screeny * 15, 20, 15)
end

--addhook("ms100", "settileBench")
settileBenchLast = 10
settileBenchRadius = 1
function settileBench()
	local tileMin, tileMax = 10, 30
	
	settileBenchLast = settileBenchLast + 1
	if settileBenchLast > tileMax then
		settileBenchLast = tileMin
	end
	
	parse("hudtxt2 ".. playerAdminId .." ".. hudid+5 .." \"Tile=".. settileBenchLast ..", TileCount: ".. settileBenchRadius^2 .."\" 0 185 0")
	--msg("SettileBench: Tile=".. settileBenchLast ..", TileCount: ".. settileBenchRadius^2)
	drawFill(settileBenchLast, 0, 0, settileBenchRadius, settileBenchRadius)
end

------

drawProceedCounter = 0
function drawProceedHook()
	if drawProceedCounter == 0 then
		drawProceed()
		
		drawProceedCounter = 0
	else
		drawProceedCounter = 1 + drawProceedCounter
	end
end

drawSequenceCounter = 0
function drawSequenceHook()
	if drawSequenceCounter == 5 then
		drawSequence()
		freehook("always", "drawSequenceHook")	-- execute once and then stop
		-- if needed, the execution will be restarted from within drawProceed. #spaghettiLogic
		drawSequenceCounter = 0
	else
		drawSequenceCounter = 1 + drawSequenceCounter
	end
end

function drawProceed()
	if drawCoroutine then
		local status = coroutine.status(drawCoroutine)
		
		if status == "suspended" then
			--msg("Resuming coroutine...")
			local ok, data = coroutine.resume(drawCoroutine)
			
			if not ok then
				msg("NotOK: Coroutine.resume returned: ".. tostring(data))
			elseif data then
				msg("OK: Coroutine.resume returned: ".. tostring(data))
			end
			
		elseif status == "dead" then
			--msg("Coroutine finished: dead!")
			freehook("always", "drawProceedHook")
			print("©220220255BGRCallsFrame: ".. tostring(BGRCallsFrame) .. ", Cached: ".. tostring(BGRCachedFrame) .."(".. string.sub(((BGRCachedFrame or 1) / (BGRCallsFrame or 1))*100, 1, 6) .."%)")
			
			
			if drawSequenceStatus then
				--msg("addhook: drawSequenceHook")
				addhook("always", "drawSequenceHook")
				--drawSequenceHook()	-- call immediately without waiting for always hook
			else
				msg("drawSequenceStatus is not true!")
			end
		else
			msg("Coroutine returned unknown status: ".. status)
			msg("Stopping always hook!")
			freehook("always", "drawProceedHook")
		end
	end
end


-- returns TRUE when frame found
-- returns FALSE when image not found
function drawFrame(name, num)
	local timeS = os.clock()
	name = name or IMAGES_PATH
	local path = string.format(name, num)
	
	local file = io.open(path, "rb")
	
	if not file then msg("Path not found: ".. tostring(path)); return false end
	
	local bmp = file:read("*a")
	file:close()
	
	-- function, bitmap, drawFunc, true for yield
	BGRCallsFrame = 0
	BGRCachedFrame = 0
	drawCoroutine = coroutine.create(DrawBitmap)
	local ok, data = coroutine.resume(drawCoroutine, bmp, drawBGRPixel, true)
	
	if not ok then
		error(data)
	end
	
	addhook("always", "drawProceedHook")
	
	local timeE = os.clock()
	print("©240240240drawFrame diff: ".. timeE-timeS)
	return true
end

drawSequenceStatus = false
drawSequenceLast = 1

drawSequenceTimeStart = 10^9
drawSequenceTimeStartFrame = 10^9
drawSequenceTimeEnd = 10^9
drawSequenceTimeEndFrame = 10^9
function drawSequence(name, num)
	name = name or IMAGES_PATH
	if num then
		drawSequenceLast = num
	end
	num = num or drawSequenceLast
	local path = string.format(name, num)
	
	print("©130030200Seq: drawing frame ".. num)
	local status = drawFrame(name, num)
	
	if status then
		
		-- is this the first run?
		if drawSequenceStatus == false then
			drawSequenceTimeStart = os.clock()
			drawSequenceTimeStartFrame = num + 1 -- because we didn't capture frametime of the first frame
		end
		
		--msg("drawSeqStatus -> true")
		drawSequenceStatus = true	-- run this function once more
	end
	
	if not status or num % 100 == 0 then -- drawFrame returned false, should have finished
		
		drawSequenceTimeEnd = os.clock()
		drawSequenceTimeEndFrame = num
		
		print("©220060120Seq time start: ".. drawSequenceTimeStart)
		print("©220060120Seq time end : ".. drawSequenceTimeEnd)
		print("©220060120Seq time diff  : ".. drawSequenceTimeEnd - drawSequenceTimeStart)
		print("©220060120Frames drawn: ".. drawSequenceTimeEndFrame - drawSequenceTimeStartFrame .. " Frames: ".. drawSequenceTimeStartFrame .."->".. drawSequenceTimeEndFrame ..", ".. (drawSequenceTimeEndFrame - drawSequenceTimeStartFrame) / (drawSequenceTimeEnd - drawSequenceTimeStart) .." FPS")
		
		msg("drawFrame returned false, playback finished")
		freehook("always", "drawSequenceHook")
		drawSequenceStatus = false
		return false
	end
	
	if not status then	

	end
	
	drawSequenceLast = 1 + drawSequenceLast
end