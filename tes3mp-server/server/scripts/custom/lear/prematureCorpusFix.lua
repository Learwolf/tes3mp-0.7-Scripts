--[[
Dagoth Gares Premature Corprus Fix
	version 1.03

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This script will prevent Dagoth Gares from giving players Corprus unless they are on the correct quest to do so.
And for the player to progress when they do have the correct quest, they must activate Dagoth Gares once's he's dead.
This will prevent accidental and pre-mature Corprus acquisition.

INSTALLATION:
This lua script should be placed in your tes3mp-servers server/scripts/custom folder.

Then, in the server/scripts folder, add the following line of text to the bottom of this page:
require("custom.prematureCorpusFix")

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DO NOT EDIT BEYOND THIS, UNLESS YOU KNOW WHAT YOU'RE DOING.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
]]

local function updateDagothGaresRecord()

	local recordStore = RecordStores["npc"]
	recordStore.data.permanentRecords["dagoth gares"] = {
		baseId = "dagoth gares",
		script = ""
	}
	recordStore:Save()

end

customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
	updateDagothGaresRecord()
end)

local addCorprusItem = function(pid, refId)
	if refId == nil then return end
	tes3mp.ClearInventoryChanges(pid)
	tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
	tes3mp.AddItemChange(pid, refId, 1, -1, -1, "")
	tes3mp.SendInventoryChanges(pid)
	Players[pid]:SaveInventory()
end

local hasCorprusQuest = function(pid, qId, qIndex)
	if tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = qId, index = qIndex }, true) then
		return true
	end
	return false
end

customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
	local name = Players[pid].name:lower()
	local cell = LoadedCells[cellDescription]

	local isValid = eventStatus.validDefaultHandler

    for n,object in pairs(objects) do
		
		local objectUniqueIndex = object.uniqueIndex
		local objectRefId = object.refId
		
		if objectRefId == "dagoth gares" then
		
			LoadedCells[cellDescription]:SaveActorStatsDynamic()
			local npcStats = LoadedCells[cellDescription].data.objectData[objectUniqueIndex].stats
			
			-- if alive, do nothing
			if npcStats == nil or npcStats.healthCurrent > 0 then
				
			-- if dead, check if player has appropriate journal entry.
			else 
				isValid = false
				if hasCorprusQuest(pid, "a2_2_6thhouse", 5) and not hasCorprusQuest(pid, "a2_2_6thhouse", 50) and not tableHelper.containsValue(Players[pid].data.customVariables.dagothGares, "garesCorprusObtained") then
					local dagothGaresDeathMessage =  "With his dying breath, Dagoth Gares smiles and curses you. 'Even as my Master wills, you shall come to him, in his flesh, and of his flesh."
					tes3mp.CustomMessageBox(pid, -1, dagothGaresDeathMessage,"Ok")
					logicHandler.RunConsoleCommandOnPlayer(pid, "journal a2_2_6thhouse 50")
					logicHandler.RunConsoleCommandOnPlayer(pid, "player->AddSpell \"Corprus\"")
					
					addCorprusItem(pid, "bk_a2_2_dagoth_message")
					logicHandler.RunConsoleCommandOnPlayer(pid, "player->playsound \"Item Misc Up\"")
					tes3mp.MessageBox(pid, -1, "Message from Dagoth Ur has been added to your inventory.")
					
					addCorprusItem(pid, "amulet of 6th house")
					logicHandler.RunConsoleCommandOnPlayer(pid, "player->playsound \"Item Clothes Up\"")
					tes3mp.MessageBox(pid, -1, "6th House Amulet has been added to your inventory.")
					
					table.insert(Players[pid].data.customVariables.dagothGares, "garesCorprusObtained")
				end
			end
		end
	end
	
	eventStatus.validDefaultHandler = isValid
    return eventStatus
end)

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, previousCellDescription, currentCellDescription)
	if currentCellDescription == "Ilunibi, Soul's Rattle" then
		-- Set up the bugfix table for this cell.
		if Players[pid].data.customVariables.dagothGares == nil then
			Players[pid].data.customVariables.dagothGares = {}
		end
		
		-- forcedGreeting bit
		if hasCorprusQuest(pid, "a2_2_6thhouse", 5)  and not hasCorprusQuest(pid, "a2_2_6thhouse", 50) and not tableHelper.containsValue(Players[pid].data.customVariables.dagothGares, "forcedGreeting") then
			logicHandler.RunConsoleCommandOnPlayer(pid, "\"dagoth gares\"->forcegreeting")
			table.insert(Players[pid].data.customVariables.dagothGares, "forcedGreeting")
		end	
	end
end)
