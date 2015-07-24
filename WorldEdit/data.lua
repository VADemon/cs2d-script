worldedit.data = {}
worldedit.data.player = {}


worldedit.data.degreeToDirection = {
	-- straight forward
	[-4] = {0, 1}, -- down
	[-3] = {-1, 1}, -- down-left
	[-2] = {-1, 0}, -- left
	[-1] = {-1, -1}, -- up-left
	
	[0] = {0, -1}, -- up
	
	[1] = {1, -1}, -- up-right
	[2] = {1, 0}, -- right
	[3] = {1, 1}, -- down-right
	[4] = {0, 1} -- down
}

-- Sets default values for joining player
function worldedit.data.join(id)
	worldedit.data.player[ id ] = {
		pos = {},
		image = {
			selection = {
				x1 = nil, -- upper line
				x2 = nil, -- bottom
				y1 = nil, -- left
				y2 = nil, -- right
				c1 = nil, -- first corner
				c2 = nil -- second corner
			}
		}
	}
	worldedit.edit.limit(id, worldedit.config.defaultLimit) 
end

-- Clears player data
function worldedit.data.leave(id)
	-- clear HUD and IMAGES first
	
	
	worldedit.data.player[id] = nil
end
