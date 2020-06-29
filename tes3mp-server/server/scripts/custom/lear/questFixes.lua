--[[

Quest Fixes for Non-Shared Journals
questFixes.lua
	version 1.01
	Updated 6/29/2020

THIS SCRIPT INCLUDES THE FOLLOWING FIXES:
Azura's Quest (DA_Azura) Fix	-	Spawn Staada when a player with the Azura Star quest logged approaches the island in the Sheogorad region.
Ajira's Stolen Report Fix		-	Resolves the issue of only one player being able to complete this quest per cell reset.
Lucan Ostorius Spawn Fix		-	Prevents Lucan Ostorius from infinitely spawning, which can cause insane lag in Ald'ruhn.

----------------------------------------------------------------------
INSTALLATION:

	1) Drag this file into your 'tes3mp-server/server/scripts/custom' folder.
	
	2) Ppen your 'customScripts.lua' that can be found in your 'tes3mp-server/server/scripts/' folder with a text editor.

	3) Add the following new line to your customScripts.lua file: (**Make sure there are no -- dashes infront of it!**)
		require("custom.questFixes")
	
	4) Save, close the file and relaunch your server.

----------------------------------------------------------------------
INFORMATION:

Azura's Quest (DA_Azura) Fix:
When approaching the Staada location, Staada will spawn assuming the player has the quest logged and not completed.
By default, Staadas respawn is set to 15 minutes, so the same player wont spawn Staada repetitively.
If Staada is already up, Staada will be deleted before respawning.

Ajira's Stolen Report Fix:
Ajiras papers are deleted and replaced with unlootable duplicates.
Players on the quest simply activate the papers and they are added to their inventory.
The unlootable duplicates are then deleted for the player that looted them.

Lucan Ostorius Spawn Fix
On my server, Lucan would infinitely spawn for players who had the appropriate quest logged.
This lead to Ald'ruhn acquiring massive lag from all the spawns, and lead to some potential server crashes.
This fix deletes the vanilla spawner and stops the quest, allowing this server script to control spawning him when necessary.


]]

local Methods = {}

local sConfig = {}
sConfig.staadaRespawnTime = 900 -- Time in seconds you want staada to respawn. Default is 900 seconds which is 15 minutes.




--==----==----==----==----==----==----==----==----==--
--
-- Shouldnt need to touch anything below this point.
--
--==----==----==----==----==----==----==----==----==--

-- Check if player has a journal entry and index:
local hasJournalIndex = function(pid, questId, index)
	for id, journalItem in pairs(Players[pid].data.journal) do
		if journalItem.quest ~= nil and journalItem.quest == questId then
			if journalItem.index == index then 
				return true
			end
		end
	end
	return false
end

-- Function to add item from player:
local playerAddItem = function(pid, refId, count, soul, charge, enchantmentCharge)
	if refId == nil then return end
	if count == nil then count = 1 end
	if soul == nil then soul = "" end
	if charge == nil then charge = -1 end
	if enchantmentCharge == nil then enchantmentCharge = -1 end
	
	if refId == "gold_005" or refId == "gold_010" or refId == "gold_025" or refId == "gold_100" then
		refId = "gold_001"
	end
	
	if logicHandler.IsGeneratedRecord(refId) then
		local cellDescription = tes3mp.GetCell(pid)
        local cell = LoadedCells[cellDescription]
		local recordType = logicHandler.GetRecordTypeByRecordId(refId)
		if RecordStores[recordType] ~= nil then
			local recordStore = RecordStores[recordType]
			for _, visitorPid in pairs(cell.visitors) do
				recordStore:LoadGeneratedRecords(visitorPid, recordStore.data.generatedRecords, {refId})
			end
		end
	end
	
	tes3mp.ClearInventoryChanges(pid)
	tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
	tes3mp.AddItemChange(pid, refId, count, charge, enchantmentCharge, soul)
	tes3mp.SendInventoryChanges(pid)
	Players[pid]:SaveInventory()
end

-- Function to remove item from player:
local playerRemoveItem = function(pid, refId, count, soul, charge, enchantmentCharge)
	if pid == nil then return end
	if refId == nil then return end
	if count == nil then count = 1 end
	if soul == nil then soul = "" end
	if charge == nil then charge = -1 end
	if enchantmentCharge == nil then enchantmentCharge = -1 end
	
	if refId == "gold_005" or refId == "gold_010" or refId == "gold_025" or refId == "gold_100" then
		refId = "gold_001"
	end
	
	tes3mp.ClearInventoryChanges(pid)
	tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.REMOVE)
	tes3mp.AddItemChange(pid, refId, count, charge, enchantmentCharge, soul)
	tes3mp.SendInventoryChanges(pid)
	Players[pid]:SaveInventory()
end


-- Stuff to do when player activates an object:
customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
	local name = Players[pid].name:lower()
	local cell = LoadedCells[cellDescription]

	local isValid = eventStatus.validDefaultHandler

    for n,object in pairs(objects) do
		
		local objectUniqueIndex = object.uniqueIndex
		local objectRefId = object.refId
		
		if objectRefId == "bk_ajira1_static" then
			
			if hasJournalIndex(pid, "mg_stolenreport", 10) and not hasJournalIndex(pid, "mg_stolenreport", 100) then
				logicHandler.DeleteObjectForPlayer(pid, cellDescription, objectUniqueIndex)				
				playerRemoveItem(pid, "bk_ajira1") -- We do this incase the player relogs, so they cant farm the paper.
				logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Book Up\"")
				playerAddItem(pid, "bk_ajira1")
				tes3mp.MessageBox(pid, -1, "Ajira's Mushroom Report has been added to your inventory.")
			else
				isValid = false
			end
			
		elseif objectRefId == "bk_ajira2_static" then
			
			if hasJournalIndex(pid, "mg_stolenreport", 10) and not hasJournalIndex(pid, "mg_stolenreport", 100) then
				logicHandler.DeleteObjectForPlayer(pid, cellDescription, objectUniqueIndex)				
				playerRemoveItem(pid, "bk_ajira2") -- We do this incase the player relogs, so they cant farm the paper.
				logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Book Up\"")
				playerAddItem(pid, "bk_ajira2")
				tes3mp.MessageBox(pid, -1, "Ajira's Flower Report has been added to your inventory.")
			else
				isValid = false
			end
			
		end
		
	end
end)



-- Stuff to do when players change cells:
customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, previousCellDescription, currentCellDescription)
-- Azura's Quest (DA_Azura) Fix
	-- Azuras Star Quest Spawn Staada
	-- If player enters nearby cells of staada's location:
	if currentCellDescription == "3, 23" or currentCellDescription == "2, 24" or currentCellDescription == "2, 23" or currentCellDescription == "3, 24" then
		-- If player has the appropriate quest index only:
		if hasJournalIndex(pid, "da_azura", 10) and not hasJournalIndex(pid, "da_azura", 20) then
			
			local targetRefId = "golden saint_staada" -- creature or npc id.
			local spawnOrPlace = "spawn" -- "spawn" for creatures or "place" for NPCs
			local refIdVariable = "golden_saint_staada" --  This is what is saved within the world file for the respawn timer
			
			local destination = "3, 24" -- Cell to spawn creature/NPC in.
			local location = {posX = 29314.740234, posY = 197027.375000, posZ = 352.015381, rotX = 0, rotY = 0, rotZ = 0} -- Position to spawn creature/NPC in.
		
			local creatOrNpc = "npcRespawns" -- No need to touch.
			if spawnOrPlace == "spawn" then
				creatOrNpc = "creatureRespawns"
			end
			
			for slot, uIndex in pairs(LoadedCells[currentCellDescription].data.objectData) do
				if uIndex.refId == refIdVariable then
					logicHandler.DeleteObjectForPlayer(pid, currentCellDescription, uIndex)
				end
			end
			
			if WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] == nil or os.time() >= WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] then 
				for slot, uIndex in pairs(LoadedCells[currentCellDescription].data.objectData) do
					if uIndex.refId == refIdVariable then
						logicHandler.DeleteObjectForPlayer(pid, currentCellDescription, uIndex)
						Methods.questMobSpawn(pid, creatOrNpc, refIdVariable, sConfig.staadaRespawnTime, destination, location)
					end
				end
			end

		end
	
	
	elseif currentCellDescription == "Balmora, Guild of Mages" then 
		
		logicHandler.DeleteObjectForPlayer(pid, currentCellDescription, "390615-0") -- bk_ajira1 underneath basket.
		logicHandler.DeleteObjectForPlayer(pid, currentCellDescription, "390616-0") -- bk_ajira2 underneath closet.
		
		local ajiraBook1Here = false
		local ajiraBook2Here = false
		
		if LoadedCells[currentCellDescription] == nil then return end
		
		for uniqueId, object in pairs(LoadedCells[currentCellDescription].data.objectData) do
			if object.refId == "bk_ajira1_static" then
				ajiraBook1Here = true
			end
			if object.refId == "bk_ajira2_static" then
				ajiraBook2Here = true
			end
		end
		if not ajiraBook1Here then
			local location = {posX = 290.35510253906,posZ = -250.99984741211,posY = -185.60943603516,rotX = 0,rotY = 0,rotZ = 0.28906273841858}
			local itemRefId = "bk_ajira1_static"
			logicHandler.CreateObjectAtLocation(currentCellDescription,location,itemRefId,"place")
		end
		if not ajiraBook2Here then
			local location = {posX = -309.93283081055,posZ = -762.99957275391,posY = -1492.6372070313,rotX = 0,rotY = 0,rotZ = -0.50777697563171}
			local itemRefId = "bk_ajira2_static"
			logicHandler.CreateObjectAtLocation(currentCellDescription,location,itemRefId,"place")
		end
		
		if hasJournalIndex(pid, "mg_stolenreport", 100) then
			for uniqueId, object in pairs(LoadedCells[currentCellDescription].data.objectData) do
				if object.refId == "bk_ajira1_static" then
					logicHandler.DeleteObjectForPlayer(pid, currentCellDescription, uniqueId)
				end
				if object.refId == "bk_ajira2_static" then
					logicHandler.DeleteObjectForPlayer(pid, currentCellDescription, uniqueId)
				end
			end
		end
		
	end
	
end)

-- Spawning in quest mob if applicable:
Methods.questMobSpawn = function(pid, creatOrNpc, refIdVariable, respawnTime, destination, location)
	
	if WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] == nil or os.time() >= WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] then 
		
		logicHandler.CreateObjectAtLocation(destination, location, targetRefId, spawnOrPlace)
		
		local setRespawnTime = os.time() + respawnTime
		WorldInstance.data.customVariables.respawning[creatOrNpc][refIdVariable] = setRespawnTime
		WorldInstance:Save()
	end
end

-- Stuff to initialize on server startup:
Methods.Init = function()
	if WorldInstance.data.customVariables.respawning == nil then WorldInstance.data.customVariables.respawning = {} WorldInstance:Save() end
	if WorldInstance.data.customVariables.respawning.creatureRespawns == nil then WorldInstance.data.customVariables.respawning.creatureRespawns = {} WorldInstance:Save() end
	if WorldInstance.data.customVariables.respawning.npcRespawns == nil then WorldInstance.data.customVariables.respawning.npcRespawns = {} WorldInstance:Save() end 
end

-- Custom Records to create on server startup:
local function 	createRecords()
	local recordStore = RecordStores["miscellaneous"]
	recordStore.data.permanentRecords["bk_ajira1_static"] = {
		name = "Ajira's Mushroom Report",
		icon = "m\\Tx_scroll_open_01.tga",
		model = "m\\Text_Scroll_01.NIF",
		script = "noPickup"
	}
	recordStore.data.permanentRecords["bk_ajira2_static"] = {
		name = "Ajira's Flower  Report",
		icon = "m\\Tx_scroll_open_01.tga",
		model = "m\\Text_Scroll_01.NIF",
		script = "noPickup"
	}
	recordStore:Save()
end

-- Stuff to push on server startup:
local function OnServerPostInit(eventStatus)
	Methods.Init()
	createRecords()
end
customEventHooks.registerHandler("OnServerPostInit", OnServerPostInit)


-- Stuff to apply on player login:
Methods.FixesOnLogin = function(pid)
	
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		logicHandler.DeleteObjectForPlayer(pid, "-2, 6", "482620-0") -- Delete lucan spawn flag under ald-ruhn
		logicHandler.RunConsoleCommandOnPlayer(pid, "stopscript lucan_ostorius") -- Stop lucans script.
	end
end

-- Stuff to push when a player has successfully logged on:
customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)

	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		tes3mp.LogMessage(enumerations.log.INFO, "Running questFixes for " .. Players[pid].name)
		Methods.FixesOnLogin(pid)
	end
end)

