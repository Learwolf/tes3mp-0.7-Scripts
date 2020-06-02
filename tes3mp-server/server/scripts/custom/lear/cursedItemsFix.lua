--[[

Cursed Items Only Trigger Once
cursedItemsFix.lua
	version 1.02



----------------------------------------------------------------------
INSTALLATION:

To install, simply drag this file into your 
	tes3mp-server/server/scripts/custom
folder, then open your 'customScripts.lua' found in your
	tes3mp-server/server/scripts/
folder. Add the following line to your 'customScripts.lua' file:
	require("custom.cursedItemsFix")
save, close the file and restart your server.

----------------------------------------------------------------------
INFORMATION:

When picking up a cursed item, the curse is triggered but the item is converted 
into its normal non-cursed version to prevent constant summoning of cursed item creatures.

Since 'silver dagger_hanin cursed' does not have a non-cursed version, this script will create one.

Also, 'chargen dagger' will be replaced with an iron dagger after looting it.

]]

-- List of items -> what they are turned into:
local itemReplacementTable = {

-- cursed items
	["ingred_cursed_daedras_heart_01"] = "ingred_daedras_heart_01",
	["ingred_dae_cursed_diamond_01"] = "ingred_diamond_01",
	["ebony broadsword_dae_cursed"] = "ebony broadsword",
	["ingred_dae_cursed_emerald_01"] = "ingred_emerald_01",
	["fiend spear_dae_cursed"] = "fiend spear",
	["glass dagger_dae_cursed"] = "glass dagger",
	["imperial helmet armor_dae_curse"] = "imperial helmet armor",
	["ingred_dae_cursed_pearl_01"] = "ingred_pearl_01",
	["ingred_dae_cursed_raw_ebony_01"] = "ingred_raw_ebony_01",
	["ingred_dae_cursed_ruby_01"] = "ingred_ruby_01",
	["light_com_dae_cursed_candle_10"] = "light_com_candle_16",
	["misc_dwrv_cursed_coin00"] = "misc_dwrv_coin00",
	["silver dagger_hanin cursed"] = "ancient silver dagger noncursed",
-- floating items
	["misc_com_bottle_14_float"] = "misc_com_bottle_14",
	["misc_com_bottle_07_float"] = "misc_com_bottle_07",
-- Scripted Items	
	["chargen dagger"] = "iron dagger"
	
}



local function updateCursedSilverDagger()

	local recordStore = RecordStores["weapon"]
	recordStore.data.permanentRecords["ancient silver dagger noncursed"] = {
		baseId = "silver dagger_hanin cursed",
		script = ""
	}
	recordStore:Save()

end

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
	updateCursedSilverDagger()
end)


local triggerLogMessage = function(whatDo, refId, count, charge, enchantmentCharge, soul)
	tes3mp.LogAppend(enumerations.log.INFO, " [Cursed Items Only Trigger Once] "..whatDo..": " .. refId .. ", count: " .. count ..
	", charge: " .. charge .. ", enchantmentCharge: " .. enchantmentCharge ..
	", soul: " .. soul)
end

local getGoldRefId = function(refId)
	if refId == "gold_005" or refId == "gold_010" or refId == "gold_025" or refId == "gold_100" then
		return "gold_001"
	end
	return refId
end

local function addInventoryItem(pid, refId, count, soul, charge, enchantmentCharge)
	if refId == nil then return end
	if count == nil then count = 1 end
	if soul == nil then soul = "" end
	if charge == nil then charge = -1 end
	if enchantmentCharge == nil then enchantmentCharge = -1 end
	
	refId = getGoldRefId(refId)
	
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
	
	triggerLogMessage("ADD", refId, count, charge, enchantmentCharge, soul)
	
end

local function removeInventoryItem(pid, refId, count, soul, charge, enchantmentCharge)
	if refId == nil then return end
	if count == nil then count = 1 end
	if soul == nil then soul = "" end
	if charge == nil then charge = -1 end
	if enchantmentCharge == nil then enchantmentCharge = -1 end
	
	refId = getGoldRefId(refId)
	
	tes3mp.ClearInventoryChanges(pid)
	tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.REMOVE)
	tes3mp.AddItemChange(pid, refId, count, charge, enchantmentCharge, soul)
	tes3mp.SendInventoryChanges(pid)
	Players[pid]:SaveInventory()
	
	if logicHandler.IsGeneratedRecord(refId) then
		local cellDescription = tes3mp.GetCell(pid)
        local cell = LoadedCells[cellDescription]
		local recordType = logicHandler.GetRecordTypeByRecordId(refId)
		if RecordStores[recordType] ~= nil then
			local recordStore = RecordStores[recordType]
			local player = logicHandler.GetPlayerByName(accountName)
			player:RemoveLinkToRecord(recordStore.recordType, refId)
			player:Save()
		end
	end
	
	triggerLogMessage("REMOVE", refId, count, charge, enchantmentCharge, soul)
	
end

customEventHooks.registerHandler("OnPlayerInventory", function(eventStatus, pid)

	local action = tes3mp.GetInventoryChangesAction(pid)
	local itemChangesCount = tes3mp.GetInventoryChangesSize(pid)

	for index = 0, itemChangesCount - 1 do
		local itemRefId = tes3mp.GetInventoryItemRefId(pid, index)

		if itemRefId ~= "" then
			
			local iCount = tes3mp.GetInventoryItemCount(pid, index)
			local iCharge = tes3mp.GetInventoryItemCharge(pid, index)
			local iEnchantmentCharge = tes3mp.GetInventoryItemEnchantmentCharge(pid, index),
			local iSoul = tes3mp.GetInventoryItemSoul(pid, index)

			if action == enumerations.inventory.SET or action == enumerations.inventory.ADD then
				
				local originalRefId = itemRefId
				local replacementRefId = itemReplacementTable[originalRefId]
				
				if replacementRefId ~= nil then
					removeInventoryItem(pid, originalRefId, iCount, iSoul, iCharge, iEnchantmentCharge)
					addInventoryItem(pid, replacementRefId, iCount, iSoul, iCharge, iEnchantmentCharge)
				end

			end
		end
	end

end)
