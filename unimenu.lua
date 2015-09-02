unimenu_menus = {}
unimenu_menuPageStrings = {{}}
unimenu_lastOpenedMenu = {}

function unimenu(id, construct, targetMenu, page)
	if not unimenu_menuPageStrings[id] then unimenu_menuPageStrings[id] = {} end
	
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
					local menuButtonName, menuButtonDesc
					
					if workMenuItems[sid] then
						if type(workMenuItems[sid][1]) == "string" then	-- if it's a string
							menuButtonName = workMenuItems[sid][1]	-- use it
						else
							menuButtonName = workMenuItems[sid][1](id, workMenuItems[sid][3])	-- if not, it should return the Button name
						end
						if type(workMenuItems[sid][2]) == "string" then
							menuButtonDesc = workMenuItems[sid][2]
						else
							menuButtonDesc = workMenuItems[sid][2](id, workMenuItems[sid][3])
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
			unimenu_lastOpenedMenu[id].items[s][4](id, unimenu_lastOpenedMenu[id].items[3], menu, sel)
		else
			unimenu_menus[ unimenu_lastOpenedMenu[id] ].items[s][4](id, unimenu_menus[ unimenu_lastOpenedMenu[id] ].items[s][3], menu, sel)
		end
	else
		if sel == 8 then
			unimenu(id, true, "current", p+1)
		elseif sel == 9 then
			unimenu(id, true, "current", p-1)
		end
	end
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
		
		if items and type(items) == "table" then
			unimenu_menus[ umid ]["items"] = items
		else
			print("[UniMenu] Could not create a new menu, type of argument 'items' is invalid, must be a table!")
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
function unimenu_addButton(umid, buttonName, buttonDesc, data, func)
	if umid and unimenu_menus[ umid ] then
		local newPointer = #unimenu_menus[ umid ].items + 1
		data = data or {}
		
		if (type(buttonName) ~= "string" and type(buttonName) ~= "function") or (type(buttonDesc) ~= "string" and type(buttonDesc) ~= "function") or type(func) ~= "function" then
			print("[UniMenu] Could not add a button to menu, one or more button descriptors are invalid!")
			return false
		end
		
		unimenu_menus[ umid ].items[ newPointer ] = {buttonName, buttonDesc, data, func}
		
		return true
	else
		print("[UniMenu] Could not add a button to menu, umid was not specified or is invalid!")
	end
	
	return false
end