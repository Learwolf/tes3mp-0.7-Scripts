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
		if tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "da_azura", index = 10 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "da_azura", index = 20 }, true) then
			
			local targetRefId = "golden saint_staada" -- creature or npc id.
			local respawnMinutes = 15 -- respawn time in minutes.
			local respawnHours = 0 -- respawn time in hours
			local respawnDays = 0 -- respawn time in days
			local spawnOrPlace = "spawn" -- "spawn" for creatures or "place" for NPCs
			local refIdVariable = "golden_saint_staada" --  This is what is saved within the world file for the respawn timer
			
			local destination = "3, 24" -- Cell to spawn creature/NPC in.
			local location = {posX = 29314.740234, posY = 197027.375000, posZ = 352.015381, rotX = 0, rotY = 0, rotZ = 0} -- Position to spawn creature/NPC in.
		
			local serverTime = tonumber(os.date("%H.%M"))--tonumber(os.date("%H.%M"))
			local creatOrNpc = "creatureRespawns" -- No need to touch.
			if spawnOrPlace == "spawn" then
				creatOrNpc = "creatureRespawns"
			else
				creatOrNpc = "npcRespawns"
			end
			
			logicHandler.RunConsoleCommandOnPlayer(pid, "\"" .. targetRefId .. "\"->setdelete 1", forEveryone)
			Methods.questMobSpawn(pid, creatOrNpc, refIdVariable, respawnMinutes, respawnHours, respawnDays, serverTime, destination, location)
			
		end
	end

end)

Methods.questMobSpawn = function(pid, creatOrNpc, refIdVariable, respawnMinutes, respawnHours, respawnDays, serverTime, destination, location)
	
	if WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] == nil or serverTime >= WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] then
			
		logicHandler.CreateObjectAtLocation(destination, location, targetRefId, spawnOrPlace)
		
		local actualMinute = os.date("%M")
		local actualHour = os.date("%H")
		
		while respawnMinutes > 59 do
			respawnMinutes = respawnMinutes - 60
			respawnHours = respawnHours + 1
		end
		
		while respawnHours > 23 do
			respawnHours = respawnHours - 24
			respawnDays = respawnDays + 1
		end
		
		actualMinute = actualMinute + respawnMinutes
		
		if actualMinute > 59 then
			actualMinute = actualMinute - 60
			rollHour = respawnHours + 1
		end
		
		actualHour = actualHour + respawnHours
		
		if actualHour > 23 then
			actualHour = actualHours - 24
			respawnDays = respawnDays + 1
		end
		
		local finalTime = actualHour .. actualMinute
		
		WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] = tonumber(finalTime)
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