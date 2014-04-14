worldedit.data = {}
worldedit.data.player = {}


-- Sets default values for joining player
function worldedit.data.join(id)
	worldedit.data.player[ id ] = {
		pos = {
			[1] = {},
			[2] = {}
		}
	}
	worldedit.edit.limit(id, worldedit.config.defaultLimit) 
end

-- Clears player data
function worldedit.data.leave(id)
	-- clear HUD and IMAGES first
	
	
	worldedit.data.player[id] = nil
end
