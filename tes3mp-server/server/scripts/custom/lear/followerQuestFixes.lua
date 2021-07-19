--[[
Follower Quest Fixes
version 1.01
----------------------------------------------------------------------
INSTALLATION:
To instal, simply drag this file into your 
	tes3mp-server/server/scripts/custom 
folder, then open your customScripts.lua found in your
	tes3mp-server/server/scripts/
folder. Add the following line to your customScripts.lua file:close
	require("custom.followersQuestFixes")
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

followerQuestFixes = {}

local pushFollowerAiEffect = function(pid, uniqueIndex, refId)
    local cell = logicHandler.GetCellContainingActor(uniqueIndex)
	if cell == nil then return end
	local cellDescription = cell.description
	if cellDescription == nil then return end
	
	if LoadedCells[cellDescription] ~= nil and LoadedCells[cellDescription].data ~= nil and LoadedCells[cellDescription].data.objectData ~= nil then
		local objData = LoadedCells[cellDescription].data.objectData
		if objData[uniqueIndex] ~= nil and objData[uniqueIndex].refId ~= nil and objData[uniqueIndex].refId == refId then
			logicHandler.SetAIForActor(LoadedCells[cellDescription], uniqueIndex, 4, pid)
		end
	end
end

local hasQIndex = function(pid, qId, qIndex)
	if Players[pid].data.journal ~= nil and tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = qId, index = qIndex }, true) then
		return true
	end
	return false
end

customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
	
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
	
		local cell = LoadedCells[cellDescription]
		local isValid = eventStatus.validDefaultHandler
	
		for n,object in pairs(objects) do
			
			local objectUniqueIndex = object.uniqueIndex
			local objectRefId = object.refId
			
			if cell ~= nil and cell.data ~= nil and objectUniqueIndex ~= nil and objectRefId ~= nil then
				
				local forceFollow = false
				
				-- Pemenie and the Boots of Blinding Speed
				if objectRefId == "pemenie" and hasQIndex(pid, "mv_traderabandoned", 20) and not hasQIndex(pid, "mv_traderabandoned", 30) and not hasQIndex(pid, "mv_traderabandoned", 70) and not hasQIndex(pid, "mv_traderabandoned", 90) and not hasQIndex(pid, "mv_traderabandoned", 110) then
					forceFollow = true
				
				-- A Man and His Guar
				elseif (objectRefId == "teris raledran" or objectRefId == "guar_rollie_unique") and hasQIndex(pid, "mv_richtrader", 20) and not hasQIndex(pid, "mv_richtrader", 25) and not hasQIndex(pid, "mv_richtrader", 100) and not hasQIndex(pid, "mv_richtrader", 105) and not hasQIndex(pid, "mv_richtrader", 110) and not hasQIndex(pid, "mv_richtrader", 120) then
					forceFollow = true
				
				-- To the Fields of Kummu	
				elseif objectRefId == "nevrasa dralor" and hasQIndex(pid, "mv_wanderingpilgrim", 30) and not hasQIndex(pid, "mv_wanderingpilgrim", 40) and not hasQIndex(pid, "mv_wanderingpilgrim", 90) and not hasQIndex(pid, "mv_wanderingpilgrim", 110) then
					forceFollow = true
				
				-- An Escort to Molag Mar
				elseif objectRefId == "paur maston" and hasQIndex(pid, "mv_tradermissed", 30) and not hasQIndex(pid, "mv_tradermissed", 40) and not hasQIndex(pid, "mv_tradermissed", 90) and not hasQIndex(pid, "mv_tradermissed", 95) then
					forceFollow = true
				
				-- The Scholars and the Mating Kagouti
				elseif objectRefId == "edras oril" and (hasQIndex(pid, "mv_strayedpilgrim", 43) or hasQIndex(pid, "mv_strayedpilgrim", 45) or hasQIndex(pid, "mv_strayedpilgrim", 48)) and not hasQIndex(pid, "mv_strayedpilgrim", 90) and not hasQIndex(pid, "mv_strayedpilgrim", 110) and not hasQIndex(pid, "mv_strayedpilgrim", 115) then
					forceFollow = true
				
				-- Tul's Escape
				elseif objectRefId == "tul" and hasQIndex(pid, "mv_fakeslave", 40) and not hasQIndex(pid, "mv_fakeslave", 50) and not hasQIndex(pid, "mv_fakeslave", 60) and not hasQIndex(pid, "mv_fakeslave", 70) and not hasQIndex(pid, "mv_fakeslave", 80) and not hasQIndex(pid, "mv_fakeslave", 90) and not hasQIndex(pid, "mv_fakeslave", 100) and not hasQIndex(pid, "mv_fakeslave", 110) then
					forceFollow = true
				
				-- Divided by Nix Hounds
				elseif objectRefId == "drerel indaren" and (hasQIndex(pid, "mv_missingcompanion", 35) or hasQIndex(pid, "mv_missingcompanion", 40)) and not hasQIndex(pid, "mv_missingcompanion", 31) and not hasQIndex(pid, "mv_missingcompanion", 36) and not hasQIndex(pid, "mv_missingcompanion", 50) and not hasQIndex(pid, "mv_missingcompanion", 60) and not hasQIndex(pid, "mv_missingcompanion", 70) then
					forceFollow = true
				
				-- Lead the Pilgrim to Koal Cave
				elseif objectRefId == "fonus rathryon" and hasQIndex(pid, "mv_poorpilgrim", 24) and not hasQIndex(pid, "mv_poorpilgrim", 90) and not hasQIndex(pid, "mv_poorpilgrim", 100) and not hasQIndex(pid, "mv_poorpilgrim", 110) and not hasQIndex(pid, "mv_poorpilgrim", 120) then
					forceFollow = true
				
				-- Viatrix, The Annoying Pilgrim
				elseif objectRefId == "viatrix petilia" and hasQIndex(pid, "mv_richpilgrim", 20) and not hasQIndex(pid, "mv_richpilgrim", 30) and not hasQIndex(pid, "mv_richpilgrim", 95) and not hasQIndex(pid, "mv_richpilgrim", 100) and not hasQIndex(pid, "mv_richpilgrim", 120) and not hasQIndex(pid, "mv_richpilgrim", 130) then
					forceFollow = true
				
				-- Search for Her Father's Amulet
				elseif objectRefId == "satyana" and hasQIndex(pid, "ms_arenimtomb", 50) and not hasQIndex(pid, "ms_arenimtomb", 100) and not hasQIndex(pid, "ms_arenimtomb", 110) then
					forceFollow = true
				
				-- Widowmaker
				elseif objectRefId == "botrir" and hasQIndex(pid, "mv_recoverwidowmaker", 30) and not hasQIndex(pid, "mv_recoverwidowmaker", 40) and not hasQIndex(pid, "mv_recoverwidowmaker", 50)  and not hasQIndex(pid, "mv_recoverwidowmaker", 60)  and not hasQIndex(pid, "mv_recoverwidowmaker", 70)  and not hasQIndex(pid, "mv_recoverwidowmaker", 80)  and not hasQIndex(pid, "mv_recoverwidowmaker", 90) then
					forceFollow = true
				
				-- The Runaway Slave
				elseif objectRefId == "reeh_jah" and (hasQIndex(pid, "mv_runawayslave", 30) or hasQIndex(pid, "mv_runawayslave", 35)) and not hasQIndex(pid, "mv_runawayslave", 36) and not hasQIndex(pid, "mv_runawayslave", 90) and not hasQIndex(pid, "mv_runawayslave", 97) and not hasQIndex(pid, "mv_runawayslave", 103) and not hasQIndex(pid, "mv_runawayslave", 120) and not hasQIndex(pid, "mv_runawayslave", 130) and not hasQIndex(pid, "mv_runawayslave", 140) then
					forceFollow = true
				
				-- Kidnapped by Cultists
				elseif objectRefId == "malexa" and (hasQIndex(pid, "mv_cultistvictim", 40) or hasQIndex(pid, "mv_cultistvictim", 45) or hasQIndex(pid, "mv_cultistvictim", 50)) and not hasQIndex(pid, "mv_cultistvictim", 46) and not hasQIndex(pid, "mv_cultistvictim", 100) and not hasQIndex(pid, "mv_cultistvictim", 110) then
					forceFollow = true
				
				-- The Man Who Spoke to Slaughterfish
				elseif objectRefId == "din" and (hasQIndex(pid, "mv_monsterdisease", 40) or hasQIndex(pid, "mv_monsterdisease", 47)) and not hasQIndex(pid, "mv_monsterdisease", 48) and not hasQIndex(pid, "mv_monsterdisease", 49) and not hasQIndex(pid, "mv_monsterdisease", 50) and not hasQIndex(pid, "mv_monsterdisease", 60) and not hasQIndex(pid, "mv_monsterdisease", 70) then
					forceFollow = true
				end
				
				if forceFollow then
					pushFollowerAiEffect(pid, objectUniqueIndex, objectRefId)
				end
			end
		end
	
		-- End New Additions
		eventStatus.validDefaultHandler = isValid
		return eventStatus
	end
end)

return followerQuestFixes
