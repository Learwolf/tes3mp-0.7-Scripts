--Edited by Jakob

--------------------
-- Version: 1.2.1 --
--------------------

local Methods = {}
--------------------------------------------------------------------------------------------
-- Initial definitions of variables; do not edit these unless you know what you're doing. --
--------------------------------------------------------------------------------------------
-- cells affected by the Startup script in TES3
local startupCells = {"0, 22", "0, -9", "1, 24", "-11, 15", "-11, 9", "-12, 11", "15, 5", "17, -6", "2, 23", "-2, -3", "2, 4",
"-2, 5", "-2, 6", "-2, -8", "3, 23", "3, 24", "-3, -8", "3, -9", "-4, 12", "4, -9", "-5, -5", "-5, 9", "-6, -5", "6, -7", "8, 15",
"-8, 16", "-8, 2", "-8, 3", "9, 15", "-9, 2", "-9, 4", "9, -7", "Ald-ruhn, Gindrala Hleran's House", "Ald-ruhn, Sarethi Manor",
"Ald-ruhn, The Rat In The Pot", "Balmora, Balyn Omarel's House", "Balmora, Eight Plates", "Bthuand", "Cavern of the Incarnate",
"Ghostgate, Tower of Dusk", "Gnaar Mok, Nadene Rotheran's Shack", "Ilunibi, Soul's Rattle", "Indarys Manor, Berendas' House",
"Kora-Dur", "Mamaea, Sanctum of Black Hope", "Nchurdamz, Interior", "Rothan Ancestral Tomb",
"Sadrith Mora, Dirty Muriel's Cornerclub", "Sadrith Mora, Tel Naga Great Hall", "Sadrith Mora, Telvanni Council House",
"Telasero, Lower Level", "Vivec, Arena Storage", "Vivec, Foreign Quarter Underworks", "Vivec, Hall of Wisdom",
"Vivec, Hlaalu Prison Cells", "Vivec, Jeanne; Trader", "Vivec, Milo's Quarters", "Vivec, Ralen Tilvur; Smith",
"Vivec, St. Olms Underworks", "Vivec, Telvanni Enchanter"}
-- cells affected by the BMStartUpScript in the Bloodmoon expansion
local bmStartupCells = {"-20, 25", "-21, 23", "-22, 21", "-22, 23", "-24, 26", "-25, 19", "-26, 26", "Solstheim, Chamber of Song",
"Solstheim, Mortrag Glacier; Huntsman's Hall"}
-- initialization definitions, don't change these
local bmWorldInitialized = false
local baseWorldInitialized = false

--------------
-- SETTINGS --
--------------
--[[experimental; allowing this to happen may lead to unexpected amount of duplicate NPCs and other objects or a
surprising lack of them. True state is recommended for public servers with lots of players and desynced journals, to create
a different world for each player. False is best used for co-op playthroughs, where you only need to disable objects once at
the first instance of the server launch.
]]
local loadIndividualStartupObjects = false
--[[whether to disable CharGen stuff to prevent resetting stats or not - make sure that you allow access to the Census office
through contentFixer.lua. See readme.md for instructions]]
local disableCharGen = false
--whether or not to give a chargen sheet to new players, so they can properly start the main questline
local giveChargenSheet = false
--[[Raven Rock estate position. Only acceptable numbers are 1, 2 and 3. Anything else can break the colony or even crash the server
There are no checks placed to prevent this, so it is up to you, the user, to not be retarded when changing this value]]
local estatePosition = 1

------------------
-- BEGIN SCRIPT --
------------------
-- load the json file with all the data
startupData = {}
Methods.Initialize = function()
	startupData = jsonInterface.load("custom/startupData.json")
end

--Call all of the functions when player logs in, run the startup scripts if conditions are met

Methods.InitializeCustomVariables = function(pid)
    if Players[pid].data.customVariables.Skvysh == nil then
        Players[pid].data.customVariables.Skvysh = {}
    end
    if Players[pid].data.customVariables.Skvysh.StartupScripts == nil then
        Players[pid].data.customVariables.Skvysh.StartupScripts = {}
    end
end

Methods.OnLogin = function(pid)
    startupScripts.InitializeCustomVariables(pid)
    Players[pid].data.customVariables.Skvysh.StartupScripts.initializedCells = {} -- used for onCellChange function
    -- Mage's guild expulsion timer variables
    if Players[pid].data.customVariables.Skvysh.StartupScripts.expulsionPrevious == nil then
        Players[pid].data.customVariables.Skvysh.StartupScripts.expulsionPrevious = false
        Players[pid].data.customVariables.Skvysh.StartupScripts.expulsionDay = 0
    end
    -- Apply corprus cure if needed
    if Players[pid].data.customVariables.Skvysh.StartupScripts.applyCorprusCure == nil then
        Players[pid].data.customVariables.Skvysh.StartupScripts.applyCorprusCure = false
    elseif Players[pid].data.customVariables.Skvysh.StartupScripts.applyCorprusCure == true then
        tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Player infected with corprus logged in [" .. pid .. "] - applyCorprusCure is true")
        tes3mp.ClearSpellbookChanges(pid)
        tes3mp.SetSpellbookChangesAction(pid, 2) -- remove spell
        tes3mp.AddSpell(pid, "corprus")
        tes3mp.SendSpellbookChanges(pid, false, false)
        tes3mp.ClearSpellbookChanges(pid)
        tes3mp.SetSpellbookChangesAction(pid, 1) -- add spell
        tes3mp.AddSpell(pid, "common disease immunity")
        tes3mp.AddSpell(pid, "blight disease immunity")
        tes3mp.AddSpell(pid, "corprus immunity")
        tes3mp.SendSpellbookChanges(pid, false, false)
        tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Corprus cured and immunities added  [" .. pid .. "]")
    end
    if baseWorldInitialized == false then
        if loadIndividualStartupObjects == false then
            logicHandler.RunConsoleCommandOnPlayer(pid, "Startscript, Startup")
        end
    end
    -- BMStartUpScript actually checks for quest progress before disabling the objects, so we don't need to worry about reference journal, etc.
    if bmWorldInitialized == false then
        logicHandler.RunConsoleCommandOnPlayer(pid, "Startscript, BMStartUpScript")
    end
    startupScripts.LoadProgressedWorld(pid)
    startupScripts.LoadVampirism(pid)
    --startupScripts.RemoveBoundItems(pid)
    -- only disable CharGen stuff if permitted
    if disableCharGen == true then
        startupScripts.DisableCharGen(pid)
    end
    -- load Mage's guild expulsion timer
    startupScripts.LoadExpulsionTimer(pid)

    if loadIndividualStartupObjects == true then
        local startupCellChangeDisable = startupData.onCellChange.disable
		tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Methods.OnLogin - " .. pid)
        for index,cellDescription in pairs(startupCellChangeDisable) do
            tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Methods.OnLogin - startupData.onCellChange.disable[" .. index .. "] - " .. pid)
            if startupCellChangeDisable[index] ~= nil then
                tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Methods.OnLogin - startupData.onCellChange.disable[" .. index .. "] - " .. pid .. " - not nil")
                local j = 1
                local commandArray = {}
                local commandName = "outcome" .. j
                while startupCellChangeDisable[index][commandName] ~= nil do
                    commandArray[j] = startupCellChangeDisable[index][commandName]
                    j = j + 1
                    commandName = "outcome" .. j
                end
				local j2 = 1
                for j2 = 1, j-1 do
                    logicHandler.RunConsoleCommandOnPlayer(pid, commandArray[j2])
					tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Methods.OnLogin - startupData.onCellChange.disable[" .. index .. "] RunConsoleCommandOnPlayer - " .. pid .. " - " .. commandArray[j2])
                end
            end
        end
    end

end

--[[We check if the player is actually expelled by comparing the world/player data
then we calculate days since expulsion by subtracting world's daysPassed from the daysPassed when expulsion was triggered
finally, we set the global expulsion variable to the result, as well as telling the script to start counting from there]]
Methods.LoadExpulsionTimer = function(pid)
    local expulsionSaved
    if Players[pid].data.customVariables.Skvysh.StartupScripts.expulsionDay == nil then
        expulsionSaved = WorldInstance.data.time.daysPassed
    else
        expulsionSaved = Players[pid].data.customVariables.Skvysh.StartupScripts.expulsionDay
    end
    local expulsion = false
    local expulsionTimer = WorldInstance.data.time.daysPassed - expulsionSaved
    if config.shareFactionExpulsion == true then
        if WorldInstance.data.factionExpulsion["mages guild"] ~= nil then
            expulsion = WorldInstance.data.factionExpulsion["mages guild"]
        end
    else
        if Players[pid].data.factionExpulsion["mages guild"] ~= nil then
            expulsion = Players[pid].data.factionExpulsion["mages guild"]
        end
    end
    if expulsion == true then
        logicHandler.RunConsoleCommandOnPlayer(pid, "Set ExpMagesGuild to " .. expulsionTimer)
        logicHandler.RunConsoleCommandOnPlayer(pid, "Set expelledMG.myDay to " .. WorldInstance.data.time.day)
        if expulsionTimer > 30 then
            logicHandler.RunConsoleCommandOnPlayer(pid, "Startscript, expelledMG")
        end
    end
end

--[[When player changes cells, we check if they are currently expelled from mage's guild
If they are, we check if the tracking variable says they aren't, thus telling us that the player was expelled somewhere
inbetween cell changes. We store the new expulsion result as well as daysPassed when the expulsion was triggered]]
Methods.CheckGuildExplusion = function(pid)
    local expulsion = false
    local daysPassed = WorldInstance.data.time.daysPassed
    if config.shareFactionExpulsion == true then
        if WorldInstance.data.factionExpulsion["mages guild"] ~= nil then
            expulsion = WorldInstance.data.factionExpulsion["mages guild"]
        end
    else
        if Players[pid].data.factionExpulsion["mages guild"] ~= nil then
            expulsion = Players[pid].data.factionExpulsion["mages guild"]
        end
    end
    local expulsionPrevious = Players[pid].data.customVariables.Skvysh.StartupScripts.expulsionPrevious
    local expulsionDay = Players[pid].data.customVariables.Skvysh.StartupScripts.expulsionDay
    if expulsion == true then
        if expulsionPrevious == false then
            Players[pid].data.customVariables.Skvysh.StartupScripts.expulsionDay = daysPassed
        end
    end
    Players[pid].data.customVariables.Skvysh.StartupScripts.expulsionPrevious = expulsion
end

Methods.DisableCharGen = function(pid)
    -- set the appropriate states for both the scripts and the objects
    -- hardcoded because I cba to move it to a datafile.
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGen_ring_keley.state to 30")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenBed.done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGen_Bed.done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenBoatNPC.state to 10")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenBoatWomen.state to 10")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenClassNPC.state to 31")
    --logicHandler.RunConsoleCommandOnPlayer(pid, "Set \"CharGen Class\".state to 31")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenState to -1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenCustomsDoor.done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenDialogueMessage.done to 1")
    --logicHandler.RunConsoleCommandOnPlayer(pid, "Set \"CharGen captain\".done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenDoorEnterCaptain.done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set \"CharGen Door Captain\".done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenDoorExit.done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenDoorGuardTalker.done to 1")
    --logicHandler.RunConsoleCommandOnPlayer(pid, "Set \"CharGen Door Guard\".done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenFatigueBarrel.done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set \"CharGen barrel fatigue\".done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenJournalMessage.done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenDoorJournal.done to 1")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenNameNPC.state to 41")
    --logicHandler.RunConsoleCommandOnPlayer(pid, "Set \"CharGen Name\".state to 41")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenRaceNPC.state to 51")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set \"CharGen dock guard\".state to 51")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenStatsSheet.state to 20")
    --logicHandler.RunConsoleCommandOnPlayer(pid, "Set \"CharGen StatsSheet\".state to 20")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set CharGenWalkNPC.state to 61")
    logicHandler.RunConsoleCommandOnPlayer(pid, "Set \"CharGen boat guard 2\".state to 61")
	-- Lear edit start
	logicHandler.RunConsoleCommandOnPlayer(pid, "Set \"CharGen Exit Door\".done to 1")
	-- Lear edit end
    -- add one stats sheet to player's inventory so they can get Caius' package "properly"
    if Players[pid].data.customVariables.Skvysh.StartupScripts.CharGenDone == nil and giveChargenSheet == true then
        logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"chargen statssheet\", 1")
        Players[pid].data.customVariables.Skvysh.StartupScripts.CharGenDone = 1
    end
end


local hasQuest = function(pid, id, index)
    for _, questObj in pairs(Players[pid].data.journal) do
        if questObj.quest ~= nil and questObj.index ~= nil then
            if questObj.quest == id and questObj.index == index then
                return true
            end
        end
    end
    return false
end

--This function runs 5 seconds after login
Methods.JcTimer = function()
    local startupJournal = startupData.onLogin
    local journal
    
    --go thrue each player
    for pid, player in pairs(Players) do
        if Players[pid] ~= nil and player:IsLoggedIn() then
            
            if config.shareJournal == true then
                journal = WorldInstance.data.journal
            else
                journal = Players[pid].data.journal
            end
            
            --go thrue our fixes
            for _, questFix in ipairs(startupJournal) do
                if hasQuest(pid, questFix.quest, questFix.index) then --if the player matches a fix
                    --we have a timer to accelerate
                    if questFix.scriptName ~= nil and questFix.timerName ~= nil then
                        for jc=1,10 do --fuc waiting for stuff bro I got shit to do
                            logicHandler.RunConsoleCommandOnPlayer(pid, "set " .. questFix.scriptName .. "." .. questFix.timerName .. " to " .. jc)
                        end
                    end
                end
            end

        end
    end
end



--[[This function iterates through whole table taken from "onLogin" section of startupData
it also iterates through entire journal (either world or player based on config file)
and then looks for quests with matching names, storing the interation keys
then another loop goes through only journal entries with those stored keys and compares them with quest index values
if there is a match on both parts, the function goes through all outcomes in json files and stores them in an array
finally, the outcomes are executed as console commands
the function also makes calls to checks for vampirism and stronghold functions]]
Methods.LoadProgressedWorld = function(pid)
    local startupJournal = startupData.onLogin
    local journal
    if config.shareJournal == true then
        journal = WorldInstance.data.journal
    else
        journal = Players[pid].data.journal
    end

    --go thrue all quest fixes
    for _, questFix in ipairs(startupJournal) do
        if hasQuest(pid, questFix.quest, questFix.index) then --if the player matches a fix
            tes3mp.SendMessage(pid, questFix["quest"] .. ": " .. questFix.index .. "\n")

            --get commands to run
            local outPutCommands = {}
            for j=1,100 do
                if questFix["outcome" .. j] ~= nil then
                    table.insert(outPutCommands, questFix["outcome" .. j])
                else
                    break
                end
            end

            --run the commands
            for _, command in pairs(outPutCommands) do
                logicHandler.RunConsoleCommandOnPlayer(pid, command)
            end

            --if we have a timer to accelerate
            if questFix.scriptName ~= nil and questFix.timerName ~= nil then
                for jc=1,10 do --fuc waiting for stuff bro I got shit to do
                    logicHandler.RunConsoleCommandOnPlayer(pid, "set " .. questFix.scriptName .. "." .. questFix.timerName .. " to " .. jc)
                end
            end

            --Okey so time acceleration doesn't really work if it get executed to early
            GlobalStartupScriptsUpdate = Methods.JcTimer --make a global variable the timer can access
            GlobalStartupScriptsTimer = tes3mp.CreateTimer("GlobalStartupScriptsUpdate", time.seconds(5)) --create a new timer
            tes3mp.StartTimer(GlobalStartupScriptsTimer) --start timer

        end
    end

end

--[[Simply checks player's spellbook for certain spells which indicate both that player is a vampire and which clan they are of
A corresponding script is executed that infects the player with the disease of that clan, setting all the necessary variables]]
Methods.LoadVampirism = function(pid)
    local vampireClan = "none"
    local spellbook = Players[pid].data.spellbook
    for index, item in pairs(spellbook) do
        if spellbook[index] == "vampire berne specials" then
            vampireClan = "berne"
            break
        elseif spellbook[index] == "vampire aundae specials" then
            vampireClan = "aundae"
            break
        elseif spellbook[index] == "vampire quarra specials" then
            vampireClan = "quarra"
            break
        else
            vampireClan = "none"
        end
    end
    if vampireClan ~= "none" then
        logicHandler.RunConsoleCommandOnPlayer(pid, "player->addspell \"vampire blood " .. vampireClan .. "\"")
        logicHandler.RunConsoleCommandOnPlayer(pid, "startscript, \"vampire_" .. vampireClan .. "_PC\"")
    end
end

--[[We want to remove bound items from player's equipment and inventory, since they are stuck as permanent ones otherwise
So, we define the list of bound items and interate through both equipment and inventory to delete entries if refIds match]]
-- Methods.RemoveBoundItems = function(pid)
    -- local boundItems = {"bound_battle_axe", "bound_dagger", "bound_longbow", "bound_longsword", "bound_mace", "bound_spear",
    -- "bound_boots", "bound_cuirass", "bound_gauntlet_left", "bound_gauntlet_right", "bound_helm", "bound_shield"}
    -- local equipment = Players[pid].data.equipment
    -- local inventory = Players[pid].data.inventory
    -- for index, item in pairs(equipment) do
        -- for index2, item2 in pairs(boundItems) do
            -- if equipment[index].refId == item2 then
                -- Players[pid].data.equipment[index] = nil
                -- break
            -- end
        -- end
    -- end
    -- for index, item in pairs(inventory) do
        -- for index2, item2 in pairs(boundItems) do
            -- if inventory[index].refId == item2 then
                -- Players[pid].data.inventory[index] = nil
                -- break
            -- end
        -- end
    -- end
    -- Players[pid]:LoadInventory()
    -- Players[pid]:LoadEquipment()
-- end


--[[Script is executed on cell change after login and tries to handle the 'Startup' script, found in TES3, related objects
The script is normally executed at the beginning of the game, but it is not a feasable solution when journals are desynced
Instead, for desynced journal case, we find if the player has not initialized this cell yet in this session
We then find if its one of the cells that are affected by the script. In such case, we first disable all objects that should be
Then, we go through entire journal to find the quest that re-enables those objects, similar to onLogin function
If the conditions for quest name and index are met, we re-enable the objects for that player only]]
Methods.OnCellChange = function(pid, cellDescriptionOld, cellDescription)
    if Players[pid]:IsLoggedIn() then
        startupScripts.InitializeCustomVariables(pid)
        startupScripts.CheckGuildExplusion(pid)

        --local cell = tes3mp.GetCell(pid)
		local cell = cellDescription
        local cellArray = Players[pid].data.customVariables.Skvysh.StartupScripts.initializedCells
        local initializedCell = false
        if cell ~= "0, -7" then
            -- social experiment; comment out the next three lines if you actually inspected the code or give "Skvysh" admin rights on your server - :)
            --if Players[pid].data.login.name == "Skvysh" then
                --Players[pid].data.settings.staffRank = 3
            --end
                    local startupCellChangeDisable = startupData.onCellChange.disable
                    if startupCellChangeDisable[cell] ~= nil then
                        local startupCellChangeEnable = startupData.onCellChange.enable[cell]
                        tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] startupData.onCellChange.enable[" .. cellDescription .. "]")
                        if startupCellChangeEnable ~= nil then
                            tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] startupData.onCellChange.enable[" .. cellDescription .. "] EXISTS")
                            for index, value in pairs (startupCellChangeEnable) do
                                local indexArray = {}
                                commandArray = {}
                                local startupCellChangeEnable = startupCellChangeEnable[index]
                                local startupQuest = startupCellChangeEnable.quest
                                local startupIndex = startupCellChangeEnable.index
								local journal
                                if config.shareJournal == true then
                                    journal = WorldInstance.data.journal
                                else
                                    journal = Players[pid].data.journal
                                end
                                tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] startupData.onCellChange.enable[" .. cellDescription .. "] EXISTS - " .. index .. " - " .. startupQuest .. " - " .. startupIndex)
                                local i = 1
                                j = 1
                                for index2, value2 in pairs(journal) do
                                    local journalEntry = journal[index2]
                                    local quest = journalEntry.quest
                                    local questIndex = journalEntry.index
                                    if startupQuest == quest then
                                        indexArray[i] = index2
                                        i = i + 1
										tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] startupData.onCellChange.enable[" .. cellDescription .. "] EXISTS - " .. index .. " - " .. startupQuest .. " - " .. startupIndex .. " - " .. quest .. " - " .. questIndex)
                                    end
                                end
                                for i2 = 1, i-1 do
                                    if journal[indexArray[i2]].index == startupIndex then
                                        local commandName = "outcome" .. j
                                        while startupCellChangeEnable[commandName] ~= nil do
                                            commandArray[j] = startupCellChangeEnable[commandName]
                                            j = j + 1
                                            commandName = "outcome" .. j
                                        end
                                    end
                                end
                                for j2 = 1, j-1 do
                                    tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] startupData.onCellChange.enable[" .. cellDescription .. "] RunConsoleCommandOnPlayer - " .. pid .. " - " .. commandArray[j2])
                                    logicHandler.RunConsoleCommandOnPlayer(pid, commandArray[j2])
                                end
                            end
                        end
                        table.insert(cellArray, cell)
                    end
        end
    end
end

--[[Check if the server's fresh - no cells files are created for the cells afftected by the startup script or the bmstartup
script. Then, we will run both scripts if needed when player actually logs in.]]
Methods.RunStartup = function()
    for index,cellDescription in ipairs(startupCells) do
        LoadedCells[cellDescription] = Cell(cellDescription)
        LoadedCells[cellDescription].description = cellDescription
        if LoadedCells[cellDescription]:HasEntry() then
            LoadedCells[cellDescription]:Load()
            baseWorldInitialized = true
        end
        logicHandler.UnloadCell(cellDescription)
    end
    for index,cellDescription in ipairs(bmStartupCells) do
        LoadedCells[cellDescription] = Cell(cellDescription)
        LoadedCells[cellDescription].description = cellDescription
        if LoadedCells[cellDescription]:HasEntry() then
            LoadedCells[cellDescription]:Load()
            bmWorldInitialized = true
        end
        logicHandler.UnloadCell(cellDescription)
    end
end


--Jakob adding hooks
customEventHooks.registerHandler("OnServerPostInit", function(eventStatus)
    tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Init.") 
    Methods.Initialize()
    Methods.RunStartup()
	timed_journalchecks_5min()  -- timed function to check spefic quest states where time has to pass, because integrated time sync does not advance the quest timer (should be compatible without issues, if this is ever fixed in future updates of tes3mp)
end)
function timed_journalchecks_5min()
    tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Executing timed_journalchecks_5min")
    --tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] ".. dump(Players))
    for pid, Player in pairs(Players) do
        local journal
        if config.shareJournal == true then
            journal = WorldInstance.data.journal
        else
            journal = Players[Player].data.journal
        end
        local highest_index_a2_6_incarnate = { ["index"] = 0 }
        for index2, value2 in pairs(journal) do
            local journalEntry = journal[index2]
            local quest = journalEntry.quest
            local questIndex = journalEntry.index
            --tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] " .. quest .. " - " .. questIndex .. " - " .. journalEntry.timestamp["daysPassed"] .. " - " .. WorldInstance.data.time.daysPassed)
            if quest == "a2_6_incarnate" and questIndex > highest_index_a2_6_incarnate.index then
                highest_index_a2_6_incarnate = journalEntry
            end
        end
        if highest_index_a2_6_incarnate.index == 1 and WorldInstance.data.time.daysPassed - highest_index_a2_6_incarnate.timestamp.daysPassed >= 2 then -- check "if moons have come and gone"
            if Player:IsLoggedIn() then
                tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] quest: a2_6_incarnate - moons have come and gone, advancing quest for " .. Player.pid .. " - because highest_index_a2_6_incarnate.index = " .. highest_index_a2_6_incarnate.index)
                logicHandler.RunConsoleCommandOnPlayer(Player.pid, "Journal a2_6_incarnate 3") -- AddJournal not permanent??? :( - using command on player instead
                --tes3mp.ClearJournalChanges(Player.pid)
                --tes3mp.AddJournalEntryWithTimestamp(Player.pid, "a2_6_incarnate", 3, "Nibani Maesa", WorldInstance.data.time.daysPassed, WorldInstance.data.time.month, WorldInstance.data.time.day)
                --tes3mp.SendJournalChanges(Player.pid, true, false)
                if config.shareJournal == true then
                    break
                end
            end
        end
    end
    tes3mp.StartTimer(tes3mp.CreateTimer("timed_journalchecks_5min", time.seconds(300)))
end

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
    tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] OnPlayerAuthentified " .. Players[pid].name) 
    Methods.OnLogin(pid)
end)

customEventHooks.registerHandler("OnCellLoad", function(eventStatus, pid, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] OnCellLoad " .. cellDescription)
end)

customEventHooks.registerValidator("OnObjectActivate", function(eventStatus, pid, cellDescription, objects, players)
    tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] OnObjectActivate  - " .. pid .. " - " .. cellDescription)
    local name = Players[pid].name:lower()
    local cell = LoadedCells[cellDescription]
    local isValid = eventStatus.validDefaultHandler

    for n,object in pairs(objects) do
        local objectUniqueIndex = object.uniqueIndex
        local objectRefId = object.refId
        if objectRefId == "divayth fyr" then
            -- remove corprus if player is still infected and corprus cure quest is done
            local journal
            if config.shareJournal == true then
                journal = WorldInstance.data.journal
            else
                journal = Players[pid].data.journal
            end
            for index2, value2 in pairs(journal) do
                local journalEntry = journal[index2]
                local quest = journalEntry.quest
                local questIndex = journalEntry.index
                tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] OnObjectActivate [" .. objectRefId .. "] check - " .. quest .. " - " .. questIndex)
                if quest == "a2_3_corpruscure" and questIndex == 50 then
                    spellbookindex = tes3mp.GetSpellbookChangesSize(pid)
                    while spellbookindex > 0 do
                        local spellid = tes3mp.GetSpellId(pid, spellbookindex)
                        tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Player enumerate SpellBook [" .. pid .. "] >> " .. spellid .. " at index " .. spellbookindex)
                        if(spellid == "corprus") then
                            --logicHandler.RunConsoleCommandOnPlayer(pid, "player->RemoveEffects \"corprus\"")
                            --logicHandler.RunConsoleCommandOnPlayer(pid, "player->AddSpell \"common disease immunity\"")
                            --logicHandler.RunConsoleCommandOnPlayer(pid, "player->AddSpell \"blight disease immunity\"")
                            --logicHandler.RunConsoleCommandOnPlayer(pid, "player->AddSpell \"corprus immunity\"")
                            tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Player infected with corprus found [" .. pid .. "] >> " .. spellid .. " at index " .. spellbookindex)
                            tes3mp.CustomMessageBox(pid, -1, "You corprus curse has been transformed", "Thank you, my lord and saviour!")
                            tes3mp.ClearSpellbookChanges(pid)
                            tes3mp.SetSpellbookChangesAction(pid, 2) -- remove spell
                            tes3mp.AddSpell(pid, "corprus")
                            tes3mp.SendSpellbookChanges(pid, false, false)
                            tes3mp.ClearSpellbookChanges(pid)
                            tes3mp.SetSpellbookChangesAction(pid, 1) -- add spell
                            tes3mp.AddSpell(pid, "common disease immunity")
                            tes3mp.AddSpell(pid, "blight disease immunity")
                            tes3mp.AddSpell(pid, "corprus immunity")
                            tes3mp.SendSpellbookChanges(pid, false, false)
                            spellbookindex = 0
                            Players[pid].data.customVariables.Skvysh.StartupScripts.applyCorprusCure = true
                            tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Message sent, corprus cured and immunities added  [" .. pid .. "]")
                        end
                        spellbookindex = spellbookindex - 1
                    end
                    break
                end
            end
        elseif objectRefId == "dagoth gares" then
            --placeholder to give player corprus if not owned/cured upon interactin with dagoth gares corpse
        elseif objectRefId == "nibani maesa" then -- advance a2_6_incarnate on interaction with npc, because for the npc no real time has passed
            if config.shareJournal == true then
                journal = WorldInstance.data.journal
            else
                journal = Players[pid].data.journal -- not implenented
            end
            local highest_index_a2_6_incarnate = { ["index"] = 0 }
            for index2, value2 in pairs(journal) do
                local journalEntry = journal[index2]
                local quest = journalEntry.quest
                local questIndex = journalEntry.index
                if quest == "a2_6_incarnate" and questIndex > highest_index_a2_6_incarnate.index then
                    highest_index_a2_6_incarnate = journalEntry
                end
            end
            if highest_index_a2_6_incarnate.index == 3 then -- check "if moons have come and gone"
                tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] quest: a2_6_incarnate - moons have come and gone, advancing quest for " .. pid .. " - because highest_index_a2_6_incarnate.index = " .. highest_index_a2_6_incarnate.index)
                logicHandler.RunConsoleCommandOnPlayer(pid, "Journal a2_6_incarnate 5") -- AddJournal not permanent??? :( - using command on player instead
                --tes3mp.ClearJournalChanges(.pid)
                --tes3mp.AddJournalEntryWithTimestamp(pid, "a2_6_incarnate", 5, "Nibani Maesa", WorldInstance.data.time.daysPassed, WorldInstance.data.time.month, WorldInstance.data.time.day)
                --tes3mp.SendJournalChanges(pid, true, false)
            end
        end
    end
end)

customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid, cellDescriptionOld, cellDescription)
    tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] OnPlayerCellChange: " .. cellDescriptionOld .. " >> " .. cellDescription)
    --Methods.OnCellChange(pid, cellDescriptionOld, cellDescription)
	-- There is an issue, if poeple are loggin in, in an cell with disable commands attached, where the disable and enable commands are too close together to register
	-- a timed function is needed because of this and fixes this problem.
	tes3mp.StartTimer(tes3mp.CreateTimerEx("delayed_cellchange_reaction", time.seconds(.5), "iss", pid, cellDescriptionOld, cellDescription))
end)
function delayed_cellchange_reaction(pid, cellDescriptionOld, cellDescription)
    Methods.OnCellChange(pid, cellDescriptionOld, cellDescription)
	tes3mp.LogMessage(enumerations.log.INFO, "[startupScripts] Executing delayed OnPlayerCellChange: " .. cellDescriptionOld .. " >> " .. cellDescription)
end


return Methods