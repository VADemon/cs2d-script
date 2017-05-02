-- Author: https://www.gamedev.net/user/47405-evil-steve/ Evil Steve
-- https://www.gamedev.net/topic/572784-lua-read-bitmap/?view=findpost&p=4662735

-- Helper function: Parse a 16-bit WORD from the binary string
function ReadWORD(str, offset)
	local loByte = str:byte(offset);
	local hiByte = str:byte(offset+1);
	return hiByte*256 + loByte;
end

-- Helper function: Parse a 32-bit DWORD from the binary string
function ReadDWORD(str, offset)
	local loWord = ReadWORD(str, offset);
	local hiWord = ReadWORD(str, offset+2);
	return hiWord*65536 + loWord;
end

-- Process a bitmap file in a string, and call DrawPoint for each pixel
function DrawBitmap(bytecode, processPixel, yield)
	-------------------------
	-- Parse BITMAPFILEHEADER
	-------------------------
	local offset = 1;
	local bfType = ReadWORD(bytecode, offset);
	if(bfType ~= 0x4D42) then
		error("Not a bitmap file (Invalid BMP magic value)");
		return;
	end
	local bfOffBits = ReadWORD(bytecode, offset+10);

	-------------------------
	-- Parse BITMAPINFOHEADER
	-------------------------
	offset = 15; -- BITMAPFILEHEADER is 14 bytes long
	local biWidth = ReadDWORD(bytecode, offset+4);
	local biHeight = ReadDWORD(bytecode, offset+8);
	local biBitCount = ReadWORD(bytecode, offset+14);
	local biCompression = ReadDWORD(bytecode, offset+16);
	if(biBitCount ~= 24) then
		error("Only 24-bit bitmaps supported (Is " .. biBitCount .. "bpp)");
		return;
	end
	if(biCompression ~= 0) then
		error("Only uncompressed bitmaps supported (Compression type is " .. biCompression .. ")");
		return;
	end

	---------------------
	-- Parse bitmap image
	---------------------
	for y = biHeight-1, 0, -1 do
		offset = bfOffBits + (biWidth*biBitCount/8)*y + 1;
		for x = 0, biWidth-1 do
			--local b = bytecode:byte(offset);
			--local g = bytecode:byte(offset+1);
			--local r = bytecode:byte(offset+2);
			local bgr = bytecode:sub(offset, offset+2)
			offset = offset + 3;

			processPixel(x, biHeight-y-1, bgr, biWidth, biHeight);
		end
		
		--if y%20==0 and yield then
		--	coroutine.yield()
		--end
	end
end

---------------

tilesetPalette = {
	-- [bgr binary] = "tile#255"
}

tilesetLastFrame = {
	-- [x] = { [y] = "tileid", },
}

function initFrameMap()
	for x = 0, map("xsize") do
		tilesetLastFrame[x] = tilesetLastFrame[x] or {}
		
		for y = 0, map("ysize") do
			tilesetLastFrame[x][y] = tostring(tile(x, y, "frame"))
		end
	end
end
initFrameMap()

function generateTileMapping(path)
	local palette = io.open(path, "rb")
	local bmp = palette:read("*a")
	palette:close()
	
	local mapPixel = function (x,y, bgr, biWidth, biHeight)
		tilesetPalette[bgr] = tostring(y*biWidth+x)
		print("mapPixel: RGB ".. bgr:byte(3) .. " ".. bgr:byte(2) .." ".. bgr:byte(1) .. " mapped as ".. y*biWidth+x)
	end
	
	DrawBitmap(bmp, mapPixel)
end

function drawRGBPixel(x, y, r,g,b)
	
end

BGRCallsFrame = 0
BGRCachedFrame = 0

BGRNewPixels = 0
BGRBatch = {}	-- command batch cache. e.g. "settile 1 1 240;settile 1 2 235;..."

BGRRatelimit = 820	-- don't draw more than N pixels at once
function drawBGRPixel(x, y, bgr, biWidth, biHeight)
	local tileid = tilesetPalette[bgr] or "255"
	BGRCallsFrame = BGRCallsFrame+1
	
	if tilesetLastFrame[x][y] ~= tileid then	-- caching: up to 10x improvement
		tilesetLastFrame[x][y] = tileid	-- update cache entry
		--parse("settile ".. x .." ".. y .." ".. tileid)
		BGRNewPixels = 1 + BGRNewPixels
		BGRBatch[#BGRBatch + 1] = "settile ".. x .." ".. y .." ".. tileid
	else
		--msg("cached")
		BGRCachedFrame = BGRCachedFrame+1
	end
	
	--if (BGRCallsFrame - BGRCachedFrame) % 100 == 0 then -- try to avoid client timeout, yield every N frames
		-- theoretical limit of 824 is too high - updating laggs due to connectivity issues
		-- 400 - same
		-- 300 - i think it's buggy with 4:3
		-- 200 - works fast, but not so fast in sequence
		--print("% ".. biWidth .." reached, yielding")
		
	-- building upon Batch improvements
	-- variable draw rate for speed
	-- or constant draw rate for synchronisation
	
	if (BGRNewPixels > BGRRatelimit) or (biWidth-1 == x and y%10==0) then	-- (800 draw calls) or (Writeout one line (X) * Y times)
		
		if (BGRNewPixels > BGRRatelimit) then
			print("Bitrate exceeded! ".. BGRNewPixels)
		end
		
		--local s = os.clock()
		
		parse(table.concat(BGRBatch, ";"), 0)	-- noticable performance improvement. drawing calls are at least 3x faster
		
		--local e = os.clock()
		--print(e-s .. "s draw call time")	-- 4-12ms - parse() is the bottleneck
		
		BGRBatch = {}
		BGRNewPixels = 0
		coroutine.yield()
	end
end