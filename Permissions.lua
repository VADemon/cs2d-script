--::===
-- Permissions plugin
-- Project Leader: VADemon
-- Thanks to: none yet :P
--::===

permissions = {}
permissions.func = {}
permissions.func.internal = {} --internal functions only, shouldn't be used by others
permissions.cache = {} --all cached data is here
permissions.func.cache = {} --cache functions
permissions.output = {} --is used rarely

permissions.get = {}    -- API
permissions.set = {}    -- API
permissions.add = {}    -- API
permissions.remove = {} -- API  -- SHIT IS THIS AND NOT AN API
permissions.create = {} -- API
permissions.delete = {} -- API
permissions.misc = {}   -- API

permissions.commands = {} --all commands are stored here
permissions.commands.meta = {}
permissions.commands.meta.args = {} --number of needed arguments // not used currently
permissions.commands.meta.help = {} 
permissions.commands.meta.syntax = {} -- is shown to user if the command's arguments are wrong
permissions.commands.meta.node = {} --required permissions node to execute // use the command name itself duh 28.12
perm = permissions -- that's why you can use, for example, perm.check()


permissions.version = "(in development)"
permissions.dir = "sys\\lua\\autorun\\Permissions\\"

print("©255255255Loading Permissions...")

permissions.filelist = {
	"config\\config.lua",
	"config\\permissions.lua",
	"scr\\permissions_get_func.lua",
	"scr\\permissions_internal_func.lua",
	"scr\\permissions_cache.lua",
	"scr\\public_API.lua",
	"scr\\commands\\command_preprocessor.lua",
	"scr\\commands\\command.lua"
	}

function permissions.load()
	local pairs,type=pairs,type
	for i=1,#permissions.filelist do --Loading the files...
		if perm.config then if perm.config.debug then print("©046139226[Permissions] Loading: "..permissions.dir..permissions.filelist[i]) end end
		dofile(permissions.dir..permissions.filelist[i])
	end
	
	for i in pairs(permissions.groups) do --Initializing the config... // loads the poorly (drawn) written configs, which allows keeping permission config file small and that also allows looking up a node directly
		if permissions.groups[i].permissions then
			for n,m in pairs(permissions.groups[i].permissions) do
				if type(permissions.groups[i].permissions[n])=="string" then
					permissions.groups[i].permissions[m]=true
					permissions.groups[i].permissions[n]=nil --Clearing the memory
				end
			end
		end
		if permissions.groups[i].map then
			for x in pairs(permissions.groups[i].map) do
				for z,a in pairs(permissions.groups[i].map[x].permissions) do --no check for not existing .map["mapname"].permissions
					if type(permissions.groups[i].map[x].permissions[z])=="string" then
						permissions.groups[i].map[x].permissions[a]=true
						permissions.groups[i].map[x].permissions[z]=nil --Clearing the memory
					end
				end
			end
		end
	end
	
	for	i in pairs(permissions.users) do
		if permissions.users[i].permissions then
			for k,v in pairs(permissions.users[i].permissions) do
				if type(permissions.users[i].permissions[k])=="string" then
					permissions.users[i].permissions[v]=true
					permissions.users[i].permissions[k]=nil --Clearing the memory
				end
			end
		end
	end
	permissions.func.internal.inittables()
end

function permissions.reload()
	permissions.load()
	permissions.cache = {}
	permissions.func.internal.inittables()
	for k,v in pairs(player(0,"table")) do
		--permissions.func.cache.clearcache(players[i])
		permissions.func.cache.addentries(v)
	end
	print("©255255255Permissions reloaded! Current version: "..perm.version)
end

permissions.load() -- load permissions AFTER defining the reload function

function permissions.save()

end

print("©255255255Permissions (version "..perm.version..") loaded!")