worldedit.func = {}
if not worldedit.chat then worldedit.chat = {} end
if not worldedit.image then worldedit.image = {} end




-- MESSAGING

worldedit.config.msgColor = "©255085255"
worldedit.config.errorMsgColor = "©255085085"

function worldedit.print(txt)
	print(worldedit.config.msgColor .. "[WorldEdit]: " .. txt)
end

function worldedit.msg(txt)
	msg(worldedit.config.msgColor .. "[WorldEdit]: " .. txt)
end

function worldedit.msg2(id, txt)
	msg2(id, worldedit.config.msgColor .. "[WorldEdit]: " .. txt)
end

-- Error messages can be used in returns, hence returning passed val-ue
function worldedit.errorMsg(txt, val)
	msg(worldedit.config.errorMsgColor .. "[WorldEdit]: " .. txt)
	return val
end

function worldedit.errorMsg2(id, txt, val)
	msg2(id, worldedit.config.errorMsgColor .. "[WorldEdit]: " .. txt)
	return val
end




-- === MATH FUNCTIONS

-- http://lua-users.org/wiki/SimpleRound
-- Igor Skoric (i.skoric@student.tugraz.at)
-- param: num-ber to round, (optional) idp - up to which decimal place to round
function worldedit.func.round(num, idp)
    local mult = 10^(idp or 0)
    if num >= 0 then return math.floor(num * mult + 0.5) / mult
    else return math.ceil(num * mult - 0.5) / mult end
end

function worldedit.func.pixelToTile(px)
	return math.ceil(px / 32) - 1
end

function worldedit.func.tileToPixel(tile)
	return (tile * 32) + 16
end

function worldedit.func.fullTileToPixel(tile)
	return (tile + 1) * 32
end

function worldedit.func.calculateRegionSize(id)
	local pos = worldedit.data.player[ id ].pos
	if pos.x1 and pos.x2 and pos.y1 and pos.y2 then
		local x = math.abs(pos.x1 - pos.x2) + 1
		local y = math.abs(pos.y1 - pos.y2) + 1
		
		return (x * y)
	else
		return "..."
	end
end

function worldedit.func.orEquals(a, b, compareWith)
	if a == compareWith or b == compareWith then
		return true
	else
		return false
	end
end

-- returns xOffset, yOffset
function worldedit.func.degreeToDirection( degree )
	if degree > 180 or degree < -180 then
		degree = degree % 180
	end
	
	return unpack(worldedit.data.degreeToDirection[ worldedit.func.round( degree / 45 , 0) ])
end



-- === DIRECTION FUNCTIONS
function worldedit.func.stringToDirection( str )
	local a, b = unpack(worldedit.func.split(string.lower(str), ","))
	local orEquals = worldedit.func.orEquals
	local xOffset, yOffset = 0, 0
	local errorMsg
	
	if a then
		if worldedit.func.validateStringDirection(a) == false then
			return 0, 0, "'" .. a .. "' is an invalid direction!"
		end
	else
		return 0, 0, "No direction specified!"
	end
	
	if not b then
		b = ""
	elseif worldedit.func.validateStringDirection(b) == false then
		return 0, 0, "'" .. b .. "' is an invalid direction!"
	end
	
	
	
	if orEquals(a, b, "north") or orEquals(a, b, "up") then
		yOffset = -1
	elseif orEquals(a, b, "south") or orEquals(a, b, "down") then
		yOffset = 1
	end
	if orEquals(a, b, "west") or orEquals(a, b, "left") then
		xOffset = -1
	elseif orEquals(a, b, "east") or orEquals(a, b, "right") then
		xOffset = 1
	end
	
	return xOffset, yOffset, errorMsg
end

-- Only to be used for user output
-- yString is to be showed BEFORE xString
function worldedit.func.directionToString(xOffset, yOffset)
	local xString, yString = "", ""
	
	if xOffset == 1 then
		xString = "east (right)"
	elseif xOffset == 0 then
		xString = "none"
	elseif xOffset == -1 then
		xString = "west (left)"
	else
		xString = "*error in dirToStr*"
	end
	
	if yOffset == -1 then
		yString = "north (up)"
	elseif yOffset == 0 then
		yString = "none"
	elseif yOffset == 1 then
		yString = "south (down)"
	else
		yString = "*error in dirToStr*"
	end
	
	return xString, yString
end





-- === IMAGE FUNCTIONS

function worldedit.image.size(imageID, x, y, origX, origY)
	local getScale = worldedit.func.getScaleFromPixelSize
	imagescale(imageID, getScale(origX, x), getScale(origY, y))
end

-- if you want an image with imgSize (px) to have targetSize (px)
-- returns a scale to use 
function worldedit.func.getScaleFromPixelSize(imgSize, targetSize)
	return targetSize / imgSize
end

-- Returns the size in pixels with current scale
function worldedit.func.getPixelSizeFromScale(imgSize, scale)
	return imgSize * scale
end

-- NOT USED, TO BE REMOVED
function worldedit.image.offsetHalf(size, step)
	return worldedit.func.round(size / step / 2)
end

function worldedit.image.align(x, size, align)
	return worldedit.func.round( x + (size / 2) * align )
end


-- === VALIDATING FUNCTIONS

-- Checks whether coordinates are valid
function worldedit.func.validateCoordinate(x, y)
	x, y = tonumber(x), tonumber(y)
	return (x >= 0 and x < tonumber(map("xsize"))) and (y >= 0 and y < tonumber(map("ysize")))
end

function worldedit.func.validateCoordinates(x, y, x2, y2)
	return (worldedit.func.validateCoordinate(x, y) and worldedit.func.validateCoordinate(x2, y2))
end

-- Checks whether tile is valid
function worldedit.func.validateTile(tile)
	return (tile >= 0 and tile < 255)
end

function worldedit.func.validPos(pos)
	return (pos==1 or pos==2)
end

function worldedit.func.checkPositionsSet(id)
	local pos = worldedit.data.player[ id ].pos
	
	if pos.x1 and pos.y1 then
		if pos.x2 and pos.y2 then
			return pos
		else
			return false, "You must set second position!"
		end
	else
		return false, "You must set first position!"
	end	
end

-- Player allowed to do operation with current region size?
-- @return: true, nil
-- @return false, oversize
function worldedit.func.validateLimit(id)
	local limit = worldedit.data.player[ id ].limit
	local selectionSize = worldedit.func.calculateRegionSize(id)
	if type(selectionSize) == "number" then
		if (selectionSize <= limit) then
			return true
		else
			return false, selectionSize - limit
		end
	else -- if input == "..."
		return true
	end
end

-- Checks variable against nil, returns boolean; sends message (to ID) if provided
-- DEPRECATED, USE worldedit.chat.validateArgument INSTEAD
function worldedit.func.checkVar(var, errorMsg, id)
	if (not var) and errorMsg then -- var is false and errorMsg submitted?
		if id then
			worldedit.errorMsg2(id, errorMsg)
		else
			worldedit.print(errorMsg)
		end
	end
	return var and true
end

function worldedit.func.validateStringDirection( str )
	if str == "north" or str == "up" or str == "south" or str == "down" or str == "west" or str == "left" or str == "east" or str == "right" then
		return true
	else
		return false
	end
end




-- === VALIDATING/MISC COMMANDS WITH PLAYER FEEDBACK
-- Checks argument _arg_ against its type and _argType_
-- returns true or false + user errormessage about missing argument #_argNum_
function worldedit.chat.validateArgument(id, arg, argType, argNum)
	if type(arg) == argType then
		return true
	elseif argNum then
		return worldedit.errorMsg2(id, "Wrong command syntax, argument #" .. argNum .." is incorrect", false)
	else
		return worldedit.errorMsg2(id, "Wrong command syntax, an argument is incorrect", false)
	end
end

-- Kinda manual one for functions with >1 tiles
function worldedit.chat.validateTile(id, tile)
	if worldedit.func.validateTile(tile) then
		return true
	else
		return worldedit.errorMsg2(id, "Invalid tile, must be >= 0 and < 255", false)
	end
end

-- Validate all 3: Tile, Positions, Limit
-- return bool
function worldedit.chat.validateTilePositionLimit(id, tile)
	if worldedit.func.validateTile(tile) then
		local pos, errorMessage = worldedit.func.checkPositionsSet(id)
		
		if pos then
			local limit, oversize =  worldedit.func.validateLimit(id)
			
			if limit then
				return true, tile, pos
			else
				return worldedit.errorMsg2(id, "Your selection exceeds your operation limit by ".. oversize .." tile(s)!", false)
			end
		else
			return worldedit.errorMsg2(id, errorMessage, false)
		end
	else
		return worldedit.errorMsg2(id, "Invalid tile, must be >= 0 and < 255", false)
	end
end

function worldedit.chat.showChangedTiles(id, count)
	worldedit.msg2(id, count .. " tile(s) have been changed")
end

function worldedit.chat.selectionExists(id)
	local pos = worldedit.data.player[ id ].pos
	
	if pos.x1 and pos.y1 then
		if pos.x2 and pos.y2 then
			return true
		else
			return worldedit.errorMsg2(id, "You must set the 2nd position to complete a selection!", false)
		end
	elseif pos.x2 and pos.y2 then
		return worldedit.errorMsg2(id, "You must set the 1st position to complete a selection!", false)
	else
		return worldedit.errorMsg2(id, "You must select a region first!", false)
	end
end





-- === RELOAD FUNCTIONS (!we reload or endround, etc)
function worldedit.func.freeimages_selection( id )
	local selection = worldedit.data.player[ id ].image.selection
	
	if selection.x1 then 
		freeimage(selection.x1); freeimage(selection.y1);
		selection.x1 = nil; selection.y1 = nil
	end

	if selection.x2 then 
		freeimage(selection.x2); freeimage(selection.y2)
		selection.x2 = nil; selection.y2 = nil
	end

	if selection.c1 then freeimage(selection.c1); selection.c1 = nil end
	if selection.c2 then freeimage(selection.c2); selection.c2 = nil end
	
	worldedit.data.player[ id ].image.selection = selection
end

function worldedit.func.freeimages() -- removes images and metadata
	local data = worldedit.data
	for id = 1, 32 do -- not doing just for existing players, ID 0 to be considered
		if data.player[ id ] then
		
			worldedit.func.freeimages_selection( id )
			
		end
	end
end





-- === MISC

function worldedit.func.callJoinHookForCurrentPlayers()
	local playerTable = player(0, "table")
	for i = 1, #playerTable do
		worldedit.data.join( playerTable[ i ] )
	end
end

-- Returns table with separated values @ http://stackoverflow.com/a/7615129
function worldedit.func.split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end