--[[

Quest Fixes
questFixes.lua
	version 1.0


INCLUDES:
Azura's Quest (DA_Azura) Fix	-	This script will spawn Staada when a player who has the quest logged approaches the island in the Sheogorad region.

----------------------------------------------------------------------
INSTALLATION:

To instal, simply drag this file into your 
	tes3mp-server/server/scripts/custom 
folder, then open your customScripts.lua found in your
	tes3mp-server/server/scripts/
folder. Add the following line to your customScripts.lua file:close
	require("custom.questFixes")
save, close the file and you're done.

----------------------------------------------------------------------
INFORMATION:

When approaching the Staada location, Staada will spawn assuming the player has the quest logged and not completed.
By default, Staadas respawn is set to 15 minutes, so the same player wont spawn Staada repetitively.
If Staada is already up, Staada will be deleted before respawning.

]]

local Methods = {}

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, previousCellDescription, currentCellDescription)

-- Azura's Quest (DA_Azura) Fix
	-- Azuras Star Quest Spawn Staada
	-- If player enters nearby cells of staada's location:
	if currentCellDescription == "3, 23" or currentCellDescription == "2, 24" or currentCellDescription == "2, 23" or currentCellDescription == "3, 24" then
		-- If player has the appropriate quest index only:
		if hasJournalIndex(pid, "da_azura", 10) and not hasJournalIndex(pid, "da_azura", 20) then
			
			local targetRefId = "golden saint_staada" -- creature or npc id.
			local respawnTime = 900 -- respawn time in seconds.
			local spawnOrPlace = "spawn" -- "spawn" for creatures or "place" for NPCs
			local refIdVariable = "golden_saint_staada" --  This is what is saved within the world file for the respawn timer
			
			local destination = "3, 24" -- Cell to spawn creature/NPC in.
			local location = {posX = 29314.740234, posY = 197027.375000, posZ = 352.015381, rotX = 0, rotY = 0, rotZ = 0} -- Position to spawn creature/NPC in.
		
			local serverTime = os.time() --tonumber(os.date("%H.%M"))--tonumber(os.date("%H.%M"))
			local creatOrNpc = "creatureRespawns" -- No need to touch.
			if spawnOrPlace == "spawn" then
				creatOrNpc = "creatureRespawns"
			else
				creatOrNpc = "npcRespawns"
			end
			
			for slot, uIndex in pairs(LoadedCells[currentCellDescription].data.objectData) do
				if uIndex.refId == refIdVariable then
					logicHandler.DeleteObjectForPlayer(pid, currentCellDescription, uIndex)
				end
			end
			
			if WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] == nil or serverTime >= WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] then 
				for slot, uIndex in pairs(LoadedCells[currentCellDescription].data.objectData) do
					if uIndex.refId == refIdVariable then
						logicHandler.DeleteObjectForPlayer(pid, currentCellDescription, uIndex)
						Methods.questMobSpawn(pid, creatOrNpc, refIdVariable, respawnTime, serverTime, destination, location)
					end
				end
			end

		end
	end

end)

Methods.questMobSpawn = function(pid, creatOrNpc, refIdVariable, respawnTime, serverTime, destination, location)
	
	if WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] == nil or serverTime >= WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] then 
		
		logicHandler.CreateObjectAtLocation(destination, location, targetRefId, spawnOrPlace)
		
		local setRespawnTime = os.time() + respawnTime
		
		WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] = setRespawnTime
		WorldInstance:Save()
	end
end

Methods.Init = function()
	if WorldInstance.data.customVariables.respawning == nil then WorldInstance.data.customVariables.respawning = {} WorldInstance:Save() end
	if WorldInstance.data.customVariables.respawning.creatureRespawns == nil then WorldInstance.data.customVariables.respawning.creatureRespawns = {} WorldInstance:Save() end
	if WorldInstance.data.customVariables.respawning.npcRespawns == nil then WorldInstance.data.customVariables.respawning.npcRespawns = {} WorldInstance:Save() end 
end

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
	Methods.Init()
end)









Methods.FixesOnLogin = function(pid)
	
	if Players[pid].data.customVariables.questFixes == nil then
		Players[pid].data.customVariables.questFixes = {}
	end
	
	logicHandler.RunConsoleCommandOnPlayer(pid, "lucan_scriptholder-> setdelete 1")
	logicHandler.RunConsoleCommandOnPlayer(pid, "stopscript lucan_ostorius")
		
end


customEventHooks.registerHandler("OnPlayerFinishLogin", function(eventStatus, pid)
	tes3mp.LogMessage(enumerations.log.INFO, "Running questFixes for " .. Players[pid].name)
	Methods.FixesOnLogin(pid)
end)

customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventStatus, pid)
	tes3mp.LogMessage(enumerations.log.INFO, "Running questFixes for " .. Players[pid].name)
	Methods.FixesOnLogin(pid)
end)
