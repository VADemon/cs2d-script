unimenu_menus = {}
unimenu_menuPageStrings = {{}}
unimenu_lastOpenedMenu = {}
unimenu_tempData = {}

function unimenu(id, construct, targetMenu, page)
	if not unimenu_menuPageStrings[id] then unimenu_menuPageStrings[id] = {} end
	if not unimenu_tempData[id] then unimenu_tempData[id] = {} end
	
	if targetMenu ~= "current" then
		if construct then
			
			if not unimenu_menus[ targetMenu ] then print("[UniMenu] There's no menu with internal ID '".. tostring(targetMenu) .."'!") return false end
			
			local workMenu, workMenuItems	-- the menu we're will work with			
			if type(targetMenu) == "table" then
				workMenu, workMenuItems = targetMenu, targetMenu.items	
			else
				workMenu, workMenuItems = unimenu_menus[ targetMenu ], unimenu_menus[ targetMenu ].items
			end
			
			unimenu_lastOpenedMenu[id] = targetMenu
			local paget = math.ceil(#workMenuItems/7)
			local menuMode = string.match(workMenu.title, "(@[ib])$") or ""	-- if mode string not found then don't set it

			for i = 1, paget do
			
				unimenu_menuPageStrings[id][i] = string.gsub(workMenu.title, "(@[ib])$", "") .." - Page ".. i .. menuMode .. "," -- replace the menuMode suffix in title with ""
				
				for ii = 1, 7 do
					local sid = ii+(7*(i-1))	-- the current button we're working on
					local menuButtonName, menuButtonDesc, menuButtonData
					
					if workMenuItems[sid] then
					
						-- buttonData - must be executed before bName and bDescription, because the latter may rely on changed data
						if type(workMenuItems[sid][3]) == "table" then
							menuButtonData = workMenuItems[sid][3]
						else
							menuButtonData = workMenuItems[sid][3](id)
							unimenu_tempData[id][sid] = menuButtonData
						end
						-- buttonName
						if type(workMenuItems[sid][1]) == "string" then	-- if it's a string
							menuButtonName = workMenuItems[sid][1]	-- use it
						else
							menuButtonName = workMenuItems[sid][1](id, menuButtonData)	-- if not, it should return the Button name
						end
						-- buttonDescription
						if type(workMenuItems[sid][2]) == "string" then
							menuButtonDesc = workMenuItems[sid][2]
						else
							menuButtonDesc = workMenuItems[sid][2](id, menuButtonData)
						end
						
						
						unimenu_menuPageStrings[id][i] = unimenu_menuPageStrings[id][i] .. menuButtonName .."|".. menuButtonDesc ..","
					else
						unimenu_menuPageStrings[id][i] = unimenu_menuPageStrings[id][i] ..","
					end
				end
				
				if i < paget then 	unimenu_menuPageStrings[id][i] = unimenu_menuPageStrings[id][i] .."Next" end
				if i > 1 then 		unimenu_menuPageStrings[id][i] = unimenu_menuPageStrings[id][i] ..",Back" end
			end
		end
	end
	
	menu(id, unimenu_menuPageStrings[id][page])
end

addhook("menu","unimenuhook")
function unimenuhook(id, menu, sel)
	local p = tonumber(menu:sub(-1))
	
	if sel < 8 and sel > 0 then
		local s = sel + (7 * (p - 1))

		if type(unimenu_lastOpenedMenu[id]) == "table" then
			local buttonData = unimenu_lastOpenedMenu[id].items[3]
			
			if type(buttonData) == "function" then	-- if data is a function, then we have a cached/correct version of it:
				buttonData = unimenu_tempData[id][s]	-- s is same as sid
			end
			
			unimenu_lastOpenedMenu[id].items[s][4](id, buttonData, menu, sel)
		else
		
			local buttonData = unimenu_menus[ unimenu_lastOpenedMenu[id] ].items[s][3]
			
			if type(buttonData) == "function" then	-- if data is a function, then we have a cached/correct version of it:
				buttonData = unimenu_tempData[id][s]	-- s is same as sid
			end
			
			unimenu_menus[ unimenu_lastOpenedMenu[id] ].items[s][4](id, buttonData, menu, sel)
		end
	else
		if sel == 8 then
			unimenu(id, true, "current", p+1)
		elseif sel == 9 then
			unimenu(id, true, "current", p-1)
		end
	end
end

-- Clear UniMenu temporary player data
addhook("leave", "unimenu_leave")
function unimenu_leave(id)
	unimenu_menuPageStrings[id] = nil
	unimenu_tempData[id] = nil
	unimenu_lastOpenedMenu[id] = nil
end

-- @param umid: Internal identifier, which you will need to open that menu. If you don't specify it, you have to save the returned value and use it instead
-- @param title: Menu's title, may end with @b and @i
-- @param items: (optional) put the ready UniMenu-compatible table with buttons here
-- @return	If argument umid was specified then it equals umid, if umid is nil then the return is a number value
function unimenu_newMenu(umid, title, items)
	if not umid then 
		umid = #unimenu_menus + 1
	end
	
	if not unimenu_menus[ umid ] then
		unimenu_menus[ umid ] = {
			["title"] = title,
			["items"] = {}
		}
		
		if type(items) ~= "nil" and type(items) == "table" then
			unimenu_menus[ umid ]["items"] = items
		else
			print("[UniMenu] Could not create a new menu (" .. umid .."), type of argument 'items' is invalid, must be a table!")
		end
		
		return umid
	else
		print("[UniMenu] Could not create a new menu, menu with umid ".. umid .." already exists!")
	end
	
	return false
end

-- @param umid: Internal identifier, which you need to open a menu.
-- @param buttonName: (string or function) button text on the left side
-- @param buttonDesc: (string or function) button description, grey text on the right side
-- @param data: (table or nil) This table will be passed as an argument to the func function
-- @param func: function which will be called when the button is pressed

-- @param initButtonName if TRUE, call the function buttonName with id=0 and data and save the returned string value to menu's buttonName
-- @param initButtonDesc same as initButtonName
-- @param initButtonData same as initButtonName. Note that this is called before buttonName and ButtonDesc are initialized, so both bName and bDesc are going to have the same data to operate with
function unimenu_addButton(umid, buttonName, buttonDesc, data, func, initButtonName, initButtonDesc, initData)
	if umid and unimenu_menus[ umid ] then
		local newPointer = #unimenu_menus[ umid ].items + 1
		data = data or {}
		
		if (type(buttonName) ~= "string" and type(buttonName) ~= "function") or (type(buttonDesc) ~= "string" and type(buttonDesc) ~= "function") or type(func) ~= "function" then
			print("[UniMenu] Could not add a button to menu, one or more button descriptors are invalid!")
			return false
		end
		
		-- initialize means call the function and save the returned results in the table
		-- data must be initialized FIRST! because ButtonName and ButtonDesc may rely on data's values
		if initData and type(data) == "function" then
			data = data()
		end
		
		if initButtonName and type(buttonName) == "function" then
			buttonName = buttonName(0, data)
		end

		if initButtonDesc and type(buttonDesc) == "function" then
			buttonDesc = buttonDesc(0, data)
		end
		
		unimenu_menus[ umid ].items[ newPointer ] = {buttonName, buttonDesc, data, func}
		
		return true
	else
		print("[UniMenu] Could not add a button to menu, umid was not specified or is invalid!")
	end
	
	return false
end