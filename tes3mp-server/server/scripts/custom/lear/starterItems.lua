-- This script allows new characters to start with specified items added below.

-- 1) Save this to your 'tes3mp-server\server\scripts\custom' folder as starterItems.lua
-- 2) Open 'customScripts.lua' in a text editor such as notepad+. It can be found in your 'tes3mp-server\server\scripts` folder.
-- 3) On a new line, add the following:		require("custom.starterItems")
-- 4) Make sure there are no dashes infront of it. (Dashes infront will disable/comment it out.)
-- 5) Save 'customScripts.lua', restart your server, and enjoy.


-- To add more items just add another bracket set with the info, IE: {"common_shirt_01", 1, ""} separated by commas.
-- data inside being organized by {"Item Ref ID", amount, soul} (soul should be "" if the item is not a filled soul gem.)
-- example: local items = { {"gold_001", 100, ""}, {"pick_apprentice_01", 1, ""}, {"misc_soulgem_grand", 1, "golden saint"} }

local items = { {"gold_001", 100, ""} }

local addStarterItem = function(pid, refId, count, soul)
	
	if refId == nil then return end
	if count == nil then count = 1 end
	if soul == nil then soul = "" end
	
	local charge = -1
	local enchantmentCharge = -1
	
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


customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventStatus, pid)
    for i,item in pairs(items) do
        addStarterItem(pid, item[1], item[2], item[3])
    end
end)

