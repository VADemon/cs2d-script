worldedit.edit = {}

function worldedit.edit.settile(x, y, tile)
	if tile(x, y, "frame") ~= tile then
		parse("settile " .. x .. " " .. y .. " " ..tile)
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

--POS1
function worldedit.edit.pos(id, pos, x, y)
	worldedit.data.player[ id ].pos["x" .. pos] = tonumber(x)
	worldedit.data.player[ id ].pos["y" .. pos] = tonumber(y)
	worldedit.msg2(id, (pos == 1 and "First" or "Second") .. " position set to (" .. x .. ", " .. y .. ") (" ..worldedit.func.calculateRegionSize(id) .. ")")
end
--POS2#

--HPOS1#

--HPOS2#

--CHUNK

--EXPAND

--CONTRACT

--OUTSET

--INSET

--SHIFT

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
function worldedit.edit.set(id, tile, x1, y1, x2, y2)
	--[[local stepX, stepY = 1, 1
	if x1 > x2 then
		stepX = -stepX
	end
	if y1 > y2 then
		stepY = -stepY
	end]]
	local stepX, stepY = worldedit.edit.setStep(x1, y1, x2, y2)
	
	for y = y1, y2, stepY do
		for x = x1, x2, stepX do
			worldedit.edit.settile(x, y, tile)
		end
	end
end

--REPLACE

--OVERLAY |3D

--WALLS

--OUTLINE

--SMOOTH |3D

--DEFORM

--HOLLOW

--REGEN

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

--FILL |3D ?

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
	
	local folder = worldedit["folder"]
	worldedit = {}
	dofile(folder .. "..\\WorldEdit.lua")
	
	worldedit.func.callJoinHookForCurrentPlayers()
	worldedit.print("Finished reloading WorldEdit")
end

--FAST |?

--====
-- BIOMES |MC ONLY
