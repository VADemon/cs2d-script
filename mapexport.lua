addhook("parse", "mapexport.onParse")

mapexport = {}
mapexport.mapexport = {}
mapexport.listexport = {}
mapexport.data = ""

function mapexport.onParse(txt)
	txt = txt:lower()

	local cmdString, os_versionSearchShift, os_type
	
	if string.sub(txt, 1, 9) == "mapexport" then
		cmdString = "mapexport"
		os_versionSearchShift = 11
	elseif string.sub(txt, 1, 10) == "listexport" then
		cmdString = "listexport"
		os_versionSearchShift = 12
	else
		return 0
	end
	
	---
	
	local os_version = string.sub(txt, os_versionSearchShift) or ""
	
	if os_version == "win" or os_version == "windows" or os.getenv("os") == "Windows_NT" then
	
		os_type = "windows"
		
	elseif os_version == "linux" or os_version == "unix" or os.getenv("OSTYPE") == "linux-gnu" or os.getenv("OSTYPE") == "FreeBSD" then
		
		os_type = "linux"
		
	elseif os_version == "mac" or os_version == "macos" or os_version == "os x" or os.getenv("OSTYPE") == "darwin"  then
		
		print("©255100100Mapexport was not tested under MAC OS!")
		os_type = "mac"
		
	else
	
		print("©255100100Operating system not specified!")
		
	end
	
	if cmdString == "mapexport" then
		print("©100255100Exporting map resources under " .. os_type)
		mapexport.mapexport[os_type]( os_type, map("name") )
	else	-- listexport
		print("©100255100Exporting list of resources under " .. os_type)
		mapexport.listexport[os_type]( os_type, map("name") )
	end
	
	--print("Returning 2!")
	return 2
end

function mapexport.onLog(text)
	mapexport.data = mapexport.data .. text .. "\n"
end

function mapexport.captureConsoleOutput(os_type, targetFolder)
	addhook("log", "mapexport.onLog")
	parse("resources")
	freehook("log", "mapexport.onLog")
	
	local data = mapexport.data
	mapexport.data = ""
	local folderList, fileList = {}, {}
	local separator = os_type == "windows" and "\\" or "/"	-- use \ if it's windows, else /
	
	--	MANUALLY ADD THE .map and MAP's .lua
	folderList[ "maps" .. separator ] = false	-- create "maps/" folder
	folderList[ "gfx" .. separator .."tiles" .. separator ] = false	-- gfx/tiles/
	fileList[1] = 'maps' .. separator .. map("name") .. '.map'
	fileList[2] = 'maps' .. separator .. map("name") .. '.lua'
	fileList[3] = 'maps' .. separator .. map("name") .. '.txt'
	fileList[4] = 'gfx' .. separator .. 'tiles' .. separator .. map("tileset")
	
	if os_type == "windows" then
		fileList[1] = fileList[1]:gsub("/", "\\")
		fileList[2] = fileList[2]:gsub("/", "\\")
		fileList[3] = fileList[3]:gsub("/", "\\")
	end
	
	
	for word in data:gmatch("%).-/.-\n") do
		if os_type == "windows" then
			folderList[ word:match("%): (.+/)"):gsub("/", "\\") ] = false	-- use [key]=value structure because we don't need multiple folder entries
		else
			folderList[ word:match("%): (.+/)") ] = false
		end
	end
	
	for word in data:gmatch("%): (.-) %(") do
		if os_type == "windows" then
			fileList[ #fileList + 1 ] = word:gsub("/", "\\")
		else
			fileList[ #fileList + 1 ] = word
		end
	end
		
	--[[print("©200200000Printing captured data")
	for k,v in pairs(folderList) do
		print("folder", k, v)
	end
	
	for k,v in pairs(fileList) do
		print("file", k, v)
	end]]
	
	return folderList, fileList
end

-- MAPEXPORT

function mapexport.mapexport.windows(os_type, targetFolder)

	local _EXECUTE = os.execute
	
	os.execute = function (arg)
		print("©100100255   " .. arg)
		_EXECUTE(arg)
	end
	----
	
	local folderCount = 0	-- count folders for later output
	local folderList, fileList = mapexport.captureConsoleOutput(os_type, targetFolder)
	targetFolder = "mapexport_" .. targetFolder
	
	print("©100255100Starting to copy files:")
	os.execute('rmdir /S /Q "' .. targetFolder .. '"')	-- remove the directory before exporting
	
	
	for k,v in pairs(folderList) do
		os.execute('mkdir "' .. targetFolder .. "\\" .. k .. '"')	-- windows' mkdir automatically creates parent dirs
		folderCount = folderCount + 1
	end
	
	for k,v in pairs(fileList) do
		os.execute('copy "'.. v ..'" "'.. targetFolder .. "\\" .. v .. '"')
	end
	
	
	os.execute = _EXECUTE
	print("©200200000Finished copying!")
	print("©200200000Copied a total of " .. folderCount .. " Folder(s) and " .. #fileList .. " File(s)!")
end


function mapexport.mapexport.linux(os_type, targetFolder)

	local _EXECUTE = os.execute
	
	os.execute = function (arg)
		print("©100100255   " .. arg)
		_EXECUTE(arg)
	end
	----
	
	local folderCount = 0	-- count folders for later output
	local folderList, fileList = mapexport.captureConsoleOutput(os_type, targetFolder)
	targetFolder = "mapexport_" .. targetFolder
	
	print("©100255100Starting to copy files:")
	os.execute('rm -rf "' .. targetFolder .. '"')	-- remove the directory before exporting
	
	
	for k,v in pairs(folderList) do
		os.execute('mkdir -p "' .. targetFolder .. "/" .. k .. '"')
		folderCount = folderCount + 1
	end
	
	for k,v in pairs(fileList) do
		os.execute('cp "'.. v ..'" "'.. targetFolder .. "/" .. v .. '"')
	end
	
	
	os.execute = _EXECUTE
	print("©200200000Finished copying!")
	print("©200200000Copied a total of " .. folderCount .. " Folder(s) and " .. #fileList .. " File(s)!")
end

mapexport.mapexport.mac = mapexport.mapexport.linux

-- LISTEXPORT

function mapexport.listexport.windows(os_type, targetFolder)

	local folderList, fileList = mapexport.captureConsoleOutput(os_type, targetFolder)
	local listexportFile, ioError = io.open("listexport_" .. targetFolder .. ".txt", "w+")
	
	if listexportFile == nil then
		print("©255100100Error writing to file: " .. ioError)
		
		return 
	end
	
	print("©100255100Starting to write to file 'listexport_" .. targetFolder .. ".txt'")
	for k,v in pairs(fileList) do
		listexportFile:write( v:gsub("\\", "/") .. "\n")
	end
	
	listexportFile:close()	
	
	print("©200200000Finished writing!")
	print("©200200000The list contains " .. #fileList .. " File(s)!")
end

mapexport.listexport.linux = mapexport.listexport.windows
mapexport.listexport.mac = mapexport.listexport.windows