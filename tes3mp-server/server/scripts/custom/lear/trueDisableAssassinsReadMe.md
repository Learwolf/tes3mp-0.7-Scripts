This is a tes3mp script that will allow server owners to configure the spawn of Dark Brotherhood Assassins. 
This version is different from other versions as this one will NOT interrupt players while they're sleeping.
This one also includes customizable level requirements and percentage rates to spawn the Assassins.

Requires Custom Hooks version of TES3MP 0.7

To Install This Script:

1) Go into your tes3mp-server folder and make your way to:
	tes3mp-server\server\scripts\custom

2) From here, create a new folder named lear and drop trueDisableAssassins.lua into the `lear` folder.
i.e.>	tes3mp-server\server\scripts\custom\lear

3) Next, backtrack your way to your default scripts folder:
i.e.>	tes3mp-server\server\scripts

4) Find the lua file titled: `customScripts.lua` and open it with a text editor such as notepad.

5) Add the following on a line at the bottom of the list (or on the top row if you have nothing in here.):
	require("custom.lear.trueDisableAssassins")

6) Save and exit. Run your server and enjoy. If you want to edit/customize script settings, make your way back to the `trueDisableAssassins.lua` file in the `lear` folder and edit it.


Script Config/Customization Information:

You can find the configuration the scripts settings at the top of `trueDisableAssassins.lua` when edited in a text editor such as Notepad.
* `dbAssassinsConfig.levelRequirement` will adjust what level the player must be at before Assassins have a chance to spawn when using a bed. 30 is Default
* `dbAssassinsConfig.spawnChance` will set the percentage rate the Assassin spawns once the player using a bed has reached the above level or higher.
		by default, this is set to 100, granting a 100% chance to spawn when a level-met player uses a bed. This can be set to anywhere between 0 and 100.
		0 means Assassins will never spawn. 25 means Assassins have a 25% chance to spawn. 50 means Assassins have a 50% chance to spawn. 
		100 means they have a 100% chance to spawn. etc.
* Players can add or remove additional beds from triggering the potential spawning of Assassins by adding or removing from the `listOfBeds` table. 
		Just be sure you know what you're doing.
		
		
Enjoy the fix!

-Lear