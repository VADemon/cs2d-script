worldedit.edit = {}

function worldedit.edit.settile(x, y, weTile)
	if tile(x, y, "frame") ~= weTile then
		parse("settile " .. x .. " " .. y .. " " .. weTile)
		return true
	else
		return false
	end
end

function worldedit.edit.limit(id, limit)
	worldedit.data.player[ id ].limit = limit
end


-- UNDO

-- REDO

-- CLEARHISTORY

-- ===

--WAND

--TOGGLEEDITWANT

--SEL

--DESEL

-- SET POSITION
function worldedit.edit.pos(id, pos, x, y)
	worldedit.data.player[ id ].pos["x" .. pos] = tonumber(x)
	worldedit.data.player[ id ].pos["y" .. pos] = tonumber(y)
	worldedit.msg2(id, (pos == 1 and "First" or "Second") .. " position set to (" .. x .. ", " .. y .. ") (" ..worldedit.func.calculateRegionSize(id) .. ")")
	worldedit.image.updateSelection(id)
end

function worldedit.edit.shiftRegionFromOffset(id, pos, amount, xOffset, yOffset)
	pos.x1 = pos.x1 + (xOffset * amount)
	pos.x2 = pos.x2 + (xOffset * amount)
	pos.y1 = pos.y1 + (yOffset * amount)
	pos.y2 = pos.y2 + (yOffset * amount)

	-- posistions were changed, push changes:
	worldedit.edit.pos(id, 1, pos.x1, pos.y1)
	worldedit.edit.pos(id, 2, pos.x2, pos.y2)
end

-- Resizes selection based on offsets
function worldedit.edit.resizeRegionFromOffset(id, pos, amount, xOffset, yOffset)
	origPos = {}
	do -- (efficient?) way to reallocate table and its contents
		local x1, y1, x2, y2 = pos.x1, pos.y1, pos.x2, pos.y2
		origPos.x1, origPos.y1, origPos.x2, origPos.y2 = x1, y1, x2, y2
	end
	
	if xOffset == 1 then
		if pos.x1 > pos.x2 then
			pos.x1 = pos.x1 + (xOffset * amount)
		else
			pos.x2 = pos.x2 + (xOffset * amount)
		end
	elseif xOffset == -1 then
		if pos.x1 < pos.x2 then
			pos.x1 = pos.x1 + (xOffset * amount)
		else
			pos.x2 = pos.x2 + (xOffset * amount)
		end
	end
	
	if yOffset == 1 then
		if pos.y1 > pos.y2 then
			pos.y1 = pos.y1 + (yOffset * amount)
		else
			pos.y2 = pos.y2 + (yOffset * amount)
		end
	elseif yOffset == -1 then
		if pos.y1 < pos.y2 then
			pos.y1 = pos.y1 + (yOffset * amount)
		else
			pos.y2 = pos.y2 + (yOffset * amount)
		end
	end

	if not (origPos.x1 == pos.x1 and origPos.y1 == pos.y1) then
		-- pos1 was changed, push changes:
		worldedit.edit.pos(id, 1, pos.x1, pos.y1)
	end
	
	if not (origPos.x2 == pos.x2 and origPos.y2 == pos.y2) then
		-- pos1 was changed, push changes:
		worldedit.edit.pos(id, 2, pos.x2, pos.y2)
	end
end

--EXPAND
function worldedit.edit.expand(id, amount, xOffset, yOffset)
	local pos = worldedit.data.player[ id ].pos
	worldedit.edit.resizeRegionFromOffset(id, pos, amount, xOffset, yOffset)
end

--CONTRACT
function worldedit.edit.contract(id, amount, xOffset, yOffset)
	worldedit.edit.expand(id, -amount, xOffset, yOffset)
end

--OUTSET

--INSET

--SHIFT
function worldedit.edit.shift(id, amount, xOffset, yOffset)
	local pos = worldedit.data.player[ id ].pos
	worldedit.edit.shiftRegionFromOffset(id, pos, amount, xOffset, yOffset)
end

--SIZE

--COUNT

--DISTR

-- ======
-- REGION OPERATIONS

-- return stepX, stepY
function worldedit.edit.setStep(x1, y1, x2, y2)
	return (x1 > x2 and -1) or 1, (y1 > y2 and -1) or 1
end

--SET
function worldedit.edit.set(id, toTile, x1, y1, x2, y2)
	local stepX, stepY = worldedit.edit.setStep(x1, y1, x2, y2)
	local changedTileCount = 0
	
	for y = y1, y2, stepY do
		for x = x1, x2, stepX do
			if worldedit.edit.settile(x, y, toTile) then
				changedTileCount = changedTileCount + 1
			end
		end
	end
	
	return changedTileCount
end

--REPLACE
function worldedit.edit.replace(id, fromTile, toTile, x1, y1, x2, y2)
	local stepX, stepY = worldedit.edit.setStep(x1, y1, x2, y2)
	local changedTileCount = 0
	
	for y = y1, y2, stepY do
		for x = x1, x2, stepX do
			if tile(x, y, "frame") == fromTile and worldedit.edit.settile(x, y, toTile) then
				changedTileCount = changedTileCount + 1
			end
		end
	end
	
	return changedTileCount
end


function worldedit.edit.replaceNonAir(id, toTile, x1, y1, x2, y2)
	local stepX, stepY = worldedit.edit.setStep(x1, y1, x2, y2)
	local changedTileCount = 0
	
	for y = y1, y2, stepY do
		for x = x1, x2, stepX do
			if tile(x, y, "frame") ~= 0 and worldedit.edit.settile(x, y, toTile) then
				changedTileCount = changedTileCount + 1
			end
		end
	end
	
	return changedTileCount
end


--OVERLAY |3D

--WALLS
function worldedit.edit.walls(id, toTile, x1, y1, x2, y2)
	local stepX, stepY = worldedit.edit.setStep(x1, y1, x2, y2)
	local changedTileCount = 0
	
	-- top wall
	changedTileCount = worldedit.edit.set(id, toTile, x1, y1, x2, y1) + changedTileCount
	-- bottom wall
	changedTileCount = worldedit.edit.set(id, toTile, x1, y2, x2, y2) + changedTileCount
	
	-- left wall | +- stepY - no need to replace the corners again
	changedTileCount = worldedit.edit.set(id, toTile, x1, y1 + stepY, x1, y2 - stepY) + changedTileCount
	
	-- right wall
	changedTileCount = worldedit.edit.set(id, toTile, x2, y1 + stepY, x2, y2 - stepY) + changedTileCount
	
	return changedTileCount
end

--OUTLINE |3D, 2D version is WALLS

--SMOOTH |3D

--DEFORM

--HOLLOW
function worldedit.edit.hollow(id, toTile, x1, y1, x2, y2)
	local stepX, stepY = worldedit.edit.setStep(x1, y1, x2, y2)
	
	return worldedit.edit.set(id, toTile, x1 + stepX, y1 + stepY, x2 - stepX, y2 - stepY)
end

--REGEN
function worldedit.edit.regen(id, x1, y1, x2, y2)
	local stepX, stepY = worldedit.edit.setStep(x1, y1, x2, y2)
	local changedTileCount = 0
	
	for y = y1, y2, stepY do
		for x = x1, x2, stepX do
			if worldedit.edit.settile(x, y, tile(x, y, "originalframe")) then
				changedTileCount = changedTileCount + 1
			end
		end
	end
	
	return changedTileCount
end

--MOVE

--STACK

--NATURALIZE |MC ONLY

-- ======
-- CLIPBOARD

-- COPY

--CUT

--PASTE

--ROTATE

--FLIP

--SCHEMATIC

--CLEARCLIPBOARD

--=======
-- GENERATION

--GENERATE

--HCYL

--CYL

--SPHERE

--HSPHERE

--PYRAMID

--HPYRAMID

--FORESTGEN

--PUMPKINS

--====
-- UTILITIES

--TOGGLEPLACE >> TOGGLEPOS

--FILL | 2D >> inside boundaries

--FILLR |3D?

--DRAIN | MC ONLY

--FIXWATER |MC ONLY

--FIXLAVA |MC ONLY

--REMOVEABOVE |3D

-- REMOVEBELOW |3D

-- REPLACENEAR

--REMOVENEAR

--SNOW |MC ONLY

--THAW | MC ONLY

--EX |MC ONLY

--BUTCHER |MC ONLY

--REMOVE |MC ONLY

--GREEN |MC ONLY or NEEDS TILE DEFINITIONS

-- ========
-- CHUNK TOOLS | MC ONLY

--CHUNKINFO

--LIST CHUNKS

--DELCHUNKS


-- =======
--SUPER PICKAXE | MC ONLY


--========
-- TOOLS

-- TOOL

-- NONE

--INFO

--TREE

--REPL

--CYCLER

--TOOL BRUSH

--====
-- BRUSHES

-- BRUSH SPHERE

-- BRUSH CYLINDER

-- BRUSH CLIPBOARD

--BRUSH SMOOTH |MC ONLY

--SIZE >> BRUSH SIZE

--MAT >> BRUSH MAT

--MASK >> BRUSH MASK

-- GMASK >> BRUSH GMASK

--= =======
-- MOVEMENT aka GETTING AROUND

--UNSTUCK

--ASCEND >> y+1

--DESCEND >> y-1

--CEIL >> y-unstuck
-- V>> FLOOR?

--THRU

--JUMPTO >> JUMP TO CURSOR

--UP | obsolete, tp command


-- =======
-- SNAPSHOTS

--RESTORE

--SNAPSHOT USE

--SNAPSHOT LIST

--SNAPSHOT BEFORE
--SNAPSHOT AFTER


--=========
-- CUSTOM SCRIPTS

--CS >> exec

--.S >> reexec

--RUN /script.lua


--==========
-- GENERAL COMMANDS

--SEARCHITEM

--WORLDEDIT

--WORLDEDIT HELP

--WORLDEDIT RELOAD
function worldedit.reload()
	worldedit.print("Reloading WE...")
	--
	worldedit.func.freeimages()
	
	local folder = worldedit["folder"]
	worldedit = {}
	dofile(folder .. "..\\WorldEdit.lua")
	
	worldedit.func.callJoinHookForCurrentPlayers()
	--
	worldedit.print("Finished reloading WorldEdit")
end

--FAST |?

--====
-- BIOMES |MC ONLY
