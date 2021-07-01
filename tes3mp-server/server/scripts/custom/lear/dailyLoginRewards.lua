--[[
Daily Login Rewards
	v1.00
		by Learwolf

How To Install:
	Drop this 'dailyLoginRewards.lua' script into your 'tes3mp-server\server\scripts\custom' folder.
	In 'customScripts.lua' (located in the 'tes3mp-server\server\scripts' folder), add the following to a new line:
		require("custom.dailyLoginRewards")

Description:
	Players can receive a daily login reward upon logging onto the server.
	Owners can also toggle for it to be a weekly instead of daily. (See below.)
	Owners can customize the reward item(s). (See below.)
	Owners can set for players to receive all reward items, or one randomly picked item from the list. (See below.)

]]

dailyLoginRewards = {}

--==----==----==----==----==--
-- CUSTOMIZATION SETTINGS:
--==----==----==----==----==--

-- Brand new characters skip their first login loot?:
local newCharactersMustSkipFirstLogin = true 	-- If true, newly created characters cannot receive their first login reward until the following day.
												-- Set this to false if you want newly created characters to get a login reward immediately upon creation.
												-- (Setting to false may lead to players constantly creating new characters to get endless login rewards.)

-- Randomize the loot table or give the player all its contents?:
local randomizeDailyReward = true	-- If true, randomly gives the player only 1 item from the dailyRewardsTable.
									-- If false, gives the player every item listed in the dailyRewardsTable.

-- Make this system be weekly instead of daily?:
local weeklyLoginsInstead = false -- If true, players will receive the weekly login once a week rather than once a day.
local weeklyLoginsResetDay = "Monday" 	-- The day of the week that is considered the reward reset day. (Only applies if weeklyLoginsInstead = true.) 
										-- Possible inputs: "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"

-- The message displayed to inform players of the reward item(s) they are receiving for logging in:
local rewardLoginMessageHeader = "The following Login Rewards have been added to your inventory:"

-- Set the sound that plays upon receiving a daily login reward:
local dailyRewardReceivedSound = {sound = "item gold up", volume = 1, pitch = 1.3} -- Clever use of pitch can simulate an entirely new sound effect.

-- Set what item(s) the player can receive as a login reward here:
local dailyRewardsTable = {

	-- Possible Daily Login Items Go Here:
	{ -- Some gold:
		refId = "gold_001", -- The items refId as it's seen in the construction set.
		name = "Gold", -- The items name as it's seen by players in game.
		count = 200, -- How many of this item will the player receive?
		soul = "" -- Leave this as is, unless the item is a soul gem that needs a soul added to it.
	}, -- <- You need a comma in between each possible item setup.
	
	{ -- A few health potions:
		refId = "p_restore_health_s",
		name = "Standard Restore Health Potion",
		count = 3,
		soul = ""
	},
	
	{ -- A few magicka potions:
		refId = "p_restore_magicka_s",
		name = "Standard Restore Magicka Potion",
		count = 3,
		soul = ""
	},
	
	{ -- A few fatigue potions:
		refId = "p_restore_fatigue_s",
		name = "Standard Restore Fatigue",
		count = 3,
		soul = ""
	},
	
	{ -- A few speed potions:
		refId = "p_fortify_speed_s",
		name = "Standard Fortify Speed",
		count = 3,
		soul = ""
	}

}


--==----==----==----==----==----==----==----==----==----==----==----==----==--
--
-- DO NOT TOUCH ANYTHING BEYOND THIS POINT UNLESS YOU KNOW WHAT YOU ARE DOING.
--
--==----==----==----==----==----==----==----==----==----==----==----==----==--

local addInventoryItem = function(pid, refId, count, soul)
	
	Players[pid].data.customVariables.allowAddItem = true -- This allows the player to bypass the block enforced within morePlayerFuncs.lua's Player:SaveInventory()
	
	if refId == nil then return end
	if count == nil then count = 1 end
	if soul == nil then soul = "" end
	
	refId = string.lower(refId)
	
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
	tes3mp.AddItemChange(pid, refId, count, -1, -1, soul)
	tes3mp.SendInventoryChanges(pid)
	Players[pid]:SaveInventory()
end

-- Loot randomization
local randomPull = function(pid, targetTable)
	
	math.randomseed((pid * (1 + math.random())) * os.time() + math.random())
	math.random()
	math.random()
	math.random()
	
	local keyset = {}
	for k in pairs(targetTable) do
		table.insert(keyset, k)
	end
	return targetTable[keyset[math.random(#keyset)]]
end

giveDailyLoginItem = function(pid)
	if not tableHelper.isEmpty(dailyRewardsTable) then
	
		local addedItems = {}
		
		local rewardMsg = ""
		if randomizeDailyReward == true then
			-- randomize the rewards.
			local t = randomPull(pid, dailyRewardsTable)
			if t ~= nil then
				addInventoryItem(pid, t.refId, t.count, t.soul)
				table.insert(addedItems, t)
			end
		else
			-- give all the rewards
			for i=1,#dailyRewardsTable do
				local t = dailyRewardsTable[i]
				if t ~= nil then
					addInventoryItem(pid, t.refId, t.count, t.soul)
					table.insert(addedItems, t)
				end
			end
			
		end
		
		if not tableHelper.isEmpty(addedItems) then
			rewardMsg = rewardLoginMessageHeader or "The following Login Rewards have been added to your inventory:"
			local dbugInfoTxt = ""
			for i=1,#addedItems do
				local t = addedItems[i]
				local iRefId = t.refId or "An item"
				local iName = t.name or iRefId
				local iCount = t.count or 1
				rewardMsg = rewardMsg.."\n"..iName
				if iCount > 1 then
					rewardMsg = rewardMsg.." (x"..iCount..")"
				end
				dbugInfoTxt = dbugInfoTxt.."refId: "..iRefId..", itemName: "..iName..", count: "..iCount
				if t.soul ~= nil then
					dbugInfoTxt = dbugInfoTxt..", soul: "..t.soul
				end
				if i < #addedItems then
					dbugInfoTxt = dbugInfoTxt..", "
				end
			end
			
			 tes3mp.LogAppend(enumerations.log.INFO, "- " .. Players[pid].accountName .. " received the following daily login items: " .. dbugInfoTxt)
		end
		
		if dailyRewardReceivedSound ~= nil then
			local sfx = dailyRewardReceivedSound.sound or ""
			local vol = dailyRewardReceivedSound.volume or 1
			local pit = dailyRewardReceivedSound.pitch or 1
			logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySoundVP \""..sfx.."\" "..vol.." "..pit)
		end
		
		tes3mp.MessageBox(pid, -1, rewardMsg)
		
	end
end

local getWeeklyResetPeriod = function()
	
	local resetDay = 7
	-- "Monday"; "Tuesday"; "Wednesday"; "Thursday"; "Friday"; "Saturday"; "Sunday"
	if weeklyLoginsResetDay == nil or weeklyLoginsResetDay == "Monday" then
		resetDay = 7
	elseif weeklyLoginsResetDay == "Tuesday" then
		resetDay = 8
	elseif weeklyLoginsResetDay == "Wednesday" then
		resetDay = 9
	elseif weeklyLoginsResetDay == "Thursday" then
		resetDay = 10
	elseif weeklyLoginsResetDay == "Friday" then
		resetDay = 11
	elseif weeklyLoginsResetDay == "Saturday" then
		resetDay = 12
	elseif weeklyLoginsResetDay == "Sunday" then
		resetDay = 13
	end
	
	return os.time({year=2021, month=6, day=resetDay, hour=0, minute=0})
end

local weeklyHasReset = function(pid)
	
	local initialWeekStamp = getWeeklyResetPeriod() -- A Monday in June.
	local getTimeSubtraction = os.time() - initialWeekStamp -- Here, we subtract the above initial date from the current date/time.
	local aWeekInOsTime = 604800 -- 7 days worth of seconds in os.time
	local currentActiveWeek = math.floor(getTimeSubtraction / aWeekInOsTime) -- Then we math.floor divide to get a whole number to represent the week.
	
	local lastMark = Players[pid].data.customVariables.dailyLoginWeek
	
	if lastMark == nil then
		Players[pid].data.customVariables.dailyLoginWeek = currentActiveWeek
		return true
	else
		if lastMark ~= currentActiveWeek then
			Players[pid].data.customVariables.dailyLoginWeek = currentActiveWeek
			return true
		end
	end
	
	return false
end

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		local currentDate = os.date("%m.%d.%Y")
		local loginDate = Players[pid].data.customVariables.dailyLoginDate
		
		if loginDate == nil and newCharactersMustSkipFirstLogin == true then
			Players[pid].data.customVariables.dailyLoginDate = currentDate
			if weeklyLoginsInstead ~= nil and weeklyLoginsInstead == true then
				weeklyHasReset(pid)
			end
		elseif loginDate == nil or loginDate ~= currentDate then
			Players[pid].data.customVariables.dailyLoginDate = currentDate
			if weeklyLoginsInstead ~= nil and weeklyLoginsInstead == true then
				if weeklyHasReset(pid) then
					giveDailyLoginItem(pid)
				end
			else
				giveDailyLoginItem(pid)
			end
		end
		
	end
end)

return dailyLoginRewards