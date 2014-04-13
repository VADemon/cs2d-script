worldedit.func = {}
if not worldedit.chat then worldedit.chat = {} end




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

function worldedit.func.pixelToTile(px)
	return math.ceil(px / 32)
end

function worldedit.func.tileToPixel(tile)
	return (tile * 32) + 16
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




-- === VALIDATING FUNCTIONS

-- Checks whether coordinates are valid
function worldedit.func.validateCoordinate(x, y)
	x, y = tonumber(x), tonumber(y)
	return (x > 0 and x < tonumber(map("xsize"))) and (y > 0 and y < tonumber(map("ysize")))
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




-- === VALIDATING/MISC COMMANDS WITH PLAYER FEEDBACK

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
				return true, tile, pos, limit
			else
				return worldedit.errorMsg2(id, "Your selection exceeds your operation limit by ".. oversize .." tiles!", false)
			end
		else
			return worldedit.errorMsg2(id, errorMessage, false)
		end
	else
		return worldedit.errorMsg2(id, "Invalid tile, must be >= 0 and < 255", false)
	end
end

function worldedit.chat.countChangedBlocks()

end


-- === MISC

function worldedit.func.callJoinHookForCurrentPlayers()
	local playerTable = player(0, "table")
	for i = 1, #playerTable do
		worldedit.data.join( playerTable[ i ] )
	end
end

-- Returns table with separated values
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