permissions.groups = {
	default = {
		options = {
			rank = 0, --the default value
			suffix = " [Player]" -- suffix to be used by chat plugins
		},
		permissions = {
			"testscript.command.laugh", --gives permission for command !laugh
			"testscript.command.stopit",
			["testscript.command.newbie"] = true,
			["testscript.count.banana"] = 10, --value (f.ex. you can have 10 bananas)
			["testscript.command.noob"] = false --negates all another "testscript.command.noob" nodes for a player. The player loses the permission to use  !noob
		}
	},
	member = {
		options = {
			rank = 500,
			prefix = "[Member] "
		},
		permissions = {
			"testscript.command.laugh",
			"testscript.command.stopit",
			["testscript.count.banana"] = 15,
			["testscript.command.noob"] = true -- ["testscript.command.noob"] = true    is the same as adding  "testscript.command.noob" without " = true"
		},
		inheritance = {"default"},  --gives all _default_ group's permissions to this group (_member_)
		map = {
			de_dust = {
				permissions = {
					"testscript.command.awesome",  --allows command "!awesome" only on the de_dust map
					"testscript.command.money"  --another random permission node
				}
			}
		}
	},
	admin = {
		options = {
			prefix = "[Admin] ",
			suffix = " \"Pro\" ",
			rank = 1000
		},
		permissions = {
			"testscript.command.laugh",
			"testscript.command.stopit",
			["testscript.count.banana"] = 50,
			"testscript.command.noob",
			"testscript.command.hammer",
			"permissions.command.group1s"
		},
		inheritance = {"default","member"}  -- group _admin_ have all these permissions added up
	}
}

permissions.users = {
	--There are users' groups.
	[7844] = { --user with USGN ID 7844
		group = {"admin"}, -- groups "admin", "default" and "member" because of inheritance
		options = {  --single user's options override groups' options
			prefix = "[Chef] ",  --no suffix here. the suffix from group admins will be used
			rank = 100
		},
		permissions = {
			"testscript.command.ballz" --only avaible for user 7844
		}		
	},
	[1337] = {
		group = {"member"}, -- groups "member" and "default"
		options = {
			prefix = "©128200000[l33t] ",
			rank = 1337
		}
	}
}