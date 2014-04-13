-- 255 85 255


-- Sets max. editable block limit
local function limit(id, args)
	for k,v in pairs(args) do
		msg(k .. v)
	end
	
	local limit = math.floor(args[3])
	if limit > 0 then
		worldedit.edit.limit(id, limit)
		worldedit.msg2(id, "Operation limit set to " .. limit .. " blocks")
		
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
		worldedit.errorMsg2(id, "Cursor position is not implemented yet")
		
	else
		if worldedit.func.validCoordinate(x, y) then
			worldedit.edit.pos(id, pos, x, y)
			
			return true
		else
			worldedit.errorMsg2(id, "Given location is not valid")
			
			return false
		end
	end
end
worldedit.chat.addCommand("pos", "setpos", pos)
--
-- === REGION OPERATIONS
--

local function set(id, args)
	local state, tile, pos, limit = worldedit.chat.validateTilePositionLimit(id, tonumber(args[3]))
	
	if state then
		worldedit.edit.set(id, tile, pos.x1, pos.y1, pos.x2, pos.y2)
		
		return true
	else
		return false
	end
end
worldedit.chat.addCommand("set", "", set)

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