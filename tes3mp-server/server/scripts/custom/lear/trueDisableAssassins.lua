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
	-- Unused
	--local name = Players[pid].name:lower()
	--local cell = LoadedCells[cellDescription]

	-- Checks
	if eventStatus.validDefaultHandler == false then return eventStatus end
	-- Don't need to do anything if the chance is 0
	if dbAssassinsConfig.spawnChance == 0 then return eventStatus end

    for n,object in pairs(objects) do
		-- If the object is a bed
		if tableHelper.containsValue(listOfBeds, object.refId) then
			-- If the player haven't started the quest yet
			if not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "tr_dbattack", index = 10 }, true) then
				-- Stop the client script, does this need to run again?
				logicHandler.RunConsoleCommandOnPlayer(pid, "stopscript dbAttackScript")
				-- Are they high enough level
				if Players[pid].data.stats.level >= dbAssassinsConfig.levelRequirement then
					local rolledDie = math.random(1, 100)
					if rolledDie <= dbAssassinsConfig.spawnChance then -- <= rolledDie then
						tes3mp.MessageBox(pid, -1, "You are interrupted by a loud noise.")
						logicHandler.CreateObjectAtPlayer(pid, "db_assassin4", "spawn")
						logicHandler.RunConsoleCommandOnPlayer(pid, "Journal TR_DBAttack 10")
					end
				end
			end
		end
    end
    return eventStatus
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	-- Does this run late enough?
	logicHandler.RunConsoleCommandOnPlayer(pid, "stopscript dbAttackScript")
end)

customEventHooks.registerHandler("OnServerInit", function(eventStatus)

	tes3mp.LogMessage(enumerations.log.INFO, "trueDisableAssassins Init")

	-- Really we only need to run this one
	if dbAssassinsConfig.spawnChance > 100 then	
		dbAssassinsConfig.spawnChance = 100
	end
	if dbAssassinsConfig.spawnChance < 0 then
		dbAssassinsConfig.spawnChance = 0
	end
end)

