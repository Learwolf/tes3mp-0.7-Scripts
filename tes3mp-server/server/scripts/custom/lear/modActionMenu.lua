--[[
Script:
	Moderator Action Menu
	
Version:
	1.02
	
For TES3MP Version:
	Alpha 0.7
	
Created by:
	Learwolf
	
Version History:
	1.02 - Date: 4/21/2020
		* Fixed some stuff related to GoTo functions.
		* Added config.GoToLocationRank for staff rank requirements to other goto functions.
		* Updated the method of which items are added to player inventories.
		
	1.01 - Date: 1/31/2020
		* Fixed issue with staff rank config settings.
		* Added some padding for /invis and /run commands speed boost.
		* HEAL will no longer kill the target. (Whoops, lol)
	
	1.00 - Date: 11/2/2019
		* Initial public release.
	
--------------------------------------------------------------------------------------------------------
How To Install:
	This script is practically plug and play. Save this script as 
		modActionMenu.lua
	And drop it into your "tes3mp-server/server/scripts/custom" folder.
	Next, back track one folder to the "tes3mp-server/server/scripts" folder and open with a text editor:
		customScripts.lua
	At the very bottom of this list, add the following line:
		require("custom.modActionMenu")
	Save, launch your server and you're good to go.
	
--------------------------------------------------------------------------------------------------------
Description:

	This is a moderator menu that I created for Nerevarine Prophecies. It has been altered (had content removed) in order to be used with other servers.
	The menu can be accessed by Moderator rank or higher (staffRank 1 - 3).
	The command(s) to access the menu are:
	/modmenu	/mm		
	
	This menu will grant moderators and admins easy access to features they may find difficult looking up, as well as some other unique moderator abilities.
	Some of these features are easily done via in-game console or via other in game chat commands. This menu simply makes them easier to find and utilize.
	This also limits your moderators to what they can do instead of giving them full console access.
	
	Example features: 
	
		- A unique invisibility toggle that will prevent players from ever seeing or hearing you while allowing you to fly around undetected.
		- A super speed toggle that increases your characters movement speed via buff rather than editing your attributes/skills.
		- A command to toggle Freezing a player in place and prevent them from doing anything.
		- A way to deathtouch a specific player.
		- A way to instantly heal a specific player.
		- A safemode that prevents you from being slain by NPCs or Players.
		- Teleport functions that let you quickly warp to a players name, players ID, cell or exact location.
		- A Summon function for a players Name or a players ID.
		- A button command to change your players model/sprite as well as revert it.
		- A method of setting any players levels.
		- Methods to add items to ones self or others.
		- An easy way to force a specific (or every) player console command(s).
		- A way to toggle visible cell borders.
		- An easy way to see where a specific player is.
		
--------------------------------------------------------------------------------------------------------		
Disclaimer:
	This script is not finished. Some features may not be accessible in-game.
	I am also not responsible for what your moderators and admins do with this script.
	Please ensure you trust your moderators before utilizing this script.
	If you need support for this script, you can find me in the official tes3mp discord as username Learwolf.
	If you would list a custom feature added onto this menu to tailor to a specific server function, feel free
		to private message me the request.
	
--------------------------------------------------------------------------------------------------------

]]


local config = {}

--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
-- Set the staff rank requirement for certain menu functions:
--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
config.MsgBoxColor = "#AB8C53"

config.ModMenuRank = 1 -- Staff rank to access the Moderator Menu.
config.InvisRank = 2 -- Staff rank in order to simulate legit invisibility.
config.MuteRank = 1 -- Staff rank required to toggle silencing other players in chat.
config.RootRank = 1 -- Staff rank to toggle freezing players in place.
config.SuperRunRank = 2 -- Staff rank in order to have super speed.
config.SafeMode = 2 -- Staff rank to enable console TGM.
config.GoToRank = 1 -- Staff rank to use the GoTo command (warp to player)
config.GoToLocationRank = 1 -- Staff rank to use the GoTo command (warp to location/xyz/etc.)
config.SummonItemRank = 2 -- Staff rank required to give self any item.
config.GiveItemRank = 2 -- Staff rank required to be able to give anyone any item.
config.BuffPC = 2 -- Staff rank required to set any players level to any number.
config.RunConsoleCommand = 2 -- Staff rank required to force a console command on any player.
config.ForceConsoleCommandAll = 2 -- Staff rank required to force all players to run the inserted console command.
config.ToggleBorder = 2 -- Staff rank required to use the Toggle Border console command on self.
config.ResetKillCount = 1 -- Staff rank required to reset the servers world kill count. (Fixes some quest issues from dead NPCs.)



-- The below adds padding for boosting your speed too high via the /invis and /run commands.
config.ServerSpeedCap = config.maxSpeedValue or 365 -- This should be whatever your config.lua files maxSpeedValue is.
config.SuperRunSpeed = config.ServerSpeedCap - 215 -- Default amount: 150
config.InvisRunSpeed = config.ServerSpeedCap - 115 -- Default amount: 250


-- Don't touch the next set of numbers.
config.moderatorActionMenuOriginGUI = 07252020 -- main menu origin
config.moderatorActionMenuAvatarGUI = 07252021 -- avatar menu
config.moderatorActionMenuNavigationGUI = 07252022 -- navigation menu
config.moderatorActionMenuProgrammingGUI = 07252024 -- programming menu
config.moderatorActionMenuTargetActionGUI = 07252031 -- target action
config.moderatorActionMenuCheckPlayerNameGUI = 07252032 -- check player name
config.moderatorActionMenuItemRefIdGUI = 07252033 -- enter item refId
config.moderatorActionMenuItemCountGUI = 07252034 -- enter count
config.moderatorActionMenuLevelNumberGUI = 07252035 -- enter level number
config.moderatorActionMenuConsoleCommandGUI = 07252036 -- enter exact console command
config.moderatorActionMenuTargetInfoGUI = 07252041 -- target info
config.moderatorActionMenuSelfGUI = 07252042 -- self
config.moderatorActionMenuCreatureRefIdGUI = 07252043 -- Change Sprite
config.moderatorActionMenuRenderGUI = 07252044
config.moderatorActionMenuGotoZoneGUI = 07252051 -- Enter Zone Name
config.moderatorActionMenuGotoLocationCellGUI = 07252052 -- Enter Goto Location Cell
config.moderatorActionMenuGotoLocationXYZGUI = 07252053 -- Enter Goto Location X Y Z
config.moderatorBroadcastGUI = 07252061 -- Broadcast
config.moderatorActionMenuConsoleCommandEveryoneGUI = 07252062 -- force console command for everyone


-- Create Spells on Start up
local function createRecord(request)
	if request == "admin_spells" then
		local recordStore = RecordStores["spell"]
		recordStore.data.permanentRecords["super_speed"] = {
			name = "Super Speed",
			subtype = 1,
			cost = 0,
			flags = 0,
			effects = {{
				id = 79,
				attribute = 4,
				skill = -1,
				rangeType = 0,
				area = 0,
				magnitudeMax = config.SuperRunSpeed,
				magnitudeMin = config.SuperRunSpeed
			}}
		}
		recordStore:Save()
		
		recordStore.data.permanentRecords["fly_speed"] = {
			name = "Fly Speed",
			subtype = 1,
			cost = 0,
			flags = 0,
			effects = {{
				id = 79,
				attribute = 4,
				skill = -1,
				rangeType = 0,
				area = 0,
				magnitudeMax = config.InvisRunSpeed,
				magnitudeMin = config.InvisRunSpeed
			}}
		}
		recordStore:Save()
	end
end

-- Push creating spells on server start up
local function OnServerPostInit(eventStatus)
	local request = "admin_spells"
	createRecord(request)
end

customEventHooks.registerHandler("OnServerPostInit", OnServerPostInit)



-- Begin Name and PID Check:
-- Second check for name:
local function playerNameOnline(pid, checkName)
	local userPid = pid
	
	local found = false
	local target
	
	for pid, player in pairs(Players) do
		if Players[pid] ~= nil and player:IsLoggedIn() then	
			local targetName = Players[pid].name
			
			--tes3mp.SendMessage(pid, color.Yellow..checkName..config.MsgBoxColor.." test.\n", false)
			if checkName:lower() == targetName:lower() then
				
				--tes3mp.SendMessage(userPid, color.Yellow..checkName..config.MsgBoxColor.."("..color.Yellow..pid..config.MsgBoxColor..")\n", false)
				target = pid
				Players[userPid].data.customVariables.modMenuTarget = target
				found = true
				return
			end
			
		end
	end
	
	if not found then
		tes3mp.SendMessage(pid, color.Yellow..checkName..color.Error.." not found.\n", false)
		Players[userPid].data.customVariables.modMenuTarget = nil
	end
	
end

-- First check for PID:
local function playerIDOnline(pid, checkName)

    local valid = false

	if checkName ~= nil and type(tonumber(checkName)) ~= "number" then
		playerNameOnline(pid, checkName)
		return false
    elseif checkName == nil or type(tonumber(checkName)) ~= "number" then
		local message = "Please specify the player ID or name.\n"
		tes3mp.SendMessage(pid, message, false)
		return false
    end

    checkName = tonumber(checkName)

    if checkName >= 0 and Players[checkName] ~= nil and Players[checkName]:IsLoggedIn() then
        valid = true
    end

    if not valid then
		local message = "That player is not logged in!\n"
		tes3mp.SendMessage(pid, message, false)
		Players[pid].data.customVariables.modMenuTarget = nil
	else
	  Players[pid].data.customVariables.modMenuTarget = checkName
    end
	
    return valid
end

-- FUNCTIONS
-- KILL Player Function
local function funcKILL(pid, target)
	
	local userName = logicHandler.GetChatName(pid)
	local targetName = logicHandler.GetChatName(target)
	
	if tes3mp.GetHealthCurrent(target) > 0 then
		tes3mp.SetHealthCurrent(target, 0) 
		tes3mp.SendStatsDynamic(target) 
		
		local modMessage = config.MsgBoxColor .. "You used "..color.Red.."Deathtouch "..config.MsgBoxColor.."on " .. color.Yellow .. logicHandler.GetChatName(target) .. config.MsgBoxColor.. "\n"
		--local targetMessage = color.Yellow .. userName .. config.MsgBoxColor .. " used "..color.Red.."Deathtouch "..config.MsgBoxColor.."on you.\n"
		tes3mp.SendMessage(pid, modMessage, false)
		--tes3mp.SendMessage(target, targetMessage, false)
	else
		local modMessage = color.Yellow .. logicHandler.GetChatName(target) .. config.MsgBoxColor.. " is already dead.\n"
		tes3mp.SendMessage(pid, modMessage, false)
	end
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" used KILL on \"" .. targetName .. "\".")

end

-- HEAL Player Function
local function funcHEAL(pid, target)
	
	local userName = logicHandler.GetChatName(pid)
	local targetName = logicHandler.GetChatName(target)
	
	if tes3mp.GetHealthCurrent(target) < tes3mp.GetHealthBase(target) then
		tes3mp.SetHealthCurrent(target, tes3mp.GetHealthBase(target)) 
		tes3mp.SendStatsDynamic(target)
		
		local modMessage = config.MsgBoxColor .. "You used "..color.Green.."Lifetouch "..config.MsgBoxColor.."on " .. color.Yellow .. logicHandler.GetChatName(target) .. config.MsgBoxColor.. ".\n"
		--local targetMessage = color.Yellow .. userName .. config.MsgBoxColor .. " used "..color.Green.."Lifetouch "..config.MsgBoxColor.."on you.\n"
		tes3mp.SendMessage(pid, modMessage, false)
		--tes3mp.SendMessage(target, targetMessage, false)
	else
		local modMessage = color.Yellow .. logicHandler.GetChatName(target) .. config.MsgBoxColor.. " has full health.\n"
		tes3mp.SendMessage(pid, modMessage, false)
	end
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" used HEAL on \"" .. targetName .. "\".")
	
end

-- Kick Player Function
local function funcKick(pid, target)
	
	local message

	if Players[target]:IsAdmin() then
		message = "You cannot kick an Admin from the server.\n"
		tes3mp.SendMessage(pid, message, false)
	elseif Players[target]:IsModerator() and not admin then
		message = "You cannot kick a Moderator from the server.\n"
		tes3mp.SendMessage(pid, message, false)
	else
		local userName = logicHandler.GetChatName(pid)
		local targetName = logicHandler.GetChatName(target)
		
		-- message = logicHandler.GetChatName(target) .. " was kicked from the server by " ..
		-- logicHandler.GetChatName(pid) .. ".\n"
		-- tes3mp.SendMessage(pid, message, true)
		Players[target]:Kick()
		
		message = color.Red .. "You have kicked " .. logicHandler.GetChatName(target) .. ".\n"
		tes3mp.SendMessage(pid, message, false)
		
		tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" kicked \"" .. targetName .. "\".")
	end

end		

-- Ban Player Function
local function funcBan(pid, target)
	
	local message
	
	if Players[target]:IsAdmin() then
		message = "You cannot ban an Admin from the server.\n"
		tes3mp.SendMessage(pid, message, false)
	elseif Players[target]:IsModerator() and not admin then
		message = "You cannot ban a Moderator from the server.\n"
		tes3mp.SendMessage(pid, message, false)
	else
		local userName = logicHandler.GetChatName(pid)
		local targetName = logicHandler.GetChatName(target)
	
		local targetName = Players[target].name
		logicHandler.BanPlayer(pid, targetName)
		
		message = color.Red .. "You have banned " .. logicHandler.GetChatName(target) .. ".\n"
		tes3mp.SendMessage(pid, message, false)
		
		tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" banned \"" .. targetName .. "\".")
	end

end		

-- Silence Player Function
local function funcSilence(pid, target)
	
	local userName = logicHandler.GetChatName(pid)
	local targetName = logicHandler.GetChatName(target)
	
	if Players[target].data.customVariables.mute == nil or Players[target].data.customVariables.mute == 0 then
		if pid == target then
            tes3mp.SendMessage(pid, "You can't mute yourself.\n")			
        elseif logicHandler.CheckPlayerValidity(pid, target) then
			if Players[target].data.settings.staffRank > 1 then
				tes3mp.SendMessage(pid, color.Red .. "You cannot mute admins.\n", false)
			else
				logicHandler.GetChatName(target)
				Players[target].data.customVariables.mute = 1			
				tes3mp.SendMessage(target, color.Red .. "You have been muted by a staff member.\n", false)
				
				message = color.Red .. "You have muted " .. logicHandler.GetChatName(target) .. ".\n"
				tes3mp.SendMessage(pid, message, false)
				
				tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" muted \"" .. targetName .. "\".")
			end
        end
	else
		if pid == target then
            tes3mp.SendMessage(pid, color.Red .. "You cannot unmute yourself.\n")			
        elseif logicHandler.CheckPlayerValidity(pid, target) then
			message = color.Green .. "You have been unmuted by a staff member.\n"
			logicHandler.GetChatName(target)
			Players[target].data.customVariables.mute = 0			
            tes3mp.SendMessage(target, message, false)
			tes3mp.SendMessage(pid, color.Green .. "You have unmuted " .. logicHandler.GetChatName(target) .. ".\n", false)
			tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" unmuted \"" .. targetName .. "\".")
        end	
	end

end

-- Freeze Player Function
local function funcFreeze(pid, target)
	
	local userName = logicHandler.GetChatName(pid)
	local targetName = logicHandler.GetChatName(target)
	
	if Players[target].data.customVariables.rootPlayer == nil or Players[target].data.customVariables.rootPlayer == 0 then
		if pid == target then
			tes3mp.SendMessage(pid, "You can't root yourself.\n")			
		elseif logicHandler.CheckPlayerValidity(pid, target) then
			message = color.Red .. "You have been rooted in place by a staff member.\n"
			Players[target].data.customVariables.rootPlayer = 1
			logicHandler.RunConsoleCommandOnPlayer(target, "disableplayercontrols")
			tes3mp.SendMessage(target, message, false)
			message = color.Red .. "You have rooted " .. targetName .. ".\n"
			tes3mp.SendMessage(pid, message, false)
			
			tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" rooted \"" .. targetName .. "\".")
		end
	else
		if pid == target then
			tes3mp.SendMessage(pid, "You can't unroot yourself.\n")			
		elseif logicHandler.CheckPlayerValidity(pid, target) then
			message = color.Red .. "You have been unrooted by a staff member.\n"
			Players[target].data.customVariables.rootPlayer = 0
			logicHandler.RunConsoleCommandOnPlayer(target, "enableplayercontrols")
			tes3mp.SendMessage(target, message, false)
			message = color.Red .. "You have unrooted " .. targetName .. ".\n"
			tes3mp.SendMessage(pid, message, false)
			
			tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" unrooted \"" .. targetName .. "\".")
		end	
	end

end

-- Summon Player Function
local function funcSummonPlayer(pid, target)
	
	if pid == target then
		tes3mp.SendMessage(pid, "You cannot summon yourself.\n")
	elseif logicHandler.CheckPlayerValidity(pid, target) then
		local userName = logicHandler.GetChatName(pid)
		local targetName = logicHandler.GetChatName(target)
	
		message = config.MsgBoxColor .. "You have been summoned by "..color.Yellow..userName..config.MsgBoxColor..".\n"
		tes3mp.SendMessage(target, message, false)
		logicHandler.TeleportToPlayer(pid, target, pid)
		message = config.MsgBoxColor .. "You have summoned "..color.Yellow..targetName..config.MsgBoxColor..".\n"
		tes3mp.SendMessage(pid, message, false)
		
		tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" summoned \"" .. targetName .. "\" to their location.")
	end
	
end

-- Mod Teleport Function
local function funcTeleportToPlayer(pid, target)
	local originPlayerName = Players[tonumber(pid)].name
    local targetPlayerName = Players[tonumber(target)].name
    local targetCell = ""
    local targetCellName
    local targetPos = {0, 0, 0}
    local targetRot = {0, 0}
    local targetGrid = {0, 0}
    targetPos[0] = tes3mp.GetPosX(target)
    targetPos[1] = tes3mp.GetPosY(target)
    targetPos[2] = tes3mp.GetPosZ(target)
    targetRot[0] = tes3mp.GetRotX(target)
    targetRot[1] = tes3mp.GetRotZ(target)
    targetCell = tes3mp.GetCell(target)

    tes3mp.SetCell(pid, targetCell)
    tes3mp.SendCell(pid)

    tes3mp.SetPos(pid, targetPos[0], targetPos[1], targetPos[2])
    tes3mp.SetRot(pid, targetRot[0], targetRot[1])
    tes3mp.SendPos(pid)
end


-- Goto Player Function
local function funcGotoPlayer(pid, target)
	
	if pid == target then
		tes3mp.SendMessage(pid, "You can't port to yourself.\n")
	elseif logicHandler.CheckPlayerValidity(pid, target) then
		local userName = logicHandler.GetChatName(pid)
		local targetName = logicHandler.GetChatName(target)
		local originPid = pid
		funcTeleportToPlayer(pid, target)
		message = config.MsgBoxColor .. "You have teleported to "..color.Yellow..targetName..config.MsgBoxColor..".\n"
		tes3mp.SendMessage(pid, message, false)
		
		tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" teleported to \"" .. targetName .. "\".")
	end
	
end

-- Buff PC Function
local function funcBuffPC(pid, target, number)
	local target = target
	
	local userName = logicHandler.GetChatName(pid)
	local targetName = logicHandler.GetChatName(target)
	
	logicHandler.RunConsoleCommandOnPlayer(target, "SetLevel "..data)
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" buffed \"" .. targetName .. "\" to level:"..data)
	
end

-- Give Item Function
local function funcGiveItem(pid, target, refId, count)
	
	if refId == nil then return end
	if count == nil then count = 1 end
	if soul == nil then soul = "" end
	if charge == nil then charge = -1 end
	if enchantmentCharge == nil then enchantmentCharge = -1 end
	
	if refId == "gold_005" or refId == "gold_010" or refId == "gold_025" or refId == "gold_100" then
		refId = "gold_001"
	end
	
	if logicHandler.IsGeneratedRecord(refId) then
		local cellDescription = tes3mp.GetCell(target)
        local cell = LoadedCells[cellDescription]
		local recordType = logicHandler.GetRecordTypeByRecordId(refId)
		if RecordStores[recordType] ~= nil then
			local recordStore = RecordStores[recordType]
			for _, visitorPid in pairs(cell.visitors) do
				recordStore:LoadGeneratedRecords(visitorPid, recordStore.data.generatedRecords, {refId})
			end
		end
	end
	
	tes3mp.ClearInventoryChanges(target)
	tes3mp.SetInventoryChangesAction(target, enumerations.inventory.ADD)
	tes3mp.AddItemChange(target, refId, count, charge, enchantmentCharge, soul)
	tes3mp.SendInventoryChanges(target)
	Players[target]:SaveInventory()
	
	local userName = logicHandler.GetChatName(pid)
	local targetName = logicHandler.GetChatName(target)	
	
	message = color.Yellow..targetName..config.MsgBoxColor.." has been given "
	message = message..color.Yellow..refId..config.MsgBoxColor.." x"..count..".\n"
	tes3mp.SendMessage(pid, message, false)
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" gave \"" .. targetName .. "\" " .. count .. " \""..refId.."\"")
		
end

-- Run Console Command Function
local function funcRunConsoleCommand(pid, target, command)
	
	local userName = logicHandler.GetChatName(pid)
	local targetName = logicHandler.GetChatName(target)
	
	message = color.Yellow..userName..config.MsgBoxColor.." forced "
	message = message .. color.Yellow..targetName.. config.MsgBoxColor .." to run:\n"
	message = message..color.Yellow..command..".\n"
	logicHandler.RunConsoleCommandOnPlayer(target, command)
	tes3mp.SendMessage(pid, message, false)
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" forced \"" .. targetName .. "\" to run console command:"..command)
end

-- Run Console Command Function for Everyone
local function funcRunConsoleCommandForEveryone(pid, command)
	
	local originPid = pid
	local listOfPlayers = ""
	local userName = logicHandler.GetChatName(pid)
	
	local notify = color.Yellow..userName..config.MsgBoxColor.." forced console command: ["
	notify = notify..color.Yellow..command..config.MsgBoxColor.."] to run for players: "
	
	for pid, player in pairs(Players) do
		local targetName = logicHandler.GetChatName(pid)
		listOfPlayers = listOfPlayers..config.MsgBoxColor.."["..color.Yellow..targetName..config.MsgBoxColor.."], "
		
		logicHandler.RunConsoleCommandOnPlayer(pid, command)
		
	end
	notify = notify..listOfPlayers.."\n"
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" forced \"" .. listOfPlayers .. "\" to run console command:"..command)
	
	tes3mp.SendMessage(originPid, notify, false)
end


-- Safe Mode Function
local function funcSafeMode(pid, target)
	
	local userName = logicHandler.GetChatName(pid)
	local targetName = logicHandler.GetChatName(target)
	
	local notification = config.MsgBoxColor.."You have "
	if Players[target].data.customVariables.safeMode == nil or Players[target].data.customVariables.safeMode == false then
		notification = notification .. color.Green .. "enabled"
		Players[target].data.customVariables.safeMode = true
	else
		notification = notification .. color.Red .. "disabled"
		Players[target].data.customVariables.safeMode = nil
	end
	
	notification = notification..config.MsgBoxColor.." Safe Mode.\n"
	tes3mp.SendMessage(target, notification, false)
	logicHandler.RunConsoleCommandOnPlayer(target, "tgm")
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" enabled Safe Mode for \"" .. targetName .. "\".")
end

-- Change Sprite
local function funcChangeSprite(pid, data)
	
	local userName = logicHandler.GetChatName(pid)
	
	local targetPid = pid
	local creatureRefId = data

	Players[targetPid].data.shapeshift.creatureRefId = creatureRefId
	tes3mp.SetCreatureRefId(targetPid, creatureRefId)
	tes3mp.SendShapeshift(targetPid)

	if creatureRefId == "" or creatureRefId == " " then
		creatureRefId = "nothing"
	end

	tes3mp.SendMessage(pid, Players[targetPid].accountName .. " is now disguised as " ..
		creatureRefId .. "\n", false)
	if targetPid ~= pid then
		tes3mp.SendMessage(targetPid, "You are now disguised as " .. creatureRefId .. "\n", false)
	end
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" changed their sprite to \"" .. data .. "\".")
	
end

-- Revert Sprite
local function funcRevertSprite(pid)
	
	local userName = logicHandler.GetChatName(pid)
	
	local targetPid = pid
	local creatureRefId = ""

	Players[targetPid].data.shapeshift.creatureRefId = creatureRefId
	tes3mp.SetCreatureRefId(targetPid, creatureRefId)
	tes3mp.SendShapeshift(targetPid)

	tes3mp.SendMessage(pid, Players[targetPid].accountName .. " is no longer disguised as anything.\n", false)
	if targetPid ~= pid then
		tes3mp.SendMessage(targetPid, "You are no longer disguised as anything.\n", false)
	end
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" reverted their sprite to normal.")

end

-- Toggle Invis
local function funcToggleInvis(pid)

	local userName = logicHandler.GetChatName(pid)
	
	local notification = config.MsgBoxColor.."You are now "
	if Players[pid].data.customVariables.adminInvis == nil or Players[pid].data.customVariables.adminInvis == false then
		notification = notification .. color.Grey .. "invisible"
		Players[pid].data.customVariables.adminInvis = true
		tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" toggled Invis on.")
		Players[pid]:SetScale(0.001)
        Players[pid]:LoadShapeshift()
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->setflying 1")
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell \"fly_speed\"")
	else
		notification = notification .. color.White .. "visible"
		Players[pid].data.customVariables.adminInvis = nil
		tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" toggled Invis off.")
		Players[pid]:SetScale(1)
        Players[pid]:LoadShapeshift()
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->setflying 0")
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell \"fly_speed\"")
	end
	
	notification = notification..config.MsgBoxColor.." to all players.\n"
	tes3mp.SendMessage(pid, notification, false)
	--logicHandler.RunConsoleCommandOnPlayer(pid, "tcl")

end



-- Lack Access to Function Message
local function funcLackAccess(pid)
	local userName = logicHandler.GetChatName(pid)
	
	local message = config.MsgBoxColor.."You do not have access to this function.\n"
	tes3mp.SendMessage(pid, message, false)
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" attempted to access an invalid function.")
end

-- Post Server Version
local function callServerVersion(pid)
	
	local userName = logicHandler.GetChatName(pid)
	
	local scriptName = "Moderator Action Menu"
	local revision = "1.00"

	local serverVersion = config.MsgBoxColor .. scriptName.." v."..revision.."\n"
	
	tes3mp.SendMessage(pid, serverVersion, false)
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" requested Moderator Action Menu Version Info.")
	
end

-- COC to Cell Name
local function funcGotoZone(pid, data)

	if data == nil then
		return
	else
		local userName = logicHandler.GetChatName(pid)
		
		logicHandler.RunConsoleCommandOnPlayer(pid, "coc \"" .. data.."\"")
		
		tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" Goto Zone \""..data.."\".")
	end

end

-- Where Is Player
local function funcWhereIsPlayer(pid, target)
	
	local userName = logicHandler.GetChatName(pid)
	local targetName = logicHandler.GetChatName(target)
	
	local pCell = Players[target].data.location.cell
	local pRegion = Players[target].data.location.regionName
	local pX = Players[target].data.location.posX
	local pY = Players[target].data.location.posY
	local pZ = Players[target].data.location.posZ
	local rX = Players[target].data.location.rotX
	local rZ = Players[target].data.location.rotZ
	
	logicHandler.TeleportToPlayer(pid, pid, target)
	local msgLoc = config.MsgBoxColor.."Where is: "..color.Yellow..logicHandler.GetChatName(target)..config.MsgBoxColor.."\nCell: "..color.Yellow..pCell
	msgLoc = msgLoc..config.MsgBoxColor.."\nRegion: "..color.Yellow..pRegion..config.MsgBoxColor.."\nX: "..color.Yellow..pX
	msgLoc = msgLoc..config.MsgBoxColor.."\nY: "..color.Yellow..pY..config.MsgBoxColor.."\nZ: "..color.Yellow..pZ
	msgLoc = msgLoc..config.MsgBoxColor.."\nrX: "..color.Yellow..rX..config.MsgBoxColor.."\nrZ: "..color.Yellow..rZ.."\n"
	tes3mp.SendMessage(pid, msgLoc, false)
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" used Where Is Player on \"" .. targetName .. "\".")
end

-- Who Is Player
local function funcWhoIsPlayer(pid, target)
	
	local userName = logicHandler.GetChatName(pid)
	local targetName = logicHandler.GetChatName(target)
	
	local whoMsg
	
	local adminRank = "Player"
	
	if Players[target].data.settings.staffRank == 3 then
		adminRank = "Server Owner"
	elseif Players[target].data.settings.staffRank == 2 then
		adminRank = "Admin"
	elseif Players[target].data.settings.staffRank == 1 then
		adminRank = "Moderator"
	end
	
	whoMsg = color.Yellow..logicHandler.GetChatName(target)..config.MsgBoxColor.." ("..color.Yellow..target..config.MsgBoxColor.."): "..adminRank.."\n"
	
	
	-- If making use of the playTime script, check their playtime:
	if Players[target].data.customVariables.playTime ~= nil then
		local playerPlayTime = Players[target].data.customVariables.playTime
		local playHours
		
		if playerPlayTime >= 3600 then
			playHours = playerPlayTime / 60
			playHours = playHours / 60
			playHours = math.floor(playHours)
			if playHours > 1 then
				playHours = color.Yellow .. playHours .. config.MsgBoxColor.. " hours"
			else
				playHours = color.Yellow .. playHours .. config.MsgBoxColor.. " hour"
			end
		else
			playHours = "less than 1 hour"
		end
		
		whoMsg = whoMsg .. config.MsgBoxColor.."Playtime: "..color.Yellow..playerPlayTime..config.MsgBoxColor.." ("..playHours..")\n"
	end
	
	tes3mp.SendMessage(pid, whoMsg, false)
	
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" used Who Is Player on \"" .. targetName .. "\".")
	
end



-- Run Speed
local function funcRunSpeed(pid)

	local userName = logicHandler.GetChatName(pid)
	
	local notification = config.MsgBoxColor.."Run Speed "
	if Players[pid].data.customVariables.adminSpeed == nil or Players[pid].data.customVariables.adminSpeed == false then
		notification = notification .. color.Green .. "increased"
		tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" toggled Super Speed on.")
		
		Players[pid].data.customVariables.adminSpeed = true
		
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell \"super_speed\"")
	else
		notification = notification .. color.Grey .. "normal"
		tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" toggled Super Speed off.")
		
		Players[pid].data.customVariables.adminSpeed = nil
		
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell \"super_speed\"")
	end
	
	notification = notification..config.MsgBoxColor..".\n"
	tes3mp.SendMessage(pid, notification, false)

end

-- Visually Toggle Cell Borders
local function funcToggleBorders(pid)
	
	local userName = logicHandler.GetChatName(pid)
	
	local target = pid
	local notification = config.MsgBoxColor.."You have "
	if Players[target].data.customVariables.displayBorders == nil or Players[target].data.customVariables.displayBorders == false then
		notification = notification .. color.Green .. "enabled"
		Players[target].data.customVariables.displayBorders = true
	else
		notification = notification .. color.Red .. "disabled"
		Players[target].data.customVariables.displayBorders = nil
	end
	
	notification = notification..config.MsgBoxColor.." Border Display.\n"
	tes3mp.SendMessage(target, notification, false)
	logicHandler.RunConsoleCommandOnPlayer(target, "tb")
	
	tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" Toggled Borders.")
	
end

--------------------------------------------------


-- Input Dialogue Menus:
-- Enter Player Name
modEnterPlayerName = function(pid)
	tes3mp.InputDialog(pid, config.moderatorActionMenuCheckPlayerNameGUI, config.MsgBoxColor.."Enter player name or PID:", "Enter \" \" (One space) to cancel.")
end

-- Enter Item refId
modEnterItemRefID = function(pid)
	tes3mp.InputDialog(pid, config.moderatorActionMenuItemRefIdGUI, config.MsgBoxColor.."Enter item refID:", "Enter \" \" (One space) to cancel.")
end

-- Enter Count
modEnterItemCount = function(pid)
	tes3mp.InputDialog(pid, config.moderatorActionMenuItemCountGUI, config.MsgBoxColor.."Enter a number:", "Enter \" \" (One space) to cancel.")
end

-- Enter Level Number
modEnterLevelNumber = function(pid)
	tes3mp.InputDialog(pid, config.moderatorActionMenuLevelNumberGUI, config.MsgBoxColor.."Enter a level number:", "Enter \" \" (One space) to cancel.")
end

-- Enter Goto Zone
modEnterGotoZone = function(pid)
	tes3mp.InputDialog(pid, config.moderatorActionMenuGotoZoneGUI, config.MsgBoxColor.."Enter Zone: (location name)", "Enter \" \" (One space) to cancel.")
end

-- Enter Goto Location Coordinates Cell
modEnterGotoLocationCell = function(pid)
	tes3mp.InputDialog(pid, config.moderatorActionMenuGotoLocationCellGUI, config.MsgBoxColor.."Enter Location: (cell name)", "Enter \" \" (One space) to cancel.")
end

-- Enter Goto Location Coordinates X Y Z
modEnterGotoLocationXYZ = function(pid)
	tes3mp.InputDialog(pid, config.moderatorActionMenuGotoLocationXYZGUI, config.MsgBoxColor.."Enter Location: (X, Y, Z)", "Enter \" \" (One space) to cancel.")
end

-- Broadcast
modBroadcast = function(pid)
	tes3mp.InputDialog(pid, config.moderatorBroadcastGUI, config.MsgBoxColor.."Enter a message to broadcast:", "Enter \" \" (One space) to cancel.")
end

-- Change Sprite
modEnterCreatureRefID = function(pid)
	tes3mp.InputDialog(pid, config.moderatorActionMenuCreatureRefIdGUI, config.MsgBoxColor.."Enter creature refID:", "Enter \" \" (One space) to cancel.")
end

-- Enter Exact Console Command
modEnterConsoleCommand = function(pid)
	tes3mp.InputDialog(pid, config.moderatorActionMenuConsoleCommandGUI, config.MsgBoxColor.."Enter exact console command:", "Enter \" \" (One space) to cancel.")
end

-- Enter Exact Console Command For Everyone
modEnterConsoleCommandForEveryone = function(pid)
	tes3mp.InputDialog(pid, config.moderatorActionMenuConsoleCommandEveryoneGUI, config.MsgBoxColor.."Enter exact console command for Everyone:", "Enter \" \" (One space) to cancel.")
end


--------------------------------------------------



-- Main Mod Menu
modMenuOrigin = function(pid)
	
	local message = color.Orange.."MODERATOR ACTION MENU\n\n"..config.MsgBoxColor.."\n"
	tes3mp.CustomMessageBox(pid, config.moderatorActionMenuOriginGUI, message, "Avatar;Navigation;Programming;Version;Exit")
	
end

-- Avatar
modMenuAvatar = function(pid)
	
	local message = color.Orange.."MODERATOR ACTION MENU\n\n"..config.MsgBoxColor.."Select an Avatar option:\n"
	tes3mp.CustomMessageBox(pid, config.moderatorActionMenuAvatarGUI, message, "Target Action;Target Info;Self;Broadcast;Render;Back;Exit")
	
end

-- Target Action
modMenuTargetAction = function(pid)
	
	local message = color.Orange.."MODERATOR ACTION MENU\n\n"..config.MsgBoxColor.."Commands to use on a specific target:\n"
	tes3mp.CustomMessageBox(pid, config.moderatorActionMenuTargetActionGUI, message, "KILL;HEAL;Kick;Ban;Silence;Freeze;Summon Player;Buff PC;Give Item;Run Console Command;Back;Exit")
	
end

-- Target Info
modMenuTargetInfo = function(pid)
	
	local message = color.Orange.."MODERATOR ACTION MENU\n\n"..config.MsgBoxColor.."Commands to see specific target info:\n"
	tes3mp.CustomMessageBox(pid, config.moderatorActionMenuTargetInfoGUI, message, "Where Is Player;Who Is Player;Back;Exit")
	
end

-- Render
modMenuRender = function(pid)
	
	local message = color.Orange.."MODERATOR ACTION MENU\n\n"..config.MsgBoxColor.."Commands to use on self:\n"
	tes3mp.CustomMessageBox(pid, config.moderatorActionMenuRenderGUI, message, "Toggle Borders;Back;Exit")
	
end

-- Self
modMenuSelf = function(pid)
	
	local message = color.Orange.."MODERATOR ACTION MENU\n\n"..config.MsgBoxColor.."Render Commands to use on self:\n"
	tes3mp.CustomMessageBox(pid, config.moderatorActionMenuSelfGUI, message, "KILL;HEAL;Safe Mode;Toggle Invis;Summon Item;Change Sprite;Revert Sprite;DISPLAY POS;Back;Exit")
	
end

-- Navigation Menu
modMenuNavigation = function(pid)
	
	local message = color.Orange.."MODERATOR ACTION MENU\n\n"..config.MsgBoxColor.."Select a Navigation option:\n"
	tes3mp.CustomMessageBox(pid, config.moderatorActionMenuNavigationGUI, message, "Goto Zone;Goto Location;Goto Player;RUN SPEED;Back;Exit")
	
end


-- Programming Menu
modMenuProgramming = function(pid)
	
	local message = color.Orange.."MODERATOR ACTION MENU\n\n"..config.MsgBoxColor.."Select a Programming option:\n"
	tes3mp.CustomMessageBox(pid, config.moderatorActionMenuProgrammingGUI, message, "Clear Kill List;Run Console Command For All;Back;Exit")
	
end
--------------------------------------------------

--GUI Calls
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	
	if idGui == config.moderatorActionMenuOriginGUI then
	
		if Players[pid].data.settings.staffRank > 0 then
			if tonumber(data) == 0 then -- Avatar
				modMenuAvatar(pid)
			elseif tonumber(data) == 1 then -- Navigation
				modMenuNavigation(pid)
			elseif tonumber(data) == 2 then -- Programming
				modMenuProgramming(pid)
			elseif tonumber(data) == 3 then
				callServerVersion(pid) -- Version Set in config
				modMenuOrigin(pid)
			elseif tonumber(data) == 4 then -- exit
				return
			end
		else
			return
		end
	
	--AVATAR
	elseif idGui == config.moderatorActionMenuAvatarGUI then	
	
		if Players[pid].data.settings.staffRank > 0 then
			if tonumber(data) == 0 then -- Target Action
				modMenuTargetAction(pid)
			elseif tonumber(data) == 1 then -- Target Info
				modMenuTargetInfo(pid)
			elseif tonumber(data) == 2 then -- Self
				modMenuSelf(pid)
			elseif tonumber(data) == 3 then -- Broadcast
				modBroadcast(pid)				
			elseif tonumber(data) == 4 then -- Render
				modMenuRender(pid)
			elseif tonumber(data) == 5 then -- Back
				modMenuOrigin(pid)
			elseif tonumber(data) == 6 then -- Exit
				return
			end
		else
			return
		end
	
	-- Target Action
	elseif idGui == config.moderatorActionMenuTargetActionGUI then
		
		if Players[pid].data.settings.staffRank > 0 then
			if tonumber(data) == 0 then -- KILL
				Players[pid].data.customVariables.modMenuLoc = "KILL"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 1 then -- HEAL
				Players[pid].data.customVariables.modMenuLoc = "HEAL"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 2 then -- Kick
				Players[pid].data.customVariables.modMenuLoc = "Kick"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 3 then -- Ban
				Players[pid].data.customVariables.modMenuLoc = "Ban"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 4 then -- Silence
				if Players[pid].data.settings.staffRank < config.MuteRank then
					funcLackAccess(pid)
					return
				end
				Players[pid].data.customVariables.modMenuLoc = "Silence"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 5 then -- Freeze
				if Players[pid].data.settings.staffRank < config.RootRank then
					funcLackAccess(pid)
					return
				end
				Players[pid].data.customVariables.modMenuLoc = "Freeze"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 6 then -- Summon Player
				Players[pid].data.customVariables.modMenuLoc = "Summon Player"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 7 then -- Buff PC
				if Players[pid].data.settings.staffRank < config.BuffPC then
					funcLackAccess(pid)
					return
				end
				Players[pid].data.customVariables.modMenuLoc = "Buff PC"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 8 then -- Give Item
				if Players[pid].data.settings.staffRank < config.GiveItemRank then
					funcLackAccess(pid)
					return
				end
				Players[pid].data.customVariables.modMenuLoc = "Give Item"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 9 then -- Run Console Command
				if Players[pid].data.settings.staffRank < config.RunConsoleCommand then
					funcLackAccess(pid)
					return
				end
				Players[pid].data.customVariables.modMenuLoc = "Run Console Command"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 10 then -- Back
				Players[pid].data.customVariables.modMenuLoc = "Avatar"
				modMenuAvatar(pid)
			elseif tonumber(data) == 11 then -- Exit
				Players[pid].data.customVariables.modMenuLoc = nil
				return
			end
		else
			return
		end
		
	elseif idGui == config.moderatorActionMenuCheckPlayerNameGUI then
		
		if data == nil or data == "" or data == " " then
			return
		else
			local checkName = data
			playerIDOnline(pid, checkName)
			
			if Players[pid].data.customVariables.modMenuLoc ~= nil and Players[pid].data.customVariables.modMenuTarget ~= nil then 
				local target = Players[pid].data.customVariables.modMenuTarget
				
				if Players[pid].data.customVariables.modMenuLoc == "KILL" then -- 
					funcKILL(pid, target) -- KILL Player
				elseif Players[pid].data.customVariables.modMenuLoc == "HEAL" then -- 
					funcHEAL(pid, target) -- HEAL Player
				elseif Players[pid].data.customVariables.modMenuLoc == "Kick" then -- 
					funcKick(pid, target) -- Kick Player
				elseif Players[pid].data.customVariables.modMenuLoc == "Ban" then -- 
					funcBan(pid, target) -- Kick Player
				elseif Players[pid].data.customVariables.modMenuLoc == "Silence" then -- 
					funcSilence(pid, target) -- Silence Player
				elseif Players[pid].data.customVariables.modMenuLoc == "Freeze" then -- 
					funcFreeze(pid, target) -- Freeze Player
				elseif Players[pid].data.customVariables.modMenuLoc == "Summon Player" then -- 
					funcSummonPlayer(pid, target) -- Summon Player
				elseif Players[pid].data.customVariables.modMenuLoc == "Goto Player" then -- 
					funcGotoPlayer(pid, target) -- Goto Player
				elseif Players[pid].data.customVariables.modMenuLoc == "Change Name" then -- 
					funcLackAccess(pid)
				elseif Players[pid].data.customVariables.modMenuLoc == "Buff PC" then -- 
					modEnterLevelNumber(pid)
				elseif Players[pid].data.customVariables.modMenuLoc == "Give Item" then -- 
					Players[pid].data.customVariables.modMenuRefId = nil
					modEnterItemRefID(pid)
					
				elseif Players[pid].data.customVariables.modMenuLoc == "Run Console Command" then -- 
					modEnterConsoleCommand(pid)
				elseif Players[pid].data.customVariables.modMenuLoc == "Run Console Command for Everyone" then -- 
					modEnterConsoleCommandForEveryone(pid)
					
				elseif Players[pid].data.customVariables.modMenuLoc == "Avatar" then -- 
					modMenuAvatar(pid)
					
				elseif Players[pid].data.customVariables.modMenuLoc == "Where Is Player" then
					funcWhereIsPlayer(pid, target)
				elseif Players[pid].data.customVariables.modMenuLoc == "Who Is Player" then
					funcWhoIsPlayer(pid, target)
				
					
				elseif Players[pid].data.customVariables.modMenuLoc == "" then -- Exit
					return
				end
			end
		end
	
	-- Item RefId Input Data
	elseif idGui == config.moderatorActionMenuItemRefIdGUI then
	
		if data == nil or data == "" or data == " " then
			return
		else
			Players[pid].data.customVariables.modMenuRefId = tostring(data)
			modEnterItemCount(pid)
		end
			
	-- Item Count Input Data
	elseif idGui == config.moderatorActionMenuItemCountGUI then
		
		if data == nil or data == "" or data == " " then
			return
		else
			if type(tonumber(data)) ~= "number" then
				local message = color.Yellow..data..config.MsgBoxColor.." is not a number.\n"
				tes3mp.SendMessage(pid, message, false)
				return
			end
			
			local target = Players[pid].data.customVariables.modMenuTarget
			local refId = Players[pid].data.customVariables.modMenuRefId
			local count = data
			funcGiveItem(pid, target, refId, count)
		end
	
	-- Level Number Input Data
	elseif idGui == config.moderatorActionMenuLevelNumberGUI then
		
		if data == nil or data == "" or data == " " then
			return
		else
			if type(tonumber(data)) ~= "number" then
				local message = color.Yellow..data..config.MsgBoxColor.." is not a number.\n"
				tes3mp.SendMessage(pid, message, false)
				return
			end
			
			local target = Players[pid].data.customVariables.modMenuTarget
			local number = data
			funcBuffPC(pid, target, number)
		end
	
	-- Console Command Input Data
	elseif idGui == config.moderatorActionMenuConsoleCommandGUI then
	
		if data == nil or data == "" or data == " " then
			return
		else
			local target = Players[pid].data.customVariables.modMenuTarget
			local command = data
			funcRunConsoleCommand(pid, target, command)
		end
	
	
	elseif idGui == config.moderatorActionMenuConsoleCommandEveryoneGUI then
	
		if data == nil or data == "" or data == " " then
			return
		else
			local target = Players[pid].data.customVariables.modMenuTarget
			local command = data
			funcRunConsoleCommandForEveryone(pid, command)
		end
	
	-- Target Info
	elseif idGui == config.moderatorActionMenuTargetInfoGUI then
		
		if Players[pid].data.settings.staffRank > 0 then
			if tonumber(data) == 0 then -- Where Is Player
				Players[pid].data.customVariables.modMenuLoc = "Where Is Player"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 1 then -- Who Is Player
				--funcLackAccess(pid)
				Players[pid].data.customVariables.modMenuLoc = "Who Is Player"
				modEnterPlayerName(pid)
			elseif tonumber(data) == 2 then -- Back
				modMenuAvatar(pid) -- Back to Avatar Menu
			elseif tonumber(data) == 3 then -- Exit
				return
			end
		else
			return
		end
	
	-- Self
	elseif idGui == config.moderatorActionMenuSelfGUI then
		
		if Players[pid].data.settings.staffRank > 0 then
			if tonumber(data) == 0 then -- KILL
				local target = pid
				funcKILL(pid, target)
			elseif tonumber(data) == 1 then -- HEAL
				local target = pid
				funcHEAL(pid, target)
			elseif tonumber(data) == 2 then -- Safe Mode
				local target = pid
				funcSafeMode(pid, target)
			elseif tonumber(data) == 3 then -- Toggle Invis
				if Players[pid].data.settings.staffRank < config.InvisRank then
					funcLackAccess(pid)
					return
				end
				funcToggleInvis(pid)
			elseif tonumber(data) == 4 then -- Summon Item
				if Players[pid].data.settings.staffRank < config.SummonItemRank then
					funcLackAccess(pid)
					return
				end
				local target = pid
				Players[pid].data.customVariables.modMenuTarget = target
				modEnterItemRefID(pid)
			elseif tonumber(data) == 5 then -- Change Sprite
				modEnterCreatureRefID(pid)
			elseif tonumber(data) == 6 then -- Revert Sprite
				funcRevertSprite(pid)
			elseif tonumber(data) == 7 then -- Display where player is
				local target = pid
				funcWhereIsPlayer(pid, target)
			elseif tonumber(data) == 9 then -- Back
				modMenuAvatar(pid)
			elseif tonumber(data) == 10 then -- Exit
				Players[pid].data.customVariables.modMenuLoc = nil
				return
			end
		else
			return
		end
	
	-- Creature Ref ID Input Data
	elseif idGui == config.moderatorActionMenuCreatureRefIdGUI then
		
		if data == nil or data == "" or data == " " then
			return
		else
			funcChangeSprite(pid, data)
		end
		
	-- Navigation
	elseif idGui == config.moderatorActionMenuNavigationGUI then
		
		if Players[pid].data.settings.staffRank > 0 then
			if tonumber(data) == 0 then -- Goto Zone
				Players[pid].data.customVariables.modMenuLoc = "Goto Zone"
				modEnterGotoZone(pid) 
			elseif tonumber(data) == 1 then -- Goto Location
				modMenuNavigation(pid)
				--modEnterGotoLocationCell(pid) -- Enter Location (Cell X Y Z)
			elseif tonumber(data) == 2 then -- Goto Player
				Players[pid].data.customVariables.modMenuLoc = "Goto Player"
				modEnterPlayerName(pid) 
			elseif tonumber(data) == 3 then -- RUN SPEED
				funcRunSpeed(pid)
			elseif tonumber(data) == 4 then -- Back
				modMenuOrigin(pid)
			elseif tonumber(data) == 5 then -- exit
				--clearAllPlayerVariables(pid)
				return
			end
		else
			return
		end
	
	-- Goto Zone
	elseif idGui == config.moderatorActionMenuGotoZoneGUI then
		
		if data == nil or data == "" or data == " " then
			return
		else
			if Players[pid].data.settings.staffRank >= config.GoToLocationRank then
				if type(tonumber(data)) == "number" then
					local message = color.Yellow..data..config.MsgBoxColor.." is not a cell.\n"
					tes3mp.SendMessage(pid, message, false)
					return
				end
				
				funcGotoZone(pid, data) -- Goto Zone / COC Cell Name
				--Players[pid].data.customVariables.modMenuCell = tostring(data)
				--modEnterGotoLocationXYZ(pid)
			else
				funcLackAccess(pid)
			end
		end
	
	-- Goto Location Cell
	elseif idGui == config.moderatorActionMenuGotoLocationCellGUI then
	
		if data == nil or data == "" or data == " " then
			return
		else
			if Players[pid].data.settings.staffRank >= config.GoToLocationRank then
				if type(tonumber(data)) == "number" then
					local message = color.Yellow..data..config.MsgBoxColor.." is not a cell.\n"
					tes3mp.SendMessage(pid, message, false)
					return
				end
				
				Players[pid].data.customVariables.modMenuCell = tostring(data)
				modEnterGotoLocationXYZ(pid)
			else
				funcLackAccess(pid)
			end
		end
			
	-- Goto Location X Y Z
	elseif idGui == config.moderatorActionMenuGotoLocationXYZGUI then
	
		if data == nil or data == "" or data == " " then
			return
		else
			-- if type(tonumber(data)) ~= "number" then
				-- local message = color.Yellow..data..config.MsgBoxColor.." is not a number.\n"
				-- tes3mp.SendMessage(pid, message, false)
				-- return
			-- end
			if Players[pid].data.settings.staffRank >= config.GoToLocationRank then
				local tCell = Players[pid].data.customVariables.modMenuCell
				Players[pid].data.customVariables.modMenuCell = nil
				
				local tPos = tonumber(data)
				
				local trotX = tes3mp.GetRotX(pid) 
				local trotZ = tes3mp.GetRotZ(pid)
				
				tes3mp.SetCell(pid, tCell)
				tes3mp.SendCell(pid)
				tes3mp.SetPos(pid, tpos)
				tes3mp.SetRot(pid, trotX, trotZ)
				tes3mp.SendPos(pid)
			else
				funcLackAccess(pid)
			end
			
		end
		
	
	-- Broadcast
	elseif idGui == config.moderatorBroadcastGUI then
		
		if data == nil or data == "" or data == " " then
			return
		else
			local message = config.MsgBoxColor..data.."\n"
			tes3mp.SendMessage(pid, message, true)
			return
		end
	
	-- Render
	elseif idGui == config.moderatorActionMenuRenderGUI then
		
		if Players[pid].data.settings.staffRank > 0 then
			if tonumber(data) == 0 then -- Toggle Borders
				if Players[pid].data.settings.staffRank < config.ToggleBorder  then
					funcLackAccess(pid)
				else
					funcToggleBorders(pid)
					modMenuRender(pid)
				end
			elseif tonumber(data) == 1 then -- Back
				modMenuAvatar(pid)
			elseif tonumber(data) == 2 then -- Exit
				--clearAllPlayerVariables(pid)
				return
			end
		else
			return
		end
	
	
	-- Programming
	elseif idGui == config.moderatorActionMenuProgrammingGUI then
		--"Clear Kill List;Clear Loot List;Back;Exit")
		if Players[pid].data.settings.staffRank > 0 then
			if tonumber(data) == 0 then -- Clear Kill List
				if Players[pid].data.settings.staffRank < config.ResetKillCount  then
					funcLackAccess(pid)
				else
					-- Set all currently recorded kills to 0 for connected players
					for refId, killCount in pairs(WorldInstance.data.kills) do
						WorldInstance.data.kills[refId] = 0
					end

					WorldInstance:QuicksaveToDisk()
					WorldInstance:LoadKills(pid, true)
					tes3mp.SendMessage(pid, "All the kill counts for creatures and NPCs have been reset.\n", true)
				end
				modMenuProgramming(pid)
			elseif tonumber(data) == 1 then -- Force Console Command for All
				if Players[pid].data.settings.staffRank < config.ForceConsoleCommandAll  then
					funcLackAccess(pid)
				else
					modEnterConsoleCommandForEveryone(pid)
				end
				--modMenuProgramming(pid)				
			elseif tonumber(data) == 2 then -- Back
				modMenuOrigin(pid)
			elseif tonumber(data) == 3 then -- exit
				--clearAllPlayerVariables(pid)
				return
			end
		else
			return
		end
	
	
	end
	
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)

	Players[pid].data.customVariables.safeMode = nil
	Players[pid].data.customVariables.displayBorders = nil


	local userName = logicHandler.GetChatName(pid)
	
	if Players[pid].data.customVariables.adminInvis ~= nil then
		Players[pid].data.customVariables.adminInvis = nil
		tes3mp.LogMessage(enumerations.log.INFO, "[ModAction]: \"".. userName .. "\" toggled Invis off.")
		Players[pid]:SetScale(1)
        Players[pid]:LoadShapeshift()
		
		logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell \"fly_speed\"")
		
	end
	
	
end)



-- If a player is mute, prevent their message from appearing.
customEventHooks.registerValidator("OnPlayerSendMessage", function(eventStatus, pid, message)
	
	if Players[pid].data.customVariables.mute ~= nil and Players[pid].data.customVariables.mute >= 1 then
		tes3mp.SendMessage(pid, color.Red .. "You have been muted by a staff member.\n", false)
		return customEventHooks.makeEventStatus(false, false)
	else
		eventStatus.validDefaultHandler = true
		return eventStatus
	end
	
end)


--------------------------------------------------


-- /modmenu
customCommandHooks.registerCommand("modmenu", function(pid, cmd)
	if Players[pid].data.settings.staffRank >= config.ModMenuRank then
		Players[pid].data.customVariables.modMenuLoc = nil
		modMenuOrigin(pid)
	end
end)

-- /mm
customCommandHooks.registerCommand("mm", function(pid, cmd)
	if Players[pid].data.settings.staffRank >= config.ModMenuRank then
		Players[pid].data.customVariables.modMenuLoc = nil
		modMenuOrigin(pid)
	end
end)

-- /invis
customCommandHooks.registerCommand("invis", function(pid, cmd)
	if Players[pid].data.settings.staffRank >= config.InvisRank then
		funcToggleInvis(pid)
	end
end)

-- /safemode
customCommandHooks.registerCommand("safemode", function(pid, cmd)
	if Players[pid].data.settings.staffRank >= config.SafeMode then
		funcSafeMode(pid, pid)
	end
end)

-- /safe
customCommandHooks.registerCommand("safe", function(pid, cmd)
	if Players[pid].data.settings.staffRank >= config.SafeMode then
		funcSafeMode(pid, pid)
	end
end)

-- /runspeed
customCommandHooks.registerCommand("runspeed", function(pid, cmd)
	if Players[pid].data.settings.staffRank >= config.SuperRunRank then
		funcRunSpeed(pid)
	end
end)

-- /run
customCommandHooks.registerCommand("run", function(pid, cmd)
	if Players[pid].data.settings.staffRank >= config.SuperRunRank then
		funcRunSpeed(pid)
	end
end)

-- /goto PID
customCommandHooks.registerCommand("goto", function(pid, cmd)
	if Players[pid].data.settings.staffRank >= config.GoToRank then
		local target = tonumber(cmd[2])
		if target == nil then
			tes3mp.SendMessage(pid, color.Red .. "Input a PID to go to.\n")
		else
			funcGotoPlayer(pid, target)
        end
	end
end)

