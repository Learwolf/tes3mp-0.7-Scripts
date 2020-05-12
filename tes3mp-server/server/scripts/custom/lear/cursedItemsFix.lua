--[[

Cursed Items Only Trigger Once
cursedItemsFix.lua
	version 1.01



----------------------------------------------------------------------
INSTALLATION:

To instal, simply drag this file into your 
	tes3mp-server/server/scripts/custom 
folder, then open your customScripts.lua found in your
	tes3mp-server/server/scripts/
folder. Add the following line to your customScripts.lua file:close
	require("custom.cursedItemsFix")
save, close the file and you're done.

----------------------------------------------------------------------
INFORMATION:

When picking up a cursed item, the curse is triggered but the item is converted 
into its normal non-cursed version to prevent constant summoning of cursed item creatures.

]]

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


local function addInventoryItem(pid, refId, count, soul, charge, enchantmentCharge)
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
	
	tes3mp.LogAppend(enumerations.log.INFO, " [Cursed Items Only Trigger Once] ADD: " .. refId .. ", count: " .. count ..
		", charge: " .. charge .. ", enchantmentCharge: " .. enchantmentCharge ..
		", soul: " .. soul)
	
end

local function removeInventoryItem(pid, refId, count, soul, charge, enchantmentCharge)
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
	
	tes3mp.LogAppend(enumerations.log.INFO, " [Cursed Items Only Trigger Once] REMOVE: " .. refId .. ", count: " .. count ..
		", charge: " .. charge .. ", enchantmentCharge: " .. enchantmentCharge ..
		", soul: " .. soul)
	
end

customEventHooks.registerHandler("OnPlayerInventory", function(eventStatus, pid)

   -- tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerInventory\" for " .. logicHandler.GetChatName(pid))
	local action = tes3mp.GetInventoryChangesAction(pid)
	local itemChangesCount = tes3mp.GetInventoryChangesSize(pid)

	tes3mp.LogMessage(enumerations.log.INFO, "Saving " .. itemChangesCount .. " item(s) to inventory with action " ..
		tableHelper.getIndexByValue(enumerations.inventory, action))

	--if action == enumerations.inventory.SET then Players[pid].data.inventory = {} end

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

				tes3mp.LogAppend(enumerations.log.INFO, "- id: " .. item.refId .. ", count: " .. item.count ..
					", charge: " .. item.charge .. ", enchantmentCharge: " .. item.enchantmentCharge ..
					", soul: " .. item.soul)

				if action == enumerations.inventory.SET or action == enumerations.inventory.ADD then

					if itemRefId == "ingred_cursed_daedras_heart_01" then
						removeInventoryItem(pid, "ingred_cursed_daedras_heart_01", 1)
						addInventoryItem(pid, "ingred_daedras_heart_01", 1)
					end
					
					if itemRefId == "ingred_dae_cursed_diamond_01" then
						removeInventoryItem(pid, "ingred_dae_cursed_diamond_01", 1)
						addInventoryItem(pid, "ingred_diamond_01", 1)
					end
					
					if itemRefId == "ebony broadsword_dae_cursed" then
						removeInventoryItem(pid, "ebony broadsword_Dae_cursed", 1)
						addInventoryItem(pid, "ebony broadsword", 1)
					end
					
					if itemRefId == "ingred_dae_cursed_emerald_01" then
						removeInventoryItem(pid, "ingred_dae_cursed_emerald_01", 1)
						addInventoryItem(pid, "ingred_emerald_01", 1)
					end
					
					if itemRefId == "fiend spear_dae_cursed" then
						removeInventoryItem(pid, "fiend spear_Dae_cursed", 1)
						addInventoryItem(pid, "fiend spear", 1)
					end
					
					if itemRefId == "glass dagger_dae_cursed" then
						removeInventoryItem(pid, "glass dagger_Dae_cursed", 1)
						addInventoryItem(pid, "glass dagger", 1)
					end
					
					if itemRefId == "imperial helmet armor_dae_curse" then
						removeInventoryItem(pid, "imperial helmet armor_dae_curse", 1)
						addInventoryItem(pid, "imperial helmet armor", 1)
					end
					
					if itemRefId == "ingred_dae_cursed_pearl_01" then
						removeInventoryItem(pid, "ingred_dae_cursed_pearl_01", 1)
						addInventoryItem(pid, "ingred_pearl_01", 1)
					end
					
					if itemRefId == "ingred_dae_cursed_raw_ebony_01" then
						removeInventoryItem(pid, "ingred_dae_cursed_raw_ebony_01", 1)
						addInventoryItem(pid, "ingred_raw_ebony_01", 1)
					end
					
					if itemRefId == "ingred_dae_cursed_ruby_01" then
						removeInventoryItem(pid, "ingred_dae_cursed_ruby_01", 1)
						addInventoryItem(pid, "ingred_ruby_01", 1)
					end
					
					if itemRefId == "light_com_dae_cursed_candle_10" then
						removeInventoryItem(pid, "light_com_dae_cursed_candle_10", 1)
						addInventoryItem(pid, "light_com_candle_16", 1)
					end

					if itemRefId == "misc_dwrv_cursed_coin00" then
						removeInventoryItem(pid, "misc_dwrv_cursed_coin00", 1)
						addInventoryItem(pid, "misc_dwrv_coin00", 1)
					end
					
					if itemRefId == "silver dagger_hanin cursed" then
						removeInventoryItem(pid, "silver dagger_hanin cursed", 1)
						addInventoryItem(pid, "ancient silver dagger noncursed", 1)
					end
					
					
					-- floating items
					
					if itemRefId == "misc_com_bottle_14_float" then
						removeInventoryItem(pid, "misc_com_bottle_14_float", 1)
						addInventoryItem(pid, "misc_com_bottle_14", 1)
					end
					
					if itemRefId == "misc_com_bottle_07_float" then
						removeInventoryItem(pid, "misc_com_bottle_07_float", 1)
						addInventoryItem(pid, "misc_com_bottle_07", 1)
					end

				end
			end
		end

end)

