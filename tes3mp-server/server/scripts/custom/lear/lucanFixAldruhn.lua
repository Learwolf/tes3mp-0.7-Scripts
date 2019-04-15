
--[[
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This script will prevent Lucan from continuosly spawning in Ald-ruhn during his quest line (mv_thieftrader).
If left uncheck, he can cause massive lag and spawn spamming in Ald-ruhn.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
DO NOT EDIT BEYOND THIS, UNLESS YOU KNOW WHAT YOU'RE DOING.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
]]

local Methods = {}


Methods.StopLucanOstoriusScript = function(pid)
	logicHandler.RunConsoleCommandOnPlayer(pid, "lucan_scriptholder-> setdelete 1")
	if Players[pid].data.customVariables.lear == nil then
		Players[pid].data.customVariables.lear = {}
	end
	if Players[pid].data.customVariables.lear.questFixes == nil then
		Players[pid].data.customVariables.lear.questFixes = {}
	end
	logicHandler.RunConsoleCommandOnPlayer(pid, "stopscript lucan_ostorius")
end

customEventHooks.registerHandler("OnPlayerFinishLogin", function(eventStatus, pid)
	tes3mp.LogMessage(enumerations.log.INFO, "Stopping lucan_ostorius script for " .. Players[pid].name)
	Methods.StopLucanOstoriusScript(pid)
end)

customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventStatus, pid)
	tes3mp.LogMessage(enumerations.log.INFO, "Stopping lucan_ostorius script for " .. Players[pid].name)
	Methods.StopLucanOstoriusScript(pid)
end)

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, previousCellDescription, currentCellDescription)
-- Delete Lucan respawn
	if currentCellDescription == "-2, 6" then
		if (tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_thieftrader", index = 20 }, true) or tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_thieftrader", index = 25 }, true)) and not tableHelper.containsKeyValuePairs(Players[pid].data.journal, { quest = "mv_thieftrader", index = 90 }, true) then
			if (Players[pid].data.customVariables.lear.questFixes.mv_thieftrader_spawn_timer == nil or os.time() >= Players[pid].data.customVariables.lear.questFixes.mv_thieftrader_spawn_timer) then
				logicHandler.RunConsoleCommandOnPlayer(pid, "startscript lucan_ostorius")
				local respawnTimer = 900
				respawnTimer = respawnTimer + os.time()
				Players[pid].data.customVariables.lear.questFixes.mv_thieftrader_spawn_timer = respawnTimer
			end
		end
	end
end)


return Methods