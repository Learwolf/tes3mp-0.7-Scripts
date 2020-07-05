--[[
	Webspinner Fix
		by Learwolf
	Version 1.00 (7/5/2020)
	
	Installation:
		1) Drop this .lua file into your "server/scripts/custom/" folder.
		
		2) Open up "customScripts.lua" that can be found in your tes3mp servers "server/scripts/" 
			folder with a text editor such a notepad.
		
		3) At the bottom of your "customScripts.lua" you just opened, add the following line of code: (**MAKE SURE THERE ARE NO DASHES INFRONT OF IT!!**)
			require("custom.webspinnerFix")
			
		4) Save, exit and relaunch your server.
		
		
	Description:
		Allows players to see what items they have not yet turned in for the 
		Threads of the Webspinner questline via chat commands: 
			/webspinner
			/threads
		
		This script also fixes a potential issue with non-shared journals:
		By default TES3MP 0.7 does not maintain player variables after relogging, 
		so logging off would reset the players turn in variable count, preventing  
		the completion of this quest if they did not turn in everything in one play 
		session.
		
		This script fixes that by correctly seting their turn in variable after logging back on.	
--]]

local sConfig = {}
sConfig.webspinnerDebugger = 07052020

local webspinnerQuestIndexesAndItems = {
	{id = "mt_s_balancedarmor", index = 100, item = "Belt of Sanguine Balanced Armor"},
	{id = "mt_s_deepbiting", index = 100, item = "Belt of Sanguine Deep Biting"},
	{id = "mt_s_denial", index = 100, item = "Belt of Sanguine Denial"},
	{id = "mt_s_fleetness", index = 100, item = "Belt of Sanguine Fleetness"},
	{id = "mt_s_fluidevasion", index = 100, item = "Ring of Sanguine Fluid Evasion"},
	{id = "mt_s_glibspeech", index = 100, item = "Amulet of Sanguine Glib Speech"},
	{id = "mt_s_golden", index = 100, item = "Ring of Sanguine Golden Wisdom"},
	{id = "mt_s_green", index = 100, item = "Ring of Sanguine Green Wisdom"},
	{id = "mt_s_hewing", index = 100, item = "Belt of Sanguine Hewing"},
	{id = "mt_s_hornyfist", index = 100, item = "Glove of Sanguine Horny Fist"},
	{id = "mt_s_impaling", index = 100, item = "Belt of Sanguine Impaling Thrust"},
	{id = "mt_s_leaping", index = 100, item = "Shoes of Sanguine Leaping"},
	{id = "mt_s_martialcraft", index = 100, item = "Belt of Sanguine Martial Craft"},
	{id = "mt_s_nimblearmor", index = 100, item = "Amulet of Sanguine Nimble Armor"},
	{id = "mt_s_red", index = 100, item = "Ring of Sanguine Red Wisdom"},
	{id = "mt_s_safekeeping", index = 100, item = "Glove of Sanguine Safekeeping"},
	{id = "mt_s_silver", index = 100, item = "Ring of Sanguine Silver Wisdom"},
	{id = "mt_s_smiting", index = 100, item = "Belt of Sanguine Smiting"},
	{id = "mt_s_stalking", index = 100, item = "Shoes of Sanguine Stalking"},
	{id = "mt_s_stolidarmor", index = 100, item = "Belt of Sanguine Stolid Armor"},
	{id = "mt_s_sublime", index = 100, item = "Ring of Sanguine Sublime Wisdom"},
	{id = "mt_s_sureflight", index = 100, item = "Belt of Sanguine Sureflight"},
	{id = "mt_s_swiftblade", index = 100, item = "Glove of Sanguine Swiftblade"},
	{id = "mt_s_transcendent", index = 100, item = "Ring of Sanguine Transcendence"},
	{id = "mt_s_transfiguring", index = 100, item = "Ring of Sanguine Transfiguring"},
	{id = "mt_s_unseen", index = 100, item = "Ring of Sanguine Unseen Wisdom"}
}

local hasJournalIndex = function(pid, questId, index)
	for id, journalItem in pairs(Players[pid].data.journal) do
		if journalItem.quest ~= nil and journalItem.quest == questId then
			if journalItem.index == index then 
				return true
			end
		end
	end
	return false
end

local function OnPlayerAuthentified(eventStatus,pid)
	
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local varCount = 0
		
		for i=1,#webspinnerQuestIndexesAndItems do
			local jId = webspinnerQuestIndexesAndItems[i].id
			local jIndex = webspinnerQuestIndexesAndItems[i].index
			if hasJournalIndex(pid, jId, jIndex) then
				varCount = varCount + 1
			end
		end
		
		logicHandler.RunConsoleCommandOnPlayer(pid, "Set ThreadsWebspinner to " .. varCount)
	end
	
end
customEventHooks.registerHandler("OnPlayerAuthentified", OnPlayerAuthentified)

local checkWebspinnerQuests = function(pid)
	
	local topMsg = color.Orange.."Threads of the Webspinner\n"
	local recoveredCounter = 26
	
	local list = ""
	
	for i=1,#webspinnerQuestIndexesAndItems do
		local jId = webspinnerQuestIndexesAndItems[i].id
		local jIndex = webspinnerQuestIndexesAndItems[i].index
		local jItem = webspinnerQuestIndexesAndItems[i].item
		
		if not hasJournalIndex(pid, jId, jIndex) then
			jItem = color.SlateGrey..jItem
			recoveredCounter = recoveredCounter - 1
		end
		
		list = list..jItem.."\n"
	end
	
	if recoveredCounter < 1 then
		recoveredCounter = color.Red..recoveredCounter
	elseif recoveredCounter < 26 then
		recoveredCounter = color.White..recoveredCounter
	end
	
	topMsg = topMsg..color.Yellow.."Threads Recovered: "..recoveredCounter
	
	tes3mp.ListBox(pid, sConfig.webspinnerDebugger, topMsg, list:sub(1, -2))
end

customCommandHooks.registerCommand("webspinner", checkWebspinnerQuests)
customCommandHooks.registerCommand("threads", checkWebspinnerQuests)
customCommandHooks.registerCommand("thread", checkWebspinnerQuests)
