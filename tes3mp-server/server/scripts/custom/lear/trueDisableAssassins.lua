local dbAssassinsConfig = {}

dbAssassinsConfig.levelRequirement = 30 -- This sets the level required to spawn an Assassin when a player uses a bed.
dbAssassinsConfig.spawnChance = 100 -- This is the percentage that an Assassin will spawn when the above set leveled player uses a bed.
					-- Example: Set this to 100 for 100% chance, 50 for a 50% chance, etc. and 0 for Assassins to never spawn.
dbAssassinsConfig.onlySpawnOnce = true -- When true, players will only be attacked by assassins once.

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
	
		for id, bedObject in pairs(listOfBeds) do
			if object.refId == bedObject then	
				
				-- If Lear variables dont exist, create them.
				if Players[pid].data.customVariables.lear == nil then
					Players[pid].data.customVariables.lear = {}
				end
				if Players[pid].data.customVariables.lear.questFixes == nil then
					Players[pid].data.customVariables.lear.questFixes = {}
				end
				
				-- Continue with script.
				if not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "tr_dbattack", index = 50 }, true) then
					if not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "tr_dbattack", index = 10 }, true) then
						logicHandler.RunConsoleCommandOnPlayer(pid, "stopscript dbAttackScript")
						if ((Players[pid].data.customVariables.lear.questFixes.dbAttackCheck == nil or dbAssassinsConfig.onlySpawnOnce == false) and Players[pid].data.stats.level >= dbAssassinsConfig.levelRequirement) then
							
							if dbAssassinsConfig.spawnChance > 100 then	
								dbAssassinsConfig.spawnChance = 100
							end
								
							if dbAssassinsConfig.spawnChance > 0 then
								local rolledDie = math.random(0, 100)
								if rolledDie <= dbAssassinsConfig.spawnChance then -- <= rolledDie then
									tes3mp.MessageBox(pid, -1, "You are interrupted by a loud noise.")
									logicHandler.CreateObjectAtPlayer(pid, "db_assassin4", "spawn")
									logicHandler.RunConsoleCommandOnPlayer(pid, "Journal TR_DBAttack 10")
									Players[pid].data.customVariables.lear.questFixes.dbAttackCheck = 1
								end
							end
						end
					end
				end
				
				break
				
			end
		end

    end
	eventStatus.validDefaultHandler = isValid
    return eventStatus
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	logicHandler.RunConsoleCommandOnPlayer(pid, "stopscript dbAttackScript")
end)


return Methods
