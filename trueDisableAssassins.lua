local dbAssassinsConfig = {}

dbAssassinsConfig.levelRequirement = 30 -- This sets the level required to spawn an Assassin when a player uses a bed.
dbAssassinsConfig.spawnChance = 100 -- This is the percentage that an Assassin will spawn when the above set leveled player uses a bed.
									-- Example: Set this to 100 for 100% chance, 50 for a 50% chance, etc. and 0 for Assassins to never spawn.
--[[
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DO NOT EDIT BEYOND THIS, UNLESS YOU KNOW WHAT YOU'RE DOING.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DO NOT EDIT BEYOND THIS, UNLESS YOU KNOW WHAT YOU'RE DOING.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DO NOT EDIT BEYOND THIS, UNLESS YOU KNOW WHAT YOU'RE DOING.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
]]

local Methods = {}

local split = function(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local listOfBeds = { 
"active_de_r_bed_02",
"active_de_p_bed_28",
"active_de_bed_29",
"active_de_bed_30",
"active_com_bunk_02",
"active_com_bunk_01",
"active_com_bed_03",
"active_com_bed_07",
"active_com_bed_06",
"active_com_bed_05",
"active_com_bed_04",
"active_com_bed_02",
"active_com_bed_01",
"active_de_pr_bed_27",
"active_de_pr_bed_26",
"active_de_pr_bed_25",
"active_de_pr_bed_24",
"active_de_pr_bed_23",
"active_de_pr_bed_22",
"active_de_pr_bed_21",
"active_de_r_bed_20",
"active_de_r_bed_19",
"active_de_r_bed_18",
"active_de_r_bed_17",
"active_de_p_bed_16",
"active_de_p_bed_15",
"active_de_p_bed_14",
"active_de_p_bed_13",
"active_de_p_bed_12",
"active_de_p_bed_11",
"active_de_p_bed_10",
"active_de_p_bed_09",
"active_de_pr_bed_08",
"active_de_pr_bed_07",
"active_de_r_bed_06",
"active_de_p_bed_05",
"active_de_p_bed_04",
"active_de_p_bed_03",
"active_de_r_bed_01",
--"active_kolfinna_beddisable", -- Disabled due to having a unique script.
--"active_kolfinna_bedenable", -- Disabled due to having a unique script.
--"CharGen_Bed", -- Disabled due to having a unique script.
"active_de_bedroll"
 }


customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
	local name = Players[pid].name:lower()
	local cell = LoadedCells[cellDescription]

	local isValid = eventStatus.validDefaultHandler

    for n,object in pairs(objects) do

		local index = n-1
        local temp = split(object["uniqueIndex"], "-")
        local RefNum = temp[1]
        local MpNum = temp[2]
		
		for id, bedObject in pairs(listOfBeds) do
			if object.refId == bedObject then	
				if not tableHelper.containsKeyValuePairs(currentPlayer.data.journal, { quest = "tr_dbattack", index = 10 }, true) then
					logicHandler.RunConsoleCommandOnPlayer(pid, "stopscript dbAttackScript")
					if (Players[pid].data.customVariables.dbAttackCheck == nil and Players[pid].data.stats.level >= dbAssassinsConfig.levelRequirement) then
						tes3mp.MessageBox(pid, -1, color.MsgBox .. "Test.")
						if dbAssassinsConfig.spawnChance > 100 then	
							dbAssassinsConfig.spawnChance = 100
						end
							
						if dbAssassinsConfig.spawnChance > 0 then
							local rolledDie = math.random(0, 100)
							if rolledDie <= dbAssassinsConfig.spawnChance then -- <= rolledDie then
								tes3mp.MessageBox(pid, -1, color.MsgBox .. "You are interrupted by a loud noise.")
								--logicHandler.RunConsoleCommandOnPlayer(pid, "PlaceAtPC \"db_assassin4\" 1 128 1")
								logicHandler.CreateObjectAtPlayer(pid, "db_assassin4", "spawn")
								logicHandler.RunConsoleCommandOnPlayer(pid, "Journal TR_DBAttack 10")
								Players[pid].data.customVariables.dbAttackCheck = 1
								--logicHandler.RunConsoleCommandOnPlayer(pid, "Journal TR_DBAttack 20")
							end
						else
							return
						end
					else
						logicHandler.RunConsoleCommandOnPlayer(pid, "stopscript dbAttackScript")
					end
				end
			end
		end

    end
	eventStatus.validDefaultHandler = isValid
    return eventStatus
end)

return Methods