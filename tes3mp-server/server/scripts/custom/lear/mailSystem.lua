
--[[

	Mail System
	version 1.01
	by Learwolf
	
	**IMPORTANT!**
	You must create a folder called `mail` inside your 'server/data/custom' folder
	
	
	INSTALLATION:
	
	1) Please see the above IMPORTANT information. I.E. You must create a folder called 'mail' inside your 'server/data/custom' folder.
	2) Place this script (mailSystem.lua) inside your 'server/scripts/custom' folder.
	3) Open up your 'customScripts.lua' with a text editor. This file can be found inside your 'server/scripts' folder.
	4) On a new line, add the following line:
		require("custom.mailSystem")
	5) Save and exit 'customScripts.lua'.
	6) Relaunch your server, and use the command '/mail'
	
	
	
	VERSION HISTORY:
	
	6/1/2020 - 1.01
		- No longer create mail files when a player logs in. This should be helpful in conserving space on populated servers.

	5/30/2020 - 1.00
		- Initial release.
	
	
--]]

local config = {}
config.mailSystemMaxLettersCount = 50 -- How many max letters a player can have.
config.mailSystemMaxModLettersCount = 250 -- How many max letters a mod can have.
config.mailSystemMaxAdminLettersCount = 500 -- How many letters an Admin can have.
config.mailSystemMaxOwnerLettersCount = 500 -- How many letters the Owner can have.

config.subjectCharaLimit = 20 -- How many characters can be used in the subject of a letter.
config.bodyCharaLimit = 500 -- How many characters can be used in a letter.

config.staffRankBypassMaxMail = 1 -- This staff rank and higher can send players more than their max mail. Useful for staff members to still send mail for someone who has a full mailbox.

config.TopMessageInfo = color.Orange  -- top message info of Mail System UI
config.tldrColor = color.White  -- color of the "..." at the end of messages that bypass the message character limit

config.unreadMailMessage = "You have unread mail."	-- The message a player sees when receiving unread mail.

config.ColorMsgBox = "#AB8C53" -- Color of general text.
config.ColorPreview = color.White -- Color of mail names/subject/body text.

config.mailSentSuccess = config.ColorMsgBox.."Mail sent successfully!" -- The confirmation to the sender that mail was sent.
config.mailboxIsFull = color.Error.."That recipients inbox is full." -- The error message players receive when trying to send mail to a full mailbox.
config.mailMissingFields = color.Error.."You must enter text in all fields." -- The error message received when you havent entered text in every field when sending mail.
config.mailDeletedSuccessfully = config.ColorMsgBox.."Mail deleted successfully!" -- The confirmation to the sender that mail was deleted.

config.mailSentSfx = "enchant success" -- Sound played when you send mail. Leave as "" for no sound.
config.mailFailedSfx = "enchant fail" -- Sound played when you failed to send mail. Leave as "" for no sound.

-- DON'T TOUCH ANYTHING BELOW UNLESSS YOU KNOW WHAT YOU'RE DOING:
config.mailSystemMainGUI = 053020202
config.mailSystemMailGUI = 053020204
config.mailSystemRecipientGUI = 053020205
config.mailSystemSubjectGUI = 053020206
config.mailSystemMessageBodyGUI = 053020207
config.mailSystemSentMailPreviewGUI = 053020208
config.mailSystemMailViewerGUI = 053020209
config.mailSystemDeleteGUI = 053020210

mailSystem = {}

mailVar = {}

local youveGotMail = function(pid)
	tes3mp.SendMessage(pid, config.ColorMsgBox..config.unreadMailMessage.."\n", false)
end

-- Enter the name of who you want to mail.
local mailRecipientName = function(pid)
	local topTxt = config.ColorMsgBox.. "Enter the recepient's name:"
	local botTxt = config.ColorMsgBox.."Or leave empty (space bar once) to cancel."
	tes3mp.InputDialog(pid, config.mailSystemRecipientGUI, topTxt, botTxt)
end

-- Enter the subject title of the mail.
local mailSubjectInput = function(pid)
	local topTxt = config.ColorMsgBox.."Enter subject:"
	local botTxt = config.ColorMsgBox.."(Limit of "..config.subjectCharaLimit.." characters displayed.)"
	tes3mp.InputDialog(pid, config.mailSystemSubjectGUI, topTxt, botTxt)
end

-- Enter the message body of the mail.
local mailBodyInput = function(pid)
	local topTxt = config.ColorMsgBox.."Enter message body:"
	local botTxt = config.ColorMsgBox.."(Use '"..color.Yellow.."/n "..config.ColorMsgBox.."' to line break.\nLimit of "..config.bodyCharaLimit.." characters displayed.)"
	tes3mp.InputDialog(pid, config.mailSystemMessageBodyGUI, topTxt, botTxt)
end


local checkIfPlayerExists = function(pid, name)
	
    local player = {}
    local accountName = fileHelper.fixFilename(name)
    player.accountFile = tes3mp.GetCaseInsensitiveFilename(tes3mp.GetModDir() .. "/player/", accountName .. ".json")

    if player.accountFile == "invalid" then
		tes3mp.SendMessage(pid, color.Error.."That player does not exist.\n", false)
        return false
    end
	
	player.mailbox = tes3mp.GetCaseInsensitiveFilename(tes3mp.GetModDir() .. "/custom/mail/", accountName .. ".json")
	
	if player.mailbox == "invalid" then
		
		player.data = jsonInterface.load("player/" .. player.accountFile)
		
		local dataToAdd = {
			staffRank = player.data.settings.staffRank,
			mail = {
				inbox = {},
				trash = {}
			}
		}
		
		jsonInterface.save("custom/mail/" .. player.accountFile, dataToAdd)
		
    end
	
	mailVar[pid].receiver = player.accountFile
   
   return true
   
end


local checkIfYouveGotMail = function(pid)
	
	local name = string.lower(Players[pid].accountName)
	
	local accountName = fileHelper.fixFilename(name)
	
	local player = {}
	player.accountFile = tes3mp.GetCaseInsensitiveFilename(tes3mp.GetModDir() .. "/player/", accountName .. ".json")
	player.mailbox = tes3mp.GetCaseInsensitiveFilename(tes3mp.GetModDir() .. "/custom/mail/", accountName .. ".json")
	
	if player.accountFile == "invalid" or player.mailbox == "invalid" then
        	return
	else
		
		local accountName = fileHelper.fixFilename(name)
		local mailbox = jsonInterface.load("custom/mail/"..accountName..".json")
		
		for i=1,#mailbox.mail.inbox do
			if mailbox.mail.inbox[i] ~= nil and mailbox.mail.inbox[i].hasRead == nil then
				youveGotMail(pid)
				break
			end
		end
		
	end
	
end


local showMailSystemMainGUI = function(pid)
	
	local message = config.TopMessageInfo .. "Mail System\n\n"
	
	local name = string.lower(Players[pid].accountName)
	local mailCount = 0

	if checkIfPlayerExists(pid, name) then
		
		local accountName = fileHelper.fixFilename(name)
		local mailbox = jsonInterface.load("custom/mail/"..accountName..".json")
		
		mailCount = #mailbox.mail.inbox or 0
		
		local unreadCount = 0
		
		for i=1,#mailbox.mail.inbox do
			local getSlot = #mailbox.mail.inbox + 1 - i
			local target = mailbox.mail.inbox[getSlot]
			if target.hasRead == nil then
				unreadCount = unreadCount + 1
			end
		end
		
		local unreadMsg = ""
		if unreadCount > 0 then
			unreadMsg = config.ColorMsgBox.."(Unread: "..config.ColorPreview..unreadCount..config.ColorMsgBox..")\n"
		end
		
		message = message..config.ColorMsgBox.."Inbox: "..config.ColorPreview..mailCount.."\n"..unreadMsg
		
	end
	
	tes3mp.CustomMessageBox(pid, config.mailSystemMainGUI, message, "View;Compose;Exit")
	
end


local canMessageBeSent = function(pid)
	if mailVar[pid].receiver ~= nil and mailVar[pid].subject ~= nil and mailVar[pid].body ~= nil then
		return true
	end
	return false
end


local sendMailMenuGUI = function(pid)
	
	local message = "Prepare Mail to Player"		
	
	local outString = " * Cancel\n"
	
	local sendColor = color.Grey
	if canMessageBeSent(pid) then
		sendColor = ""
	end
	outString = outString..sendColor.." * Send Mail\n"..config.ColorMsgBox.."~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"
	
	local recipientName = mailVar[pid].initialReceiverName or ""
	local subjectPreview = mailVar[pid].subject or ""
	local bodyPreview = mailVar[pid].body or ""
	
	
	if subjectPreview ~= "" then
		subjectPreview = subjectPreview:sub(1,35)
		if string.len(tostring(subjectPreview)) > 32 then
			subjectPreview = subjectPreview .. config.tldrColor .. "..."
		end
	end
	
	local bodyOutString = ""
	if bodyPreview ~= "" then
		bodyPreview = tostring(bodyPreview)
		
		if bodyPreview ~= nil then
			local maxLine = 47
			local currentChars = 0
			local wordList = {}

			for w in bodyPreview:gmatch("%S+") do table.insert(wordList, w) end

			for _, word in pairs(wordList) do
				
				currentChars = currentChars + word:len()
				
				if string.match(word, "/n") then
					
					bodyOutString = bodyOutString..config.ColorPreview..string.gsub( word, "(/n)", "" ).."\n"
					currentChars = 5 + word:len() + 1
				
				elseif string.match(word, "/r") then
					bodyOutString = bodyOutString..config.ColorPreview..string.gsub( word, "(/r)", recipientName )
					currentChars = 5 + word:len() + 1
					
				else
				
					if currentChars > maxLine then
						bodyOutString = bodyOutString .. "\n"..config.ColorPreview..word.." "
						currentChars = 5 + word:len() + 1
					else
						bodyOutString = bodyOutString..config.ColorPreview..word.." "
						currentChars = currentChars + 1
					end
					
				end
			end
			bodyOutString = bodyOutString .. "\n" 
			
		end
		
	end
	
	outString = outString.."Recipient: "..config.ColorPreview..recipientName.."\n"
	outString = outString.."Subject: "..config.ColorPreview..subjectPreview.."\n"
	outString = outString.."Body:\n"..config.ColorPreview..bodyOutString.."\n"
	
	return tes3mp.ListBox(pid, config.mailSystemSentMailPreviewGUI, message, outString)
	
end


-- When viewing your own mail list:
local viewMailListGUI = function(pid)
	
	local message = config.ColorMsgBox.."Viewing Mail\n"		
	
	local name = string.lower(Players[pid].accountName)
	
	local mailCount = 0
	
	mailVar[pid].mailList = {}
	
	local mailInboxLetters = " * Back\n"
	
	if checkIfPlayerExists(pid, name) then
		
		local accountName = fileHelper.fixFilename(name)
		local mailbox = jsonInterface.load("custom/mail/"..accountName..".json")
		
		mailCount = #mailbox.mail.inbox or 0
		
		message = message..config.ColorMsgBox.."Inbox: "..config.ColorPreview..mailCount
		
		local mailListCounter = 0
		local unreadCount = 0
		
		for i=1,#mailbox.mail.inbox do
			local getSlot = #mailbox.mail.inbox + 1 - i
			local target = mailbox.mail.inbox[getSlot]
			
			for t=1, 2 do
				mailListCounter = mailListCounter + 1
				mailVar[pid].mailList[tostring(mailListCounter)] = getSlot
			end
			
			local readColor = ""
			local lowerColor = config.ColorMsgBox
			if target.hasRead ~= nil then
				readColor = config.ColorPreview
				lowerColor = config.ColorPreview
			else
				unreadCount = unreadCount + 1
			end
			
			mailInboxLetters = mailInboxLetters.."View: "..readColor..target.mailSubject..
			"\n"..config.ColorMsgBox.."  > From: "..lowerColor..target.mailSendersName.."  ("..target.mailDate..")\n"
			
		end
		
		if unreadCount > 0 then
			message = message..config.ColorMsgBox.."  (Unread: "..config.ColorPreview..unreadCount..config.ColorMsgBox..")"
		end
		
	end
	
	return tes3mp.ListBox(pid, config.mailSystemMailGUI, message, mailInboxLetters)	
	
end

-- View the mail you selected:
local viewSpecificMail = function(pid)
	
	if not pid or not mailVar[pid] or not mailVar[pid].targetMail then return end
	
	local getSlot = mailVar[pid].mailList[tostring(mailVar[pid].targetMail)]
	
	local message = config.ColorMsgBox.."Viewing Mail\n"
	
	local name = string.lower(Players[pid].accountName)
	local accountName = fileHelper.fixFilename(name)
	local mailbox = jsonInterface.load("custom/mail/"..accountName..".json")
	
	local target = mailbox.mail.inbox[getSlot]
	
	mailbox.mail.inbox[getSlot].hasRead = true
	jsonInterface.save("custom/mail/"..accountName..".json", mailbox)
	
	-- Setup for if the player were to select "Reply":
	mailVar[pid].replyPlayersName = target.mailSendersName
	mailVar[pid].replySubject = target.mailSubject
	
	local sentBody = target.mailBody
	
	local output = " * Back\n * Reply\n * Delete\n"
	output = output..config.ColorMsgBox.."~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n"..config.ColorMsgBox..
	"From: "..config.ColorPreview..target.mailSendersName.."\n"..config.ColorMsgBox..
	"Sent: "..config.ColorPreview..target.mailDate.."\n"..config.ColorMsgBox..
	"Subject: "..config.ColorPreview..target.mailSubject.."\n"..config.ColorMsgBox..
	"Message:\n"..config.ColorPreview
	
	local bodyOutString = ""
	
	if sentBody ~= "" then
			local maxLine = 47
			local currentChars = 0
			local wordList = {}

			for w in sentBody:gmatch("%S+") do table.insert(wordList, w) end

			for _, word in pairs(wordList) do
				
				currentChars = currentChars + word:len()
				
				if string.match(word, "/n") then
					bodyOutString = bodyOutString..config.ColorPreview..string.gsub( word, "(/n)", "" ).."\n"
					currentChars = 5 + word:len() + 1
				
				elseif string.match(word, "/r") then
					bodyOutString = bodyOutString..config.ColorPreview..string.gsub( word, "(/r)", Players[pid].accountName )
					currentChars = 5 + word:len() + 1				
				else
				
					if currentChars > maxLine then
						bodyOutString = bodyOutString .. "\n"..config.ColorPreview..word.." "
						currentChars = 5 + word:len() + 1
					else
						bodyOutString = bodyOutString..config.ColorPreview..word.." "
						currentChars = currentChars + 1
					end
					
				end
			end
			bodyOutString = bodyOutString .. "\n" 
	
	end
	output = output..bodyOutString
	
	return tes3mp.ListBox(pid, config.mailSystemMailViewerGUI, message, output)	
	
end



-- Check Subject Field
local sendMailMessageSubjectCheck = function(pid)
	
	if mailVar[pid] ~= nil and mailVar[pid].subject ~= nil and mailVar[pid].subject ~= "" then 
		
		local subjectText = mailVar[pid].subject
		
		subjectText = subjectText:sub(1,config.subjectCharaLimit)
		local limitAmount = config.subjectCharaLimit - 3
		if string.len(tostring(subjectText)) > limitAmount then
			subjectText = subjectText .. config.tldrColor .. "..."
			tes3mp.SendMessage(pid, color.Error.."Your subject was too many characters.\n", false)
		end
		
		mailVar[pid].subject = subjectText
		
	end
	
end

-- Check Body Field
local sendMailMessageBodyCheck = function(pid)
	
	if mailVar[pid] ~= nil and mailVar[pid].body ~= nil and mailVar[pid].body ~= "" then 
		
		local bodyText = mailVar[pid].body
		
		bodyText = bodyText:sub(1,config.bodyCharaLimit)
		local limitAmount = config.bodyCharaLimit - 3
		if string.len(tostring(bodyText)) > limitAmount then
			bodyText = bodyText .. config.tldrColor .. "..."
			tes3mp.SendMessage(pid, color.Error.."Your message was too many characters.\n", false)
		end
		
		mailVar[pid].body = bodyText
		
	end
	
end


local getPlayersMailLimit = function(staffRank)
	
	local amount = config.mailSystemMaxLettersCount
	
	if staffRank == 1 then
		amount = config.mailSystemMaxModLettersCount
	elseif staffRank == 2 then
		amount = config.mailSystemMaxAdminLettersCount
	elseif staffRank == 3 then
		amount = config.mailSystemMaxOwnerLettersCount
	end
	
	return amount
	
end


local sendTheMailToPlayer = function(pid)
	
	local name = string.lower(mailVar[pid].initialReceiverName)
	
	if checkIfPlayerExists(pid, name) then
		
		local accountName = fileHelper.fixFilename(name)
		local mailbox = jsonInterface.load("custom/mail/"..accountName..".json")

		local mailAddition = {
			mailTime = os.time(),
			mailDate = os.date("%m/%d/%y %H:%M:%S"),
			mailSendersName = Players[pid].accountName,
			mailSubject = mailVar[pid].subject,
			mailBody = mailVar[pid].body
		}
		
		local mailCount = #mailbox.mail.inbox or 0
		if mailCount >= getPlayersMailLimit(mailbox.staffRank) and Players[pid].data.settings.staffRank < config.staffRankBypassMaxMail then
			tes3mp.SendMessage(pid, config.mailboxIsFull.."\n", false)
			return
		end
		
		table.insert(mailbox.mail.inbox, mailAddition)
		
		jsonInterface.save("custom/mail/"..accountName..".json", mailbox)
		
		mailVar[pid].receiver = accountName
		
		logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \""..config.mailSentSfx.."\"")
		
		tes3mp.SendMessage(pid, config.mailSentSuccess.."\n", false)
		
		for tPid, player in pairs(Players) do
			if Players[tPid] ~= nil and Players[tPid]:IsLoggedIn() then
				if string.lower(Players[tPid].accountName) == name then
					youveGotMail(tPid)
				end
			end
		end
		
	end
	
	mailVar[pid] = {}
	
end


local deleteMailFunction = function(pid)
	
	if not pid or not mailVar[pid] or not mailVar[pid].targetMail then return end
	
	local getSlot = mailVar[pid].mailList[tostring(mailVar[pid].targetMail)]
	
	local name = string.lower(Players[pid].accountName)
	local accountName = fileHelper.fixFilename(name)
	local mailbox = jsonInterface.load("custom/mail/"..accountName..".json")
	
	local target = mailbox.mail.inbox[getSlot]
	
	local redistributeInbox = {}
	
	for i=1,#mailbox.mail.inbox do
		if mailbox.mail.inbox[i] ~= target then
			table.insert(redistributeInbox, mailbox.mail.inbox[i])
		else
			table.insert(mailbox.mail.trash, mailbox.mail.inbox[i])
		end
	end
	
	mailbox.mail.inbox = redistributeInbox
	
	jsonInterface.save("custom/mail/"..accountName..".json", mailbox)
	
	tes3mp.SendMessage(pid, config.ColorMsgBox..config.mailDeletedSuccessfully.."\n", false)
	
	return viewMailListGUI(pid)
end


local deleteMailConfirmGUI = function(pid)
	if not pid or not mailVar[pid] or not mailVar[pid].targetMail then return end
	local message = config.ColorMsgBox.."Delete Mail\n\nAre you sure you want to delete this?\n"
	tes3mp.CustomMessageBox(pid, config.mailSystemDeleteGUI, message, "Delete;Cancel;Exit")
end

-- GUI Calls
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	
	if idGui == config.mailSystemMainGUI then
		
		if tonumber(data) == 0 then -- view mail
			viewMailListGUI(pid)
		elseif tonumber(data) == 1 then -- compose mail
			sendMailMenuGUI(pid)
		else -- exit
			return
		end
	
	elseif idGui == config.mailSystemMailGUI then
		
		if tonumber(data) == 0 then -- cancel
			return showMailSystemMainGUI(pid)
		elseif tonumber(data) > 0 and tonumber(data) < 1000 then
			mailVar[pid].targetMail = data
			return viewSpecificMail(pid)
		else
			--return viewMailListGUI(pid)
			return showMailSystemMainGUI(pid)
		end
			
	elseif idGui == config.mailSystemMailViewerGUI then
		
		if tonumber(data) == 0 then -- Back
			return viewMailListGUI(pid)
		elseif tonumber(data) == 1 then -- Reply
			mailVar[pid].receiver = string.lower(mailVar[pid].replyPlayersName)
			mailVar[pid].initialReceiverName = mailVar[pid].replyPlayersName
			mailVar[pid].subject = "Re: "..mailVar[pid].replySubject
			mailVar[pid].body = nil
			return sendMailMenuGUI(pid)
		elseif tonumber(data) == 2 then -- Delete\n
			return deleteMailConfirmGUI(pid)
		else
			return showMailSystemMainGUI(pid)
		end
		
	elseif idGui == config.mailSystemSentMailPreviewGUI then
		
		if tonumber(data) == 0 then -- cancel
			showMailSystemMainGUI(pid)
		elseif tonumber(data) == 1 then -- Send Message
			if canMessageBeSent(pid) then
				sendTheMailToPlayer(pid)
			else
				-- Cannot send message, need more filled out.
				logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \""..config.mailFailedSfx.."\"")
				tes3mp.SendMessage(pid, config.mailMissingFields.."\n", false)
			end
			return showMailSystemMainGUI(pid)
		elseif tonumber(data) == 2 then -- Border Line.
			sendMailMenuGUI(pid)		
		elseif tonumber(data) == 3 then -- recipient name input
			mailRecipientName(pid)
		elseif tonumber(data) == 4 then -- subject input
			mailSubjectInput(pid)
		elseif tonumber(data) == 5 then -- message input
			mailBodyInput(pid)
		else
			return sendMailMenuGUI(pid)
		end
		
	elseif idGui == config.mailSystemRecipientGUI then
		if data ~= nil then
		
			local checkName = tostring(data)
			
			mailVar[pid].sender = string.lower(Players[pid].accountName)
			mailVar[pid].initialSenderName = Players[pid].accountName
			
			--local name = string.lower(Players[pid].accountName)
			local name = string.lower(checkName)
			
			if checkIfPlayerExists(pid, name) then
				mailVar[pid].initialReceiverName = tostring(data)
				
			end
			sendMailMenuGUI(pid)
			
		end
		
	elseif idGui == config.mailSystemSubjectGUI then
		if data ~= nil then
			mailVar[pid].subject = tostring(data)
			sendMailMessageSubjectCheck(pid)
			sendMailMenuGUI(pid)
		end
	
	elseif idGui == config.mailSystemMessageBodyGUI then
		if data ~= nil then
			mailVar[pid].body = tostring(data)
			sendMailMessageBodyCheck(pid)
			sendMailMenuGUI(pid)
		end
	
	-- Delete Mail GUI:
	elseif idGui == config.mailSystemDeleteGUI then
	
		if tonumber(data) == 0 then -- Delete
			return deleteMailFunction(pid)
		elseif tonumber(data) == 1 then -- Cancel
			return viewSpecificMail(pid)
		elseif tonumber(data) == 1 then -- Exit
			return
		else -- Else
			return viewSpecificMail(pid)
		end
		
	end

end)


customCommandHooks.registerCommand("mail", function(pid, cmd)
	mailVar[pid] = {}
	showMailSystemMainGUI(pid)
end)

local checkMailOnLogin = function(pid)
	mailVar[pid] = {}
	checkIfYouveGotMail(pid)
end

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
	checkMailOnLogin(pid)
end)

return mailSystem
