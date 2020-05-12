--[[
SCRIPT:
	Creature Merchants Restock Gold

VERSION:
	- 1.01
	
REQUIREMENTS:
	TES3MP 0.7 Alpha build that supports customEventHooks.

INSTALLATION:
	1) Create a new folder (if you don't have it already) in your tes3mp servers "server/scripts/custom/" folder called:
		lear
		
	2) Drop this .lua file into your newly created "lear" folder.
	
	3) Open up "customScripts.lua" that can be found in your tes3mp servers "server/scripts/" 
		folder with a text editor such a notepad.
		
	4) At the bottom of your "customScripts.lua" you just opened, add the following line of code:
		require("custom.lear.creatureMerchantRestockGold")
		
	5) Save, exit and launch your server.

DESCRIPTION:	
	This script will allow the creeper and mudcrab merchant to restock 
	their gold simply by exiting their dialogue menu and speaking to 
	them again.
]]

local configCM = {}

configCM.merchantCell = "mark's vampire test cell" -- This should be a cell that's inaccessible to players.
configCM.merchantLocation = {posX = 0, posY = 0, posZ = 0, rotX = 0, rotY = 0, rotZ = 0} -- Recommended not to touch this.

--==----==----==----==----==--
--  Don't Touch:
--==----==----==----==----==--
local split = function(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

--==----==----==----==----==--
--  Activate Merchants:
--==----==----==----==----==--
customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)

	local isValid = eventStatus.validDefaultHandler

    for n,object in pairs(objects) do
		
		local index = n-1
        local temp = split(object["uniqueIndex"], "-")
        local RefNum = temp[1]
        local MpNum = temp[2]
		
		local objectUniqueIndex = object.uniqueIndex
		local objectRefId = object.refId

-- Mudcrab Merchant - Talk to again for respawning gold.
		if objectRefId == "mudcrab_unique" then
			LoadedCells[cellDescription]:SaveActorStatsDynamic()
			if cellDescription == nil or objectUniqueIndex == nil then isValid = false return end
			
			local npcStats = LoadedCells[cellDescription].data.objectData[objectUniqueIndex].stats

			if npcStats == nil or npcStats.healthCurrent > 0 then
			
				local merchantCell = configCM.merchantCell
				
				if LoadedCells[merchantCell] == nil then
					logicHandler.LoadCell(merchantCell)
				end
				
				
				local merchantPid = pid
	
				local merchantRefId = "mudcrab_unique"
				local merchantMpNum = "999999971" .. string.byte(logicHandler.GetChatName(merchantPid)) 
				local merchantUniqueIndex = 0 .. "-" .. merchantMpNum
				
				LoadedCells[merchantCell]:DeleteObjectData(merchantUniqueIndex)
				logicHandler.DeleteObjectForEveryone(merchantCell, merchantUniqueIndex)
				logicHandler.DeleteObject(pid, merchantCell, merchantUniqueIndex, forEveryone)
				
				LoadedCells[merchantCell]:InitializeObjectData(merchantUniqueIndex, merchantRefId)
				
				local merchantLocation = configCM.merchantLocation
				LoadedCells[merchantCell].data.objectData[merchantUniqueIndex].location = merchantLocation
				
				table.insert(LoadedCells[merchantCell].data.packets.actorList, merchantUniqueIndex)
				
				local objectData = {}
				objectData.refId = merchantRefId
				objectData.goldValue = -1
				objectData.location = merchantLocation
				packetBuilder.AddObjectPlace(merchantUniqueIndex, objectData)
				tes3mp.SendObjectPlace(false, false)

				logicHandler.ActivateObjectForPlayer(pid, merchantCell, merchantUniqueIndex)
			
				isValid = false
			else
				isValid = false
			end

		
-- Creeper Merchant - Talk to again for respawning gold.
		elseif objectRefId == "scamp_creeper" then
			LoadedCells[cellDescription]:SaveActorStatsDynamic()
			
			if cellDescription == nil or objectUniqueIndex == nil then isValid = false return end
			local npcStats = LoadedCells[cellDescription].data.objectData[objectUniqueIndex].stats

			if npcStats == nil or npcStats.healthCurrent > 0 then
			
				local merchantCell = configCM.merchantCell
				
				if LoadedCells[merchantCell] == nil then
					logicHandler.LoadCell(merchantCell)
				end
				
				
				local merchantPid = pid
	
				local merchantRefId = "scamp_creeper"
				local merchantMpNum = "999999972" .. string.byte(logicHandler.GetChatName(merchantPid)) 
				local merchantUniqueIndex = 0 .. "-" .. merchantMpNum
				
				LoadedCells[merchantCell]:DeleteObjectData(merchantUniqueIndex)
				logicHandler.DeleteObjectForEveryone(merchantCell, merchantUniqueIndex)
				logicHandler.DeleteObject(pid, merchantCell, merchantUniqueIndex, forEveryone)
				
				LoadedCells[merchantCell]:InitializeObjectData(merchantUniqueIndex, merchantRefId)
				
				local merchantLocation = configCM.merchantLocation
				LoadedCells[merchantCell].data.objectData[merchantUniqueIndex].location = merchantLocation
				
				table.insert(LoadedCells[merchantCell].data.packets.actorList, merchantUniqueIndex)
				
				local objectData = {}
				objectData.refId = merchantRefId
				objectData.goldValue = -1
				objectData.location = merchantLocation
				packetBuilder.AddObjectPlace(merchantUniqueIndex, objectData)
				tes3mp.SendObjectPlace(false, false)

				logicHandler.ActivateObjectForPlayer(pid, merchantCell, merchantUniqueIndex)
			
				isValid = false
			else
				isValid = false
			end		
		end

	-- End New Additions
	eventStatus.validDefaultHandler = isValid
    return eventStatus

	end
end)
