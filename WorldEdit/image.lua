if not worldedit.image then worldedit.image = {} end

function worldedit.image.updateSelection(id)
	local pos = worldedit.data.player[ id ].pos
	local selection = worldedit.data.player[ id ].image.selection
	local tileToPixel = worldedit.func.tileToPixel
	local fullTileToPixel = worldedit.func.fullTileToPixel
	local align = worldedit.image.align
	local imagesize = worldedit.image.size
	
	local imagePathCorner = "gfx/hud_buildhelper.png"
	local imagePathLine = "gfx/block.bmp"
	local imageLineSize = 32
	local imageLineTargetSize = 1
	local c1Color = {r = 0, g = 200, b = 0}
	local c2Color = {r = 0, g = 0, b = 200}
	local alpha = 0.45 -- for imageCorner only
	
	if pos.x1 then
		if selection.c1 then -- already drawn
			-- reposition existing image
			imagepos(selection.c1, tileToPixel(pos.x1), tileToPixel(pos.y1), 0)
		else
			-- draw tile selection, c1
			selection.c1 = image(imagePathCorner, tileToPixel(pos.x1), tileToPixel(pos.y1), 1)
			imagecolor(selection.c1, c1Color.r, c1Color.g, c1Color.b)
			imagealpha(selection.c1, alpha)
		end
	end
	
	if pos.x2 then
		if selection.c2 then -- already drawn
			-- reposition existing image
			imagepos(selection.c2, tileToPixel(pos.x2), tileToPixel(pos.y2), 0)
		else
			-- draw tile selection, c2
			selection.c2 = image(imagePathCorner, tileToPixel(pos.x2), tileToPixel(pos.y2), 1)
			imagecolor(selection.c2, c2Color.r, c2Color.g, c2Color.b)
			imagealpha(selection.c2, alpha)
		end
	end
	
	if pos.x1 and pos.x2 then
		local stepX, stepY = worldedit.edit.setStep(pos.x1, pos.y1, pos.x2, pos.y2)
		stepX, stepY = -stepX, -stepY
		
		-- selection is complete, is a rectangle
		local xWidth = math.abs(pos.x1 - pos.x2)
		local yHeight = math.abs(pos.y1 - pos.y2)
		
		local x1_xPos, x1_yPos = align(tileToPixel(pos.x1) + (16*stepX), fullTileToPixel(xWidth), -stepX), tileToPixel(pos.y1) + (14*stepY)
		local x2_xPos, x2_yPos = align(tileToPixel(pos.x2) - (16*stepX), fullTileToPixel(xWidth), stepX), tileToPixel(pos.y2) - (14*stepY)
								
		local y1_xPos, y1_yPos = tileToPixel(pos.x1) + (14*stepX), align(tileToPixel(pos.y1) + (16*stepY), fullTileToPixel(yHeight), -stepY)
		local y2_xPos, y2_yPos = tileToPixel(pos.x2) - (14*stepX), align(tileToPixel(pos.y2) - (16*stepY), fullTileToPixel(yHeight), stepY)
		
		if not (selection.x1 and selection.x2) then -- draw images
			-- horizontal lines
			selection.x1 = image(imagePathLine, x1_xPos, x1_yPos, 0)
			selection.x2 = image(imagePathLine, x2_xPos, x2_yPos, 0)
			
			-- vertical lines
			selection.y1 = image(imagePathLine, y1_xPos, y1_yPos, 0)
			selection.y2 = image(imagePathLine, y2_xPos, y2_yPos, 0)
		
			-- set color of all lines
			imagecolor(selection.x1, 200, 0, 0)
			imagecolor(selection.y1, 200, 0, 0)
			imagecolor(selection.x2, 200, 0, 0)
			imagecolor(selection.y2, 200, 0, 0)
			
			-- alpha
			imagealpha(selection.x1, alpha)
			imagealpha(selection.y1, alpha)
			imagealpha(selection.x2, alpha)
			imagealpha(selection.y2, alpha)
		else -- reposition images if already drawn
			imagepos(selection.x1, x1_xPos, x1_yPos, 0)
			imagepos(selection.x2, x2_xPos, x2_yPos, 0)
			imagepos(selection.y1, y1_xPos, y1_yPos, 0)
			imagepos(selection.y2, y2_xPos, y2_yPos, 0)
		end
		
		-- resize images, newly created or recently moved ones
		-- size of horizontal lines
		imagesize(selection.x1, fullTileToPixel(xWidth) - 2, 2, 32, 32)
		imagesize(selection.x2, fullTileToPixel(xWidth) - 2, 2, 32, 32)
		
		-- size of vertical lines
		imagesize(selection.y1, 2, fullTileToPixel(yHeight) - 6, 32, 32)
		imagesize(selection.y2, 2, fullTileToPixel(yHeight) - 6, 32, 32)

	end
	
	worldedit.data.player[ id ].image.selection = selection
end