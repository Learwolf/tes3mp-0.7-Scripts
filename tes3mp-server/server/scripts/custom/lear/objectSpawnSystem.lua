--[[
	Object Spawn System
	   version 1.00
		by Learwolf
		
	Version History:
		* 1.00 (6/18/2020) - Initial release.
	
	Install Instructions:
		- Place this script inside your 'server/scripts/custom' folder.
		- Open the 'customScripts.lua' found inside your 'server/scripts' folder.
		- Add the following text on a new line:
				require("custom.objectSpawnSystem.objectSpawnSystem")
		- Make sure there are no '--' characters infront of it (as that disables scripts).
		- Save 'customScripts.lua' and relaunch your server.
	
	
	Description:
		This script will allow you to save the objects placed in the cell you are in so that should the cell be deleted from, say, 
		a hard reset, it will revert back to this exact save. Meaning, all placed/scaled objects will be reverted to this save, as 
		well as any custom placed containers will remember their original inventory contents when the save was made.
		
		Once a player enters the cell after a reset, if any of the objects from when the save were made are missing, it will add them back 
		in a seamless transition.
		
		This can be useful for server owners who want certain cells to always have certain objects to be in a cell, even after a reset.
		
		Do note, I have not made this compatible with in-game cell resets (Like Urm or Atkanas scripts) 'yet'. If needed, I will make the compatibility, 
		but I do not feel its needed at this point in time.
	
	
	Information:
		There is nothing really to configure aside from the default staffRank that can use the command.
		
		In game, use the chat command '/sobj' inside the cell that you want to save your placed objects to persist through server resets.
		From the '/sobj' menu, you can either save the entire cell (I recommend doing this after you've adjusted a fresh cell to your liking) or 
		you can enter one uniqueIndex (only enter uniqueIndexes of the cell you are in. You can use 'tb' in the games console if you're uncertain where
		the cell boundaries are) to save just that one object to the cell.
		
		The 'save all' feature should (I havent tested every possibility) know if you've already saved ceratain objects, and will skip them if so,
		so there should be no duplicates saved.
		
		A log of everything that is saved to the cell is placed inside your 'server/data' folder labled something along the lines of:
			'objectsSaved 06.18.20.txt'
		This log will list the uniqueIndex/refId and scale that saved. As well as what (if any) contents a container has in it.
		
		Upon objects being saved, from the next server restart onward, that cell will spawn everything automatically when the cell is loaded.
		
		If its your kind of thing:
		It is also possible to make adjustments on a test server, that can than be pushed to your live server on the next restart without you having to 
		be around to do it. See the information below regarding:
			local updatedObjectSpawnDB = jsonInterface.load("custom/updatedSpawnedObjectsDB.json")
		
--]]


objectSpawnSystem = {}

local config = {}

config.staffRankToSaveObjectSpawns = 2 -- This is the only thing you should need to configure. >= this number is the staff rank that can use the /sobj command.

config.InputUniqueIndexOfObject = 0505072020
config.UniqueIndexConfirmation = 0505072021
config.InputScaleForUniqueIndexOfObject = 0505072022
config.ObjectSpawnOptionsMenu = 0505072023
config.ObjectSpawnSaveAllConfirm = 0505072024

local objectSpawnDB = jsonInterface.load("custom/spawnedObjectsDB.json")

-- This file is used for updating from a test server to your live server (see explanation below):
local updatedObjectSpawnDB = jsonInterface.load("custom/updatedSpawnedObjectsDB.json")
--[[ 
^ ^ ^ ^ ^ ^ ^ ^ ^ ^
I.E., if you update spawnedObjectsDB.json on your test server, and want to push it to your live server on the next server restart, 
all you would need to do is rename your test servers 'spawnedObjectsDB.json' to 'updatedSpawnedObjectsDB.json' and place it inside 
the same folder where your live servers 'spawnedObjectsDB.json' is. Then on the next server restart, it will pull replace the contents completely.

--]]

-- Setup objectSpawnDB
if objectSpawnDB == nil then
    objectSpawnDB = {}
end

-- Saving of the .json file
local Save = function()
	jsonInterface.save("custom/spawnedObjectsDB.json", objectSpawnDB)
end

-- Loading of the .json file
local Load = function()
	objectSpawnDB = jsonInterface.load("custom/spawnedObjectsDB.json")
end

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
	if objectSpawnDB.spawnedObjectLocations == nil then
		objectSpawnDB.spawnedObjectLocations = {}
		Save()
	end
	
	if updatedObjectSpawnDB ~= nil and objectSpawnDB.spawnedObjectLocations ~= nil then
		objectSpawnDB.spawnedObjectLocations = updatedObjectSpawnDB.spawnedObjectLocations
		Save()
	end
	Load()
end)





local loadPrintout = function()
	local textDate = os.date("%m.%d.%y")
	local file = io.open(tes3mp.GetModDir() .. "/objectsSaved "..textDate..".txt", "a")
	
	return file
end

local writePrintout = function(text2Write)
	local file = loadPrintout()
	file:write(text2Write,"\n")
	io.close(file)
end





cellsAlreadyHandledThisSession = {}

local getPlacedObjectCountForCell = function(pid)
	
	local thisCell = tes3mp.GetCell(pid)
	local amount = 0
	
	if LoadedCells[thisCell] == nil then
		if LoadedCells[thisCell].data.packets.place ~= nil then
			for i=1, #LoadedCells[thisCell].data.packets.place do
				amount = amount + 1
			end
		end
	end
	
	return amount
end



-- Save Every Altered Object in the cell:
local savePlacedObjectsForCell = function(pid)
	
	local triggerSave = false
	
	local thisCell = tes3mp.GetCell(pid)
	local placeAmount = 0
	local scaleAmount = 0
	
	local containerAmount = 0
	
	local uniqueIndexesToCheck = {}
	
	if LoadedCells[thisCell] ~= nil then
		if LoadedCells[thisCell].data.packets.place ~= nil then
			for i=1, #LoadedCells[thisCell].data.packets.place do
				table.insert(uniqueIndexesToCheck, LoadedCells[thisCell].data.packets.place[i])
			end
		end
	end
	
	
	for _,uniqueIndex in pairs(uniqueIndexesToCheck) do
	
		if objectSpawnDB.spawnedObjectLocations[thisCell] ~= nil and objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex] ~= nil then
			
			tes3mp.SendMessage(pid, color.Yellow.."[Object Spawn System]: "..color.Error.."The unique index "..color.Yellow..uniqueIndex..color.Error.." has been previously added. Skipping it.\n", false) 
			
			local txt = uniqueIndex.." has been previously added, so skipping it.\n"
			writePrintout(txt)
			
		else
			
			if LoadedCells[thisCell].data.objectData[uniqueIndex] ~= nil then
				local oRefId = LoadedCells[thisCell].data.objectData[uniqueIndex].refId
				--print(oRefId)
				
				if LoadedCells[thisCell].data.objectData[uniqueIndex].location == nil then 
					tes3mp.SendMessage(pid, color.Yellow.."[Object Spawn System]: "..color.Error.."The unique index "..color.Yellow..uniqueIndex..color.Error..
					" does not have a location set or is hidden/deleted. Skipping it.\n", false) 
					
					local txt = uniqueIndex.." ("..oRefId..") does not have a set location or is hidden/deleted, so skipping it.\n"
					writePrintout(txt)
					
				else
					
					local oLocation = {
						posX = LoadedCells[thisCell].data.objectData[uniqueIndex].location.posX,
						posY = LoadedCells[thisCell].data.objectData[uniqueIndex].location.posY,
						posZ = LoadedCells[thisCell].data.objectData[uniqueIndex].location.posZ,
						rotX = LoadedCells[thisCell].data.objectData[uniqueIndex].location.rotX,
						rotY = LoadedCells[thisCell].data.objectData[uniqueIndex].location.rotY,
						rotZ = LoadedCells[thisCell].data.objectData[uniqueIndex].location.rotZ
					}
					
					
					if objectSpawnDB.spawnedObjectLocations[thisCell] == nil then objectSpawnDB.spawnedObjectLocations[thisCell] = {} end
					
					objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex] = {}
					
					objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex].refId = oRefId
					
					objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex].posX = oLocation.posX
					objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex].posY = oLocation.posY
					objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex].posZ = oLocation.posZ
					objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex].rotX = oLocation.rotX
					objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex].rotY = oLocation.rotY
					objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex].rotZ = oLocation.rotZ
					
					-- CONTAINER CHECK:
					if  LoadedCells[thisCell].data.objectData[uniqueIndex].inventory ~= nil then
						local containerContents = {}
						
						for i=1, #LoadedCells[thisCell].data.objectData[uniqueIndex].inventory do
							table.insert(containerContents, LoadedCells[thisCell].data.objectData[uniqueIndex].inventory[i])
						end
						
						containerAmount = containerAmount + 1
						objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex].inventory = containerContents
						
						local txt = uniqueIndex.." ("..oRefId..")had the following contents added to its inventory:\n"
						
						for i=1, #containerContents do
							txt = txt.."refId: \""..containerContents[i].refId.."\", ".."count: \""..containerContents[i].count.."\", "..
							"enchantmentCharge: \""..containerContents[i].enchantmentCharge.."\", ".."charge: \""..containerContents[i].charge.."\", "..
							"soul: \""..containerContents[i].soul.."\"\n"
						end
						
						writePrintout(txt)
					end
					-- END CONTAINER CHECK.
					
					-- SCALE CHECK:
					if LoadedCells[thisCell].data.objectData[uniqueIndex].scale ~= nil then
						objectSpawnDB.spawnedObjectLocations[thisCell][uniqueIndex].scale = LoadedCells[thisCell].data.objectData[uniqueIndex].scale
						scaleAmount = scaleAmount + 1
						
						local txt = uniqueIndex.." ("..oRefId..") had its scale saved as "..LoadedCells[thisCell].data.objectData[uniqueIndex].scale..".\n"
						writePrintout(txt)
					end
					-- END SCALE CHECK.
					
					placeAmount = placeAmount + 1
					triggerSave = true
					
					local txt = uniqueIndex.." ("..oRefId..") finished succesfully!\n"
					writePrintout(txt)
					
				end
				
			else
				tes3mp.SendMessage(pid, color.Yellow.."[Object Spawn System]: "..color.Error.."An error occurred! "..color.Yellow..uniqueIndex..color.Error.." does not exist. Skipping it.\n", false)
				local txt = uniqueIndex.." ("..oRefId..") does not have a set location or is hidden/deleted, so skipping it.\n"
				writePrintout(txt)
			end
		
		
			
		end
	
	end
	
	
	if triggerSave then
		Save()
		local msg = color.Yellow.."[Object Spawn System]: "..color.MsgBox..thisCell..color.Green.." saved successfully"..color.MsgBox.."!\n"..
					"Saved Objects: "..color.White..placeAmount..color.MsgBox.."\nSaved Scales: "..color.White..scaleAmount.."\n"..
					"Saved Containers: "..color.White..containerAmount..color.MsgBox.."\n"
		
		
		local txt = thisCell.." saved successfully!\nSaved Objects: "..placeAmount.."\nSaved Scales: "..scaleAmount.."\nSaved Container Contents: "..containerAmount
		writePrintout(txt)
		
		tes3mp.SendMessage(pid, msg, false)
	end
	
	
	
end


local function updateScale(cellId, tUniqueIndex, tRefId, bScale)
	
	local foundUniqueIndex = tUniqueIndex
	
	if LoadedCells[cellId] ~= nil then
		
		local objData = LoadedCells[cellId].data.objectData
		
		if foundUniqueIndex == nil then
			for uId,_data in pairs(objData) do
				if _data.refId == tRefId then
					foundUniqueIndex = uId
						for pid, player in pairs(Players) do
							if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
								--tes3mp.SendMessage(pid, "Index found: "..uId.."\n", false)
							end
						end
					break
				end
			end
		end
		
		objData[foundUniqueIndex].scale = bScale
		table.insert(LoadedCells[cellId].data.packets.scale, foundUniqueIndex)
		
		local oData = {refId = tRefId, scale = bScale}
		packetBuilder.AddObjectScale(foundUniqueIndex, oData)
		tes3mp.SendObjectScale()
		
		LoadedCells[cellId]:Save()
		
	end

end


objectSpawnSystem.CheckForCellObjectSpawns = function(pid)
	
	for cellId, oCellData in pairs(objectSpawnDB.spawnedObjectLocations) do
		if LoadedCells[cellId] ~= nil and not tableHelper.containsValue(cellsAlreadyHandledThisSession, cellId) then
			
			for uniqueIndex, _uIndexData in pairs(objectSpawnDB.spawnedObjectLocations[cellId]) do
				Load()
				
				if not tableHelper.containsValue(LoadedCells[cellId].data.packets.place, uniqueIndex) or (LoadedCells[cellId].data.objectData[uniqueIndex] ~= nil and LoadedCells[cellId].data.objectData[uniqueIndex].refId ~= _uIndexData.refId) then
				--if not tableHelper.containsValue(LoadedCells[cellId].data.packets.place, uniqueIndex) then
					local oLocation = {
						posX = _uIndexData.posX,
						posY = _uIndexData.posY,
						posZ = _uIndexData.posZ,
						rotX = _uIndexData.rotX,
						rotY =  _uIndexData.rotY,--0,
						rotZ = _uIndexData.rotZ
					}
					local oRefId = _uIndexData.refId
					local scale = 1
					if _uIndexData.scale ~= nil then
						scale = _uIndexData.scale
					end
					
					local newUniqueIndex = logicHandler.CreateObjectAtLocation(cellId,oLocation,oRefId,"place")
					
					objectSpawnDB.spawnedObjectLocations[cellId][newUniqueIndex] = objectSpawnDB.spawnedObjectLocations[cellId][uniqueIndex]
					
					if objectSpawnDB.spawnedObjectLocations[cellId][uniqueIndex].scale ~= nil then
						local scaleSize = objectSpawnDB.spawnedObjectLocations[cellId][uniqueIndex].scale
						-- local authPid = LoadedCells[cellId]:GetAuthority()
						-- local timeAmount = os.time() + 15
						-- Players[authPid].data.customVariables.temporaryConsoleAllowed = timeAmount
						-- logicHandler.RunConsoleCommandOnObject(authPid, "setscale "..scaleSize, cellId, newUniqueIndex, false)
						updateScale(cellId, newUniqueIndex, oRefId, scaleSize)
					end
					
					
					
					
					if objectSpawnDB.spawnedObjectLocations[cellId][uniqueIndex].inventory ~= nil then
						LoadedCells[cellId].data.objectData[newUniqueIndex].inventory = objectSpawnDB.spawnedObjectLocations[cellId][uniqueIndex].inventory
						LoadedCells[cellId]:LoadContainers(pid, LoadedCells[cellId].data.objectData, { newUniqueIndex })
					end
					
					
					
					
					objectSpawnDB.spawnedObjectLocations[cellId][uniqueIndex] = nil
					Save()
				end
				
				
			end
			
			
			tableHelper.insertValueIfMissing(cellsAlreadyHandledThisSession, cellId)
		end
	end

end


customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, previousCellDescription, currentCellDescription)
	objectSpawnSystem.CheckForCellObjectSpawns(pid)
end)

objectSpawnSystem.AddUniqueIndexToDatabase = function(pid)
	
	local currentCell = tes3mp.GetCell(pid)
	local uniqueIndex = objectSpawnSelected[pid]
	

	if objectSpawnDB.spawnedObjectLocations[currentCell] == nil then
		objectSpawnDB.spawnedObjectLocations[currentCell] = {}
	end
	
	if objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex] ~= nil then
		tes3mp.SendMessage(pid, color.Yellow.."[Object Spawn System]: "..color.Error.."This unique index has been previously added already.\n", false)
	else
		if LoadedCells[currentCell].data.objectData[uniqueIndex] ~= nil then
			local oRefId = LoadedCells[currentCell].data.objectData[uniqueIndex].refId
			--print(oRefId)
			
			if LoadedCells[currentCell].data.objectData[uniqueIndex].location == nil then return tes3mp.SendMessage(pid, color.Yellow.."[Object Spawn System]: "..color.Error.."This unique index does not have a location set or is hidden/deleted.\n", false) end
		
			local oLocation = {
				posX = LoadedCells[currentCell].data.objectData[uniqueIndex].location.posX,
				posY = LoadedCells[currentCell].data.objectData[uniqueIndex].location.posY,
				posZ = LoadedCells[currentCell].data.objectData[uniqueIndex].location.posZ,
				rotX = LoadedCells[currentCell].data.objectData[uniqueIndex].location.rotX,
				rotY = LoadedCells[currentCell].data.objectData[uniqueIndex].location.rotY,
				rotZ = LoadedCells[currentCell].data.objectData[uniqueIndex].location.rotZ
			}
			
			
			if objectSpawnDB.spawnedObjectLocations[currentCell] == nil then objectSpawnDB.spawnedObjectLocations[currentCell] = {} end
			
			objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex] = {}
			
			objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex].refId = oRefId
			
			objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex].posX = oLocation.posX
			objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex].posY = oLocation.posY
			objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex].posZ = oLocation.posZ
			objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex].rotX = oLocation.rotX
			objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex].rotY = oLocation.rotY
			objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex].rotZ = oLocation.rotZ
			
			-- local containerContents
			
			-- if  LoadedCells[currentCell].data.objectData[uniqueIndex].inventory ~= nil then
				-- containerContents = {}
				-- for i=1, #LoadedCells[currentCell].data.objectData[uniqueIndex].inventory do
					-- table.insert(containerContents, LoadedCells[currentCell].data.objectData[uniqueIndex].inventory[i])
				-- end
				-- objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex].inventory = containerContents
			-- end
			
			if objectSpawnSelectedScale[pid] ~= nil and objectSpawnSelectedScale[pid] ~= 1 then
				objectSpawnDB.spawnedObjectLocations[currentCell][uniqueIndex].scale = tonumber(objectSpawnSelectedScale[pid])
			end
			
			Save()
			tes3mp.SendMessage(pid, color.Yellow.."[Object Spawn System]: "..color.MsgBox.."Unique index "..color.Green.."successfully"..color.MsgBox.." added.\n", false)
		else
			tes3mp.SendMessage(pid, color.Yellow.."[Object Spawn System]: "..color.Error.."An error occurred. Please check the uniqueIndex and your cell then try again.\n", false)
		end
	end
	
	
	objectSpawnSelected[pid] = nil
	objectSpawnSelectedScale[pid] = nil
	
end

objectSpawnSelected = {}
objectSpawnSelectedScale = {}

objectSpawnSystem.InputUniqueIndexOfObject = function(pid)
	tes3mp.InputDialog(pid, config.InputUniqueIndexOfObject, color.MsgBox.."Enter Objects Unique Index:", "To enter it into the database.\nEnter \" \" (One space) to cancel.")
end

objectSpawnSystem.InputScaleForUniqueIndexOfObject = function(pid)
	tes3mp.InputDialog(pid, config.InputScaleForUniqueIndexOfObject, color.MsgBox.."Enter Objects Unique Index:", "To enter it into the database.\nEnter \" \" (One space) to cancel.")
end

objectSpawnSystem.UniqueIndexConfirmation = function(pid)
	
	local currentCell = tes3mp.GetCell(pid)
	local uniqueIndex = objectSpawnSelected[pid]
	local PossibleScale = LoadedCells[currentCell].data.objectData[uniqueIndex]
	
	if LoadedCells[currentCell].data.objectData[uniqueIndex] ~= nil and LoadedCells[currentCell].data.objectData[uniqueIndex].scale ~= nil then 
		PossibleScale = LoadedCells[currentCell].data.objectData[uniqueIndex].scale 
	else 
		PossibleScale = 1
	end
	if objectSpawnSelectedScale[pid] == nil then objectSpawnSelectedScale[pid] = PossibleScale end
	
	local msg = color.Orange.."Object Spawn System:\n\n"..color.MsgBox..
		color.MsgBox.."Selected Unique Index:\n"..color.Yellow..
		objectSpawnSelected[pid].."\n\n"..color.MsgBox..
		"Your current cell: \n"..color.Green..
		tes3mp.GetCell(pid).."\n\n"..color.MsgBox..
		"Unique Indexes Scale: \n"..color.White..
		objectSpawnSelectedScale[pid].."\n\n"..color.Red..
		"MAKE SURE YOU ARE IN THE OBJECTS CELL!!!\n\n"..color.MsgBox..
		"Add this unique index to the database?\n"
		
	tes3mp.CustomMessageBox(pid, config.UniqueIndexConfirmation, msg, "No;Yes;Setcale;Exit")
	
end


objectSpawnSystem.ObjectSpawnOptionsMenu = function(pid)
	
	local msg = color.Orange.."Object Spawn System:\n\n"..color.MsgBox..
		color.Yellow.."Enter Unique Index "..color.MsgBox.."to save only that index/scale.\n\n"..
		color.Yellow.."Save Entire Cell "..color.MsgBox.."to save all the custom placed objects in a cell.\n"..
		color.MsgBox.."("..color.Red.."Warning:"..color.MsgBox.." this will literally save every 0-XXXXXXXX object in the cell!!)\n"
		
	tes3mp.CustomMessageBox(pid, config.ObjectSpawnOptionsMenu, msg, "Enter Unique Index;Save Entire Cell;Exit")
	
end


objectSpawnSystem.SaveAllConfirmation = function(pid)
	
	local thisCell = tes3mp.GetCell(pid)
	local objectCount = getPlacedObjectCountForCell(pid)
	
	local msg = color.Orange.."Object Spawn System:\n\n"..color.MsgBox..
		color.Red.."WARNING!\n\n"..color.MsgBox.."You are about to save every custom placed object in this cell:\n"..color.Yellow..thisCell..color.MsgBox..
		"\n\nThere are "..color.White..objectCount..color.MsgBox.." placed objects in this cell to save.\n\nAre you sure you want to save?\n"
		
	tes3mp.CustomMessageBox(pid, config.ObjectSpawnSaveAllConfirm, msg, "Yes, Save;No, Don't Save;Exit")

end



customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	
	if idGui == config.InputUniqueIndexOfObject then
		if data == nil or data == " " then
            objectSpawnSelected[pid] = nil
			return tes3mp.SendMessage(pid, color.Yellow.."[Object Spawn System]: "..color.Error.."No unique index entered.\n", false)
        else
			objectSpawnSelected[pid] = tostring(data)
			return objectSpawnSystem.UniqueIndexConfirmation(pid)
        end
	
	elseif idGui == config.UniqueIndexConfirmation then
		if tonumber(data) == 1 then -- Save
			return objectSpawnSystem.AddUniqueIndexToDatabase(pid)
		elseif tonumber(data) == 2 then -- Set scale
			return objectSpawnSystem.InputScaleForUniqueIndexOfObject(pid)
        else
			objectSpawnSelected[pid] = nil
			objectSpawnSelectedScale[pid] = nil
			return tes3mp.SendMessage(pid, color.Yellow.."[Object Spawn System]: "..color.MsgBox.."unique index "..color.Yellow.."not"..color.MsgBox.." added.\n", false)
        end
		
	elseif idGui == config.InputScaleForUniqueIndexOfObject then
		if data == nil or data == " " then
            objectSpawnSelected[pid] = nil
			return tes3mp.SendMessage(pid, color.Yellow.."[Object Spawn System]: "..color.Error.."No scale entered.\n", false)
        else
			objectSpawnSelectedScale[pid] = tonumber(data)
			return objectSpawnSystem.UniqueIndexConfirmation(pid)
        end
		
	
	elseif idGui == config.ObjectSpawnOptionsMenu then
		if tonumber(data) == 0 then -- Enter Unique Index
			return objectSpawnSystem.InputUniqueIndexOfObject(pid)
		elseif tonumber(data) == 1 then -- Save Entire Cell
			return objectSpawnSystem.SaveAllConfirmation(pid)
        else -- Do nothing/Exit/Cancel
			return
        end
	
	
	elseif idGui == config.ObjectSpawnSaveAllConfirm then
		if tonumber(data) == 0 then -- Save
			return savePlacedObjectsForCell(pid)
		elseif tonumber(data) == 1 then --Don't Save
			return objectSpawnSystem.ObjectSpawnOptionsMenu(pid)
        else -- Do nothing/Exit/Cancel
			return
        end
	
	
	
	end
	
end)

-- Commands
customCommandHooks.registerCommand("sobj", function(pid, cmd)
	if Players[pid].data.settings.staffRank >= config.staffRankToSaveObjectSpawns then
		objectSpawnSystem.ObjectSpawnOptionsMenu(pid)
	end
end)



return objectSpawnSystem