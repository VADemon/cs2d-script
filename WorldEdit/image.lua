--[[worldedit.image = {}

function worldedit.image.test()
	reqcld2(1, 2, "", worldedit.image.msg, "")
end

function worldedit.image.msg(id, x, y, param)
	msg(x .. "|" .. y .. " :: " .. param)
	x, y = worldedit.func.pixelToTile(x), worldedit.func.pixelToTile(y)
	msg(x .. "|" .. y .. " :: " .. param)
end]]