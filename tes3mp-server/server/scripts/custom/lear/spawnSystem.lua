--[[
	Learwolf's Spawn System
	
		Version 1.03
		
		Update History:
			
			Version 1.03 (10/23/2020)
				* Resolved issues with scaling.
				* Adjusted spawn menu gui's.
				* Resolved some issues with deletion of spawn points.
			
			Version 1.02 (3/31/2020)
				* Simplify the respawn check in order to prevent spawn duplications.
				* Adjust the distance of which despawning due to distance occurs.
			
			Version 1.00 (3/25/2020)
				* Initial release.
	
	
	Install Instructions:
		1) Drop this spawnSystem.lua into your "tes3mp-server\server\scripts\custom" folder.
		2) Open "customScripts.lua" (can be found in "tes3mp-server\server\scripts" folder) with a text editor.
		3) On a new line with nothing infront of it (example, make sure the line does not have "--" infront of it)
			copy paste this:		
				require("custom.spawnSystem")
		
		4) Save customScripts.lua and restart your server.
		5) See information below on how to utilize this script.
	
	Script Information/How it works:
	
	COMMAND(S):
		/spawnpoint
			Opens the spawnpoint admin menu.
		/sp 
			Opens the spawnpoint admin menu.
	
	** Note: This script does nothing by itself until a staff members manually sets up spawn points in game thru use of /sp **
	
	This script allows server admins (customizable below) to setup spawn points in Morrowind that can spawn between 1 and 
		any amount of creatures or NPCs an admin desires. The spawns occur on a timer, so you can set respawn times for 
		when they should respawn.
		
	Respawn timers will not begin until the spawn has had its corpse removed, or if the corpse has not been activated 
		for a certain amount of time (in which case, their corpse will automatically be removed). 
		
	USAGE:
		Opening the spawnpoint menu with /sp will bring up a (likely at first) confusing menu.
		When setting up a new spawn, the spawn will be created at your current coordinates and facing. 
		The options at the bottom of this menu are as follows:
		
		Spawn refIds: 	-Add or remove the refIds of a creature or NPC for your new spawn point.
							You can add multiple, but need to manually enter them one by one with the
							"Add refId" or "Remove refId" options.
							
		Respawn Time: 	-Set the amount of time it takes (in seconds) for a despawned/deleted creature to respawn.
							Respawn timers do not begin until the placeholder creature that died has been deleted.
							If a player does not delete a corpse, it will automatically delete if untouched for an
							extended period of time.
		
		Respawn Variance:
						- If you add a number here, each respawn for this specific respawn point will randomly select 
							a number between 0 and whatever you inserted to add as additional time before this point 
							will respawn. (It gives randomization to the respawn time.)
							
		
		Rare Spawn: 	-Setting this notes this spawn as being a rare or boss spawn.
							(I recommend using this if you have a creature that you want a long respawn timer for
							and you also want that respawn timer to persist through a hard server reset/cell deletions.)
							If this is false, this respawn point will instantly respawn on a server reset if the cell 
							is missing/has deleted the creature tied to this spawn point.
		
		Vanilla Unique Index To Delete: 
						-If the creature/NPC you are wanting to spawn is replacing a default/vanilla creature or NPC
							in your current cell (for example, making a respawnable Divayth Fyr) you should enter the 
							first digits of their uniqueIndex (the digits just before "-0" when you click on an NPC or 
							creature with the in-game console up) it will look something like:
								3457723-0							
							(In this example, for the Original Unique Index option, all you need to enter is: 3457723)
							Then, once the NPC/Creature spawn point is made, visit the vanilla NPC/creature once or twice
							(or relog in their cell) to ensure they're deleted.
							
							**NOTE: If the creatures uniqueIndex has a 0 before the - (i.e.; looks like 0-2475672) then it is  
							not a default creature/npc and should not be used with this feature.
		
		Other Spawn Info:	-This lets you view information on your creature spawns you've setup.
							The first option is the current cell name that you are in. It will show you all of the creature 
								spawn points you have setup in this current cell.
								
								If you have any spawns for this specific cell, they will be visible here. The number in brackets 
								is the spawnDB.json files way of tracking what spawnId it is. This number should not be important 
								to you. Beside the spawnId is the refId(s) set for this spawnId.
								
								If you select one of these spawnId spawns followed by the OK button, you can see information on 
								that specific spawn point. You can then either "Warp to Spawn Point" which takes you to the exact 
								coordinates and cell where that creature/NPC spawns, or you can "Delete" the spawn.
								
								Deleting the spawn will delete the creature/NPC, but due to a few reasons (me not wanting to rewrite 
								code being the main one) the spawn point will still exist, but no refIds will be tied to it.
								When this occurs, the next spawn point you setup in that cell will utilize that spawn point.
								My reasoning in noting this, is if you have a cell in the "Cells with Spawns" list, this is why.
								Think of it as letting you know, you have a spawnId but nothing tied to it.
								
							The second option "List of Cells" will show you every cell you have a spawn point setup in.
								Selecting a cell and clicking OK inside this list will bring you to an identical menu as the 
								first button, but with the cell you selected instead of the cell you are currently in.
								
								
		
		Save This Spawn:
						-Assuming you have input all the required information correctly, this will save and spawn your 
						creature/NPC. The spawn is now saved, and will always spawn here with your set respawn time.
						This will persist even through hard resets.
		
		Reset Options:	-Sets the main Spawn System Menu back to it's default options.
						
		Delete Spawn:
						-For reasons, the in-game menu deletion is limited to simply deleting the spawns refId's, which 
						prevents anything from spawning. Proper deletion would require a rewrite of the script, which may 
						happen one day, but for the time being, this works well enough.
						
	Server Data files:
		For those who know what they're doing, after launching the server with this script implemented for the first time, 
		you can find two files in your "tes3mp-server\server\data\custom" folder;
			decayDB.json	and		spawnDB.json
			
			decayDB.json is the servers way of keeping track of which creatures are dead and when they should despawn or "decay".
			
			spawnDB.json is where your spawn creature information is stored. After setting a few up in game, you can view this 
			file to see how they are stored. You can also manually delete spawns in this file, just make sure you delete 
			the spawnId (it's in the cell name nest) and make sure your server is offline when doing this. Be sure to make backups 
			just incase.
			
			If you plan on editing either of these .json files(I strongly urge you not to), be sure to do it while the server 
			is OFF, else it will not save.
			

--]]

CreatureSpawnSystem = {}

local config = {}

config.staffRankToUseSpawnMenu = 2 -- The staffRank allowed to use `/spawnpoint` to setup creature spawnpoints.

config.creatureSpawnTimer = 5 	-- This is how often the server checks to see if a spawn should occur.
								-- I recommend keeping this at around 5.

config.defaultCreatureRespawnTimer = 30	-- This is the default amount of time for creatures to respawn if you do not enter
										-- a custom amount of time for repsawning.

config.defaultCreatureRespawnTimerVariance = 0	-- This is the amount of random seconds to add to the respawn timer, this is typically used
												-- with rare spawns/bosses, that way players cannot definitively "learn" respawn times.

config.corpseDespawnTimer = 300	-- This is how long in seconds before an untouched corpse from the spawn system is deleted.
config.corpseDespawnTimerRefresh = 300	-- This is what the despawn timer for corpses gets set to everytime the corpse is activated.

config.distanceBeforeResetSpawn = 2000	-- This is how far a creature/npc can travel before they are deleted and respawned at their spawn point.

config.spawnCellsToAlwaysDelete = {"-3, -2", "-3, -3", "18, 4"} -- Insert cells that should ALWAYS wipe the db clean on reset.
											 -- This is useful for cells that you have saved and reload on server resets, 
											 -- but do not have the NPC saved in the cell.
											 -- 
config.onlyDeleteTheAboveCellsOnResetTimes = true -- True to only delete the above cells on server reset timers stated below. False to delete them every time the server restarts, even on crashes.
config.deleteCellsServerResetTimer = {"06:00","18:00"} -- This is the time(s) that a hard server reset occurs in order to push the cells to always delete (seen above)
config.deleteCellsServerResetTimerLeeway = 15 -- Seconds of leeway from the stated reset timer above, incase anything delays the server reset.							



--logicHandler.DeleteObjectForPlayer(pid, "Gnisis, Almu Cave Dwelling", "12051-0")
--config.spawnsToDelete = {["Gnisis, Almu Cave Dwelling"] = "12051-0"}
config.spawnsToDelete = {
	-- EXAMPLES: (Uncomment out these examples to use them.)
	
	--{cell = "Ebonheart, Grand Council Chambers", uniqueIndex = "7404-0"}, -- apelles matius Mournhold Porter
	--{cell = "-9, 17", uniqueIndex = "8368-0"}, -- s'virr Solstheim Porter in Khuul	
	--{cell = "-3, -3", uniqueIndex = "32901-0"}, -- Rock at Balmora Silt Strider -- This removes a rock near the silt strider that causes some players to get stuck.
	
} 	
-- If you know what you're doing, you can input vanilla creatures/NPCs to automatically delete when players log on.
-- This can be useful if you have vanilla NPC's, creatures or objects that you want deleted or to spawn in a different 
-- cell from where they are originally placed. Make sure they are separated with commas.
--
-- An example usage of the above would be as such:		
--config.spawnsToDelete = {["Gnisis, Almu Cave Dwelling"] = "12051-0", ["insert a cell name here"] = "######-0"}
--								^Cell name:						^Vanilla spawns uniqueIndex:


-- Don't touch:
config.spawnSystemMainMenu = 03252020 -- Don't touch.
config.spawnSystemRefIdMenu = 03252021 -- Don't touch.
config.spawnSystemRefIdInput = 03252022 -- Don't touch.
config.spawnSystemRefIdRemove = 03252023 -- Don't touch.
config.spawnSystemRespawnTimeInput = 03252024 -- Don't touch.
config.spawnSystemUniqueIndexInput = 03252025 -- Don't touch.
config.spawnSystemOtherInfoMenu = 03252026 -- Don't touch.
config.spawnSystemThisCellInfoMenu = 03252027 -- Don't touch.
config.spawnSystemTargetInfoMenu = 03252028 -- Don't touch.
config.spawnSystemDeletionConfirmationMenu = 03252029 -- Don't touch.
config.spawnSystemAllCellsListInfoMenu = 03252030 -- Don't touch.
config.spawnSystemRespawnTimeVarianceInput = 03252031 -- Don't touch.
config.spawnSystemScaleSizeInput = 03252032 -- Don't touch.

local TimerEvent = tes3mp.CreateTimer("checkCreatureSpawns", time.seconds(config.creatureSpawnTimer))
--tes3mp.RestartTimer(TimerEvent, time.seconds(config.creatureSpawnTimer))
local spawnListInfo = {}
local indexesToDelete = {}


local mobDecayDB = jsonInterface.load("custom/decayDB.json")
local mobSpawnDB = jsonInterface.load("custom/spawnDB.json")

-- This file is used for updating from a test server to your live server (see explanation below):
local updatedMobSpawnDB = jsonInterface.load("custom/updatedSpawnDB.json")

-- Setup mobDecayDB
if mobDecayDB == nil then
    mobDecayDB = {}
end
if mobSpawnDB == nil then
    mobSpawnDB = {}
end

-- Saving of the .json file
local Save = function()
	jsonInterface.save("custom/decayDB.json", mobDecayDB)
end
local SaveSpawns = function()
	jsonInterface.save("custom/spawnDB.json", mobSpawnDB)
end

-- Loading of the .json file
local Load = function()
	mobDecayDB = jsonInterface.load("custom/decayDB.json")
end
local LoadSpawns = function()
	mobSpawnDB = jsonInterface.load("custom/spawnDB.json")
end

local specifiedCellDeletionCheck = function(uniqueIndex) 
	
	local sTimeCheck = os.date("%H:%M")
				
	local allowCellDeletion = false
	
	if config.onlyDeleteTheAboveCellsOnResetTimes then 
		if not tableHelper.isEmpty(config.spawnCellsToAlwaysDelete) then
			for tIndex,tString in pairs(config.spawnCellsToAlwaysDelete) do
				if sTimeCheck == tString then
					allowCellDeletion = true
				end
			end
		end
	else
		allowCellDeletion = true
	end
	
	if allowCellDeletion then
		-- Lets reset the cells that are stated above to always wipe clean.
		if not tableHelper.isEmpty(config.spawnCellsToAlwaysDelete) then
			for listSlot, wipeCell in pairs(config.spawnCellsToAlwaysDelete) do
				if sCell ~= nil and sCell == wipeCell then
					mobDecayDB.spawnedMobs[uniqueIndex] = nil
				end
			end
		end
	end
	
end

local updateStartupData = function()
	
	Load()
	LoadSpawns()
	local cellsToEnsureExist = {}
	
	for uniqueIndex,data in pairs(mobDecayDB.spawnedMobs) do
		--if data == nil then -- Why was it this..?
		if data ~= nil then
			
			-- If no cell data, and not a rare spawn, delete
			if data.rareSpawn == nil then
				
				local sCell = mobDecayDB.spawnedMobs[uniqueIndex].cell
			
				if sCell ~= nil and tes3mp.GetCaseInsensitiveFilename(tes3mp.GetDataPath() .. "/cell/", sCell .. ".json") == "invalid" then
					--tes3mp.LogAppend(enumerations.log.INFO, "Cell: ".. sCell .." not found, deleteing creatureSpawn Data.")
					mobDecayDB.spawnedMobs[uniqueIndex] = nil
				end
				
				-- Check if should forcibly delete spawn cell information:
				specifiedCellDeletionCheck(uniqueIndex)
			
			-- if cell data, and a rare spawn, do stuff
			elseif data.rareSpawn ~= nil then
				
				local sCell = mobDecayDB.spawnedMobs[uniqueIndex].cell
				local bypassFurtherChecks = false
				
				-- Lets reset the cells that are stated above to always wipe clean.
				if not tableHelper.isEmpty(config.spawnCellsToAlwaysDelete) then
					for wipeCell, __data in pairs(config.spawnCellsToAlwaysDelete) do
						if sCell ~= nil and sCell == wipeCell then
							mobDecayDB.spawnedMobs[uniqueIndex] = nil
							bypassFurtherChecks = true
						end
					end
				end
				
				if not bypassFurtherChecks then
					if sCell ~= nil and tes3mp.GetCaseInsensitiveFilename(tes3mp.GetDataPath() .. "/cell/", sCell .. ".json") == "invalid" then
						if mobDecayDB.spawnedMobs[uniqueIndex].deleteTime ~= nil then
							local sId = mobDecayDB.spawnedMobs[uniqueIndex].spawnId
							
							if mobSpawnDB.creatureSpawnLocations[sCell][sId].respawnVariance ~= nil then
								local resVar = mobSpawnDB.creatureSpawnLocations[sCell][sId].respawnVariance
								
								local seedFactor = os.time()
								local playerSeed = math.randomseed(seedFactor)
								local randoVar = math.random(1,resVar)
								
								mobDecayDB.spawnedMobs[uniqueIndex].respawnTime = os.time() + mobSpawnDB.creatureSpawnLocations[sCell][sId].respawnTime + randoVar
							else
								mobDecayDB.spawnedMobs[uniqueIndex].respawnTime = os.time() + mobSpawnDB.creatureSpawnLocations[sCell][sId].respawnTime
							end
							
							mobDecayDB.spawnedMobs[uniqueIndex].deleteTime = nil
						elseif mobDecayDB.spawnedMobs[uniqueIndex].deleteTime == nil and mobDecayDB.spawnedMobs[uniqueIndex].respawnTime == nil then
							mobDecayDB.spawnedMobs[uniqueIndex] = nil
						end
						
					end
				end
				
			end
			
		end
	end
	
	Save()
end


-- Setup when Server Launches
customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
	if mobDecayDB.spawnedMobs == nil then
		mobDecayDB.spawnedMobs = {}
		Save()
	end
	
	if mobSpawnDB.creatureSpawnLocations == nil then
		mobSpawnDB.creatureSpawnLocations = {}
		SaveSpawns()
	end
	
	if updatedMobSpawnDB ~= nil and updatedMobSpawnDB.creatureSpawnLocations ~= nil then
		mobSpawnDB.creatureSpawnLocations = updatedMobSpawnDB.creatureSpawnLocations
		Save()
	end
	
	updateStartupData()		
	
	tes3mp.StartTimer(TimerEvent)
	tes3mp.LogAppend(enumerations.log.INFO, "-=-=-START TIMER CREATURE SPAWNS-=-=-")	
end)


customEventHooks.registerValidator("OnActorDeath", function(eventStatus, pid, cellDescription)
	
	local letsSave = false
	
	local cell = LoadedCells[cellDescription]
    tes3mp.ReadReceivedActorList()
    local actorListSize = tes3mp.GetActorListSize()
    local foundRespawningActor = false

    for actorIndex = 0, actorListSize - 1 do

        local uniqueIndex = tes3mp.GetActorRefNum(actorIndex) .. "-" .. tes3mp.GetActorMpNum(actorIndex)
		
		if mobDecayDB.spawnedMobs[uniqueIndex] ~= nil then
			
			local decayTime = os.time() + config.corpseDespawnTimer
			
			mobDecayDB.spawnedMobs[uniqueIndex].deleteTime = decayTime
			
			letsSave = true
			
		end
		
    end
	
	if letsSave then
		Save()
	end
end)


--logicHandler.SetAIForActor(cell, uniqueIndex, actionNumericalId, nil, nil, nil, nil, nil, distance, duration, shouldRepeat)
--logicHandler.SetAIForActor(cell, actorUniqueIndex, action, targetPid, targetUniqueIndex, posX, posY, posZ, distance, duration, shouldRepeat)
-- ai.action == enumerations.ai.ACTIVATE   or    enumerations.ai.COMBAT    or     enumerations.ai.ESCORT    or     enumerations.ai.FOLLOW 


-- Effectively delete the creature:
CreatureSpawnSystem.deleteCreature = function(pid, uniqueIndex)--, targetRefId)	
	
	if uniqueIndex == nil then return end
	local cell = logicHandler.GetCellContainingActor(uniqueIndex)
	if cell == nil then return end
    local cellDescription = cell.description
	if cellDescription == nil or uniqueIndex == nil then return end
	-- logicHandler.RunConsoleCommandOnObject(pid, "setdelete 1", cellDescription, uniqueIndex, true)
	
	logicHandler.DeleteObject(pid, cellDescription, uniqueIndex, true)
	LoadedCells[cellDescription]:DeleteObjectData(uniqueIndex)
end

CreatureSpawnSystem.distanceTooFarCreature = function(uniqueIndex)--, targetRefId)	
	
	if uniqueIndex == nil then return end
	
	local letsSave = false
	
	if mobDecayDB.spawnedMobs[uniqueIndex] ~= nil then
		local cellId = mobDecayDB.spawnedMobs[uniqueIndex].cell
		local sId = mobDecayDB.spawnedMobs[uniqueIndex].spawnId
		
		local cell = logicHandler.GetCellContainingActor(uniqueIndex)
		if cell == nil or uniqueIndex == nil then return end
		local cellDescription = cell.description
		if cellDescription == nil then return end
		
		for pid, player in pairs(Players) do
			if Players[pid] ~= nil and player:IsLoggedIn() then
				
				if LoadedCells[cellDescription] ~= nil then
					logicHandler.DeleteObject(pid, cellDescription, uniqueIndex, true)
					break
				end
				
			end
		end
		
		LoadedCells[cellDescription]:DeleteObjectData(uniqueIndex)
		
		mobDecayDB.spawnedMobs[uniqueIndex] = nil
		
		local cSpawn = mobSpawnDB.creatureSpawnLocations[cellId][sId]
		local location = {posX = cSpawn.posX, posY = cSpawn.posY, posZ = cSpawn.posZ, rotX = cSpawn.rotX, rotY = 0, rotZ = cSpawn.rotZ}
		local cRef = mobSpawnDB.creatureSpawnLocations[cellId][sId].spawnRefs
		local keys = {}
		for i=1,#cRef do 
			table.insert(keys, i) 
		end
		
		local targetRefId = cRef[math.random(#keys)]--cRef[keys[math.random(#keys)]]
		
		local newIndex = logicHandler.CreateObjectAtLocation(cellId, location, targetRefId, "spawn")
		
		
		if newIndex == nil then return end -- added due to a nil check crash
		
		mobDecayDB.spawnedMobs[newIndex] = {}
		mobDecayDB.spawnedMobs[newIndex].cell = cellId
		mobDecayDB.spawnedMobs[newIndex].spawnId = sId
		
		-- Set Rare:
		if mobSpawnDB.creatureSpawnLocations[cellId][sId].rareSpawn ~= nil then
			mobDecayDB.spawnedMobs[newIndex].rareSpawn = true
		end
		-- Set Questmob:
		if mobSpawnDB.creatureSpawnLocations[cellId][sId].questSpawn ~= nil then
			mobDecayDB.spawnedMobs[newIndex].questSpawn = true
		end
		-- Adjust scale:
		if mobSpawnDB.creatureSpawnLocations[cellId][sId].scale ~= nil then
			local scaleSize = mobSpawnDB.creatureSpawnLocations[cellId][sId].scale
			
			local objectData = LoadedCells[cellId].data.objectData
			LoadedCells[cellId].data.objectData[newIndex].scale = tonumber(scaleSize)
			
			table.insert(LoadedCells[cellId].data.packets.scale, newIndex)
			
			for index, visitorPid in pairs(LoadedCells[cellId].visitors) do
			   if Players[visitorPid] ~= nil and Players[visitorPid]:IsLoggedIn() then
					if LoadedCells[cellId] ~= nil then
						LoadedCells[cellId]:LoadObjectsScaled(visitorPid, objectData, {newIndex})
					end
				end
			end
			
		end
		
		Save()
	end
end

-- Reset dispose counter when activated:
customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
	local name = Players[pid].name:lower()
	local cell = LoadedCells[cellDescription]

	local isValid = eventStatus.validDefaultHandler
	
	local letsSave = false
	
    for n,object in pairs(objects) do
				
		local objectUniqueIndex = object.uniqueIndex
		local objectRefId = object.refId
		
		if mobDecayDB.spawnedMobs[objectUniqueIndex] ~= nil then
			mobDecayDB.spawnedMobs[objectUniqueIndex].deleteTime = (os.time() + config.corpseDespawnTimerRefresh)
			letsSave = true
		end
		
    end
	
	if letsSave then
		Save()
	end
end)

customEventHooks.registerValidator("OnObjectDelete", function(eventStatus, pid, cellDescription, objects)
	
	local cell = LoadedCells[cellDescription]
	
	local letsSave = false
	
	for n,object in pairs(objects) do
		
		local objectUniqueIndex = object.uniqueIndex
		local objectRefId = object.refId
		
		if mobDecayDB.spawnedMobs[objectUniqueIndex] ~= nil then
			
			mobDecayDB.spawnedMobs[objectUniqueIndex].deleteTime = nil
			
			local cSpawnId = mobDecayDB.spawnedMobs[objectUniqueIndex].spawnId
			local cSpawnCell = mobDecayDB.spawnedMobs[objectUniqueIndex].cell
			

			if mobSpawnDB.creatureSpawnLocations[cSpawnCell][cSpawnId].respawnVariance ~= nil then
				local resVar = mobSpawnDB.creatureSpawnLocations[cSpawnCell][cSpawnId].respawnVariance
				
				local seedFactor = os.time()
				local playerSeed = math.randomseed(seedFactor)
				local randoVar = math.random(1,resVar)
				
				
				mobDecayDB.spawnedMobs[objectUniqueIndex].respawnTime = os.time() + mobSpawnDB.creatureSpawnLocations[cSpawnCell][cSpawnId].respawnTime + randoVar
			else
				mobDecayDB.spawnedMobs[objectUniqueIndex].respawnTime = os.time() + mobSpawnDB.creatureSpawnLocations[cSpawnCell][cSpawnId].respawnTime
			end
			
			Save()
			
			eventStatus.validDefaultHandler = true --allow deletion
			return eventStatus
				
		end
		
    end

end)


-- Working fine for checking/creating spawns:
function checkCreatureSpawns()
	
	local spawnCells = {}
	
	local letsSave = false
	
	for cellId, sCellData in pairs(mobSpawnDB.creatureSpawnLocations) do
	
		if LoadedCells[cellId] ~= nil then
			CreatureSpawnSystem.distanceDespawner()
			CreatureSpawnSystem.disposeTimerMet()
			
			for sId, sData in pairs(sCellData) do
				local targetFound = false
				
				local targetCell = cellId
				local targetSID = sId
				
				for uid,uniqueIndex in pairs(mobDecayDB.spawnedMobs) do
					local fCell = uniqueIndex.cell
					local fSpawnId = uniqueIndex.spawnId
					local fRespawnTime = uniqueIndex.respawnTime
					
					if fCell ~= nil and fCell == cellId and fSpawnId ~= nil and fSpawnId == sId then
						targetFound = true
						if fRespawnTime ~= nil and os.time() > fRespawnTime then
							mobDecayDB.spawnedMobs[uid] = nil				
							letsSave = true
							targetFound = false
						end
						break
					end
				end
				
				if not targetFound then
					local cSpawn = mobSpawnDB.creatureSpawnLocations[cellId][sId]
					
					letsSave = true
					
					local location = {posX = cSpawn.posX, posY = cSpawn.posY, posZ = cSpawn.posZ, rotX = cSpawn.rotX, rotY = 0, rotZ = cSpawn.rotZ}
					local cRef = mobSpawnDB.creatureSpawnLocations[cellId][sId].spawnRefs
					local keys = {}
					for i=1,#cRef do 
						table.insert(keys, i) 
					end
					
					local targetRefId = cRef[math.random(#keys)]
					
					local newIndex = logicHandler.CreateObjectAtLocation(cellId, location, targetRefId, "spawn")
					
					mobDecayDB.spawnedMobs[newIndex] = {}
					mobDecayDB.spawnedMobs[newIndex].cell = cellId
					mobDecayDB.spawnedMobs[newIndex].spawnId = sId
					
					-- Set Rare:
					if mobSpawnDB.creatureSpawnLocations[cellId][sId].rareSpawn ~= nil then
						mobDecayDB.spawnedMobs[newIndex].rareSpawn = true
					end
					-- Adjust scale:
					if mobSpawnDB.creatureSpawnLocations[cellId][sId].scale ~= nil then
						local scaleSize = mobSpawnDB.creatureSpawnLocations[cellId][sId].scale
						
						local objectData = LoadedCells[cellId].data.objectData
						LoadedCells[cellId].data.objectData[newIndex].scale = tonumber(scaleSize)
						
						table.insert(LoadedCells[cellId].data.packets.scale, newIndex)
						
						for index, visitorPid in pairs(LoadedCells[cellId].visitors) do
						   if Players[visitorPid] ~= nil and Players[visitorPid]:IsLoggedIn() then
								if LoadedCells[cellId] ~= nil then
									LoadedCells[cellId]:LoadObjectsScaled(visitorPid, objectData, {newIndex})
								end
							end
						end
					end
					
				end
				
			end
			
		end
	
	end
	
	if letsSave then
		Save()
	end
	
	tes3mp.RestartTimer(TimerEvent, time.seconds(config.creatureSpawnTimer))
end


-- Make adjustments when the dispose timer has been reached:
CreatureSpawnSystem.disposeTimerMet = function()
		
	for refIndex,_data in pairs(mobDecayDB.spawnedMobs) do
				
		if mobDecayDB.spawnedMobs[refIndex].deleteTime ~= nil then
			
			if os.time() > mobDecayDB.spawnedMobs[refIndex].deleteTime then
				
				
				local sId = mobDecayDB.spawnedMobs[refIndex].spawnId
				local sCell = mobDecayDB.spawnedMobs[refIndex].cell
				
				if mobSpawnDB.creatureSpawnLocations[sCell] ~= nil and mobSpawnDB.creatureSpawnLocations[sCell][sId] ~= nil then
				
					if mobSpawnDB.creatureSpawnLocations[sCell][sId].respawnVariance ~= nil then
						local resVar = mobSpawnDB.creatureSpawnLocations[sCell][sId].respawnVariance
						
						local seedFactor = os.time()
						local playerSeed = math.randomseed(seedFactor)
						local randoVar = math.random(1,resVar)
						
						
						mobDecayDB.spawnedMobs[refIndex].respawnTime = os.time() + mobSpawnDB.creatureSpawnLocations[sCell][sId].respawnTime + randoVar
					else
						mobDecayDB.spawnedMobs[refIndex].respawnTime = os.time() + mobSpawnDB.creatureSpawnLocations[sCell][sId].respawnTime
					end
					
					for pid, player in pairs(Players) do
						if Players[pid] ~= nil and player:IsLoggedIn() then
							
							
							if LoadedCells[sCell] ~= nil then
								CreatureSpawnSystem.deleteCreature(pid, refIndex)
								mobDecayDB.spawnedMobs[refIndex].deleteTime = nil
								break
							end
							
						end
					end
				
				
				end
				
				
			end
			
		end
		
	end
	
	Save()
end


CreatureSpawnSystem.distanceDespawner = function()
	
	for refIndex,_data in pairs(mobDecayDB.spawnedMobs) do
	
			
		local cell = logicHandler.GetCellContainingActor(refIndex)
		if cell ~= nil then
			
			local cellDescription = cell.description
			
			if LoadedCells[cellDescription].data.objectData[refIndex] ~= nil then 
				local spawnLocation = LoadedCells[cellDescription].data.objectData[refIndex].location
				
				if spawnLocation ~= nil and mobDecayDB.spawnedMobs[refIndex] ~= nil and mobDecayDB.spawnedMobs[refIndex].deleteTime == nil and mobDecayDB.spawnedMobs[refIndex].respawnTime == nil then 
					
					local spawnPosX = spawnLocation.posX
					local spawnPosY = spawnLocation.posY
					
					local originCell = mobDecayDB.spawnedMobs[refIndex].cell
					local originSpawnId = mobDecayDB.spawnedMobs[refIndex].spawnId
					
					local originPosX = mobSpawnDB.creatureSpawnLocations[originCell][originSpawnId].posX
					local originPosY = mobSpawnDB.creatureSpawnLocations[originCell][originSpawnId].posY
					
					local distance = math.sqrt((originPosX - spawnPosX) * (originPosX - spawnPosX) + (originPosY - spawnPosY) * (originPosY - spawnPosY))
					
					local maxDistance = config.distanceBeforeResetSpawn
					
					if mobSpawnDB.creatureSpawnLocations[originCell][originSpawnId].range ~= nil then
						maxDistance = mobSpawnDB.creatureSpawnLocations[originCell][originSpawnId].range
					end
					
					if distance > maxDistance then
						tes3mp.LogAppend(enumerations.log.INFO, "[DEBUG]: despawning due to distance. Max Distance: "..maxDistance)
						CreatureSpawnSystem.distanceTooFarCreature(refIndex)
					end
					
				end
			
			end
			
		end
		
		
	end
	
end


CreatureSpawnSystem.cellChangeDespawner = function(pid)
	
	local playerCell = tes3mp.GetCell(pid)
	
	for refIndex,_data in pairs(mobDecayDB.spawnedMobs) do
		
		if playerCell ~= nil and refIndex ~= nil and LoadedCells[playerCell] ~= nil and LoadedCells[playerCell].data.objectData[refIndex] ~= nil then
			
			local originCell = mobDecayDB.spawnedMobs[refIndex].cell
			local originSpawnId = mobDecayDB.spawnedMobs[refIndex].spawnId
			if mobSpawnDB.creatureSpawnLocations[originCell] ~= nil and mobSpawnDB.creatureSpawnLocations[originCell][originSpawnId] ~= nil then
				local interiorOnly = mobSpawnDB.creatureSpawnLocations[originCell][originSpawnId].interior
				
				if playerCell ~= originCell then
					local pushDespawn = false
					if interiorOnly ~= nil then -- if spawn is interior only
						if LoadedCells[playerCell].isExterior then
							pushDespawn = true
						end
					else -- if spawn is exterior only
						if not LoadedCells[playerCell].isExterior then
							pushDespawn = true
						end
					end
					
					if pushDespawn then
						
						CreatureSpawnSystem.deleteCreature(pid, refIndex)
						if mobDecayDB.spawnedMobs[refIndex] ~= nil then
							mobDecayDB.spawnedMobs[refIndex].cellDespawn = true
							Save()
						end
					end
					
				end
				
			else
				mobDecayDB.spawnedMobs[refIndex] = nil
				Save()
				
			end
			
		end
		
		
	end
	
end


CreatureSpawnSystem.originIndexDeletion = function(pid)
	
	if not tableHelper.isEmpty(indexesToDelete) then
		for _,tIndex in pairs(indexesToDelete) do
			local cell = logicHandler.GetCellContainingActor(tIndex)
			if cell ~= nil then
				local cellDescription = cell.description
				logicHandler.DeleteObjectForPlayer(pid, cellDescription, tIndex)
				logicHandler.DeleteObject(pid, cellDescription, tIndex, true)
			end
		end
	end
	
end


customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, previousCellDescription, currentCellDescription)
	CreatureSpawnSystem.cellChangeDespawner(pid)
	CreatureSpawnSystem.originIndexDeletion(pid)
end)

-- Insert the vanilla NPCs to delete on login:
CreatureSpawnSystem.deleteOnLogin = function(pid)
	
	for i=1, #config.spawnsToDelete do
		local target = config.spawnsToDelete[i]
		logicHandler.DeleteObjectForPlayer(pid, target.cell, target.uniqueIndex)
	end
	
	for sCell,sCellData in pairs(mobSpawnDB.creatureSpawnLocations) do
		for spawns,spawnData in pairs(sCellData) do
			if spawnData.originalIndex ~= nil then
				logicHandler.DeleteObjectForPlayer(pid, sCell, spawnData.originalIndex)
			end
		end
	end
end




CreatureSpawnSystem.updateDeletion = function(pid, tIndex)
	if tIndex == nil then return end
	local cell = logicHandler.GetCellContainingActor(tIndex)
	if cell ~= nil then
		local cellDescription = cell.description
		tes3mp.SendMessage(pid, "pullCell: "..cellDescription.."\n", false)
		logicHandler.DeleteObjectForPlayer(pid, cellDescription, tIndex)
		logicHandler.DeleteObject(pid, cellDescription, tIndex, true)
	end
end


local staffVars = {}
local staffSelectedCell = {}

local setupStaffVars = function(pid)
	staffVars[pid] = {
		refIds = {}
	}
end

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		CreatureSpawnSystem.deleteOnLogin(pid)
		if Players[pid].data.settings.staffRank >= config.staffRankToUseSpawnMenu then
			setupStaffVars(pid)
		end
	end
end)


local setupSpawnVariables = function(pid)
	if Players[pid].data.customVariables.spawnSettings == nil then
		Players[pid].data.customVariables.spawnSettings = {}
		Players[pid].data.customVariables.spawnSettings.respawnTime = config.defaultCreatureRespawnTimer
		Players[pid].data.customVariables.spawnSettings.respawnTimeVariance = config.defaultCreatureRespawnTimerVariance
		Players[pid].data.customVariables.spawnSettings.respawnScaleSize = 1
		Players[pid].data.customVariables.spawnSettings.cell = ""
		Players[pid].data.customVariables.spawnSettings.posX = 0
		Players[pid].data.customVariables.spawnSettings.posY = 0
		Players[pid].data.customVariables.spawnSettings.posZ = 0
		Players[pid].data.customVariables.spawnSettings.rotX = 0
		Players[pid].data.customVariables.spawnSettings.rotZ = 0
		
	end
end

local clearSpawnVariables = function(pid)
	Players[pid].data.customVariables.spawnSettings = nil
end

local setSpawnPosRot = function(pid)
	Players[pid].data.customVariables.spawnSettings.cell = tes3mp.GetCell(pid)
	
	Players[pid].data.customVariables.spawnSettings.posX = tes3mp.GetPosX(pid)
	Players[pid].data.customVariables.spawnSettings.posY = tes3mp.GetPosY(pid)
	Players[pid].data.customVariables.spawnSettings.posZ = tes3mp.GetPosZ(pid)
	
	Players[pid].data.customVariables.spawnSettings.rotX = tes3mp.GetRotX(pid)
	Players[pid].data.customVariables.spawnSettings.rotZ = tes3mp.GetRotZ(pid)
	
end

CreatureSpawnSystem.DeleteTargetSpawnInfo = function(pid)
	
	local msg = color.Orange.."Spawn Deletion\n\n"..color.Yellow
	msg = msg.."Are you certain you want to delete this spawn?\n"
	
	tes3mp.CustomMessageBox(pid, config.spawnSystemDeletionConfirmationMenu, msg, "No, don't delete;Yes, delete;Back;Exit")
end

CreatureSpawnSystem.AdminMainMenu = function(pid)
	
	setupSpawnVariables(pid)
	setSpawnPosRot(pid)
	
	local pVar = Players[pid].data.customVariables.spawnSettings
	
	local variable1 = ""
	
	if pVar.refIds ~= nil then
		for s,refId in pairs(pVar.refIds) do
			variable1 = variable1.." [\""..refId.."\"] "
		end
		variable1:sub(1, -2)
	end
	
	local variable2 = pVar.respawnTime
	local variable3 = color.White.."False"
	if pVar.rareSpawn then
		variable3 = color.Green.."True"
	end
	
	local variable4 = ""
	
	local cellCheck = pVar.cell
	if cellCheck == "" then
		variable4 = color.Red.."No cell selected."
	elseif LoadedCells[cellCheck] ~= nil then
		if not LoadedCells[cellCheck].isExterior then
			variable4 = color.Green.."True"
		else
			variable4 = color.White.."False"
		end
	else
		variable4 = color.White.."False"
	end
	
	local variable5 = "-"
	
	if pVar.uniqueIndex ~= nil then
		variable5 = pVar.uniqueIndex
	end
	
	local variable6 = pVar.respawnTimeVariance or 0
	
	local variableScale = pVar.respawnScaleSize or 1
	
	local msg = color.Orange.."Spawn System Menu\n"..color.Yellow
	msg = msg.."\nSpawn RefId(s):\n{"..color.White..variable1..color.Yellow.."}"
	msg = msg.."\nRespawn Time (seconds): "..color.White..variable2..color.Yellow
	msg = msg.."\nRespawn Time Variance (seconds): "..color.White..variable6..color.Yellow
	
	msg = msg.."\n\nCell: "..color.White..pVar.cell..color.Yellow
	msg = msg.."\nPOS-(X, Y, Z):\n("..color.White..pVar.posX..", "..pVar.posY..", "..pVar.posZ..color.Yellow..")"
	msg = msg.."\nROT-(X, Z):\n("..color.White..pVar.rotX..", "..pVar.rotZ..color.Yellow..")\n"
	
	msg = msg..color.Orange.."\n\nOptional Settings\n"..color.Red.."(**SEE SCRIPT README FOR INFO ON WHAT THESE OPTIONS DO**)\n"..color.Yellow
	msg = msg.."\nRare Spawn: "..color.White..variable3..color.Yellow
	
	msg = msg.."\nScale: "..color.White..variableScale..color.Yellow
	
	msg = msg.."\nInterior Cell: "..variable4..color.Yellow
	msg = msg.."\nOriginal Unique Index: "..color.White..variable5.."\n"..color.Yellow
	
	tes3mp.CustomMessageBox(pid, config.spawnSystemMainMenu, msg, "Set Spawn refIds;Set Respawn Time;Set Respawn Time Variance;Rare Spawn Toggle;"..color.Red.."Vanilla Unique Index To Delete;Other Spawn Info;Save This Spawn;Reset Options;Scale;Exit")

end

CreatureSpawnSystem.OtherSpawnInfoMenu = function(pid)
	
	local cellOption = tes3mp.GetCell(pid)
	
	local msg = color.Orange.."Spawn Information\n\n"..color.Yellow
	
	msg = msg..cellOption..color.White.." will bring up spawn information on the cell you're in.\n\n"..color.Yellow
	msg = msg.."List of Cells"..color.White.." will let you select a cell with spawn info in it.\n\n"..color.Yellow
	
	
	tes3mp.CustomMessageBox(pid, config.spawnSystemOtherInfoMenu, msg, cellOption..";List of Cells;Back;Exit")
end

CreatureSpawnSystem.ThisCellSpawnInfoMenu = function(pid, targetCell)
	
	if targetCell == nil then targetCell = tes3mp.GetCell(pid) end
	
	local cellOption = targetCell
	 
	local msg = color.Orange.."Spawn Information\n"..color.Yellow.."Cell: "..color.White..cellOption.."\n"
	local listOptions = " * Cancel * \n"
	spawnListInfo[pid] = {}
	
	if mobSpawnDB.creatureSpawnLocations[cellOption] ~= nil then
		
		local sort = {}
		for i, sData in pairs(mobSpawnDB.creatureSpawnLocations[cellOption]) do
			local storeData = {
				cell = cellOption,
				spawnId = tonumber(i),
				data = sData
			}
			table.insert(sort, storeData)
		end
		table.sort(sort, function(a,b) return a.spawnId<b.spawnId end)
		
		local count = 0
		
		for i=1,#sort do
			local tSpawnId = sort[i].spawnId
			local sData = sort[i].data
			if sData ~= nil and sData.spawnRefs ~= nil and not tableHelper.isEmpty(sData.spawnRefs) then
				local tRefIds = ""
				
				for _,tRId in pairs(sData.spawnRefs) do
					tRefIds = tRefIds.."[\""..tRId.."\"]"
				end
				
				table.insert(spawnListInfo[pid], sort[i])
				
				count = count + 1
				listOptions = listOptions.."["..tSpawnId.."]: "..tRefIds.."\n"
			end
		end
		
		msg = msg..color.Yellow.."Available Spawns: "..color.White..count
		
	else
		msg = msg..color.Red.."There are no spawns setup here."
	end
	
	tes3mp.ListBox(pid, config.spawnSystemThisCellInfoMenu, msg, listOptions:sub(1, -2))
end

CreatureSpawnSystem.ListOfCellsSpawnInfoMenu = function(pid)
	
	local cellOption = tes3mp.GetCell(pid)
	
	local msg = color.Orange.."Spawn Information\n"..color.Yellow.."Current Cell: "..color.White..cellOption.."\n"
	local listOptions = " * Cancel * \n"
	spawnListInfo[pid] = {}
	
	local sort = {}
	for cellName, cellData in pairs(mobSpawnDB.creatureSpawnLocations) do
		table.insert(sort, cellName)
	end
	table.sort(sort, function(a,b) return a<b end)
	
	local counter = 0
	for i=1,#sort do
		counter = counter + 1
		table.insert(spawnListInfo[pid], sort[i])
		listOptions = listOptions.."\""..sort[i].."\"\n"
	end
	
	msg = msg..color.Yellow.." Cells with Spawns: "..color.White..counter

	tes3mp.ListBox(pid, config.spawnSystemAllCellsListInfoMenu, msg, listOptions)
end


CreatureSpawnSystem.TargetSpawnInfoMenu = function(pid, data)
	
	if data == nil or spawnListInfo[pid][tonumber(data)] == nil then 
		return CreatureSpawnSystem.ThisCellSpawnInfoMenu(pid, staffSelectedCell[pid])
	end
	
	local tSpawnCell = spawnListInfo[pid][tonumber(data)].cell
	local tSpawnId = tostring(spawnListInfo[pid][tonumber(data)].spawnId)
	
	if tSpawnCell == nil then return end
	
	local msg = color.Orange.."Spawn Information\n\n"..color.Yellow
	
	msg = msg.."Cell: "..color.White..tSpawnCell.."\n\n"..color.Yellow
	
	local refIdList = ""
	
	local spawnTarget = mobSpawnDB.creatureSpawnLocations[tSpawnCell][tSpawnId]
	for _,tRId in pairs(spawnTarget.spawnRefs) do
		refIdList = refIdList.."["..tRId.."]"
	end
	
	local tPosX = spawnTarget.posX
	local tPosY = spawnTarget.posY
	local tPosZ = spawnTarget.posZ
	local tRotX = spawnTarget.rotX
	local tRotZ = spawnTarget.rotZ
	
	msg = msg.."refIds: "..color.White..refIdList.."\n\n"..color.Yellow
	
	msg = msg.."POS-X: "..color.White..tPosX.."\n"..color.Yellow
	msg = msg.."POS-Y: "..color.White..tPosY.."\n"..color.Yellow
	msg = msg.."POS-Z: "..color.White..tPosZ.."\n\n"..color.Yellow
	msg = msg.."ROT-X: "..color.White..tRotX.."\n"..color.Yellow
	msg = msg.."ROT-Z: "..color.White..tRotZ.."\n\n"..color.Yellow
	
	if spawnTarget.scale then
		msg = msg.."Scale: "..color.White..spawnTarget.scale.."\n"..color.Yellow
	else
		msg = msg.."Scale: "..color.White.."1\n"..color.Yellow
	end
	
	msg = msg.."Respawn Time: "..color.White..spawnTarget.respawnTime.."\n"..color.Yellow
	
	local rTVar = spawnTarget.respawnTime or 0
	msg = msg.."Respawn Time Variance: "..color.White..rTVar.."\n\n"..color.Yellow
	
	if spawnTarget.rareSpawn then
		msg = msg.."Rare Spawn: "..color.White.."True\n"..color.Yellow
	else
		msg = msg.."Rare Spawn: "..color.White.."False\n"..color.Yellow
	end
	if spawnTarget.interior then
		msg = msg.."Interior: "..color.White.."True\n"..color.Yellow
	else
		msg = msg.."Interior: "..color.White.."False\n"..color.Yellow
	end
	if spawnTarget.originalIndex then
		msg = msg.."Original Unique Index: "..color.White.."["..spawnTarget.originalIndex.."]\n"..color.Yellow
	else
		msg = msg.."Original Unique Index: "..color.White.."False\n"..color.Yellow
	end
	
	Players[pid].data.customVariables.spawnSystemTarget = {}
	Players[pid].data.customVariables.spawnSystemTarget[tSpawnCell] = tSpawnId
	
	tes3mp.CustomMessageBox(pid, config.spawnSystemTargetInfoMenu, msg, "Warp to Spawn Point;Delete;Back;Exit")
end


CreatureSpawnSystem.DeleteSpawnPoint = function(pid)

	if Players[pid].data.customVariables.spawnSystemTarget ~= nil then
		local letsSaveSpawns = false
		local letsSaveMobs = false
		
		for t,tData in pairs(Players[pid].data.customVariables.spawnSystemTarget) do
			local targetCell = t
			local targetSpawnId = tData
			
			tes3mp.SendMessage(pid, color.Yellow.."[spawnSystem]: "..color.Green.."targetCell: \""..targetCell.."\"\ntargetSpawnId: ["..targetSpawnId.."]\n", false)
			
			local spawnCount = 0
			
			if mobSpawnDB.creatureSpawnLocations[targetCell] ~= nil then
				for spawnId,spawnData in pairs(mobSpawnDB.creatureSpawnLocations[targetCell]) do
					spawnCount = spawnCount + 1
				end
			end
			
			if spawnCount > 0 then
				
				for refIndex,_data in pairs(mobDecayDB.spawnedMobs) do
					if refIndex ~= nil then
						local target = mobDecayDB.spawnedMobs[refIndex]
						if target.cell ~= nil and target.cell == targetCell then
							if target.spawnId ~= nil and target.spawnId == targetSpawnId then
								mobDecayDB.spawnedMobs[refIndex] = nil
								letsSaveMobs = true
							end
						end
					end
				end
				
				tableHelper.cleanNils(mobDecayDB.spawnedMobs)
				
				mobSpawnDB.creatureSpawnLocations[targetCell][targetSpawnId] = nil
				tableHelper.cleanNils(mobSpawnDB.creatureSpawnLocations)
				
				if tableHelper.isEmpty(mobSpawnDB.creatureSpawnLocations[targetCell]) then
					mobSpawnDB.creatureSpawnLocations[targetCell] = nil
					tableHelper.cleanNils(mobSpawnDB.creatureSpawnLocations)
				end
				
				letsSaveSpawns = true
				
			end
			
		end
		
		if letsSaveMobs then
			Save()
		end
		
		if letsSaveSpawns then
			SaveSpawns()
		end
		
		if target ~= nil then
			return CreatureSpawnSystem.TargetSpawnInfoMenu(pid, target)
		end
	end
	
end


CreatureSpawnSystem.RefIdMenu = function(pid)
	
	setupSpawnVariables(pid)
	
	local pVar = Players[pid].data.customVariables.spawnSettings
	
	local variable1 = ""
	local count = 0
	
	if pVar.refIds ~= nil then
		for s,refId in pairs(pVar.refIds) do
			variable1 = variable1.."\""..refId.."\"\n"
			count = count + 1
		end
	end
		
	
	local msg = color.Orange.."Spawn System refId Menu\n"..color.Yellow
	msg = msg.."\nSpawn RefIds ("..color.White..count..color.Yellow.."):\n"..color.White..variable1..color.Yellow
	
	
	tes3mp.CustomMessageBox(pid, config.spawnSystemRefIdMenu, msg, "Add refId;Remove refId;Remove all refIds;Back;Exit")
end

CreatureSpawnSystem.InputRefIds = function(pid)
	tes3mp.InputDialog(pid, config.spawnSystemRefIdInput, color.White.."Add creature/npc refId:",  color.Red.."Use ALL LOWERCASE and avoid quotations.\nEnter \" \" (One space) to cancel.")
end

CreatureSpawnSystem.RemoveRefIds = function(pid)
	local sort = {}
	local pVar = Players[pid].data.customVariables.spawnSettings
	
	if pVar.refIds ~= nil then
		for s,refId in pairs(pVar.refIds) do
			table.insert(sort, refId)
		end
	end
	table.sort(sort, function(a,b) return a<b end)
	
	local list = "  * Cancel *\n"
	
	for i=1,#sort do
		table.insert(staffVars[pid].refIds, sort[i])
		list = list..sort[i].."\n"
	end
	
	return tes3mp.ListBox(pid, config.spawnSystemRefIdRemove, "Select a refId to remove.", list:sub(1, -2))	
end

CreatureSpawnSystem.InputRespawnTime = function(pid)
	tes3mp.InputDialog(pid, config.spawnSystemRespawnTimeInput, color.White.."Enter respawn time:",  color.Red.."This is time (in seconds) it takes to respawn.\nEnter \" \" (One space) to cancel.")
end




CreatureSpawnSystem.InputRespawnTimeVariance = function(pid)
	tes3mp.InputDialog(pid, config.spawnSystemRespawnTimeVarianceInput, color.White.."Enter respawn time variance:",  color.Red.."This is variance (in seconds) added to the set respawn time.\nEnter \" \" (One space) to cancel.")
end

CreatureSpawnSystem.InputUniqueIndex = function(pid)
	tes3mp.InputDialog(pid, config.spawnSystemUniqueIndexInput, color.White.."Enter UniqueIndex:",  color.Red.."Enter the targets first set of uniqueIndex digits (before the "..color.Yellow.."\"-0\""..color.Red..").\nEnter \" \" (One space) to cancel.")
end

CreatureSpawnSystem.InpueScaleSize = function(pid)
	tes3mp.InputDialog(pid, config.spawnSystemScaleSizeInput, color.White.."Enter Scale Size:",  color.Red.."1 is Default."..color.White.."\nEnter \" \" (One space) to cancel.")
end


local invalidSettings = function(pid)
	tes3mp.SendMessage(pid, color.Yellow.."[spawnSystem]: "..color.Red.."Invalid Settings. Double check spawn settings. Requires at least 1 refId.\n", false)
	return CreatureSpawnSystem.AdminMainMenu(pid)
end



CreatureSpawnSystem.SaveSpawnFunction = function(pid)
	
	local pVar = Players[pid].data.customVariables.spawnSettings
	
	if pVar == nil or (pVar.cell == nil and pVar.cell == "") or (pVar.posX == nil or pVar.posX == 0 or pVar.posY == nil or pVar.posY == 0 or pVar.posZ == nil or pVar.posZ == 0) or (pVar.rotX == nil or pVar.rotX == 0 or pVar.rotZ == nil or pVar.rotZ == 0) then
		return invalidSettings(pid)
	end
	
	if pVar.refIds ~= nil then
		local refIdCount = 0
		for s,refId in pairs(pVar.refIds) do
			refIdCount = refIdCount + 1
		end
		if refIdCount < 1 then
			return invalidSettings(pid)
		end
	else
		return invalidSettings(pid)
	end
	
	if pVar.respawnTime == nil or pVar.respawnTime < 0 then
		return invalidSettings(pid)
	end
	
	if mobSpawnDB.creatureSpawnLocations[pVar.cell] == nil then
		 mobSpawnDB.creatureSpawnLocations[pVar.cell] = {}
	end
	
	local newSpawnId = 1
	for sId,sdata in pairs(mobSpawnDB.creatureSpawnLocations[pVar.cell]) do
		sId = tonumber(sId)
		if sdata.spawnRefs == nil or tableHelper.isEmpty(sdata.spawnRefs) then
			break
		else
			newSpawnId = newSpawnId + 1
		end
	end
	
	newSpawnId = tostring(newSpawnId)
	
	mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId] = {}
	mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].spawnRefs = {}
	
	for s,refId in pairs(pVar.refIds) do
		table.insert(mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].spawnRefs, refId)
	end
	
	mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].respawnTime = pVar.respawnTime
	
	if pVar.rareSpawn then
		mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].rareSpawn = pVar.rareSpawn
	end
	
	mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].posX = pVar.posX
	mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].posY = pVar.posY
	mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].posZ = pVar.posZ
	mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].rotX = pVar.rotX
	mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].rotZ = pVar.rotZ
	
	if pVar.respawnTimeVariance > 0 then
		mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].respawnVariance = pVar.respawnTimeVariance
	end
	
	local cellCheck = pVar.cell
	if LoadedCells[cellCheck] ~= nil then
		if not LoadedCells[cellCheck].isExterior then
			mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].interior = true
		end
	else
		return invalidSettings(pid)
	end
	
	-- if uniqueIndex is found, lets delete it:
	if pVar.uniqueIndex ~= nil then
		mobSpawnDB.creatureSpawnLocations[pVar.cell][newSpawnId].originalIndex = pVar.uniqueIndex
		CreatureSpawnSystem.updateDeletion(pid, pVar.uniqueIndex)
		tableHelper.insertValueIfMissing(indexesToDelete, pVar.uniqueIndex)
		pVar.uniqueIndex = nil
	end
	
	local cellId =  pVar.cell
	local cSpawn = mobSpawnDB.creatureSpawnLocations[cellId][newSpawnId]
	
	if not tableHelper.isEmpty(mobDecayDB.spawnedMobs) then
		for uid,uniqueIndex in pairs(mobDecayDB.spawnedMobs) do
		
			if uniqueIndex.cell ~= nil and uniqueIndex.cell == cellId and uniqueIndex.spawnId ~= nil and uniqueIndex.spawnId == newSpawnId then
				mobDecayDB.spawnedMobs[uid] = nil
			end
			
		end
	end
	
	local location = {posX = cSpawn.posX, posY = cSpawn.posY, posZ = cSpawn.posZ, rotX = cSpawn.rotX, rotY = 0, rotZ = cSpawn.rotZ}
	local cRef = mobSpawnDB.creatureSpawnLocations[cellId][newSpawnId].spawnRefs
	local keys = {}
	for i=1,#cRef do 
		table.insert(keys, i) 
	end
	
	local targetRefId = cRef[math.random(#keys)]
	
	local newIndex = logicHandler.CreateObjectAtLocation(cellId, location, targetRefId, "spawn")
	
	mobDecayDB.spawnedMobs[newIndex] = {}
	mobDecayDB.spawnedMobs[newIndex].cell = cellId
	mobDecayDB.spawnedMobs[newIndex].spawnId = newSpawnId
	
	-- Set Rare:
	if mobSpawnDB.creatureSpawnLocations[cellId][newSpawnId].rareSpawn ~= nil then
		mobDecayDB.spawnedMobs[newIndex].rareSpawn = true
	end
	-- Adjust scale:
	if mobSpawnDB.creatureSpawnLocations[cellId][newSpawnId].scale ~= nil then
		local scaleSize = mobSpawnDB.creatureSpawnLocations[cellId][newSpawnId].scale
		
		local objectData = LoadedCells[cellId].data.objectData
		LoadedCells[cellId].data.objectData[newIndex].scale = tonumber(scaleSize)
		
		table.insert(LoadedCells[cellId].data.packets.scale, newIndex)
		
		for index, visitorPid in pairs(LoadedCells[cellId].visitors) do
		   if Players[visitorPid] ~= nil and Players[visitorPid]:IsLoggedIn() then
				if LoadedCells[cellId] ~= nil then
					LoadedCells[cellId]:LoadObjectsScaled(visitorPid, objectData, {newIndex})
				end
			end
		end
	end
	
	LoadedCells[cellId].data.entry.spawnSystemInitialized = true
	
	tes3mp.SendMessage(pid, "Spawn setup complete!\n", false)
	SaveSpawns()
end


customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	
	if idGui == config.spawnSystemMainMenu then -- View Main Perks Menu GUI
		if tonumber(data) == 0 then -- Spawn refIds
			CreatureSpawnSystem.RefIdMenu(pid)
			
		elseif tonumber(data) == 1 then -- Respawn Time
			CreatureSpawnSystem.InputRespawnTime(pid)
		
		elseif tonumber(data) == 2 then -- Respawn Time Variance
			CreatureSpawnSystem.InputRespawnTimeVariance(pid)
			
		elseif tonumber(data) == 3 then --Rare Spawn
			if Players[pid].data.customVariables.spawnSettings.rareSpawn == nil then
				Players[pid].data.customVariables.spawnSettings.rareSpawn = true
			else
				Players[pid].data.customVariables.spawnSettings.rareSpawn = nil
			end
			CreatureSpawnSystem.AdminMainMenu(pid)
			
		elseif tonumber(data) == 4 then --	Original Unique Index
			CreatureSpawnSystem.InputUniqueIndex(pid)
		
		elseif tonumber(data) == 5 then --	Other Spawn Info
			CreatureSpawnSystem.OtherSpawnInfoMenu(pid)
			
		elseif tonumber(data) == 6 then --	Save This Spawn
			CreatureSpawnSystem.SaveSpawnFunction(pid)
		
		elseif tonumber(data) == 7 then -- reset options
			clearSpawnVariables(pid)
			return CreatureSpawnSystem.AdminMainMenu(pid)
		
		elseif tonumber(data) == 8 then -- scale or exit
			CreatureSpawnSystem.InpueScaleSize(pid)
			
		else -- Exit
			return
		end
	
	
	elseif idGui == config.spawnSystemRefIdMenu then
		if tonumber(data) == 0 then -- Add refIds
			CreatureSpawnSystem.InputRefIds(pid)
		elseif tonumber(data) == 1 then -- Remove refIds
			CreatureSpawnSystem.RemoveRefIds(pid)
		elseif tonumber(data) == 2 then -- Remove all refIds
			tes3mp.SendMessage(pid, "All selected refId's removed.\n", false)
			Players[pid].data.customVariables.spawnSettings.refIds = {}
			CreatureSpawnSystem.RefIdMenu(pid)
		elseif tonumber(data) == 3 then -- Back
			CreatureSpawnSystem.AdminMainMenu(pid)
		else -- Exit
			return
		end
	
	elseif idGui == config.spawnSystemRefIdInput then
		if data == nil or data == "" or data == " " then
			return CreatureSpawnSystem.RefIdMenu(pid)
		else			
			if Players[pid].data.customVariables.spawnSettings.refIds == nil then
				Players[pid].data.customVariables.spawnSettings.refIds = {}
			end
			tes3mp.SendMessage(pid, "\""..data.."\" added to refIds.\n", false)
			tableHelper.insertValueIfMissing(Players[pid].data.customVariables.spawnSettings.refIds, data)
			return CreatureSpawnSystem.RefIdMenu(pid)
		end
	
	elseif idGui == config.spawnSystemRefIdRemove then
		if tonumber(data) == nil or tonumber(data) == 0 then
			return CreatureSpawnSystem.RefIdMenu(pid)
		else
			local var = tonumber(data)
			if staffVars[pid] and staffVars[pid].refIds then
				local targetRefId = staffVars[pid].refIds[var]
				
				if Players[pid].data.customVariables.spawnSettings.refIds ~= nil then
					if tableHelper.containsValue(Players[pid].data.customVariables.spawnSettings.refIds, targetRefId) then
						tableHelper.removeValue(Players[pid].data.customVariables.spawnSettings.refIds, targetRefId)
						
						tes3mp.SendMessage(pid, "Removed refId: \""..targetRefId.."\"\n", false)
					else
						tes3mp.SendMessage(pid, "\""..targetRefId.."\" not found.\n", false)
					end
				else
					tes3mp.SendMessage(pid, "No refIds have been set yet.\n", false)
				end
			else
				tes3mp.SendMessage(pid, color.Error.."List of refId's not found.\n", false)
			end
			return CreatureSpawnSystem.RefIdMenu(pid)
		end
		
	
	elseif idGui == config.spawnSystemRespawnTimeInput then
		if data == nil or data == "" or data == " " then
			return CreatureSpawnSystem.AdminMainMenu(pid)
		else
			if type(tonumber(data)) ~= "number" then
				local message = color.Yellow..data..color.White.." is not a number.\n"
				tes3mp.SendMessage(pid, message, false)
				return CreatureSpawnSystem.AdminMainMenu(pid)
			elseif tonumber(data) < 0 then
				tes3mp.SendMessage(pid, "This cannot be a negative number.\n", false)
				return CreatureSpawnSystem.AdminMainMenu(pid)
			end
			
			local msg = "Respawn seconds set to: "..data.."\n"		
			tes3mp.SendMessage(pid, msg, false)
			Players[pid].data.customVariables.spawnSettings.respawnTime = tonumber(data)
			return CreatureSpawnSystem.AdminMainMenu(pid)
		end
		
	elseif idGui == config.spawnSystemRespawnTimeVarianceInput then
		if data == nil or data == "" or data == " " then
			return CreatureSpawnSystem.AdminMainMenu(pid)
		else
			if type(tonumber(data)) ~= "number" then
				local message = color.Yellow..data..color.White.." is not a number.\n"
				tes3mp.SendMessage(pid, message, false)
				return CreatureSpawnSystem.AdminMainMenu(pid)
			elseif tonumber(data) < 0 then
				tes3mp.SendMessage(pid, "This cannot be a negative number.\n", false)
				return CreatureSpawnSystem.AdminMainMenu(pid)
			end
			
			local msg = "Respawn variance seconds set to: "..data.."\n"		
			tes3mp.SendMessage(pid, msg, false)
			Players[pid].data.customVariables.spawnSettings.respawnTimeVariance = tonumber(data)
			return CreatureSpawnSystem.AdminMainMenu(pid)
		end
		
	elseif idGui == config.spawnSystemScaleSizeInput then
		if data == nil or data == "" or data == " " then
			return CreatureSpawnSystem.AdminMainMenu(pid)
		else
			if type(tonumber(data)) ~= "number" then
				local message = color.Yellow..data..color.White.." is not a number.\n"
				tes3mp.SendMessage(pid, message, false)
				return CreatureSpawnSystem.AdminMainMenu(pid)
			elseif tonumber(data) <= 0 then
				tes3mp.SendMessage(pid, "This cannot be a negative number.\n", false)
				return CreatureSpawnSystem.AdminMainMenu(pid)
			end
			
			local msg = "Respawn variance seconds set to: "..data.."\n"		
			tes3mp.SendMessage(pid, msg, false)
			Players[pid].data.customVariables.spawnSettings.respawnScaleSize = tonumber(data)
			return CreatureSpawnSystem.AdminMainMenu(pid)
		end
		
	elseif idGui == config.spawnSystemUniqueIndexInput then
		if data == nil or data == "" or data == " " then
			return CreatureSpawnSystem.AdminMainMenu(pid)
		else
			if type(tonumber(data)) ~= "number" then
				local message = color.Yellow..data..color.White.." is not a number.\n"
				tes3mp.SendMessage(pid, message, false)
				return CreatureSpawnSystem.AdminMainMenu(pid)
			elseif tonumber(data) < 0 then
				tes3mp.SendMessage(pid, "This cannot be a negative number.\n", false)
				return CreatureSpawnSystem.AdminMainMenu(pid)
			end
			
			local uId = tostring(data).."-0"
			local msg = "UniqueIndex: "..uId.."\n"		
			tes3mp.SendMessage(pid, msg, false)
			Players[pid].data.customVariables.spawnSettings.uniqueIndex = uId
			return CreatureSpawnSystem.AdminMainMenu(pid)
		end
	
	elseif idGui == config.spawnSystemOtherInfoMenu then
		if tonumber(data) == 0 then -- This cell
			local targetCell = tes3mp.GetCell(pid)
			staffSelectedCell[pid] = targetCell
			CreatureSpawnSystem.ThisCellSpawnInfoMenu(pid, targetCell)
		elseif tonumber(data) == 1 then -- List of cells
			CreatureSpawnSystem.ListOfCellsSpawnInfoMenu(pid)
		elseif tonumber(data) == 2 then -- Back
			CreatureSpawnSystem.AdminMainMenu(pid)
		else -- Exit
			return
		end
	
	elseif idGui == config.spawnSystemThisCellInfoMenu then
		if tonumber(data) == 0 then -- This cell
			CreatureSpawnSystem.OtherSpawnInfoMenu(pid)
		elseif tonumber(data) > 0 and tonumber(data) < 90000 then -- List of refids?
			CreatureSpawnSystem.TargetSpawnInfoMenu(pid, data)
		else -- Exit
			return CreatureSpawnSystem.OtherSpawnInfoMenu(pid)
		end
	
	elseif idGui == config.spawnSystemAllCellsListInfoMenu then
		if tonumber(data) == 0 then -- Cancel
			CreatureSpawnSystem.OtherSpawnInfoMenu(pid)
		elseif tonumber(data) > 0 and tonumber(data) < 90000 then -- List of cells
			local choice = tonumber(data)--tostring(data)
			
			local cellName = spawnListInfo[pid][choice]
			staffSelectedCell[pid] = cellName 
			if cellName == nil then tes3mp.SendMessage(pid, color.Error.."An error occurred. Try again.\n", false) return end
			CreatureSpawnSystem.ThisCellSpawnInfoMenu(pid, cellName)
		else -- Exit
			return CreatureSpawnSystem.OtherSpawnInfoMenu(pid)
		end
		
	--"Update POS to your\ncurrent POS;Edit Respawn Time;Edit Rare Spawn;Edit Original Unique Index;Delete;Back;Exit")
	elseif idGui == config.spawnSystemTargetInfoMenu  then
		if tonumber(data) == 0 then -- Warp to Spawn Point
			
			for t,tData in pairs(Players[pid].data.customVariables.spawnSystemTarget) do
				local targetCell = t
				local targetSpawnId = tData
				
				local spawnTarget = mobSpawnDB.creatureSpawnLocations[targetCell][targetSpawnId]
				
				if LoadedCells[targetCell] == nil then
					logicHandler.LoadCell(targetCell)
				end
				
				tes3mp.SetCell(pid, targetCell)
				tes3mp.SendCell(pid)
				tes3mp.SetPos(pid, spawnTarget.posX, spawnTarget.posY, spawnTarget.posZ)
				tes3mp.SetRot(pid, spawnTarget.rotX, spawnTarget.rotZ)
				tes3mp.SendPos(pid)
			
			end
			
		elseif tonumber(data) == 1 then -- Delete
			CreatureSpawnSystem.DeleteTargetSpawnInfo(pid)
		elseif tonumber(data) == 2 then -- Back
			local cellName = staffSelectedCell[pid]
			CreatureSpawnSystem.ThisCellSpawnInfoMenu(pid, cellName)
			--CreatureSpawnSystem.OtherSpawnInfoMenu(pid)
		else -- Exit
			return
		end
	
	elseif idGui == config.spawnSystemDeletionConfirmationMenu then
		if tonumber(data) == 0 then -- Don't delete
			if Players[pid].data.customVariables.spawnSystemTarget ~= nil then
				for t,tData in pairs(Players[pid].data.customVariables.spawnSystemTarget) do
					local target = tData
				end
				if target ~= nil then
					return CreatureSpawnSystem.TargetSpawnInfoMenu(pid, target)
				end
			end
			return CreatureSpawnSystem.OtherSpawnInfoMenu(pid)
			
		elseif tonumber(data) == 1 then -- Delete
			CreatureSpawnSystem.DeleteSpawnPoint(pid)
			return CreatureSpawnSystem.OtherSpawnInfoMenu(pid)
		elseif tonumber(data) == 2 then -- Back
			CreatureSpawnSystem.ThisCellSpawnInfoMenu(pid, staffSelectedCell[pid])
		else -- Exit
			return
		end
		
	end
	
end)

customCommandHooks.registerCommand("sp", function(pid, cmd)
	if Players[pid].data.settings.staffRank > 1 then
		CreatureSpawnSystem.AdminMainMenu(pid)
	end
end)

customCommandHooks.registerCommand("spawnpoint", function(pid, cmd)
	if Players[pid].data.settings.staffRank > 1 then
		CreatureSpawnSystem.AdminMainMenu(pid)
	end
end)

return CreatureSpawnSystem