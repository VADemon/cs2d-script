worldedit.reqcld = {}
-- Mode 0: Cursor position on screen
-- Mode 1: Map scrolling
-- Mode 2: Cursor position on map in px
-- Mode 3: advanced light; enabled=1, disabled=0
-- Mode 4: 1 if the file specified with parameter (file path relative to the CS2D folder) has been loaded, 0 otherwise (second value always 0)

-- reqcld( playerID, mode, parameter )
-- reqcld2( playerID, mode, parameter, function, customParameter)

function worldedit.reqcld.pos(id, x, y, pos)
	x, y = worldedit.func.pixelToTile(x), worldedit.func.pixelToTile(y)
	
	if worldedit.func.validateCoordinate(x, y) then
		worldedit.edit.pos(id, pos, x, y)
	else
		worldedit.errorMsg2(id, "Invalid coordinates (" .. x .. "|" .. y .. ")!")
	end
end