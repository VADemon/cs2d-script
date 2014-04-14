print("Loading WorldEdit Core")
worldedit = {}

worldedit.folder = "sys\\lua\\autorun\\WorldEdit\\"
worldedit.version = "InDev"

worldedit.files = {}

worldedit.files[1] = "config.lua"
worldedit.files[2] = "hooks.lua"
worldedit.files[3] = "functions.lua"
worldedit.files[4] = "edit.lua"
worldedit.files[5] = "chat_processor.lua"
worldedit.files[6] = "commands.lua"
worldedit.files[7] = "data.lua"
worldedit.files[8] = "image.lua"
worldedit.files[9] = "reqcld.lua"
worldedit.files[10] = "imports.lua"


function worldedit.init()
	print("Loading Worldedit v. " .. worldedit.version)
	worldedit.loadFiles()
	print("WorldEdit loaded!")
end

function worldedit.loadFiles()
	for _, v in pairs(worldedit.files) do
		if worldedit.config and worldedit.config.debug then
			print("[WorldEdit] Loading file: " .. v)
		end
		
		dofile(worldedit.folder .. v)
	end
end

worldedit.init()