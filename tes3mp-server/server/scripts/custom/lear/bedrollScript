--[[
	Bedroll Script for TES3MP 0.7
		by Learwolf
			version 1.00 (1/3/2022)

	DESCRIPTION:
		This script allows every player to receive 1 bedroll inventory item upon logging in.
		Players can place this inventory item on the ground, which places a useable bedroll.
		To pick the bedroll back up, sneak + activate the bedroll. (An automated message tells the players of this upon activating the bedroll.)
		If a player loses their bedroll, it is up to the server owner to find another means of getting the bedrolls to said player(s).
		
	
	INSTALLATION:
		1) Save this to your 'tes3mp-server\server\scripts\custom' folder as 'bedrollScript.lua'
		2) Open 'customScripts.lua' in a text editor such as notepad+. It can be found in your 'tes3mp-server\server\scripts` folder.
		3) On a new line, add the following:		require("custom.bedrollScript")
		4) Make sure there are no dashes infront of it. (Dashes infront will disable/comment it out.)
		5) Save 'customScripts.lua', restart your server, and enjoy.
		
		
--]]


playerBedrollScript = {}


local bedrollName = "Player Bedroll" -- the dame displayed in-game to players.
local bedrollRefId = "droppable_bedroll" -- The refId of bedroll item.
local bedrollWeight = 1 -- How much the bedroll weighs. Must be a number value.
local bedrollValue = 0 -- Value of the bedroll. Must be a number value.


local addBedrollItem = function(pid)
	tes3mp.ClearInventoryChanges(pid)
	tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
	tes3mp.AddItemChange(pid, bedrollRefId, 1, -1, -1, "")
	tes3mp.SendInventoryChanges(pid)
	Players[pid]:SaveInventory()
	logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Misc Up\"")
	tes3mp.MessageBox(pid, -1, bedrollName.." was added to your inventory.")
end

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if Players[pid].data.customVariables.giveBedroll == nil or Players[pid].data.customVariables.giveBedroll ~= bedrollRefId then
			addBedrollItem(pid)
			Players[pid].data.customVariables.giveBedroll = bedrollRefId
		end
	end
end)


local bedRollFunction = function(pid)

	if tes3mp.GetSneakState(pid) then
		return true
	end
	
	tes3mp.MessageBox(pid, -1, "Activate while crouching to pick up this bedroll.")
	logicHandler.RunConsoleCommandOnPlayer(pid, "player->ShowRestMenu")
	
	return false
end

customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
	
	local isValid = eventStatus.validDefaultHandler
	
	if isValid ~= false then
		for n,object in pairs(objects) do
			
			local objectUniqueIndex = object.uniqueIndex
			local objectRefId = object.refId
			
			if objectRefId ~= nil and objectRefId == bedrollRefId then
				isValid = bedRollFunction(pid)
			end
			
		end

	end

	eventStatus.validDefaultHandler = isValid
    return eventStatus
end)


local function createBedrollRecord()
	
	local recordStore = RecordStores["miscellaneous"]
	
	recordStore.data.permanentRecords[bedrollRefId] = {
		name = bedrollName,
		model = "f\\Active_De_Bedroll.NIF",
		icon = "m\\Misc_Uni_Pillow_02.tga",
		weight = bedrollWeight,
		value = bedrollValue
	}
	
	recordStore:Save()
end

local function OnServerPostInit(eventStatus)
	createBedrollRecord()
end
customEventHooks.registerHandler("OnServerPostInit", OnServerPostInit)

return playerBedrollScript
