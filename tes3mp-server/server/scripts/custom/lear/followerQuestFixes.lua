--[[
Follower Quest Fixes
version 1.0
----------------------------------------------------------------------
INSTALLATION:

To instal, simply drag this file into your 
	tes3mp-server/server/scripts/custom 
folder, then open your customScripts.lua found in your
	tes3mp-server/server/scripts/
folder. Add the following line to your customScripts.lua file:close
	require("custom.followerQuestFixes")
save, close the file and you're done.

----------------------------------------------------------------------
INFORMATION:
This script is aimed to resolve bugs with quests that involve certain characters following you.
The bug consist of NPCs from escord quests no longer following you should your server crash or restart mid escorting.
Players simply talk to the NPC again once they log in, and the NPC will continue following them.

Affected NPCs are from the following quests:

	- A Man and His Guar
    - An Escort to Molag Mar
    - Divided by Nix Hounds
    - Kidnapped by Cultists
    - Lead the Pilgrim to Koal Cave
    - Pemenie and the Boots of Blinding Speed
    - Search for Her Father's Amulet
    - The Man Who Spoke to Slaughterfish
    - The Runaway Slave
    - The Scholars and the Mating Kagouti
    - To the Fields of Kummu
    - Tul's Escape
    - Viatrix, The Annoying Pilgrim
    - Widowmaker


]]

local split = function(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
	local name = Players[pid].name:lower()
	local cell = LoadedCells[cellDescription]
	local cell = LoadedCells[cellDescription]

	local isValid = eventStatus.validDefaultHandler

    for n,object in pairs(objects) do
		
		local index = n-1
        local temp = split(object["uniqueIndex"], "-")
        local RefNum = temp[1]
        local MpNum = temp[2]
		
		local objectUniqueIndex = object.uniqueIndex
		local objectRefId = object.refId
		
	-- Pemenie and the Boots of Blinding Speed
		if objectRefId == "pemenie" and tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_traderabandoned", index = 20 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_traderabandoned", index = 30 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_traderabandoned", index = 70 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_traderabandoned", index = 90 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_traderabandoned", index = 110 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			-- (1 == wanders..?) | (2 == attacks player) | (3 == retreat..?) | (4 == follow target) |
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end
		
		
	-- A Man and His Guar
		if (objectRefId == "teris raledran" or objectRefId == "guar_rollie_unique") and tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richtrader", index = 20 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richtrader", index = 25 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richtrader", index = 100 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richtrader", index = 105 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richtrader", index = 110 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richtrader", index = 120 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			-- (1 == wanders..?) | (2 == attacks player) | (3 == retreat..?) | (4 == follow target) |
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end
		
		
	-- To the Fields of Kummu	
		if objectRefId == "nevrasa dralor" and tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_wanderingpilgrim", index = 30 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_wanderingpilgrim", index = 40 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_wanderingpilgrim", index = 90 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_wanderingpilgrim", index = 110 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end
		
		
	-- An Escort to Molag Mar
		if objectRefId == "paur maston" and tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_tradermissed", index = 30 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_tradermissed", index = 40 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_tradermissed", index = 90 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_tradermissed", index = 95 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end
		
		
	-- The Scholars and the Mating Kagouti	
		if objectRefId == "edras oril" and (tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_strayedpilgrim", index = 43 }, true) or tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_strayedpilgrim", index = 45 }, true) or tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_strayedpilgrim", index = 48 }, true)) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_strayedpilgrim", index = 90 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_strayedpilgrim", index = 110 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_strayedpilgrim", index = 115 }, true) then 
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end
		
		
	-- Tul's Escape
		if objectRefId == "tul" and 
		tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_fakeslave", index = 40 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_fakeslave", index = 50 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_fakeslave", index = 60 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_fakeslave", index = 70 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_fakeslave", index = 80 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_fakeslave", index = 90 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_fakeslave", index = 100 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_fakeslave", index = 110 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end	
		
		
	-- Divided by Nix Hounds
		if objectRefId == "drerel indaren" and (tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_missingcompanion", index = 35 }, true) or tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_missingcompanion", index = 40 }, true)) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_missingcompanion", index = 31 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_missingcompanion", index = 36 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_missingcompanion", index = 50 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_missingcompanion", index = 60 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_missingcompanion", index = 70 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end	
		
		
	-- Lead the Pilgrim to Koal Cave
		if objectRefId == "fonus rathryon" and tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_poorpilgrim", index = 24 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_poorpilgrim", index = 90 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_poorpilgrim", index = 100 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_poorpilgrim", index = 110 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_poorpilgrim", index = 120 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end	
		
		
	-- Viatrix, The Annoying Pilgrim
		if objectRefId == "viatrix petilia" and 
		tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richpilgrim", index = 20 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richpilgrim", index = 30 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richpilgrim", index = 95 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richpilgrim", index = 100 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richpilgrim", index = 120 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_richpilgrim", index = 130 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end	
		
		
	-- Search for Her Father's Amulet
		if objectRefId == "satyana" and 
		tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "ms_arenimtomb", index = 50 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "ms_arenimtomb", index = 100 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "ms_arenimtomb", index = 110 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end	
		
		
	-- Widowmaker
		if objectRefId == "botrir" and 
		tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_recoverwidowmaker", index = 30 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_recoverwidowmaker", index = 40 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_recoverwidowmaker", index = 50 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_recoverwidowmaker", index = 60 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_recoverwidowmaker", index = 70 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_recoverwidowmaker", index = 80 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_recoverwidowmaker", index = 90 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end	
		
		
	-- The Runaway Slave
		if objectRefId == "reeh_jah" and (tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_runawayslave", index = 30 }, true) or tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_runawayslave", index = 35 }, true)) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_runawayslave", index = 36 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_runawayslave", index = 90 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_runawayslave", index = 97 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_runawayslave", index = 103 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_runawayslave", index = 120 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_runawayslave", index = 130 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_runawayslave", index = 140 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end	
		
		
	-- Kidnapped by Cultists
		if objectRefId == "malexa" and 
		(tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_cultistvictim", index = 40 }, true) or tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_cultistvictim", index = 45 }, true) or tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_cultistvictim", index = 50 }, true)) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_cultistvictim", index = 46 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_cultistvictim", index = 100 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_cultistvictim", index = 110 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end	
		
		
	-- The Man Who Spoke to Slaughterfish
		if objectRefId == "din" and 
		(tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_monsterdisease", index = 40 }, true) or tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_monsterdisease", index = 47 }, true)) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_monsterdisease", index = 48 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_monsterdisease", index = 49 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_monsterdisease", index = 50 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_monsterdisease", index = 60 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_monsterdisease", index = 70 }, true) then
			
			local player = pid
			if objectUniqueIndex == nil then return end
			if cell == nil then return end
			if player == nil then return end
			
			-- -- (1 == wanders..?) | (2 == attacks player) | (3 == retreat..?) | (4 == follow target) |
			logicHandler.SetAIForActor(cell, objectUniqueIndex, 4, player)
		end	
		

    end
	-- End New Additions
	eventStatus.validDefaultHandler = isValid
    return eventStatus
end)
