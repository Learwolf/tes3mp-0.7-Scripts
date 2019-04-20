--[[
Dagoth Gares Premature Corprus Fix
	version 1.00

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This script will prevent Dagoth Gares from giving players Corprus unless they are on the correct quest to do so.
And for the player to progress when they do have the correct quest, they must activate Dagoth Gares once's he's dead.
This will prevent accidental and pre-mature Corprus acquisition.

INSTALLATION:
This lua script should be placed in your tes3mp-servers server/scripts/custom/lear folder. If you do not have a lear folder,
simply add one and place this script within.

Then, in the server/scripts folder, add the following line of text to the bottom of this page:
require("custom.lear.prematureCorpusFix")

Lastly, you MUST edit Dagoth Gares to not have his default script attached to him. The way to do this, is by going to your 
tes3mp-server server/data/recordstore folders creature.json file and copying the following line of text:

"dagoth gares":{"baseId":"dagoth gares","script":""}

(Yes, quotations and all.) And adding it into the permanentRecords of your creature.json

If you do not have any permanentRecords already, then it should look like this afterwards:

  "permanentRecords":{
    "dagoth gares":{
	  "baseId":"dagoth gares",
	  "script":""
	}
  }
  
However, if you DO have other permanent records, it should look something like this:

  "permanentRecords":{
    "dagoth gares":{
	  "baseId":"dagoth gares",
	  "script":""
	},
	"someOtherRecord":{
      "name":"blahBlahBlah",
	  "level":12
    },
  }

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DO NOT EDIT BEYOND THIS, UNLESS YOU KNOW WHAT YOU'RE DOING.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
]]

local split = function(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
	local name = Players[pid].name:lower()
	local cell = LoadedCells[cellDescription]

	local isValid = eventStatus.validDefaultHandler

    for n,object in pairs(objects) do
		
		local index = n-1
        local temp = split(object["uniqueIndex"], "-")
        local RefNum = temp[1]
        local MpNum = temp[2]
		
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
				if tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "a2_2_6thhouse", index = 5 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "a2_2_6thhouse", index = 50 }, true) and not tableHelper.containsValue(Players[pid].data.customVariables.lear.questFixes.dagothGares, "garesCorprusObtained") then
					local dagothGaresDeathMessage =  "With his dying breath, Dagoth Gares smiles and curses you. 'Even as my Master wills, you shall come to him, in his flesh, and of his flesh."
					tes3mp.CustomMessageBox(pid, -1, dagothGaresDeathMessage,"Ok")
					logicHandler.RunConsoleCommandOnPlayer(pid, "journal a2_2_6thhouse 50")
					logicHandler.RunConsoleCommandOnPlayer(pid, "player->AddSpell \"Corprus\"")
					
					logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"bk_a2_2_dagoth_message\" 1")
					logicHandler.RunConsoleCommandOnPlayer(pid, "player->playsound \"Item Misc Up\"")
					tes3mp.MessageBox(pid, -1, "Message from Dagoth Ur has been added to your inventory.")
					
					logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"amulet of 6th house\" 1")
					logicHandler.RunConsoleCommandOnPlayer(pid, "player->playsound \"Item Clothes Up\"")
					tes3mp.MessageBox(pid, -1, "6th House Amulet has been added to your inventory.")
					
					table.insert(Players[pid].data.customVariables.lear.questFixes.dagothGares, "garesCorprusObtained")
				end
			end
		end
	end
	
	eventStatus.validDefaultHandler = isValid
    return eventStatus
end)

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, previousCellDescription, currentCellDescription)
-- 
	if currentCellDescription == "Ilunibi, Soul's Rattle" then
		-- Set up the bugfix table for this cell.
		if Players[pid].data.customVariables.lear.questFixes.dagothGares == nil then
			Players[pid].data.customVariables.lear.questFixes.dagothGares = {}
		end
		
		-- forcedGreeting bit
		if tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "a2_2_6thhouse", index = 5 }, true) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "a2_2_6thhouse", index = 50 }, true) and not tableHelper.containsValue(Players[pid].data.customVariables.lear.questFixes.dagothGares, "forcedGreeting") then
			logicHandler.RunConsoleCommandOnPlayer(pid, "\"dagoth gares\"->forcegreeting")
			table.insert(Players[pid].data.customVariables.lear.questFixes.dagothGares, "forcedGreeting")
		end	
	end
end)
