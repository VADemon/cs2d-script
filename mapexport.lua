addhook("parse", "resource_export.onParse")

resource_export = {}
resource_export.os = {}
resource_export.data = ""

function resource_export.onParse(txt)
	txt = txt:lower()
	local os_type
	
	if string.sub(txt, 1, 9) == "mapexport" then
		local os_version = string.sub(txt, 11) or ""
		print(os_version)
		
		if os_version == "win" or os_version == "windows" or os.getenv("os") == "Windows_NT" then
		
			os_type = "windows"
			
		elseif os_version == "linux" or os_version == "unix" or os.getenv("OSTYPE") == "linux-gnu" or os.getenv("OSTYPE") == "FreeBSD" then
			
			os_type = "linux"
			
		elseif os_version == "mac" or os_version == "macos" or os_version == "os x" or os.getenv("OSTYPE") == "darwin"  then
			
			print("©255100100Mapexport was not tested under MAC OS!")
			os_type = "mac"
			
		else
		
			print("©255100100Operating system not specified, using Windows!")
			os_type = "windows"
			
		end
		
		print("©100255100Exporting resources under " .. os_type)
		resource_export.os[os_type]( os_type, map("name") )
		
		--print("Returning 2!")
		return 2
	end
end

function resource_export.onLog(text)
	resource_export.data = resource_export.data .. text .. "\n"
end

function resource_export.captureConsoleOutput(os_type, targetFolder)
	addhook("log", "resource_export.onLog")
	parse("resources")
	freehook("log", "resource_export.onLog")
	
	local data = resource_export.data
	resource_export.data = ""
	local folderList, fileList = {}, {}
	local separator = os_type == "windows" and "\\" or "/"	-- use \ if it's windows, else /
	
	--	MANUALLY ADD THE .map and MAP's .lua
	folderList[ "maps" .. separator ] = false	-- create "maps\" folder
	fileList[1] = 'maps/' .. map("name") .. '.map'
	fileList[2] = 'maps/' .. map("name") .. '.lua'
	fileList[3] = 'maps/' .. map("name") .. '.txt'
	
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

function resource_export.os.windows(os_type, targetFolder)

	local _EXECUTE = os.execute
	
	os.execute = function (arg)
		print("©100100255   " .. arg)
		_EXECUTE(arg)
	end
	----
	
	local folderCount = 0	-- count folders for later output
	local folderList, fileList = resource_export.captureConsoleOutput(os_type, targetFolder)
	targetFolder = "mapexport_" .. targetFolder
	
	print("Starting to copy files:")
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


function resource_export.os.linux(os_type, targetFolder)

	local _EXECUTE = os.execute
	
	os.execute = function (arg)
		print("©100100255   " .. arg)
		_EXECUTE(arg)
	end
	----
	
	local folderCount = 0	-- count folders for later output
	local folderList, fileList = resource_export.captureConsoleOutput(os_type, targetFolder)
	targetFolder = "mapexport_" .. targetFolder
	
	print("Starting to copy files:")
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

resource_export.os.mac = resource_export.os.linux