--[[
	Quick Key Pages
		version 1.01
			by Learwolf
	
	Description:
		- This script allows server owners to implement additional quick key pages by pressing the first quick key slot.
		- This works by adding an item to the player, that is bound to quick key slot 1. When pressed, it changes the quick key page.
		- The amount of pages players can have is customizable by the server owner.
		
		- With this script, you can also prevent specific items from being setup as quick keys, as well as have specific cells 
		  hide the players quick keys so they cannot be used again until they leave the cell (in which case, the quick keys will
		  reappear in their setup prior to entering the cell.)
		
		- The quick key page turner utilizes the skirt slot, so players who use skirts may notice their skirt being requipped after using it.
		
	
	Notes:
		- Players are unable to drop their quick key pager, nor are they able to place them in any container.
		- If a player somehow manages to lose their quick key pager, relogging will add it back to their inventory.
	
	
	Install Instructions:
		- Save this script inside your 'server/scripts/custom' folder as 'quickKeyPages.lua'.
		- Open the 'customScripts.lua' found inside your 'server/scripts' folder.
		- Add the following text on a new line:
				require("custom.quickKeyPages")
		- Make sure there are no '--' characters infront of it (as that disables scripts).
		- Save 'customScripts.lua' and relaunch your server.
	
	
	Version History:
		1.01 (1/1/2021)
			- Players can no longer put the quick key pager into containers.
			- Fixed a crash related to adding the quick key pager back to the players inventory.
		
		1.00 (12/30/2021)
			- Initial public release.
		
--]]


-- SERVER ADMIN CONFIGURATIONS:

local quickKeyPagesMax = 4 -- The number of quick key pages you want players to have access to.

local cellsWithNoQuickKeys = { "Seyda Neen, Census and Excise Office" } -- This below table lets you insert cells that should temporarily remove quick keys for players.
																		-- (Such as, having a cell where you don't want a player to cast something via quick keys.)

local nonQuickKeyableItemRefIds = {"artifact_bittercup_01", "misc_6th_ash_statue_01"} -- These examples can be removed if desired.
	-- Insert all the refIds of items you don't want the player to ever set a quick key into the `nonQuickKeyableItemRefIds` table above.
	-- Note, this function utilizes the string.match function, so you can insert "$custom_potion" to prevent ALL potions from being set as quick keys.
		-- The down side to this, is you need to be cautious as to not accidentally include something you didnt mean to due to a matching string.



-- NO NEED TO TOUCH ANYTHING ELSE BELOW UNLESS YOU KNOW WHAT YOU'RE DOING.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- The below are two refIds used on your server for the items in this script. Avoid changing them after using this script on your server, as to not cause duplicates.
local qkcEmpty = "qkp_empty" -- The refId used for clearing quick keys. (This is needed, due to an oversight in tes3mp 0.7).
local qkcNextPage = "qkc_next_page" -- The refId used for players to go to the next quickkey page.

local function createRecord()
	
	local recordStore = RecordStores["miscellaneous"]
	recordStore.data.permanentRecords[qkcEmpty] = {
		name = "Empty Quick Key",
		icon = "m\\misc_dwrv_Ark_cube00.tga"
	}
	recordStore:Save()
	
	recordStore = RecordStores["clothing"]
	recordStore.data.permanentRecords[qkcNextPage] = {
		name = "Quick Keys Page +",
		icon = "menu_number_inc.dds",
		subtype = 7,
		 parts = {
			{
				partType = 5,
				malePart = ""
			}
		 },
		script = ""
	}
	recordStore:Save()
end

local function OnServerPostInit(eventStatus)
	createRecord()
end
customEventHooks.registerHandler("OnServerPostInit", OnServerPostInit)


-- YOU SHOULD TECHNICALLY ADD THE BELOW FUNCTION TO YOUR tableHelper.lua SCRIPT, BUT I'LL ADD IT HERE ANYWAY.
-- Copy the value of a variable in a deep way, useful for copying a table's top level values
-- and direct children to another table safely, also handling metatables
--
-- Based on http://lua-users.org/wiki/CopyTable
function tableHelper.deepCopy(inputValue)

    local inputType = type(inputValue)

    local newValue

    if inputType == "table" then
        newValue = {}
        for innerKey, innerValue in next, inputValue, nil do
            newValue[tableHelper.deepCopy(innerKey)] = tableHelper.deepCopy(innerValue)
        end
        setmetatable(newValue, tableHelper.deepCopy(getmetatable(inputValue)))
    else -- number, string, boolean, etc
        newValue = inputValue
    end

    return newValue
end
--

local quickKeysPageMessage = function(pid)
	local page = Players[pid].quickKeysPage
	if page then
		tes3mp.MessageBox(pid, -1, "Quick Key Page: "..color.White..page)
	end
end

local givePlayerItem = function(pid, refId, count, soul, charge, enchantmentCharge)
	
	Players[pid].data.customVariables.allowAddItem = true -- This allows the player to bypass the block enforced within morePlayerFuncs.lua's Player:SaveInventory()
	
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
		if RecordStores[recordType] ~= nil and cell ~= nil then
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

local takePlayerItem = function(pid, refId, count, soul, charge, enchantmentCharge)
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


-- Load a specified quick key page:
local loadQuickKeyPage = function(pid, page)
	if Players[pid].data.customVariables.quickKeyPaging and page ~= nil and Players[pid].data.customVariables.quickKeyPaging[page] ~= nil then
		
		Players[pid].data.quickKeys = tableHelper.deepCopy(Players[pid].data.customVariables.quickKeyPaging[page])
		Players[pid]:LoadQuickKeys()
		
		Players[pid].data.quickKeys[1] = { keyType = 0, itemId = qkcNextPage }
		Players[pid]:LoadQuickKeys()
	end
end

local saveBackupQuickKeys = function(pid)
	if Players[pid].data.customVariables.quickKeysBackup == nil then
		Players[pid].data.customVariables.quickKeysBackup = tableHelper.deepCopy(Players[pid].data.quickKeys)
	end
end

local loadBackupQuickKeys = function(pid)
	if Players[pid].data.customVariables.quickKeysBackup ~= nil then
		Players[pid].data.quickKeys = tableHelper.deepCopy(Players[pid].data.customVariables.quickKeysBackup)
		Players[pid].data.customVariables.quickKeysBackup = nil
		Players[pid]:LoadQuickKeys()
	end
end

function blockSpecificQuickKeyItem(pid)

    local shouldReloadQuickKeys = false

    for index = 0, tes3mp.GetQuickKeyChangesSize(pid) - 1 do

        local slot = tes3mp.GetQuickKeySlot(pid, index)
        local itemRefId = tes3mp.GetQuickKeyItemId(pid, index)
        	
		if not tableHelper.isEmpty(nonQuickKeyableItemRefIds) then
			for _,refId in pairs(nonQuickKeyableItemRefIds) do
			
				local blockedRefId = string.lower(refId)
				 if string.match(itemRefId, blockedRefId) then
					tes3mp.SendMessage(pid, color.Red .. "This item cannot be set as a Quick Key.\n", false)
						Players[pid].data.quickKeys[slot] = { keyType = 0, itemId = qkcEmpty }
					shouldReloadQuickKeys = true
				end
				
			end
		end
		
    end

    if shouldReloadQuickKeys then
        -- add dummy item:
		givePlayerItem(pid, qkcEmpty, 1)
    
        Players[pid]:LoadQuickKeys() 
        -- remove dummy item:
		takePlayerItem(pid, qkcEmpty, 1)
    end
end

function clearQuickKeys(pid)
    
    for keyIndex = 1, 9 do
        Players[pid].data.quickKeys[keyIndex] = { keyType = 3, itemId = "" }
    end
	
    Players[pid]:LoadQuickKeys()
	
    Players[pid].data.quickKeys[1] = { keyType = 0, itemId = qkcNextPage }
    Players[pid]:LoadQuickKeys()

    tes3mp.LogMessage(enumerations.log.INFO, "[QuickKeys] Cleared quick keys for " .. logicHandler.GetChatName(pid))
end

local checkForQuickKeyClearing = function(pid)
	-- Always clear this player's quick keys if they're in a cell where no quick keys are allowed
	local currentCell = tes3mp.GetCell(pid)
	if tableHelper.containsValue(cellsWithNoQuickKeys, currentCell) then
		
		-- If a backup is not already made, lets make one.
		if Players[pid].data.customVariables.quickKeysBackup == nil then
			saveBackupQuickKeys(pid)
		end
		
        clearQuickKeys(pid)
		tes3mp.LogAppend(enumerations.log.INFO, "[QuickKeys] Cleared quickkeys for player ["..logicHandler.GetChatName(pid).."] inside cell ["..currentCell.."].")
	else
		loadBackupQuickKeys(pid)
    end
end



-- Change Quick Key Pages:
local changeQuickKeysPage = function(pid, direction)
	
	if Players[pid].data.customVariables.quickKeyPaging then
		local totalPageCount = quickKeyPagesMax
		local currentPage = Players[pid].quickKeysPage or 1
		
		if direction == "left" then
			if currentPage == 1 then
				currentPage = totalPageCount
			else
				currentPage = currentPage - 1
			end
		elseif direction == "right" then
			if currentPage == totalPageCount then
				currentPage = 1
			else
				currentPage = currentPage + 1
			end
		end
		
		Players[pid].quickKeysPage = currentPage
		
		quickKeysPageMessage(pid)
		
		clearQuickKeys(pid)
		
		loadQuickKeyPage(pid, currentPage)
	end
end


local loadSkirtSlot = function(pid)
	if Players[pid].data.equipment then
		
		local reloadEquipment = false
		
		local lastItem = Players[pid].lastEquippedSkirt
		
		for index = 0, tes3mp.GetEquipmentSize() - 1 do
			local currentItem = Players[pid].data.equipment[index]
			if currentItem ~= nil then
				
				if currentItem.refId == qkcNextPage then
					tes3mp.UnequipItem(pid, index)
					
					if lastItem then
						if lastItem.enchantmentCharge == nil then
							lastItem.enchantmentCharge = -1
						end
						
						tes3mp.EquipItem(pid, index, lastItem.refId, lastItem.count, lastItem.charge, lastItem.enchantmentCharge)
					end
					
					tes3mp.SendEquipment(pid)
					Players[pid]:SaveEquipment()
				end
				
			end
		end
		
	end
end


local quickKeyPageItemUsed = function(pid, refId)	
	local currentCell = tes3mp.GetCell(pid)
	if tableHelper.containsValue(cellsWithNoQuickKeys, currentCell) then
		tes3mp.MessageBox(pid, -1, color.Error.."You cannot change Quick Key Pages here.")
	else
		if refId == qkcNextPage then
			loadSkirtSlot(pid)
			changeQuickKeysPage(pid, "right")
		end
	end
end


local saveSkirtSlot = function(pid)
	if Players[pid].data.equipment then
		
		local slot = Players[pid].data.equipment[10] --10 is the skirt slot.
		
		if slot then
			if slot.refId ~= nil and slot.refId ~= qkcNextPage then
				Players[pid].lastEquippedSkirt = tableHelper.deepCopy(slot)
			end
			quickKeyPageItemUsed(pid, slot.refId)
		else
			Players[pid].lastEquippedSkirt = nil
		end
	end
end

customEventHooks.registerHandler("OnPlayerEquipment", function(eventStatus, pid) 
	saveSkirtSlot(pid)
end)

local preventPagingOverwrite = function(pid)
	if Players[pid].data.quickKeys[1].itemId ~= qkcNextPage then
		Players[pid].data.quickKeys[1] = { keyType = 0, itemId = qkcNextPage }
		Players[pid]:LoadQuickKeys()
		
		tes3mp.MessageBox(pid, -1, color.Error.."You cannot change that Quick Key.")
	end
end

local saveQuickKeyPage = function(pid)
	if Players[pid].data.customVariables.quickKeyPaging then
		local currentCell = tes3mp.GetCell(pid)
		if not tableHelper.containsValue(cellsWithNoQuickKeys, currentCell) then
			local page = Players[pid].quickKeysPage or 1
			Players[pid].data.customVariables.quickKeyPaging[page] = tableHelper.deepCopy(Players[pid].data.quickKeys)
		end
	end
end


customEventHooks.registerValidator("OnPlayerQuickKeys", function(eventStatus, pid)
	Players[pid]:SaveQuickKeys()
	blockSpecificQuickKeyItem(pid)
    checkForQuickKeyClearing(pid)
	
	preventPagingOverwrite(pid)
	saveQuickKeyPage(pid)
end)

customEventHooks.registerValidator("OnPlayerCellChange", function(eventStatus, pid)
	checkForQuickKeyClearing(pid)
end)

-- Prevent the player from trying to place the custom quick key related items:
customEventHooks.registerValidator("OnObjectPlace", function(eventStatus, pid, cellDescription, objects)
	
	local isValid = eventStatus.validDefaultHandler
	
	if isValid ~= false then
		local cell = cellDescription
		
		tes3mp.ReadReceivedObjectList()
		
		for n,object in pairs(objects) do
			
			local uniqueIndex = object.uniqueIndex
			local refId = object.refId
			local count = tes3mp.GetObjectCount(n-1) 
			
			if refId == qkcEmpty or refId == qkcNextPage then
				tes3mp.MessageBox(pid, -1, "You cannot drop this item.")
				givePlayerItem(pid, refId, count)
				return customEventHooks.makeEventStatus(false, false)
			end
			
		end
	end
	
	eventStatus.validDefaultHandler = isValid
	return eventStatus
end)

local playerActivateTracking = {}
local resolveContainerPlacement = function(pid)

	if playerActivateTracking[pid] ~= nil then
		
		local cellDescription = playerActivateTracking[pid].cellDescription
		local uniqueIndex = playerActivateTracking[pid].uniqueIndex
		
		if LoadedCells[cellDescription] ~= nil and LoadedCells[cellDescription].data.objectData ~= nil then
			local objData = LoadedCells[cellDescription].data.objectData[uniqueIndex]
			if objData ~= nil and objData.inventory ~= nil then
				local reloadForPlayers = false
				local objectsToSearch = {qkcEmpty,qkcNextPage}
				
				for _,itemRefId in pairs(objectsToSearch) do
					
					if inventoryHelper.containsItem(objData.inventory, itemRefId) then
						inventoryHelper.removeItem(objData.inventory,itemRefId,100) -- Could probably just be 1, but lets do 100 incase something weird happens.
						reloadForPlayers = true
					end
				end
				
				if not inventoryHelper.containsItem(Players[pid].data.inventory, qkcNextPage) then
					givePlayerItem(pid, qkcNextPage, 1) -- Lets assume, if the player doesnt have their page turn item, that its because of the above and we need to add it back.
				end
				
				if reloadForPlayers then
					local obj = LoadedCells[cellDescription].data.objectData
					if obj[uniqueIndex] ~= nil and obj[uniqueIndex].inventory ~= nil then
						for pid, player in pairs(Players) do
							if Players[pid] ~= nil and player:IsLoggedIn() and LoadedCells[cellDescription] ~= nil then
								LoadedCells[cellDescription]:LoadContainers(pid,obj,{uniqueIndex})
							end
						end
					end
				end
			end
		end
	
	end
end

customEventHooks.registerHandler("OnPlayerInventory", function(eventStatus, pid)
	if not eventStatus.validCustomHandlers then return end
	
	local action = tes3mp.GetInventoryChangesAction(pid)
	local itemChangesCount = tes3mp.GetInventoryChangesSize(pid)
	
	local logToServer = false

	for index = 0, itemChangesCount - 1 do
		local itemRefId = tes3mp.GetInventoryItemRefId(pid, index)

		if itemRefId ~= "" then
		
			local item = {
				refId = itemRefId,
				count = tes3mp.GetInventoryItemCount(pid, index),
				charge = tes3mp.GetInventoryItemCharge(pid, index),
				enchantmentCharge = tes3mp.GetInventoryItemEnchantmentCharge(pid, index),
				soul = tes3mp.GetInventoryItemSoul(pid, index)
			}
			
			if item.refId == qkcNextPage then
				
				if action == enumerations.inventory.REMOVE then
					
					resolveContainerPlacement(pid)
					
					return customEventHooks.makeEventStatus(false, false)
				end
				
			end
		end
	end
	
end)

-- Since there is no way to edit the prevention of placing items in containers with editing core scripts, here is a work around:
customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
	
	local isValid = eventStatus.validDefaultHandler
	
	if isValid ~= false then
		for n,object in pairs(objects) do
			
			local uniqueIndex = object.uniqueIndex
			local refId = object.refId
			
			if LoadedCells[cellDescription] ~= nil and LoadedCells[cellDescription].data.objectData ~= nil then
				local objData = LoadedCells[cellDescription].data.objectData[uniqueIndex]
				if objData ~= nil and objData.inventory ~= nil then
					
					playerActivateTracking[pid] = { cellDescription = cellDescription, uniqueIndex = uniqueIndex }
					resolveContainerPlacement(pid)
					
				end
			end
			
		end

	end

	eventStatus.validDefaultHandler = isValid
    return eventStatus
end)


-- Setup quickkey paging on login.
customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		
		if not inventoryHelper.containsItem(Players[pid].data.inventory, qkcNextPage) then
			givePlayerItem(pid, qkcNextPage, 1)
		else
			local iLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, qkcNextPage)
			if iLoc and Players[pid].data.inventory[iLoc].count > 1 then
				local amountToRemove = Players[pid].data.inventory[iLoc].count - 1
				takePlayerItem(pid, qkcNextPage, amountToRemove)
			end
		end
		
		local player = Players[pid].data.customVariables.quickKeyPaging
		if player == nil or #player ~= quickKeyPagesMax then
			
			local page = {{keyType = 3,itemId = ""},{keyType = 3,itemId = ""},{keyType = 3,itemId = ""},{keyType = 3,itemId = ""},{keyType = 3,itemId = ""},{keyType = 3,itemId = ""},{keyType = 3,itemId = ""},{keyType = 3,itemId = ""},{keyType = 3,itemId = ""}}
			
			Players[pid].data.customVariables.quickKeyPaging = {}
			
			Players[pid].data.quickKeys[1] = { keyType = 0, itemId = qkcNextPage }
			Players[pid]:LoadQuickKeys()
			
			for i=1,quickKeyPagesMax do
				table.insert(Players[pid].data.customVariables.quickKeyPaging, page)
			end
			Players[pid].data.customVariables.quickKeyPaging[1] = tableHelper.deepCopy(Players[pid].data.quickKeys)
			player = Players[pid].data.customVariables.quickKeyPaging
		else
			Players[pid].data.quickKeys = tableHelper.deepCopy(Players[pid].data.customVariables.quickKeyPaging[1])
			Players[pid]:LoadQuickKeys()
		end
		
		
		Players[pid].quickKeysPage = 1
		
		saveSkirtSlot(pid)
	end
end)

