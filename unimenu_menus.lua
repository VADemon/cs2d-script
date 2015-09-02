-- OLD METHOD OF CREATING MENUS - A LOT OF TIME REQUIRED TO MAKE A LITTLE CHANGE

unimenu_menus["example_menu_old"] = {
	title = "Weapon Shop - OLD@b",
	items = {
		{"AK-47","$2500",{}, function(id)
			if player(id,"money")>=2500 then
				parse("equip "..id.." 30")
				parse("setmoney "..id.." "..player(id,"money")-2500)
			else
				msg2(id,"You don't have enough money!") 
			end
		end},
		{"AWP","$3000", {}, function(id)
			if player(id,"money")>=3000 then
				parse("equip "..id.." 35")
				parse("setmoney "..id.." "..player(id,"money")-3000)
			else
				msg2(id,"You don't have enough money!")
			end
		end},
		{"M4A1","$2600", {}, function(id)
			if player(id,"money")>=2600 then
				parse("equip "..id.." 32")
				parse("setmoney "..id.." "..player(id,"money")-2600)
			else
				msg2(id,"You don't have enough money!")
			end
		end},
		{"Five-Seven","$500", {}, function(id)
			if player(id,"money")>=500 then
				parse("equip "..id.." 6")
				parse("setmoney "..id.." "..player(id,"money")-500)
			else
				msg2(id,"You don't have enough money!") 
			end
		end},
		{"Message: Red","$10", {}, function(id)
			parse("setmoney "..id.." "..player(id,"money")-10)
			msg("©255000000Red Message")
		end},
		{"Message: Green","$10", {}, function(id)
			parse("setmoney "..id.." "..player(id,"money")-10)
			msg("©000255000Green Message")
		end},
		{"Message: Blue","$10", {}, function(id)
			parse("setmoney "..id.." "..player(id,"money")-10)
			msg("©000000255Blue Message")
		end},
		{"Message: White","$10", {}, function(id)
			parse("setmoney "..id.." "..player(id,"money")-10)
			msg("©255255255White Message")
		end},
		{"Message: Black","$10", {}, function(id)
			parse("setmoney "..id.." "..player(id,"money")-10)
			msg("©000000000Black Message")
		end},
		
		{"Set money", "$1337", {money = 1337}, function (id, data)
			parse("setmoney ".. id .." ".. data.money)
		end},	
		{"Set money", "$9000", {}, function (id, data)
			parse("setmoney ".. id .." 9000")
		end}
	},
}



-- NEW METHOD OF CREATING MENUS

do	-- to eliminate the copy-paste job, we'll use locals so we can edit the menuID by changing a single line
	local menuID = "example_menu_new"
	unimenu_newMenu(menuID, "Weapon Shop - NEW@b")
	
	
	local weaponName = function (id, data)	-- we'll use this function as buttonName
		return data.weapon
	end
	
	local weaponPrice = function (id, data)	-- this is for buttonDesc-ription
		return "$" .. data.price
	end
	
	local onClick = function (id, data)	-- equip weapon and set money based on the data values
		local weaponName, weaponPrice, weaponID = data.weapon, data.price, data.id
		
		if player(id,"money") >= weaponPrice then
			parse("equip "..id.." " .. weaponID)
			parse("setmoney "..id.." "..player(id,"money") - weaponPrice)
		else
			msg2(id,"You don't have enough money to buy '".. weaponName .."'!")
		end
	end
	
	unimenu_addButton(menuID, weaponName, weaponPrice, {weapon = "AK-47", price = 2500, id = 30}, onClick)
	unimenu_addButton(menuID, weaponName, weaponPrice, {weapon = "AWP", price = 3000, id = 35}, onClick)
	unimenu_addButton(menuID, weaponName, weaponPrice, {weapon = "M4A1", price = 2600, id = 32}, onClick)
	unimenu_addButton(menuID, weaponName, weaponPrice, {weapon = "Five-Seven", price = 500, id = 6}, onClick)
	
	
	local messageColorName = function (id, data)
		return data.colorName .. " colored message"
	end
	local messageColorPrice = function (id, data)
		return "$" .. data.price
	end
	local messageOnClick =  function (id, data)
		local colorName, color, price = data.colorName, data.colorcode, data.price
		
		if player(id,"money") >= price then
			msg("©".. color .."Hello, this is a ".. colorName .."!")
			parse("setmoney "..id.." "..player(id,"money") - price)
		else
			msg2(id,"You don't have enough money to send a '".. colorName .."'!")
		end
	end
	
	unimenu_addButton(menuID, messageColorName, messageColorPrice, {colorName = "Red", colorcode = "255000000", price = 50}, messageOnClick)
	unimenu_addButton(menuID, messageColorName, messageColorPrice, {colorName = "Green", colorcode = "000255000", price = 30}, messageOnClick)
	unimenu_addButton(menuID, messageColorName, messageColorPrice, {colorName = "Blue", colorcode = "000000255", price = 20}, messageOnClick)
	unimenu_addButton(menuID, messageColorName, messageColorPrice, {colorName = "White", colorcode = "255255255", price = 250}, messageOnClick)
	unimenu_addButton(menuID, messageColorName, messageColorPrice, {colorName = "Black", colorcode = "000000000", price = 100}, messageOnClick)
	
	local setMoney = function (id, data)
		parse("setmoney ".. id .." ".. data.money)
	end
	
	unimenu_addButton(menuID, "Set money", "$1337", {money = 1337}, setMoney)
	unimenu_addButton(menuID, "Set money", "$9000", {money = 9000}, setMoney)
end

-- add more of those  * do ... end * blocks if you need more menus.

