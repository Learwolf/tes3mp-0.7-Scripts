--[[
		TES3MP Mannequins
			by Learwolf
			  V.1.01
	--==----==----==----==----==----==----==----==----==----==----==----==----==----==----==----==--
	-- Installation Notes:
	--==----==----==----==----==----==----==----==----==----==----==----==----==----==----==----==--
		1) Place `mannequinNPC.lua` inside your TES3MP servers `server\scripts\custom` folder.
		2) Open your `customScripts.lua` file in a text editor. 
				(It can be found in `server\scripts` folder.)
		3) Add the below line to your `customScripts.lua` file:
				require("custom.mannequinNPC")
		4) BE SURE THERE IS NO `--` SYMBOLS TO THE LEFT OF IT, ELSE IT WILL NOT WORK.
		5) Restart your server.
		
	--==----==----==----==----==----==----==----==----==----==----==----==----==----==----==----==--
	-- Script Notes
	--==----==----==----==----==----==----==----==----==----==----==----==----==----==----==----==--
		* A current limitation; mannequins cannot be placed in exteriors.
		
		* The mannequin items are available for purchase from the Mannequin Shop, which can be accessed 
			with the in-game chat command:
				/mannequins
			
		* By default, when a player places a mannequin, it will be locked to everyone else except 
			who placed it. That player can unlock it by activating their placed mannequin and 
			toggling the option to unlock it.
		
		* By default, Admins or higher can access any mannequin, regardless if locked. This is 
			adjustable in this scripts config section.
		
		* Mannequins can display a players currently equipped items.
		
		* Players can equip a mannequins currently displayed gear.
		
		* Players can remove the mannequins display gear completely.
		
		* Mannequins can be used as training dummies.
		
		* Players can pick up mannequins.
		
	--==----==----==----==----==----==----==----==----==----==----==----==----==----==----==----==--
	--	Version History
	--==----==----==----==----==----==----==----==----==----==----==----==----==----==----==----==--
			Version 1.01 (4/3/2020)
				- Revision for public release.
				- Added method for players to lock mannequins.
	
			Version 1.00 (3/31/2020)
				- Initial release for the Nerevarine Prophecies server.

	--==----==----==----==----==----==----==----==----==----==----==----==----==----==----==----==--
	--	List of Mannequin Item refIds:
	--==----==----==----==----==----==----==----==----==----==----==----==----==----==----==----==--
		"mannequin_script_item_dunmer_male"
		"mannequin_script_item_dunmer_female"
		"mannequin_script_item_breton_male"
		"mannequin_script_item_breton_female"
		"mannequin_script_item_altmer_male"
		"mannequin_script_item_altmer_female"
		"mannequin_script_item_imperial_male"
		"mannequin_script_item_imperial_female"
		"mannequin_script_item_nord_male"
		"mannequin_script_item_nord_female"
		"mannequin_script_item_orc_male"
		"mannequin_script_item_orc_female"
		"mannequin_script_item_redguard_male"
		"mannequin_script_item_redguard_female"
		"mannequin_script_item_bosmer_male"
		"mannequin_script_item_bosmer_female"
		
--]]



mannequinNPC = {} -- Don't Touch.
local config = {} -- Don't Touch.
--==----==----==----==----==----==----==----==--
-- SERVER OWNER CONFIGURATION SETTINGS:
-- Feel free to read and adjust the below.
--==----==----==----==----==----==----==----==--

config.MenuTextColor = "#AB8C53" -- Set this to the color you want mannequin menu text.

config.LockByDefault = true -- True locks mannequins to whoever placed them by default.
							-- False requires players to manually lock them.
														
config.StaffRankToBypassLock = 2 	-- This is the minimum staffRank that is allowed
									-- to bypass locked mannequins.
									-- 3 = owner; 2 = admin; 1 = mods; 0 = anyone.

config.DefaultMannequinPrice = 25000	-- This is the default price of mannequinShopInventory
										-- when purchased from the mannequin shop.

--==----==----==----==----==----==----==----==--
-- 
-- 	DON't TOUCH ANYTHING BELOW HERE
-- 
-- 	UNLESS YOU KNOW WHAT YOU'RE DOING!!
-- 
--==----==----==----==----==----==----==----==--
config.mannequinDisplayEquipmentOptions = 03302030
config.menuMannequinShop = 03302031

mannequinShopInventory = {
	{name = "Mannequin: Altmer Male", refId = "mannequin_script_item_altmer_male", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Altmer Female", refId = "mannequin_script_item_altmer_female", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Bosmer Male", refId = "mannequin_script_item_bosmer_male", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Bosmer Female", refId = "mannequin_script_item_bosmer_female", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Breton Male", refId = "mannequin_script_item_breton_male", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Breton Female", refId = "mannequin_script_item_breton_female", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Dunmer Male", refId = "mannequin_script_item_dunmer_male", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Dunmer Female", refId = "mannequin_script_item_dunmer_female", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Imperial Male", refId = "mannequin_script_item_imperial_male", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Imperial Female", refId = "mannequin_script_item_imperial_female", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Nord Male", refId = "mannequin_script_item_nord_male", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Nord Female", refId = "mannequin_script_item_nord_female", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Orsimer Male", refId = "mannequin_script_item_orc_male", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Orsimer Female", refId = "mannequin_script_item_orc_female", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Redguard Male", refId = "mannequin_script_item_redguard_male", price = config.DefaultMannequinPrice, qty = 1},
	{name = "Mannequin: Redguard Female", refId = "mannequin_script_item_redguard_female", price = config.DefaultMannequinPrice, qty = 1}
}

config.mannequinRefIDs = {
	"mannequin_script_dunmer_male",
	"mannequin_script_dunmer_female",
	"mannequin_script_breton_male",
	"mannequin_script_breton_female",
	"mannequin_script_altmer_male",
	"mannequin_script_altmer_female",
	"mannequin_script_imperial_male",
	"mannequin_script_imperial_female",
	"mannequin_script_nord_male",
	"mannequin_script_nord_female",
	"mannequin_script_orc_male",
	"mannequin_script_orc_female",
	"mannequin_script_redguard_male",
	"mannequin_script_redguard_female",
	"mannequin_script_bosmer_male",
	"mannequin_script_bosmer_female"
}

config.droppableItemsInHome = {
	"mannequin_script_item_dunmer_male",
	"mannequin_script_item_dunmer_female",
	"mannequin_script_item_breton_male",
	"mannequin_script_item_breton_female",
	"mannequin_script_item_altmer_male",
	"mannequin_script_item_altmer_female",
	"mannequin_script_item_imperial_male",
	"mannequin_script_item_imperial_female",
	"mannequin_script_item_nord_male",
	"mannequin_script_item_nord_female",
	"mannequin_script_item_orc_male",
	"mannequin_script_item_orc_female",
	"mannequin_script_item_redguard_male",
	"mannequin_script_item_redguard_female",
	"mannequin_script_item_bosmer_male",
	"mannequin_script_item_bosmer_female"
}

config.mannequinItemToNPC = {
	["mannequin_script_item_dunmer_male"] = "mannequin_script_dunmer_male", 
	["mannequin_script_item_dunmer_female"] = "mannequin_script_dunmer_female",
	["mannequin_script_item_breton_male"] = "mannequin_script_breton_male",
	["mannequin_script_item_breton_female"] = "mannequin_script_breton_female",
	["mannequin_script_item_altmer_male"] = "mannequin_script_altmer_male",
	["mannequin_script_item_altmer_female"] = "mannequin_script_altmer_female",
	["mannequin_script_item_imperial_male"] = "mannequin_script_imperial_male",
	["mannequin_script_item_imperial_female"] = "mannequin_script_imperial_female",
	["mannequin_script_item_nord_male"] = "mannequin_script_nord_male",
	["mannequin_script_item_nord_female"] = "mannequin_script_nord_female",
	["mannequin_script_item_orc_male"] = "mannequin_script_orc_male",
	["mannequin_script_item_orc_female"] = "mannequin_script_orc_female",
	["mannequin_script_item_redguard_male"] = "mannequin_script_redguard_male",
	["mannequin_script_item_redguard_female"] = "mannequin_script_redguard_female",
	["mannequin_script_item_bosmer_male"] = "mannequin_script_bosmer_male",
	["mannequin_script_item_bosmer_female"] = "mannequin_script_bosmer_female"
}



local targetMannequin = {}
local mannequinShop = {}

-- Create the note on server startup:
local function createRecord()
--==----==----==----==----==----==----==----==----==----==----==----==----==--
	local recordStore = RecordStores["spell"]
	recordStore.data.permanentRecords["npc_buffing_mannequin_buff"] = {
		name = "Mannequin Buff",
		subtype = 1, -- subtype = 4,
		cost = 0,
		flags = 0,
		effects = {
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 45, -- Paralyze
				rangeType = 0,
				skill = -1,
				magnitudeMin = 1000,
				magnitudeMax = 1000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 49, -- Calm Humanoid
				rangeType = 0,
				skill = -1,
				magnitudeMin = 1000,
				magnitudeMax = 1000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 68, -- Reflect
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 90, -- Resist Fire
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 91, -- Resist Frost
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 92, -- Resist Shock
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 93, -- Resist Magicka
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 94, -- Resist Common Disease
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 95, -- Resist Blight Disease
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 96, -- Resist Corprus Disease
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 97, -- Resist Poison
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 98, -- Resist Normal Weapons
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 77, -- Restore Fatigue
				rangeType = 0,
				skill = -1,
				magnitudeMin = 20000,
				magnitudeMax = 20000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 67, -- Spell Absorption
				rangeType = 0,
				skill = -1,
				magnitudeMin = 10000,
				magnitudeMax = 10000
			},
			{
				attribute = -1,
				area = 0,
				duration = 10,
				id = 75, -- Restore Health
				rangeType = 0,
				skill = -1,
				magnitudeMin = 200000,
				magnitudeMax = 200000
			}
		}
	}
	
		
--==----==----==----==----==----==----==----==----==----==----==----==----==--
	
	recordStore = RecordStores["npc"]
	
	recordStore.data.permanentRecords["mannequin_script_dunmer_male"] = {
		name = "Mannequin: Dunmer Male",
		--gender = 1,
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "dark elf",
		head = "b_n_dark elf_m_head_06",
		hair = "b_n_dark elf_m_hair_22",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_dunmer_female"] = {
		name = "Mannequin: Dunmer Female",
		gender = 0,
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "dark elf",
		head = "b_n_dark elf_f_head_02",
		hair = "b_n_dark elf_f_hair_01",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_breton_male"] = {
		name = "Mannequin: Breton Male",
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "breton",
		head = "b_n_breton_m_head_05",
		hair = "b_n_breton_m_hair_02",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_breton_female"] = {
		name = "Mannequin: Breton Female",
		gender = 0,
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "breton",
		head = "b_n_breton_f_head_02",
		hair = "b_n_breton_f_hair_02",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_altmer_male"] = {
		name = "Mannequin: Altmer Male",
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "high elf",
		head = "b_n_high elf_m_head_03",
		hair = "b_n_high elf_m_hair_04",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_altmer_female"] = {
		name = "Mannequin: Altmer Female",
		gender = 0,
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "high elf",
		head = "b_n_high elf_f_head_03",
		hair = "b_n_high elf_f_hair_02",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_imperial_male"] = {
		name = "Mannequin: Imperial Male",
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "imperial",
		head = "B_N_Imperial_M_Head_07",
		hair = "b_n_imperial_m_hair_05",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_imperial_female"] = {
		name = "Mannequin: Imperial Female",
		gender = 0,
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "imperial",
		head = "b_n_Imperial_f_head_03",
		hair = "b_n_imperial_f_hair_01",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_nord_male"] = {
		name = "Mannequin: Nord Male",
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "nord",
		head = "b_n_nord_m_head_05",
		hair = "b_n_nord_m_hair01",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_nord_female"] = {
		name = "Mannequin: Nord Female",
		gender = 0,
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "nord",
		head = "b_n_nord_f_head_03",
		hair = "b_n_nord_f_hair_03",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_orc_male"] = {
		name = "Mannequin: Orsimer Male",
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "orc",
		head = "b_n_orc_m_head_01",
		hair = "b_n_orc_m_hair_05",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_orc_female"] = {
		name = "Mannequin: Orsimer Female",
		gender = 0,
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "orc",
		head = "b_n_orc_f_head_02",
		hair = "b_n_orc_f_hair05",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_redguard_male"] = {
		name = "Mannequin: Redguard Male",
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "redguard",
		head = "b_n_redguard_m_head_04",
		hair = "b_n_redguard_m_hair_03",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_redguard_female"] = {
		name = "Mannequin: Redguard Female",
		gender = 0,
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "redguard",
		head = "b_n_redguard_f_head_03",
		hair = "b_n_redguard_f_hair_01",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_bosmer_male"] = {
		name = "Mannequin: Bosmer Male",
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "wood elf",
		head = "b_n_wood elf_m_head_04",
		hair = "b_n_wood elf_m_hair_06",
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_bosmer_female"] = {
		name = "Mannequin: Bosmer Female",
		gender = 0,
		baseId = "belvis sedri",
		health = 999999999,
		fatigue = 999999999,
		level = 9999,
		items = {},
		race = "wood elf",
		head = "b_n_wood elf_f_head_03",
		hair = "b_n_wood elf_f_hair_03",
		script = ""
	}
	recordStore:Save()
	
	
--==----==----==----==----==----==----==----==----==----==----==----==----==--
	
	recordStore = RecordStores["miscellaneous"]
	recordStore.data.permanentRecords["mannequin_script_item_dunmer_male"] = {
		name = "Mannequin: Dunmer Male",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_dunmer_female"] = {
		name = "Mannequin: Dunmer Female",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_breton_male"] = {
		name = "Mannequin: Breton Male",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_breton_female"] = {
		name = "Mannequin: Breton Female",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_altmer_male"] = {
		name = "Mannequin: Altmer Male",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_altmer_female"] = {
		name = "Mannequin: Altmer Female",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_imperial_male"] = {
		name = "Mannequin: Imperial Male",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_imperial_female"] = {
		name = "Mannequin: Imperial Female",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_nord_male"] = {
		name = "Mannequin: Nord Male",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_nord_female"] = {
		name = "Mannequin: Nord Female",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_orc_male"] = {
		name = "Mannequin: Orsimer Male",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_orc_female"] = {
		name = "Mannequin: Orsimer Female",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_redguard_male"] = {
		name = "Mannequin: Redguard Male",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_redguard_female"] = {
		name = "Mannequin: Redguard Female",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_bosmer_male"] = {
		name = "Mannequin: Bosmer Male",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
	recordStore.data.permanentRecords["mannequin_script_item_bosmer_female"] = {
		name = "Mannequin: Bosmer Female",
		icon = "m\\Tx_vivec_ashmask_01.tga",
		model = "m\\Misc_vivec_ashmask_01.NIF",
		weight = 0.5,
		value = 0,
		script = ""
	}
	recordStore:Save()
	
end

local function OnServerPostInit(eventStatus)
	createRecord()
end

customEventHooks.registerHandler("OnServerPostInit", OnServerPostInit)


local pName = function(pid)
	return tostring(Players[pid].accountName)
end

-- Paralyzation of the Mannequin NPC:
local checkForMannequinRefIds = function(pid, cellDescription)
	if LoadedCells[cellDescription] ~= nil then
		for _index,objIndex in pairs(LoadedCells[cellDescription].data.packets.actorList) do
			if cellDescription ~= nil and LoadedCells[cellDescription] ~= nil and LoadedCells[cellDescription].data.objectData[objIndex] ~= nil then 
				local targetRefId = LoadedCells[cellDescription].data.objectData[objIndex].refId
				
				if tableHelper.containsValue(config.mannequinRefIDs, targetRefId) then
					local consoleCommand = "addspell npc_buffing_mannequin_buff"
					logicHandler.RunConsoleCommandOnObject(pid, consoleCommand, cellDescription, objIndex, true)
					LoadedCells[cellDescription]:LoadActorEquipment(pid, LoadedCells[cellDescription].data.objectData, {objIndex})
				end
				
			end
		end
	end
end


mannequinNPC.pushMannequinParalysis = function(pid)
	local cellDescription = tes3mp.GetCell(pid)
	if cellDescription ~= nil and LoadedCells[cellDescription] ~= nil then
		checkForMannequinRefIds(pid, cellDescription)
	end
end

-- Ensure mannequins are paralyzed on cell change:
customEventHooks.registerHandler("OnPlayerCellChange", function(eventStatus, pid)
	mannequinNPC.pushMannequinParalysis(pid)
end)

-- Ensure mannequins are paralyzed on actor list:
customEventHooks.registerHandler("OnActorList", function(eventStatus, pid)
	mannequinNPC.pushMannequinParalysis(pid)
end)


-- Spawn Mannequin When Item Placed In Home:
mannequinNPC.spawnPlacedMannequin = function(pid, refId)
	
	--Players[pid]:QuicksaveToDisk()
	
	
	local cellId = tes3mp.GetCell(pid)
	local location = {posX = tes3mp.GetPosX(pid), posY = tes3mp.GetPosY(pid), posZ = tes3mp.GetPosZ(pid), rotX = tes3mp.GetRotX(pid), rotY = 0, rotZ = tes3mp.GetRotZ(pid)}
	local targetRefId = config.mannequinItemToNPC[refId]
	local targetUniqueIndex = logicHandler.CreateObjectAtLocation(cellId, location, targetRefId, "spawn")
	
	if cellId ~= nil and targetUniqueIndex ~= nil then
		if LoadedCells[cellId] ~= nil then
			LoadedCells[cellId].data.objectData[targetUniqueIndex].equipment = {}
			LoadedCells[cellId].data.objectData[targetUniqueIndex].inventory = {}
			
			
			if config.LockByDefault then
				LoadedCells[cellId].data.objectData[targetUniqueIndex].mannequinOwner = pName(pid)
			end
			
			-- Reload Mannequin For Players In Cell:
			for tPid, player in pairs(Players) do
				if LoadedCells[cellId] ~= nil then
					local uniqueIndexArray = {targetUniqueIndex}
					LoadedCells[cellId]:LoadActorEquipment(tPid, LoadedCells[cellId].data.objectData, uniqueIndexArray)
				end
			end
		end
	end
	
end



-- Spawn Mannequin Delete From Home:
mannequinNPC.deletePlacedMannequin = function(pid)
	
	if targetMannequin[pid] ~= nil then
		
		local cellDescription = targetMannequin[pid].cell
		local tRefId = targetMannequin[pid].refId
		local tUniqueIndex = targetMannequin[pid].uniqueIndex
	
		if cellDescription == nil or tUniqueIndex == nil or tRefId == nil then return end
		
		mannequinNPC.takeMannequinEquipment(pid)
		
		for itemRefId,npcRefId in pairs(config.mannequinItemToNPC) do
			if npcRefId == tRefId then
				mannequinNPC.add(pid, itemRefId, 1)
				logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Misc Up\"")
			end
		end
		
		for pid, player in pairs(Players) do
			if Players[pid] ~= nil and player:IsLoggedIn() then
				if LoadedCells[cellDescription] ~= nil then
					logicHandler.DeleteObject(pid, cellDescription, tUniqueIndex, true)
					LoadedCells[cellDescription]:DeleteObjectData(tUniqueIndex)
				end
			end
		end
		
	end
	
end	



-- Equip the mannequins equipment:
mannequinNPC.equipMannequinsEquipment = function(pid)
	if targetMannequin[pid] ~= nil then
		local cell = targetMannequin[pid].cell
		local tRefId = targetMannequin[pid].refId
		local tUniqueIndex = targetMannequin[pid].uniqueIndex
		
		if cell ~= nil and tUniqueIndex ~= nil then
			if LoadedCells[cell] ~= nil then	
				
				if LoadedCells[cell].data.objectData[tUniqueIndex].inventory ~= nil and not tableHelper.isEmpty(LoadedCells[cell].data.objectData[tUniqueIndex].inventory) then
					local inventoryItems = 0
					for iSlot,iData in pairs(LoadedCells[cell].data.objectData[tUniqueIndex].inventory) do
						local iRefId = iData.refId
						local iCount = iData.count
						local iECharge = iData.enchantmentCharge
						local iCharge = iData.charge
						local iSoul = iData.soul
						mannequinNPC.add(pid, iRefId, iCount, iSoul, iCharge, iECharge)
						inventoryItems = inventoryItems + 1
					end
					
					if inventoryItems > 0 then
						local plural = "items."
						if inventoryItems == 1 then
							plural = "item."
						end	
						
						tes3mp.MessageBox(pid, -1, config.MenuTextColor.."You have received "..color.White..inventoryItems..config.MenuTextColor.." display "..plural)
						logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Misc Up\"")						
						
						-- Reload Mannequin For Players In Cell:
						--for tPid, player in pairs(Players) do				
							mannequinNPC.reloadNPCEquipment(pid)
						--end
					end					
					
				end
				
				if LoadedCells[cell].data.objectData[tUniqueIndex].equipment ~= nil and not tableHelper.isEmpty(LoadedCells[cell].data.objectData[tUniqueIndex].equipment) then
					local equippedItemCount = 0
					for iSlot,iData in pairs(LoadedCells[cell].data.objectData[tUniqueIndex].equipment) do
						equippedItemCount = equippedItemCount + 1
					end
					
					if equippedItemCount > 0 then
						local plural = "items."
						if equippedItemCount == 1 then
							plural = "item."
						end	
						
						tes3mp.MessageBox(pid, -1, config.MenuTextColor.."You have equipped "..color.White..equippedItemCount..config.MenuTextColor.." display "..plural)
						local equipmentTransfer = LoadedCells[cell].data.objectData[tUniqueIndex].equipment
						logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Misc Up\"")
						
						Players[pid].data.equipment = equipmentTransfer
						Players[pid]:LoadEquipment()
						
						
						-- Pull equipment:
						LoadedCells[cell].data.objectData[tUniqueIndex].inventory = {}
						LoadedCells[cell].data.objectData[tUniqueIndex].equipment = {}
				
						-- Reload Mannequin For Players In Cell:
						--for tPid, player in pairs(Players) do				
							mannequinNPC.reloadNPCEquipment(pid)
						--end
					end					
					
				end
							
			end
			
		end
		
	end
end

-- Remove All Mannequins Equipment:
mannequinNPC.takeMannequinEquipment = function(pid)
	if targetMannequin[pid] ~= nil then
		local cell = targetMannequin[pid].cell
		local tRefId = targetMannequin[pid].refId
		local tUniqueIndex = targetMannequin[pid].uniqueIndex
		
		if cell ~= nil and tUniqueIndex ~= nil then
			if LoadedCells[cell] ~= nil then
				-- Pull inventory items:
				if LoadedCells[cell].data.objectData[tUniqueIndex].inventory ~= nil and not tableHelper.isEmpty(LoadedCells[cell].data.objectData[tUniqueIndex].inventory) then
					local inventoryCounter = 0
					for iSlot,iData in pairs(LoadedCells[cell].data.objectData[tUniqueIndex].inventory) do
						local iRefId = iData.refId
						local iCount = iData.count
						local iECharge = iData.enchantmentCharge
						local iCharge = iData.charge
						local iSoul = iData.soul
						mannequinNPC.add(pid, iRefId, iCount, iSoul, iCharge, iECharge)
						inventoryCounter = inventoryCounter + 1
					end
					local plural = "items have"
					if equippedItemCount == 1 then
						plural = "item has"
					end	
						
					tes3mp.MessageBox(pid, -1, "This mannequins "..inventoryCounter.." display "..plural.." been added to your inventory.")
					logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Misc Up\"")
					
				end
				-- Pull equipment:
				LoadedCells[cell].data.objectData[tUniqueIndex].inventory = {}
				LoadedCells[cell].data.objectData[tUniqueIndex].equipment = {}
				
				-- Reload Mannequin For Players In Cell:
				--for tPid, player in pairs(Players) do				
					mannequinNPC.reloadNPCEquipment(pid)
				--end
				
			end
			
		end
		
	end
end

-- -- Add Equipment As Mannequins Equipment:
mannequinNPC.addMannequinEquipment = function(pid)
	if targetMannequin[pid] ~= nil then
		local cell = targetMannequin[pid].cell
		local tRefId = targetMannequin[pid].refId
		local tUniqueIndex = targetMannequin[pid].uniqueIndex
		
		
		if cell ~= nil and tUniqueIndex ~= nil then
			mannequinNPC.takeMannequinEquipment(pid)
			if Players[pid].data.equipment ~= nil and not tableHelper.isEmpty(Players[pid].data.equipment) then
				local equipmentTransfer = Players[pid].data.equipment
				local displayCount = 0
				
				for eSlot,eData in pairs(Players[pid].data.equipment) do
					displayCount = displayCount + 1
					
					local eRefId = eData.refId
					local eCount = eData.count
					local eSoul = eData.soul or ""
					local eCharge = eData.charge
					local eECharge = eData.enchantmentCharge
					
					mannequinNPC.remove(pid, eRefId, eCount, eSoul, eCharge, eECharge)
					local addInventoryItem = {refId = eRefId, enchantmentCharge = eECharge, count = eCount, charge = eCharge, soul = eSoul}
					if LoadedCells[cell].data.objectData[tUniqueIndex].inventory == nil then 
						LoadedCells[cell].data.objectData[tUniqueIndex].inventory = {}
					end
					table.insert(LoadedCells[cell].data.objectData[tUniqueIndex].inventory, addInventoryItem)
				end
				LoadedCells[cell].data.objectData[tUniqueIndex].equipment = equipmentTransfer
				
				local plural = "items are"
				if displayCount == 1 then
					plural = "item is"
				end				
				tes3mp.MessageBox(pid, -1, color.White..displayCount.." "..config.MenuTextColor..plural.." now displayed on this mannequin.")
				
				-- Reload Mannequin For Players In Cell:
				--for tPid, player in pairs(Players) do				
					mannequinNPC.reloadNPCEquipment(pid)
				--end
			
			else
				tes3mp.MessageBox(pid, -1, "You must have equipped items in order to display them on the mannequin.")
			end
			
		end
		
	end
end




-- Run This Function When an NPCs equipment has changed:
mannequinNPC.reloadNPCEquipment = function(pid)
	if targetMannequin[pid] ~= nil then
		local cell = targetMannequin[pid].cell
		local tRefId = targetMannequin[pid].refId
		local tUniqueIndex = targetMannequin[pid].uniqueIndex
		
		if cell ~= nil and tUniqueIndex ~= nil then
			for tPid, player in pairs(Players) do
				if LoadedCells[cell] ~= nil then
					
					local uniqueIndexArray = {tUniqueIndex}
					LoadedCells[cell]:LoadActorEquipment(tPid, LoadedCells[cell].data.objectData, uniqueIndexArray)
					
				end
			end
		end
		
	end
end

-- When the mannequin is activated:
mannequinNPC.activateMannequin = function(pid, cellDescription, tRefId, tUniqueIndex)
	
	if LoadedCells[cellDescription] ~= nil and tUniqueIndex ~= nil then
		
		if Players[pid].data.settings.staffRank < config.StaffRankToBypassLock then
			local mOwner = LoadedCells[cellDescription].data.objectData[tUniqueIndex].mannequinOwner
			if mOwner ~= nil and mOwner ~= pName(pid) then 
				local txt = config.MenuTextColor.."This mannequin has been locked by "..color.Yellow..mOwner..config.MenuTextColor.."."
				tes3mp.MessageBox(pid, -1, txt)
				return
			end
		end
		
		targetMannequin[pid] = {}
		targetMannequin[pid].cell = cellDescription
		targetMannequin[pid].refId = tRefId
		targetMannequin[pid].uniqueIndex = tUniqueIndex
		
		mannequinNPC.menuActivatedMannequin(pid)
		
		--LoadedCells[cellDescription]:LoadActorEquipment(pid, objectData, uniqueIndexArray)
		local uniqueIndexArray = {tUniqueIndex}
		LoadedCells[cellDescription]:LoadActorEquipment(pid, LoadedCells[cellDescription].data.objectData, uniqueIndexArray)
	end
	
end




-- Mannequin Menu:
mannequinNPC.menuActivatedMannequin = function(pid)
	
	if targetMannequin[pid] ~= nil then
		local cellDescription = targetMannequin[pid].cell
		local tUniqueIndex = targetMannequin[pid].uniqueIndex
		
		if cellDescription ~= nil and tUniqueIndex ~= nil then
			local msg = color.Orange.."Mannequin Menu:\n\n"..config.MenuTextColor..
				color.Yellow.."Display My Equipment "..config.MenuTextColor..
				"will give this mannequin any items you have equipped to display.\n\n"..
				color.Yellow.."Remove Display Equipment "..config.MenuTextColor..
				"will return any display equipment to your inventory.\n\n"..
				color.Yellow.."Equip This Outfit "..config.MenuTextColor..
				"will retrieve and equip this mannequins display equipment.\n\n"..
				color.Yellow.."Pick Up "..config.MenuTextColor..
				"will return any equipment as well as this mannequin itself to your inventory.\n\n"
			
			local lockedTxt = color.Red.."[Locked] "..config.MenuTextColor.."This mannequin is currently only accessible by you.\n"
			local lockChoice = color.Red.."[Locked]"
			local mOwner = LoadedCells[cellDescription].data.objectData[tUniqueIndex].mannequinOwner
			if mOwner == nil then 
				lockedTxt = color.Green.."[Unlocked] "..config.MenuTextColor.."This mannequin is currently accessible by anyone.\n"
				lockChoice = color.Green.."[Unlocked]"
			else
				if Players[pid].data.settings.staffRank >= config.StaffRankToBypassLock then
					lockedTxt = color.Red.."[Locked] "..config.MenuTextColor.."This mannequin is currently only accessible by "..color.Yellow..mOwner..config.MenuTextColor..".\n"
				end
			end
			
			msg = msg..lockedTxt
			
			tes3mp.CustomMessageBox(pid, config.mannequinDisplayEquipmentOptions, msg, "Display My Equipment;Remove Display Equipment;Equip This Outfit;Pick Up;"..lockChoice..";Exit")	
			
		end
	end
	
end


local pullMannequinShopInventory = function()
	
	local items = {}
	
	for i = 1, #mannequinShopInventory do
		table.insert(items, mannequinShopInventory[i])
	end
	
	return items
end

local getPlayerCurrencyAmount = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		if inventoryHelper.containsItem(Players[pid].data.inventory, "gold_001") then
			local goldLoc = inventoryHelper.getItemIndex(Players[pid].data.inventory, "gold_001")
			if goldLoc then
				return Players[pid].data.inventory[goldLoc].count
			end
		end
	end
	
	return 0
end

-- Mannequin Shop:
mannequinNPC.menuMannequinShop = function(pid)
	
	local label = color.Orange.."Mannequin Shop\n"..config.MenuTextColor.."You have "..getPlayerCurrencyAmount(pid).." gold"
	
	local options = pullMannequinShopInventory()
	local msg = " * Cancel * \n"
	
	
	for i = 1, #options do
		local cashColor = color.Red
		if getPlayerCurrencyAmount(pid) > options[i].price then
			cashColor = color.White
		end
		msg = msg..options[i].name..config.MenuTextColor.."  ("..cashColor..options[i].price..config.MenuTextColor..")\n"
	end
	mannequinShop[tostring(pid)] = options
	
	tes3mp.ListBox(pid, config.menuMannequinShop, label, msg)
end

-- Mannequin Purchase
local purchaseMannequinFunction = function(pid, data)
	
	local pGold = getPlayerCurrencyAmount(pid)
	local choice = mannequinShop[tostring(pid)][data]
	if choice == nil or choice.price == nil then return mannequinNPC.menuMannequinShop(pid) end
	
	if pGold < choice.price then
		tes3mp.MessageBox(pid, -1, "You can not afford " .. choice.name .. ".")
		return mannequinNPC.menuMannequinShop(pid)
	end
	
	local refId = string.lower(choice.refId)
	local cost = choice.price
	
	
	mannequinNPC.remove(pid, "gold_001", cost)
	mannequinNPC.add(pid, refId, choice.qty)
	logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Gold Down\"")
	logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Misc Up\"")
	tes3mp.MessageBox(pid, -1, "You purchased "..choice.qty.." "..choice.name.." for "..cost.." gold.")
	
	return mannequinNPC.menuMannequinShop(pid)
	
end

-- GUI Handler:
customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, idGui, data)
	
	if idGui == config.mannequinDisplayEquipmentOptions then -- 
		if tonumber(data) == 0 then -- Display My Equipment
			mannequinNPC.addMannequinEquipment(pid)
			return
		elseif tonumber(data) == 1 then -- Remove Display Equipment
			mannequinNPC.takeMannequinEquipment(pid)
			return
		elseif tonumber(data) == 2 then -- Equip This Outfit
			mannequinNPC.equipMannequinsEquipment(pid)
			return
		elseif tonumber(data) == 3 then -- Pick Up Mannequin
			mannequinNPC.deletePlacedMannequin(pid)
			return
		elseif tonumber(data) == 4 then -- Lock/Unlock
			if targetMannequin[pid] ~= nil then
				local cellDescription = targetMannequin[pid].cell
				local tRefId = targetMannequin[pid].refId
				local tUniqueIndex = targetMannequin[pid].uniqueIndex
			
				if LoadedCells[cellDescription].data.objectData[tUniqueIndex].mannequinOwner == nil then
					LoadedCells[cellDescription].data.objectData[tUniqueIndex].mannequinOwner = pName(pid)
					tes3mp.MessageBox(pid, -1, "This mannequin can now only be activated by you.")
				else
					LoadedCells[cellDescription].data.objectData[tUniqueIndex].mannequinOwner = nil
					tes3mp.MessageBox(pid, -1, "This mannequin can now be activated by anyone.")
				end
				return mannequinNPC.menuActivatedMannequin(pid)
			end
		else -- Exit
			return
		end
	
	elseif idGui == config.menuMannequinShop then
		--mannequinShop[tostring(pid)] = options
		if tonumber(data) == 0 or tonumber(data) > 1000 then --Close/Nothing Selected
			return
		else
			return purchaseMannequinFunction(pid, tonumber(data))
		end
		
	end
	
end)



-- ObjectActivateValidator:
function mannequinNPC.OnObjectActivateValidator(eventStatus, pid, cellDescription, objects, players)
    for _, object in pairs(objects) do
		if tableHelper.containsValue(config.mannequinRefIDs, object.refId) then
				
			if not Players[pid].data.shapeshift.isWerewolf then	
				local cellDescription = tes3mp.GetCell(pid)
				
				--logicHandler.GetCellContainingActor(tUniqueIndex)
				local tRefId = object.refId
				local tUniqueIndex = object.uniqueIndex
				mannequinNPC.activateMannequin(pid, cellDescription, tRefId, tUniqueIndex)
			end
			
			return customEventHooks.makeEventStatus(false, false)
		end
    end
end

customEventHooks.registerValidator("OnObjectActivate", mannequinNPC.OnObjectActivateValidator)


mannequinNPC.add = function(pid, refId, count, soul, charge, enchantmentCharge)
	if refId == nil then return end
	if count == nil then count = 1 end
	if soul == nil then soul = "" end
	if charge == nil then charge = -1 end
	if enchantmentCharge == nil then enchantmentCharge = -1 end
	
	tes3mp.ClearInventoryChanges(pid)
	tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.ADD)
	tes3mp.AddItemChange(pid, refId, count, charge, enchantmentCharge, soul)
	tes3mp.SendInventoryChanges(pid)
	Players[pid]:SaveInventory()
end

mannequinNPC.remove = function(pid, refId, count, soul, charge, enchantmentCharge)
	if refId == nil then return end
	if count == nil then count = 1 end
	if soul == nil then soul = "" end
	if charge == nil then charge = -1 end
	if enchantmentCharge == nil then enchantmentCharge = -1 end
	
	tes3mp.ClearInventoryChanges(pid)
	tes3mp.SetInventoryChangesAction(pid, enumerations.inventory.REMOVE)
	tes3mp.AddItemChange(pid, refId, count, charge, enchantmentCharge, soul)
	tes3mp.SendInventoryChanges(pid)
	Players[pid]:SaveInventory()
end


local split = function(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function mannequinNPC.OnObjectPlaceValidator(eventStatus, pid, cellDescription, objects)
	
	for i, object in pairs(objects) do
		local temp = split(object.uniqueIndex, "-")
        local RefNum = temp[1]
		local MpNum = temp[2]
		local refId = object.refId
		
		local itemSoul = tes3mp.GetObjectSoul(i-1)
		local count = tes3mp.GetObjectCount(i-1)
		local itemCharge = tes3mp.GetObjectCharge(i-1)
        local itemEnchantmentCharge = tes3mp.GetObjectEnchantmentCharge(i-1)
		
		if tableHelper.containsValue(config.droppableItemsInHome, refId) then
		
			if LoadedCells[cellDescription].isExterior then
				tes3mp.MessageBox(pid, -1, "Mannequins cannot be placed in exteriors.")
				logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Misc Up\"")
				mannequinNPC.add(pid, refId, count)
			else
				if count > 1 then
					tes3mp.MessageBox(pid, -1, "You can only place one of these at a time.")
					logicHandler.RunConsoleCommandOnPlayer(pid, "PlaySound \"Item Misc Up\"")
					local dropCount = count - 1
					mannequinNPC.add(pid, refId, dropCount)
				end
				
				mannequinNPC.spawnPlacedMannequin(pid, refId)
				mannequinNPC.pushMannequinParalysis(pid)
			end
			
			return customEventHooks.makeEventStatus(false, false)
		end
	end
	
end

customEventHooks.registerValidator("OnObjectPlace", mannequinNPC.OnObjectPlaceValidator)



-- Commands
customCommandHooks.registerCommand("mannequins", function(pid, cmd)
	mannequinNPC.menuMannequinShop(pid)
end)

return mannequinNPC