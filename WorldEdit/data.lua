worldedit.data = {}
worldedit.data.player = {}


worldedit.data.degreeToDirection = {
	-- straight forward
	[-4] = {0, 1},
	[-3] = {-1, -1},
	[-2] = {-1, 0},
	[-1] = {-1, -1},
	
	[0] = {0, -1},
	
	[1] = {1, -1},
	[2] = {1, 0},
	[3] = {1, 1},
	[4] = {0, 1}
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
