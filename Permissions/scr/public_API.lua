-- @param id Player's ID
-- @param node Perm.node to check
-- @param custom_message (Boolean) Use own error message?
-- Checks a player for a permissions node
function permissions.check(id, node, custom_message)
	if perm.cache.perm_nodes[id][node] then
		return true
	end
	
	if not custom_message then
		perm.output.denied(id)
	end
	
	return false
end


--GET

function permissions.get.prefix(id)
	return permissions.cache.prefix[id]
end

function permissions.get.rank(id)
	return permissions.cache.rank[id]
end

function permissions.get.suffix(id)
	return permissions.cache.suffix[id]
end

-- @return Requested option or nil
function permissions.get.userOption(usgn, option)
	if permissions.misc.userExist(usgn) and permissions.users[usgn].options then
		return permissions.users[usgn].options[option] or ""
	end
end

-- @return Requested option or nil
function permissions.get.groupOption(name, option)
	if permissions.misc.groupExist(name) and permissions.groups[name].options then
		return permissions.groups[name].options[option] or ""
	end
end


-- ADD


function permissions.add.groupNode(name, node, value)
	if not permissions.func.internal.check_group_nodes(name) then
		if not permissions.group_exist(usgn) then
			print("©255180180[Permissions] Group \""..name.."\" doesn't exist, creating...")
			perm.groups[name] = {}
		end
		
		perm.groups[name].permissions = {}
	end
	
	perm.groups[name].permissions[node] = value
	
	print("©255255255[Permissions] Node "..node.." = "..tostring(value).." was added to group \""..name.."\"!")
end

-- @param usgn Player USGN
-- @param node Node to add
-- @param value Positive/negative/a value node? True: "give" permission, false: "take" permission (aka ["node"] = false); or use any other value
function permissions.add.userNode(usgn, node, value)
	if not permissions.func.internal.check_user_nodes(usgn) then
		if not permissions.player_exist(usgn) then
			perm.users[usgn] = {}
		end
		
		perm.users[usgn].permissions = {}
	end
	
	perm.users[usgn].permissions[node] = value --@@check if nil
	perm.save()
	
	print("©255255255[Permissions] Node "..node.." = "..tostring(value).." was added to user \'"..usgn.."\'!")
	
	return true
end

-- @param name Group Name
-- @param parent (String) Group to add as a parent
function permissions.add.groupParent(name, parent)
	if permissions.misc.groupExist(name) then
		if type(parent)=="string" then
			if permissions.misc.groupExist(parent) then
				if permissions.groups[name].inheritance then
					for k,v in pairs(permissions.groups[name].inheritance) do
						if v == parent then
							return false, parent.. " is already a parent group of "..name.."!"
						end
					end
					
					permissions.groups[name].inheritance[ #permissions.groups[name].inheritance + 1 ] = parent
					return true
				end
			else
				return false, "Group \""..parent"\" doesn't exist!"
			end
		else
			return false, "Parent name must be a string!"
		end
	else
		return false, "Group doesn't exist!"
	end
	
end


-- SET

function permissions.set.groupOption(name, option, value)
	if permissions.misc.groupExist(name) then
		if not permissions.groups[name].options then
			permissions.groups[name].options = {}
		end
		
		permissions.groups[name].options[option] = value
		perm.save()
		
		print("©255255255[Permissions] Option " ..option.." = \'" ..value.. "\' was set for group \'" ..name.. "\'!")
		
		return true
	else
		return false, 1
	end
end

function permissions.set.userOption(usgn, option, value)
	if permissions.misc.userExist(usgn) then
		if not permissions.users[usgn].options then
			permissions.users[usgn].options = {}
		end
		
		permissions.users[usgn].options[option] = value
		perm.save()
		
		print("©255255255[Permissions] Option " ..option.." = \'" ..value.. "\' was set for user " ..usgn.. "!")
		
		return true
	else
		return false, 1
	end
end


-- CREATE

-- @param name Group name
-- @param parent (Optional) Inheritance for the group (table)
function permissions.create.group(name, parent)
	if permissions.misc.groupExist(name) then
		permissions.output.error("[Permissions] Group " ..name.. " already exists!")
		return false, "[Permissions] Group " ..name.. " already exists!"
	end
	
	permissions.groups[name] = {}
	
	if type(parent)=="table" then

		if permissions.misc.checkGroupsExist(parent) then
			permissions.groups[name].inheritance = parent
		else
			perm.output.error("[Permissions] Adding a parent to a created group failed: group doesn't exist!")
		end
		
	else
		perm.output.error("[Permissions] Adding a parent to a created group failed: not a table!") --better we don't do a shit even if it's a single group (string)
	end
	
	return true
end

-- @param usgn User usgn
-- @param group (Optional) User's group or default group if not specified
function permissions.create.user(usgn, group)
	if permissions.misc.userExist(usgn) then
		permissions.output.error("[Permissions] User " ..usgn.. " already exists!")
		return false, "[Permissions] User " ..usgn.. " already exists!"
	end
	
	permissions.users[usgn] = {}
	
	if type(group)=="table" then

		if permissions.misc.checkGroupsExist(group) then
			permissions.users[usgn].groups = group
		else
			perm.output.error("[Permissions] Assigning groups to a created user (" ..usgn..") failed: group doesn't exist!")
		end
		
	elseif type(group)=="string" then
		permissions.users[usgn].groups = {group}
	else
		perm.output.error("[Permissions] Assigning a group to a created user failed: not a table//string!")
	end
	
	return true
end


-- DELETE

function permissions.delete.group(name)  --@@print all data of the deleted group/user
	if perm.groups[name] then
		permissions.output.print("[Permissions] Deleted group \'" ..name.. "\'!")
		permissions.groups[name] = nil
		return true
	else
		perm.output.print("[Permissions] Group \'" ..name.. "\' doesn't exist!")
		return false
	end
end


function permissions.delete.user(usgn)  --@@print all data of the deleted group/user
	if perm.users[usgn] then
		permissions.output.print("[Permissions] Deleted user (" ..usgn.. ")!")
		permissions.users[usgn] = nil
		return true
	else
		perm.output.print("[Permissions] User (" ..name.. ") doesn't exist!")
		return false
	end
end


-- MISC

-- @param gname (string) Group name
-- @return (boolean) True if the group exists
function permissions.misc.groupExist(name)
	if permissions.groups[name] then
		return true
	end
	return false
end

-- @param usgn (number) Player USGN
-- @return (boolean) True if the player's custom entry exists
function permissions.misc.playerExist(usgn) --strange name xD
	if permissions.users[usgn] then
		return true
	end
	return false
end

-- @param groups (Table) List with groups to check existance
-- @return (boolean) True if all groups exist, false otherwise
function permissions.misc.checkGroupsExist(groups) -- multiple groups ONLY! |groupExist
	for k,v in pairs(groups) do
		if not permissions.misc.groupExist(v) then
			return false
		end
	end
	
	return true
end

