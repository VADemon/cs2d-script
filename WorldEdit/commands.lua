-- 255 85 255


-- Sets max. editable block limit
local function limit(id, args)
	local limit = math.floor(args[3])
	if limit > 0 then
		worldedit.edit.limit(id, limit)
		worldedit.msg2(id, "Operation limit set to " .. limit .. " tile(s)")
		
		return true
	end
end
worldedit.chat.addCommand("limit", "", limit)

--
-- === HISTORY
--




--
-- === SELECTION
--

-- !we pos 1 15 20
-- !we pos 2 me
-- !we pos 2 cur
-- !we pos 1 pl 2
local function pos(id, args)
	local pos = tonumber(args[3]) -- 1 - top left | 2 - bottom right
	local x, y = args[4], args[5] -- str/int x
	
	if not (pos and x) then
		worldedit.errorMsg2(id, "Wrong command syntax!")
		return false
	end
	
	if not worldedit.func.validPos(pos) then
		worldedit.errorMsg2(id, "Position must be 1 or 2, your value: " .. pos)
		return false
	end
	
	if x == "pl" then -- pl-ayer coordinates
		if not worldedit.func.checkVar(y, "Wrong command syntax, player ID must be set!") then 
			return false
		else
			worldedit.edit.pos(id, pos, player(y, "tilex"), player(y, "tiley"))
			
			return true
		end
	elseif x == "me" then -- set to your own position
		worldedit.edit.pos(id, pos, player(id, "tilex"), player(id, "tiley"))
		
		return true
	elseif x == "cur" then -- set to cursor position
		reqcld2(id, 2, "", worldedit.reqcld.pos, pos)
		
		return true		
	else
		local x, y = tonumber(x), tonumber(y)
		
		if x ~= nil and y ~= nil then
			if worldedit.func.validateCoordinate(x, y) then
				worldedit.edit.pos(id, pos, x, y)
				
				return true
			else
				return worldedit.errorMsg2(id, "Given location is not valid", false)
			end
		
		else
			return worldedit.errorMsg2(id, "Wrong command syntax, x and y must be numbers!")
		end
	end
end
worldedit.chat.addCommand("pos", "setpos", pos)
--
-- === REGION OPERATIONS
--

-- !we set 5
local function set(id, args)
	if tonumber(args[3]) == nil then return false end

	
	local state, tile, pos = worldedit.chat.validateTilePositionLimit(id, tonumber(args[3]))
	
	if state then
		local changedTiles = worldedit.edit.set(id, tile, pos.x1, pos.y1, pos.x2, pos.y2)
		
		worldedit.chat.showChangedTiles(id, changedTiles)
		
		return true
	else
		return false
	end
end
worldedit.chat.addCommand("set", "", set)


-- !we replace 20
-- !we replace 0 20
local function replace(id, args)
	if tonumber(args[3]) == nil then return false end
	
	
	local state, fromTile, pos = worldedit.chat.validateTilePositionLimit(id, tonumber(args[3]))
	local toTile = tonumber(args[4]) -- doesn't work if it's in the line above... >:/

	if state then
		
		if toTile then
			if worldedit.chat.validateTile(id, toTile) then
				-- replace fromTile to toTile
				local changedTiles = worldedit.edit.replace(id, fromTile, toTile, pos.x1, pos.y1, pos.x2, pos.y2)
				
				worldedit.chat.showChangedTiles(id, changedTiles)
				
				return true
			end
		else
			-- replace non-Air to fromTile
			local changedTiles = worldedit.edit.replaceNonAir(id, fromTile, pos.x1, pos.y1, pos.x2, pos.y2)
			
			worldedit.chat.showChangedTiles(id, changedTiles)
			
			return true
		end
	else
		return false
	end	
end
worldedit.chat.addCommand("replace", "", replace)


local function walls(id, args)
	if tonumber(args[3]) == nil then return false end
	
	
	local state, toTile, pos = worldedit.chat.validateTilePositionLimit(id, tonumber(args[3]))
	
	if state and toTile then
		local changedTiles = worldedit.edit.walls(id, toTile, pos.x1, pos.y1, pos.x2, pos.y2)
		
		worldedit.chat.showChangedTiles(id, changedTiles)
		
		return true
	else
		return false
	end
end
worldedit.chat.addCommand("walls", "", walls)


local function hollow(id, args)
	if tonumber(args[3]) == nil then return false end
	
	
	local state, toTile, pos = worldedit.chat.validateTilePositionLimit(id, tonumber(args[3]))
	
	if state and toTile then
		local changedTiles = worldedit.edit.hollow(id, toTile, pos.x1, pos.y1, pos.x2, pos.y2)
		
		worldedit.chat.showChangedTiles(id, changedTiles)
		
		return true
	else
		return false
	end
end
worldedit.chat.addCommand("hollow", "", hollow)


local function regen(id)
	local state, _, pos = worldedit.chat.validateTilePositionLimit(id, 0)
	
	if state then
		local changedTiles = worldedit.edit.regen(id, pos.x1, pos.y1, pos.x2, pos.y2)
		
		worldedit.chat.showChangedTiles(id, changedTiles)
		
		return true
	else
		return false
	end
end
worldedit.chat.addCommand("regen", "", regen)

--
-- === 
--


--
-- === 
--
--
-- === 
--
--
-- === 
--
--
-- === 
--
--
-- === 
--
--
-- === GENERAL COMMANDS
--

local function reload(id)
	worldedit.reload()
	if id then worldedit.msg2(id, "Reloaded! Version " .. worldedit.version) end
end
worldedit.chat.addCommand("reload", "", reload)