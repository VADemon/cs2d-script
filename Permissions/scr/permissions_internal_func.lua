-- @Param id Player ID
-- @Param option Prefix OR Suffix
-- @return (String) Prefix or Suffix, lowercase!
function permissions.func.internal.getpresuf(id,option)

	local user_groups = permissions.func.getAllGroups(id)
	local return_presuf = ""
	
	for i=1,#user_groups do
		local temp_presuf = permissions.groups[user_groups[i]].options[option]
		if temp_presuf then
			return_presuf = return_presuf..temp_presuf
		end
	end
	
	return return_presuf
end

-- @return (Table) All groups to check the nodes
function permissions.func.internal.getgroupstocheck(id) --depreciated?!

	local users_groups = permissions.func.getAllGroups(id)
	local inheritances = permissions.func.getInheritance(id)
	local product = {}
	local return_groups = {}
	
	for _,v in pairs(users_groups) do
		--print("adding "..v)
		product[v] = v
	end

	for _,v in pairs(inheritances) do
		--print("adding "..v)
		product[v] = v
	end

	for _,v in pairs(product) do
		--print("inserting "..v)
		table.insert(return_groups, v)
	end

	return return_groups
end

function permissions.func.internal.checkMapNodes(name)
	if permissions.misc.groupExist(name) then
		local map_name = map("name") --mapname
		
		if perm.groups[name].map and perm.groups[name].map[map_name] and perm.groups[name].map[map_name].permissions then

			if #perm_usergroup.map.map_name.permissions~=0 then
				return true
			else
				if perm.config.debug then print("[Permissions] Empty per-map permissions table found! Group: \""..name.."\" and map: "..map("name")) end
			end
		end
	end
	return false
end

function permissions.func.internal.check_group_nodes(name)
	local groups = perm.groups

	if permissions.group_exist(name) then
		if groups[name].permissions then
			return true
		end
	end

	return false --unnecessary, but better so
end

-- @param usgn (number) USGN ID
function permissions.func.internal.check_user_nodes(usgn)
	local users = perm.users

	if permissions.player_exist(usgn) then
		if users[usgn].permissions then
			return true
		end
	end

	return false
end

-- @param usgnid USGN ID of Player
-- @param option Option to return
-- @return Returns the option or false
function permissions.func.internal.user_option(usgnid, option)
	local users=permissions.users
	if users[usgnid] then
		if users[usgnid].options[option] then
			return users[usgnid].options[option]
		end
	end
	return false
end

-- @param name Name of the group
-- @param option Option to return
-- @return Returns the option or false
function permissions.func.internal.group_option(name, option)
	local groups=permissions.groups
	if groups[name] then
		if groups[name].options[option] then
			return groups[name].options[option]
		end
	end
	return false
end

function permissions.func.internal.toBoolean(txt)
	if txt == "true" then
		return true
	elseif txt == "false" then
		return false
	end
end

function permissions.output.denied(id)
	msg2(id,"©200000000You don't have permission!")
end

-- @param id Player ID (not necessary)
-- @param message Message (necessary)
function permissions.output.error(id, message)
	if message then
		msg2(id, "©255180180" .. message)
	else
		print("©255180180" .. id)
	end
end

function permissions.output.print(id, message)
	if message then
		msg2(id, "©255255255" .. message)
	else
		print("©255255255" .. id)
	end
end

function permissions.output.found_nnode(id,node) --negated node
	print("[Permissions] User ("..id..") "..player(id,"name").." was checked for \""..node.."\", negated node found!")
end

function permissions.output.found_node(id,node) --positive/normal node
	print("[Permissions] User ("..id..") "..player(id,"name").." was checked for \""..node.."\", node found!")
end

function permissions.func.internal.initarray(x,y)
	local array = {}
	if not y then y = 0 end
	for i = 1, x do
		array[i] = y
	end
	return array
end

function permissions.func.internal.inittables()
	local initarray = perm.func.internal.initarray

	--permissions.cache.perm_nodes = initarray(32, {})
	permissions.cache.perm_nodes = {}
	permissions.cache.user_groups = initarray(32, {})
	permissions.cache.rank = initarray(32)
	permissions.cache.prefix = initarray(32, "")
	permissions.cache.suffix = initarray(32, "")
end