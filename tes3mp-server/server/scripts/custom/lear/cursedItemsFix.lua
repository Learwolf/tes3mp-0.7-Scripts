--[[

Cursed Items Only Trigger Once
cursedItemsFix.lua
	version 1.0



----------------------------------------------------------------------
INSTALLATION:

To instal, simply drag this file into your 
	tes3mp-server/server/scripts/custom 
folder, then open your customScripts.lua found in your
	tes3mp-server/server/scripts/
folder. Add the following line to your customScripts.lua file:close
	require("custom.cursedItemsFix")
save, close the file and you're done.

----------------------------------------------------------------------
INFORMATION:

When picking up a cursed item, the curse is triggered but the item is converted 
into its normal non-cursed version to prevent constant summoning of cursed item creatures.

]]

customEventHooks.registerHandler("OnPlayerInventory", function(eventStatus, pid)

   -- tes3mp.LogMessage(enumerations.log.INFO, "Called \"OnPlayerInventory\" for " .. logicHandler.GetChatName(pid))
	local action = tes3mp.GetInventoryChangesAction(pid)
	local itemChangesCount = tes3mp.GetInventoryChangesSize(pid)

	tes3mp.LogMessage(enumerations.log.INFO, "Saving " .. itemChangesCount .. " item(s) to inventory with action " ..
		tableHelper.getIndexByValue(enumerations.inventory, action))

	--if action == enumerations.inventory.SET then Players[pid].data.inventory = {} end

		for index = 0, itemChangesCount - 1 do
			local itemRefId = tes3mp.GetInventoryItemRefId(pid, index)

			if itemRefId ~= "" then
			
				local item = {
					refId = itemRefId,
					count = tes3mp.GetInventoryItemCount(pid, index),
					charge = tes3mp.GetInventoryItemCharge(pid, index),
					enchantmentCharge = tes3mp.GetInventoryItemEnchantmentCharge(pid, index),
					soul = tes3mp.GetInventoryItemSoul(pid, index)
				}

				tes3mp.LogAppend(enumerations.log.INFO, "- id: " .. item.refId .. ", count: " .. item.count ..
					", charge: " .. item.charge .. ", enchantmentCharge: " .. item.enchantmentCharge ..
					", soul: " .. item.soul)

				if action == enumerations.inventory.SET or action == enumerations.inventory.ADD then

					-- Lear edit Start - Replace cursed objects if applicable
					local usedOverride = false

					if itemRefId == "ingred_cursed_daedras_heart_01" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"ingred_cursed_daedras_heart_01\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"ingred_daedras_heart_01\", 1")
						usedOverride = true
					end
					
					if itemRefId == "ingred_dae_cursed_diamond_01" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"ingred_Dae_cursed_diamond_01\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"ingred_diamond_01\", 1")
						usedOverride = true
					end
					
					if itemRefId == "ebony broadsword_dae_cursed" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"ebony broadsword_Dae_cursed\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"ebony broadsword\", 1")
						usedOverride = true
					end
					
					if itemRefId == "ingred_dae_cursed_emerald_01" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"ingred_Dae_cursed_emerald_01\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"ingred_emerald_01\", 1")
						usedOverride = true
					end
					
					if itemRefId == "fiend spear_dae_cursed" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"fiend spear_Dae_cursed\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"fiend spear\", 1")
						usedOverride = true
					end
					
					if itemRefId == "glass dagger_dae_cursed" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"glass dagger_Dae_cursed\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"glass dagger\", 1")
						usedOverride = true
					end
					
					if itemRefId == "imperial helmet armor_dae_curse" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"imperial helmet armor_Dae_curse\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"imperial helmet armor\", 1")
						usedOverride = true
					end
					
					if itemRefId == "ingred_dae_cursed_pearl_01" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"ingred_dae_cursed_pearl_01\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"ingred_pearl_01\", 1")
						usedOverride = true
					end
					
					if itemRefId == "ingred_dae_cursed_raw_ebony_01" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"ingred_Dae_cursed_raw_ebony_01\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"ingred_raw_ebony_01\", 1")
						usedOverride = true
					end
					
					if itemRefId == "ingred_dae_cursed_ruby_01" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"ingred_Dae_cursed_ruby_01\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"ingred_ruby_01\", 1")
						usedOverride = true
					end
					
					if itemRefId == "light_com_dae_cursed_candle_10" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"light_com_Dae_cursed_candle_10\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"Light_Com_Candle_16\", 1")
						usedOverride = true
					end

					if itemRefId == "misc_dwrv_cursed_coin00" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"misc_dwrv_cursed_coin00\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"misc_dwrv_coin00\", 1")
						usedOverride = true
					end
					
					if itemRefId == "silver dagger_hanin cursed" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"silver dagger_hanin cursed\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"ancient silver dagger noncursed\", 1")
						usedOverride = true
					end
					
					
					-- floating items
					
					if itemRefId == "misc_com_bottle_14_float" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"misc_com_bottle_14_float\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"misc_com_bottle_14\", 1")
						usedOverride = true
					end
					
					if itemRefId == "misc_com_bottle_07_float" then
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->removeitem \"misc_com_bottle_07_float\", 1")
						logicHandler.RunConsoleCommandOnPlayer(pid, "player->additem \"misc_com_bottle_07\", 1")
						usedOverride = true
					end

				end
			end
		end

end)

