--[[
	Bed Respawn for TES3MP 0.7
		by Learwolf at the request of Liam
			version 1.00 (2/6/2022)
	
	INSTALLATION:
		1) Place this file as `bedRespawn.lua` inside your TES3MP servers `server\scripts\custom` folder.
		2) Open your `customScripts.lua` file in a text editor. 
				(It can be found in `server\scripts` folder.)
		3) Add the below line to your `customScripts.lua` file:
				require("custom.`bedRespawn.lua")
		4) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
		5) Save `customScripts.lua` and restart your server.

--]]

bedRespawn = {}
-------------------------------
-- User Configuration Settings:
-------------------------------
local displayRespawnSetText = true -- Shows the below message on bed activation if true. Does not display anything if false.
local respawnPointSetMessage = "Your have set your respawn point here." -- Message displayed when setting your respawn point.
local respawnPointMessageBox = true -- If true, shows the above text in a messagebox. If false, shows in tes3mp chat box.
local revivedMessage = "You have been revived at your last spawnpoint." -- Message that displays when revived.

local listOfBeds = { -- Add all the in-game bed refIds to this list you want to have auto-set a players respawn point.
"active_de_r_bed_02",
"active_de_p_bed_28",
"active_de_bed_29",
"active_de_bed_30",
"active_com_bunk_02",
"active_com_bunk_01",
"active_com_bed_03",
"active_com_bed_07",
"active_com_bed_06",
"active_com_bed_05",
"active_com_bed_04",
"active_com_bed_02",
"active_com_bed_01",
"active_de_pr_bed_27",
"active_de_pr_bed_26",
"active_de_pr_bed_25",
"active_de_pr_bed_24",
"active_de_pr_bed_23",
"active_de_pr_bed_22",
"active_de_pr_bed_21",
"active_de_r_bed_20",
"active_de_r_bed_19",
"active_de_r_bed_18",
"active_de_r_bed_17",
"active_de_p_bed_16",
"active_de_p_bed_15",
"active_de_p_bed_14",
"active_de_p_bed_13",
"active_de_p_bed_12",
"active_de_p_bed_11",
"active_de_p_bed_10",
"active_de_p_bed_09",
"active_de_pr_bed_08",
"active_de_pr_bed_07",
"active_de_r_bed_06",
"active_de_p_bed_05",
"active_de_p_bed_04",
"active_de_p_bed_03",
"active_de_r_bed_01",
--"active_kolfinna_beddisable", -- Disabled due to having a unique script.
--"active_kolfinna_bedenable", -- Disabled due to having a unique script.
--"CharGen_Bed", -- Disabled due to having a unique script.
"active_de_bedroll"
 }

------------------------------------------------------
-- Shouldn't need to touch anything below this point!
------------------------------------------------------
customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
	
	local isValid = eventStatus.validDefaultHandler

    for n,object in pairs(objects) do
	
		for id, bedObject in pairs(listOfBeds) do
			if object.refId == bedObject then	
				
				Players[pid].data.customVariables.bedRespawnPoint = {
					cellDescription = cellDescription,
					posX = tes3mp.GetPosX(pid),
					posY = tes3mp.GetPosY(pid),
					posZ = tes3mp.GetPosZ(pid),
					rotX = tes3mp.GetRotX(pid),
					--rotY = 0, -- This is not necessary because it will always be 0.
					rotZ = tes3mp.GetRotZ(pid)
				}
				
				if displayRespawnSetText ~= nil and displayRespawnSetText == true then
					if respawnPointSetMessage ~= nil and respawnPointSetMessage ~= "" then
						if not respawnPointMessageBox then
							tes3mp.SendMessage(pid, respawnPointSetMessage.."\n", false)
						else
							tes3mp.MessageBox(pid, -1, respawnPointSetMessage)
						end
					end
				end
				
				
			end
		end

    end
	
	eventStatus.validDefaultHandler = isValid
    return eventStatus
end)

local newResurrectFunction = function(pid)
	
	local player = Players[pid].data.customVariables.bedRespawnPoint
	
	tes3mp.SetCell(pid, player.cellDescription)
	tes3mp.SendCell(pid)
		
	tes3mp.SetPos(pid, player.posX, player.posY, player.posZ)
    tes3mp.SetRot(pid, player.rotX, player.rotZ)
    tes3mp.SendPos(pid)
	
    -- Ensure that dying as a werewolf turns you back into your normal form
    if Players[pid].data.shapeshift.isWerewolf == true then
        Players[pid]:SetWerewolfState(false)
    end

    -- Ensure that we unequip deadly items when applicable, to prevent an
    -- infinite death loop
    contentFixer.UnequipDeadlyItems(pid)
	
    tes3mp.Resurrect(pid, enumerations.resurrect.REGULAR)

    if config.deathPenaltyJailDays > 0 or config.bountyDeathPenalty then
        local jailTime = 0
        local resurrectionText = "You've been revived and brought back here, " ..
            "but your skills have been affected by "

        if config.bountyDeathPenalty then
            local currentBounty = tes3mp.GetBounty(pid)

            if currentBounty > 0 then
                jailTime = jailTime + math.floor(currentBounty / 100)
                resurrectionText = resurrectionText .. "your bounty"
            end
        end

        if config.deathPenaltyJailDays > 0 then
            if jailTime > 0 then
                resurrectionText = resurrectionText .. " and "
            end

            jailTime = jailTime + config.deathPenaltyJailDays
            resurrectionText = resurrectionText .. "your time spent incapacitated"    
        end

        resurrectionText = resurrectionText .. ".\n"
        tes3mp.Jail(pid, jailTime, true, true, "Recovering", resurrectionText)
    end

    if config.bountyResetOnDeath then
        tes3mp.SetBounty(pid, 0)
        tes3mp.SendBounty(pid)
        Players[pid]:SaveBounty()
    end

    tes3mp.SendMessage(pid, revivedMessage, false)
end

customEventHooks.registerValidator("OnDeathTimeExpiration", function(eventStatus, pid)
	
	local isValid = eventStatus.validDefaultHandler
	
	if isValid ~= false then
		if Players[pid].data.customVariables.bedRespawnPoint ~= nil then
			newResurrectFunction(pid)
			isValid = false
		else
			isValid = true
		end
	end
	
	eventStatus.validDefaultHandler = isValid
    return eventStatus
end)

return bedRespawn
