--[[
	Learwolf's NPC Buff System
		
		Version 1.00
		
		Update History:
		
			Version 1.00 (10/25/2020)
				* Initial public release.
	
	Install Instructions:
		1) Drop this npcBuffing.lua into your "tes3mp-server\server\scripts\custom" folder.
		2) Open "customScripts.lua" (can be found in "tes3mp-server\server\scripts" folder) with a text editor.
		3) On a new line with nothing infront of it (example, make sure the line does not have "--" infront of it)
			copy paste this:		
				npcBuffing = require("custom.npcBuffing")
		
		4) Save customScripts.lua and restart your server.
	
	
	Script Information/How it works:
	
	COMMAND(S):
		/nbuffs
			Opens the npc buffs admin menu.
			
	This script allows server admins to setup buffs that actors will receive upon spawning or upon being loaded up by other players.
		This means you can give npc's or creatures all kinds of effects to make them unique. You could give Caius Cosades a buff that 
		increases his agility and luck to 9999 so he can never be physically hit. Or you could give merchants a Calm Humanoid effect 
		with a magnitude to 2000 so they'll never stop selling their goods.
		
	USAGE:
		There are two ways to utilize this script. In-game and out of game. I prefer out of game, because it's just easier for me personally, 
		but same may prefer in-game. 
		
		I will cover out of game setup first. (Done via inside this script.)
		
		Go down to the `npcBuffSpells` table. From here, you will see a few examples. On the left you input the actors refId, and on the right the spellId's to add.
		A bit further down, you will find the `createRecord` table. This allows the server to automatically create the spells when launched. If you know what you're doing,
			you can create custom spells here. For more information regarding the creation of custom spells, you can read up at these webpages: 
							https://github.com/OpenMW/openmw/blob/master/components/esm/loadspel.hpp
							https://github.com/OpenMW/openmw/blob/master/components/esm/loadmgef.hpp#L105
							https://github.com/OpenMW/openmw/blob/master/components/esm/loadench.hpp
							https://github.com/OpenMW/openmw/blob/master/components/esm/attr.hpp
							https://github.com/OpenMW/openmw/blob/master/components/esm/loadskil.hpp
		
		Now for ingame setup:
			
			On an admin account, use the chat command `/nbuffs` to open up the main menu.
			
			On this main menu, you will be able to:
				`Select Actor refId` - selects an actor you've already established as having buffs/spells.
				`Add Actor refId` - allows you to manually enter an actors refId. (i.e. mudcrab_unique for the mudcrab merchant.)
				`Remove Actor refId` - allows you to select from the list of established actor refIds and remove one.
			
			Once you've selected an actor from the `Select Actor refId` screen, you will have various more options to select from.
				`View Attached Spells/Buffs` - displays all spell refId's tied to this actor.
				`Give Spell/Buff` - allows you to enter the spellId of a spell to attach to this actor.
				`Remove Spell/Buff` - allows you to select a spellId attached to this actor and remove it.
				`Remove All Spells/Buffs` - removes all of the spellId's attached to the selected actor.
			
			Some things to note; This script does not know if the refId you entered is a valid actor or spell. So it is up to you to ensure you've entered a correct ID.
		
		
		
		** Lastly, be sure to note that anything listed inside the `npcBuffSpells` table below, will ALWAYS ensure its been added to your actors on server startup. 
			If you do not want the default predefined Actors and Buffs, simply comment them out. 
			To comment them out, put two dashes infront of them like: 
					-- ["mudcrab_unique"] = {"npc_immortality","permanent_enable_interact"},
		

	If you have any questions, please feel free to reach out to me on the TES3MP official discord.
--]]


npcBuffing = {}
local doLogs = true -- Set to true to display information in server logs. Set to false to not, which may prevent server log spam.


npcBuffing.requiredStaffRank = 2 -- This is the minimum staffRank required in order to tamper with this scripts in-game menus.

-- These shouldnt need to be adjusted:
npcBuffing.mainMenuGUI = 102520200
npcBuffing.actorListGUI = 102520201
npcBuffing.selectedActorGUI = 102520202
npcBuffing.addActorGUI = 102520203
npcBuffing.removeActorGUI = 102520204
npcBuffing.removeActorConfirmGUI = 102520205
npcBuffing.viewBuffGUI = 102520206
npcBuffing.addBuffGUI = 102520207
npcBuffing.removeBuffGUI = 102520208
npcBuffing.removeActorAllEffectsConfirmGUI = 102520209


-- You can use this section to input buffs to specific npc's on server startup:
	-- ** Take note, npcs will ALWAYS ensure these spells are attached to them on each server startup. **
local npcBuffSpells = {	
	-- actor refId:		-- All the spell ID's to automatically add to them:
	["mudcrab_unique"] = {"npc_immortality","permanent_enable_interact"}, -- The mudcrab merchant will be unhittable, and permanently calm.
	["scamp_creeper"] = {"npc_immortality","permanent_enable_interact"}, -- The mudcrab merchant will be unhittable, and permanently calm.
	
	["caius cosades"] = {"npc_immortality", "permanent_enable_interact"}, -- Caius Cosades will be unhittable, and permanently calm.
	["dilami androm"] = {"npc_permanent_levitate"}, -- The silt strider caravaner at Molag Mar will never fall to their death.
	
}

-- This section is for creating new buffs on server startup:
local function createRecord()
	local recordStore = RecordStores["spell"]
	
	--NPC Immortality:
	recordStore.data.permanentRecords["npc_immortality"] = { -- This buff grants a lot of resistances and such to make the actor unhittable.
		name = "Permanent Immortality",
		subtype = 1,
		cost = 0,
		flags = 0,
		effects = {
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 67, -- Spell Absorption
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 90, -- Resist Fire
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 91, -- Resist Frost
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 92, -- Resist Shock
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 93, -- Resist Magicka
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 94, -- Resist Common Disease
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 95, -- Resist Blight Disease
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 96, -- Resist Corprus Disease
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 97, -- Resist Poison
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 98, -- Resist Normal Weapons
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 99, -- Resist Paralysis
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 82, -- Fortify Fatigue
				rangeType = 0,
				skill = -1,
				magnitudeMin = 20000,
				magnitudeMax = 20000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 77, -- Restore Fatigue
				rangeType = 0,
				skill = -1,
				magnitudeMin = 5000,
				magnitudeMax = 5000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 76, -- Restore Magicka
				rangeType = 0,
				skill = -1,
				magnitudeMin = 5000,
				magnitudeMax = 5000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 80, -- Fortify Health
				rangeType = 0,
				skill = -1,
				magnitudeMin = 200000,
				magnitudeMax = 200000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 75, -- Restore Health
				rangeType = 0,
				skill = -1,
				magnitudeMin = 20000,
				magnitudeMax = 20000
			},
			{
				attribute = 2, -- Willpower
				area = 0,
				duration = 10,
				id = 79, -- Fortify Attribute
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			},
			{
				attribute = 3, -- Agility
				area = 0,
				duration = 10,
				id = 79, -- Fortify Attribute
				rangeType = 0,
				skill = -1,
				magnitudeMin = 9000,
				magnitudeMax = 9000
			}
		}
	}
	
	recordStore.data.permanentRecords["permanent_enable_interact"] = { -- This buff grants the actor a calm spell so they can always be interactable.
		name = "Permanent Enabled Interaction",
		subtype = 1, -- subtype = 4,
		cost = 0,
		flags = 0,
		effects = {
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 49, -- Calm Humanoid
				rangeType = 0,
				skill = -1,
				magnitudeMin = 900,
				magnitudeMax = 900
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 50, -- Calm Creature
				rangeType = 0,
				skill = -1,
				magnitudeMin = 900,
				magnitudeMax = 900
			},
		}
	}
	
	recordStore.data.permanentRecords["npc_permanent_levitate"] = { -- This buff grants an actor a permanent levitate spell.
		name = "Permanent Levitate",
		subtype = 1, -- subtype = 4,
		cost = 0,
		flags = 0,
		effects = {
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 10, -- Levitate
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10,
				magnitudeMax = 10
			}
		}
	}
	
	recordStore:Save()
end




-- SHOULD NOT NEED TO TOUCH ANYTHING BELOW THIS POINT.

local buffDB = jsonInterface.load("custom/npcBuffDB.json")
-- Setup buffDB
if buffDB == nil then
    buffDB = {}
end

-- Saving of the .json file
local Save = function()
	jsonInterface.save("custom/npcBuffDB.json", buffDB)
end
-- Loading of the .json file
local Load = function()
	buffDB = jsonInterface.load("custom/npcBuffDB.json")
end


local function OnServerPostInit(eventStatus)
	
	if buffDB.actors == nil then
		buffDB.actors = {}
		Save()
	end
	
	createRecord()
	local updatedDB = false
	
	-- refIds will add these everytime the server starts.
	for actorRefId,buffData in pairs(npcBuffSpells) do
		if buffDB.actors[actorRefId] == nil then
			buffDB.actors[actorRefId] = {}
			updatedDB = true
		end
		for i,effect in pairs(buffData) do
			if not tableHelper.containsValue(buffDB.actors[actorRefId], effect) then
				table.insert(buffDB.actors[actorRefId], effect)
				updatedDB = true
			end
		end
	end
	
	if updatedDB == true then
		Save()
	end
	
	Load()
end
customEventHooks.registerHandler("OnServerPostInit", OnServerPostInit)


npcBuffing.CheckForRefIds = function(pid, cellDescription, forEveryone)
	--if cellDescription == nil or LoadedCells[cellDescription] == nil then return end
	if LoadedCells[cellDescription] ~= nil then
		
		local addedBuffIndexes = {}
		
		for _index,objIndex in pairs(LoadedCells[cellDescription].data.packets.actorList) do
			if cellDescription ~= nil and LoadedCells[cellDescription] ~= nil and LoadedCells[cellDescription].data.objectData[objIndex] ~= nil and not tableHelper.containsValue(addedBuffIndexes, objIndex) then 
				
				local targetRefId = LoadedCells[cellDescription].data.objectData[objIndex].refId
				
				--if npcBuffSpells[targetRefId] ~= nil then
				if buffDB.actors[targetRefId] ~= nil then
					
					--for buffIndex,buffRefId in pairs(npcBuffSpells[targetRefId]) do
					for _,buffRefId in pairs(buffDB.actors[targetRefId]) do
						local consoleCommand = "addspell \"" .. buffRefId .. "\""
						--logicHandler.RunConsoleCommandOnObject(pid, consoleCommand, cellDescription, objIndex, true)
						if forEveryone == nil then
							forEveryone = false
						end
						logicHandler.RunConsoleCommandOnObject(pid, consoleCommand, cellDescription, objIndex, forEveryone)
						if doLogs then
							tes3mp.LogAppend(enumerations.log.INFO, "-[NpcBuffing]: \""..targetRefId.."\" ("..objIndex..") had spell: \""..buffRefId.."\" added by PID: ("..pid..").")
						end
					end
					
					table.insert(addedBuffIndexes, objIndex)
				end
			end
		end
	end
end

local pushAddUpdateToRefIds = function(refId)
	for pid, player in pairs(Players) do
		if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
			local cellDescription = tes3mp.GetCell(pid)
			if cellDescription ~= nil and LoadedCells[cellDescription] ~= nil then
				npcBuffing.CheckForRefIds(pid, cellDescription)	
			end
		end
	end	
end

local pushRemoveUpdateToRefIds = function(refId, spells2Remove, forEveryone)
	
	if refId == nil or spells2Remove == nil or tableHelper.isEmpty(spells2Remove) then return end
	for pid, player in pairs(Players) do
		if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		
			local cellDescription = tes3mp.GetCell(pid)
			if cellDescription ~= nil and LoadedCells[cellDescription] ~= nil then
				
				for _index,objIndex in pairs(LoadedCells[cellDescription].data.packets.actorList) do
					if cellDescription ~= nil and LoadedCells[cellDescription] ~= nil and LoadedCells[cellDescription].data.objectData[objIndex] ~= nil and LoadedCells[cellDescription].data.objectData[objIndex].refId ~= nil and LoadedCells[cellDescription].data.objectData[objIndex].refId == refId then 
						
						local targetRefId = LoadedCells[cellDescription].data.objectData[objIndex].refId
						for _,buffRefId in pairs(spells2Remove) do
							local consoleCommand = "removespell \"" .. buffRefId .. "\""
							if forEveryone == nil then
								forEveryone = false
							end
							logicHandler.RunConsoleCommandOnObject(pid, consoleCommand, cellDescription, objIndex, forEveryone)
							if doLogs then
								tes3mp.LogAppend(enumerations.log.INFO, "-[NpcBuffing]: \""..targetRefId.."\" ("..objIndex..") had spell: \""..buffRefId.."\" removed by PID: ("..pid..").")
							end
						end
						
					end
				end
				
			end
		
		end
	end	
end

customEventHooks.registerHandler("OnActorList", function(eventStatus, pid)
	local cellDescription = tes3mp.GetCell(pid)
	if cellDescription ~= nil and LoadedCells[cellDescription] ~= nil then
		npcBuffing.CheckForRefIds(pid, cellDescription)	
	end
end)

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid)
	local cellDescription = tes3mp.GetCell(pid)
	if cellDescription ~= nil and LoadedCells[cellDescription] ~= nil then
		npcBuffing.CheckForRefIds(pid, cellDescription)	
	end
end)



local trackSelections = {}

local mainBuffMenu = function(pid) -- This is the main GUI menu to give you options to the below menus.
	
	if trackSelections[pid] == nil then trackSelections[pid] = {} end
	if trackSelections[pid].page == nil then trackSelections[pid].page = 1 end
	
	local msg = color.DarkOrange.."NPC Buffs Menu\n\n"..color.Yellow..
			"Select Actor refId"..color.White.." to select an actor in the buff database.\n"..color.Yellow..
			"Add Actor refId"..color.White.." to add an actor refId to the database.\n"..color.Yellow..
			"Remove Actor refId"..color.White.." to remove an actor refId from the database.\n"
	
	tes3mp.CustomMessageBox(pid, npcBuffing.mainMenuGUI, msg, "Select Actor refId;Add Actor refId;Remove Actor refId;Exit")
end

local actorRefIdMenu = function(pid) -- This allows you to select an actors refId in order to give or take spells/buffs.
	
	local itemsPerPage = 50
	
	local count = 0
	local page = trackSelections[pid].page or 1
	
	local endIndex = (page * itemsPerPage)
	local startIndex = endIndex - itemsPerPage
	
	local listToDisplay = {}
	for aRefId,_data in pairs(buffDB.actors) do
		table.insert(listToDisplay, aRefId)
		count = count + 1
	end
	table.sort(listToDisplay, function(a,b) return a<b end)
	
	if count <= itemsPerPage then
		trackSelections[pid].pageTotal = 1
	else
		trackSelections[pid].pageTotal = math.ceil(count / itemsPerPage)
	end
	local pageTotal = trackSelections[pid].pageTotal
	
	local cancel = " * Cancel * \n"
	local nPage = " * Next Page * \n"
	if page == pageTotal then
		nPage = color.Grey..nPage
	end
	local pPage = " * Prev. Page * \n"
	if page == 1 then
		pPage = color.Grey..pPage
	end
	
	local listOfActors = ""
	trackSelections[pid].actors = {}
	local countTrack = 0
	for i=1,#listToDisplay do
		if i > startIndex and i <= endIndex then
			table.insert(trackSelections[pid].actors, listToDisplay[i])
			listOfActors = listOfActors..listToDisplay[i].."\n"
			countTrack = countTrack + 1
		elseif i > endIndex then
			break
		end
	end
	
	listOfActors = cancel..nPage..pPage..listOfActors:sub(1, -2)
	
	local label = color.DarkOrange.."Actor refId Menu (Total: "..color.White..count..color.DarkOrange..")\n"..
	color.Yellow.."Select an actor refId to adjust their spells/buffs.\nPage "..color.White..page..color.Yellow.." of "..color.White..pageTotal..color.Yellow.." ("..color.White..countTrack..color.Yellow.." on this page)"
	
	tes3mp.ListBox(pid, npcBuffing.actorListGUI, label, listOfActors)
end

local selectedActor = function(pid) -- This is the main GUI menu to give you options to the below menus.
	
	local tActor = trackSelections[pid].selectedActor
	if tActor == nil then return mainBuffMenu(pid) end -- if somehow no actor is selected, return to main menu.
	
	local aRefId = tActor
	
	local count = 0
	
	if buffDB.actors[aRefId] ~= nil then
		for index,spellId in pairs(buffDB.actors[aRefId]) do
			count = count + 1
		end
	end	
	
	local msg = color.Orange.."Actor refId: "..color.White..aRefId..color.Yellow..
			"\n\nCurrently attached spell count: "..color.White..count.."\n\n"..color.Yellow..
			"View Attached Spells/Buffs"..color.White.." to view all effects tied to this actor.\n"..color.Yellow..
			"Give Spell/Buff"..color.White.." to attach a spell/buff.\n"..color.Yellow..
			"Remove Spell/Buff"..color.White.." to remove a spells/buff.\n"..color.Yellow..
			"Remove All Spells/Buffs"..color.White.." to remove all of this actors spells/buffs.\n"
	
	tes3mp.CustomMessageBox(pid, npcBuffing.selectedActorGUI, msg, "View Attached Spells/Buffs;Give Spell/Buff;Remove Spell/Buff;Remove All Spells/Buffs;Back;Exit")
end

local removeActorRefIdMenu = function(pid) -- This allows you to select an actors refId in order to give or take spells/buffs.
	
	local count = 0
	
	trackSelections[pid].actors = {}
	for aRefId,_data in pairs(buffDB.actors) do
		table.insert(trackSelections[pid].actors, aRefId)
		count = count + 1
	end
	table.sort(trackSelections[pid].actors, function(a,b) return a<b end)
	
	local listOfActors = " * Cancel * \n"
	for i=1,#trackSelections[pid].actors do
		listOfActors = listOfActors..trackSelections[pid].actors[i].."\n"
	end
	listOfActors = listOfActors:sub(1, -2)
	
	local label = color.DarkOrange.."Remove Actor refId Menu: "..color.White..count.."\n"..color.Yellow.."Select an actor to remove their refId from the spells/buffs database."
	
	tes3mp.ListBox(pid, npcBuffing.removeActorGUI, label, listOfActors)
end


local confirmRemoveActorMenu = function(pid)
	local tActor = trackSelections[pid].selectedActor
	if tActor == nil then return end
	
	local msg = color.Error.."WARNING:\n\n"..color.Yellow..
			"You are about to completely remove the npc/creature refId: "..color.White..tActor..color.Yellow.." and any attached buffs/spells from the database.\n\n"..
			color.Error.."Are you sure you want to do this?\n"
	tes3mp.CustomMessageBox(pid, npcBuffing.removeActorConfirmGUI, msg, "Cancel;Remove Them Entirely;Exit")
end

local confirmRemoveEffectMenu = function(pid)
	local tEffect = trackSelections[pid].selectedEffect
	local tActor = trackSelections[pid].selectedActor
	if tEffect == nil or tActor == nil then return end
	
	local msg = color.Error.."WARNING:\n\n"..color.Yellow..
			"You are about to remove the effect "..color.White..tEffect..color.Yellow.." from the npc/creature refId: "..color.White..tActor..color.Yellow..".\n\n"..
			color.Error.."Are you sure you want to do this?\n"
	tes3mp.CustomMessageBox(pid, npcBuffing.removeActorConfirmGUI, msg, "Cancel;Remove Them Entirely;Exit")
end


local inputActorRefId = function(pid) -- This allows you to inpurt spell effects to add to target creature.
	tes3mp.InputDialog(pid, npcBuffing.addActorGUI, color.White.."Add a NPC or Creature refId:",  color.Red.."Leave one space and press enter to cancel.")
end

local inputEffectId = function(pid) -- This allows you to inpurt spell effects to add to target creature.
	tes3mp.InputDialog(pid, npcBuffing.addBuffGUI, color.White.."Add a spell refId:",  color.Red.."Leave one space and press enter to cancel.")
end

local removeBuffsFromRefIdList = function(pid) -- This displays a list of active buffs on target refId that can be removed.
	
	if trackSelections[pid].selectedActor == nil then return end
	
	local targetRefId = trackSelections[pid].selectedActor
	local effectCount = 0
	
	trackSelections[pid].effects = {}
	for _,effect in pairs(buffDB.actors[targetRefId]) do
		table.insert(trackSelections[pid].effects, effect)
		effectCount = effectCount + 1
	end
	table.sort(trackSelections[pid].effects, function(a,b) return a<b end)
	
	local listOfBuffs = " * Cancel * \n"
	for i=1,#trackSelections[pid].effects do
		listOfBuffs = listOfBuffs..trackSelections[pid].effects[i].."\n"
	end
	listOfBuffs = listOfBuffs:sub(1, -2)
	
	local label = color.DarkOrange .. "Current Spells/Buffs: "..color.White..effectCount..color.Error.."\nSelect and press OK to remove."
	
	tes3mp.ListBox(pid, npcBuffing.removeBuffGUI, label, listOfBuffs)
end

local viewBuffsFromRefIdList = function(pid) -- This displays a list of active buffs on target refId.
	
	if trackSelections[pid].selectedActor == nil then return end
	
	local targetRefId = trackSelections[pid].selectedActor
	local effectCount = 0
	
	trackSelections[pid].effects = {}
	for _,effect in pairs(buffDB.actors[targetRefId]) do
		table.insert(trackSelections[pid].effects, effect)
		effectCount = effectCount + 1
	end
	table.sort(trackSelections[pid].effects, function(a,b) return a<b end)
	
	local listOfBuffs = " * Cancel * \n"
	for i=1,#trackSelections[pid].effects do
		listOfBuffs = listOfBuffs..trackSelections[pid].effects[i].."\n"
	end
	listOfBuffs = listOfBuffs:sub(1, -2)
	
	local label = color.DarkOrange .. "Current Spells/Buffs: "..color.White..effectCount..color.Yellow.."\nPress OK to return."
	
	tes3mp.ListBox(pid, npcBuffing.viewBuffGUI, label, listOfBuffs)
end

local confirmRemoveAllEffectMenu = function(pid)
	local tActor = trackSelections[pid].selectedActor
	if tActor == nil then return end
	
	local msg = color.Error.."WARNING:\n\n"..color.Yellow..
			"You are about to remove all effects from the npc/creature refId: "..color.White..tActor..color.Yellow..".\n\n"..
			color.Error.."Are you sure you want to do this?\n"
	tes3mp.CustomMessageBox(pid, npcBuffing.removeActorAllEffectsConfirmGUI, msg, "Cancel;Remove Them All;Exit")
end






customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	
	if idGui == npcBuffing.mainMenuGUI then -- Main Menu
		if tonumber(data) == 0 then -- Select Actor refId
			actorRefIdMenu(pid)
		elseif tonumber(data) == 1 then -- Add Actor refId
			inputActorRefId(pid)
		elseif tonumber(data) == 2 then -- Remove Actor refId
			removeActorRefIdMenu(pid)
		else -- Exit
			return
		end
		
	elseif idGui == npcBuffing.addActorGUI then -- Add actor to database
		if data == nil or data == "" or data == " " then
			return mainBuffMenu(pid)
		else			
			local refId = string.lower(data)
			if buffDB.actors[refId] ~= nil then
				tes3mp.SendMessage(pid, color.Error.."Actor refId: \""..color.Yellow..data..color.Error.."\" already exists in the database.\n", false)
				return mainBuffMenu(pid)
			else
				buffDB.actors[refId] = {}
				Save()
				tes3mp.SendMessage(pid, color.Green.."Actor refId: \""..color.Yellow..data..color.Green.."\" has been added to the database.\n", false)
				trackSelections[pid].selectedActor = refId
				return selectedActor(pid)
			end
			
		end
	
	elseif idGui == npcBuffing.removeActorGUI then -- Select an actor to remove
		if data ~= nil and tonumber(data) > 0 then -- Option Selected:
			local target = tonumber(data)
			if buffDB.actors[trackSelections[pid].actors[target]] ~= nil then
				trackSelections[pid].selectedActor = trackSelections[pid].actors[target]
				return confirmRemoveActorMenu(pid)
			end
			return mainBuffMenu(pid)
		else
			return mainBuffMenu(pid)
		end
	
	elseif idGui == npcBuffing.removeActorConfirmGUI then -- Confirm Remove Actor Menu
		if data == nil or tonumber(data) == 0 then -- Cancel
			return mainBuffMenu(pid)
		elseif tonumber(data) == 1 then -- Remove Them Entirely
			local target = trackSelections[pid].selectedActor
			if target ~= nil and buffDB.actors[target] ~= nil then
				buffDB.actors[target] = nil
				tableHelper.cleanNils(buffDB.actors)
				Save()
				tes3mp.SendMessage(pid, color.Error.."Actor refId: \""..color.Yellow..target..color.Error.."\" has been removed from the database.\n", false)
			end
			trackSelections[pid].selectedActor = nil
			return mainBuffMenu(pid)
		else -- Exit
			return
		end
	
	elseif idGui == npcBuffing.actorListGUI then -- Select actor list
		if tonumber(data) ~= nil then
			if tonumber(data) == 0 then -- Cancel
				return mainBuffMenu(pid)
			elseif tonumber(data) == 1 then -- Next Page
				if trackSelections[pid].pageTotal ~= nil then
					local pge = trackSelections[pid].page
					if pge ~= nil and pge < trackSelections[pid].pageTotal then
						 trackSelections[pid].page =  trackSelections[pid].page + 1 
					end
				end
				return actorRefIdMenu(pid)
			elseif tonumber(data) == 2 then -- Previous Page
				if trackSelections[pid].page ~= nil and trackSelections[pid].page > 1 then
					trackSelections[pid].page = trackSelections[pid].page - 1
				end
				return actorRefIdMenu(pid)
			elseif tonumber(data) >= 3 then -- Option Selected:
				local target = tonumber(data)
				target = target - 2 -- This is to take into account the above page options.
				if trackSelections[pid].actors[target] ~= nil then
					trackSelections[pid].selectedActor = trackSelections[pid].actors[target]
					return selectedActor(pid)
				end
				return mainBuffMenu(pid)
			end
		else
			return mainBuffMenu(pid)
		end
	
	
	elseif idGui == npcBuffing.selectedActorGUI then -- Selected Actor Menu
		if tonumber(data) == 0 then -- View Attached Spells/Buffs
			return viewBuffsFromRefIdList(pid)
		elseif tonumber(data) == 1 then -- Give Spell/Buff
			return inputEffectId(pid)
		elseif tonumber(data) == 2 then -- Remove Spell/Buff
			return removeBuffsFromRefIdList(pid)
		elseif tonumber(data) == 3 then -- Remove All Spells/Buffs
			return confirmRemoveAllEffectMenu(pid)
		elseif tonumber(data) == 4 then -- Back
			return actorRefIdMenu(pid)
		else -- Exit
			return
		end
		
	elseif idGui == npcBuffing.addBuffGUI then -- Adding a buff to target
		if data == nil or data == "" or data == " " then
			return selectedActor(pid)
		else			
			local refId = trackSelections[pid].selectedActor
			local spellId = string.lower(data)
			
			if buffDB.actors[refId] ~= nil then
				if tableHelper.containsValue(buffDB.actors[refId], spellId) then
					tes3mp.SendMessage(pid, color.Error.."Actor refId: \""..color.Yellow..refId..color.Error.."\" already has spellId: "..color.Yellow..spellId..color.Error.." in the database.\n", false)
				else
					table.insert(buffDB.actors[refId], spellId)
					Save()
					
					pushAddUpdateToRefIds(refId)
					
					tes3mp.SendMessage(pid, color.Green.."Actor refId: \""..color.Yellow..refId..color.Green.."\" has attached spellId: "..color.Yellow..spellId..color.Green.." in the database.\n", false)
				end
			else
				buffDB.actors[refId] = {}
				table.insert(buffDB.actors[refId], spellId)
				Save()
				
				pushAddUpdateToRefIds(refId)
				
				tes3mp.SendMessage(pid, color.Green.."Actor refId: \""..color.Yellow..refId..color.Green.."\" has been added to the database and attached spellId: "..spellId.."\n", false)
			end
			
			return selectedActor(pid)
		end
	
	elseif idGui == npcBuffing.removeBuffGUI then -- Removing a buff from target
		if data ~= nil and tonumber(data) > 0 then
			local target = tonumber(data)
			local sId = trackSelections[pid].effects[target]
			if sId ~= nil then
				local refId = trackSelections[pid].selectedActor
				local replacementSpells = {}
				for slot,spellId in pairs(buffDB.actors[refId]) do
					if spellId ~= sId then
						table.insert(replacementSpells, spellId)
					end
				end
				buffDB.actors[refId] = replacementSpells
				Save()
				
				local toRemove = {}
				table.insert(toRemove, sId)
				pushRemoveUpdateToRefIds(refId, toRemove)
				
				tes3mp.SendMessage(pid, color.Error.."Actor refId: \""..color.Yellow..refId..color.Error.."\" already has spellId: "..color.Yellow..sId..color.Error.." in the database.\n", false)
			end
			return selectedActor(pid)
		else
			return selectedActor(pid)
		end
	
	elseif idGui == npcBuffing.removeActorAllEffectsConfirmGUI then -- Remove all buffs from target actor
		if data == nil or tonumber(data) == 0 then -- Cancel
			return selectedActor(pid)
		elseif tonumber(data) == 1 then -- Remove Them All
			local target = trackSelections[pid].selectedActor
			if target ~= nil and buffDB.actors[target] ~= nil then
				
				local toRemove = {}
				for i,sId in pairs(buffDB.actors[target]) do
					table.insert(toRemove, sId)
				end
				buffDB.actors[target] = {}
				Save()
				pushRemoveUpdateToRefIds(target, toRemove)
				
				tes3mp.SendMessage(pid, color.Error.."Actor refId: \""..color.Yellow..target..color.Error.."\" has had all spells and buffs removed.\n", false)
			end
			return selectedActor(pid)
		else -- Exit
			return
		end
	
	elseif idGui == npcBuffing.viewBuffGUI then
		return selectedActor(pid)
	
	end
	
end)


customCommandHooks.registerCommand("nbuffs", function(pid, cmd)
	if Players[pid].data.settings.staffRank >= npcBuffing.requiredStaffRank then
		mainBuffMenu(pid)
	end
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if Players[pid].data.settings.staffRank >= npcBuffing.requiredStaffRank then
			trackSelections[pid] = {}
		end
	end
end)

return npcBuffing
