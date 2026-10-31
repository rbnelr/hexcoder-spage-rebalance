local const = require("const")
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

local function hard_intermediates()
	-- raw cost: vanilla -> mod, ore/coal/stone 1, oil fluids 1/10, water 0, assemblers and furnaces without modules
	-- machines: how much cheaper data_updates-game machines make it, vanilla and mod each against its own raw cost:
	--   foundry casting and EM plant wherever cheaper, prod 3 in every machine
	--   (vanilla foundry 90%, EM plant 100%, AM3 40% -> mod 30%, 65%, 30%); see tools/item_costs.py

	-- raw cost 2 -> 2.5 (1.25x)
	-- machines: vanilla 2 -> 0.28 (7.2x), mod 2.5 -> 1.06 (2.4x)
	meld(data.raw["recipe"]["iron-gear-wheel"], {
		energy_required = 1.5, -- was 0.5
		ingredients = meld.overwrite{
			{ type = "item", name = "iron-plate", amount = 5 }, -- was 2
		},
		results = meld.overwrite{
			{ type = "item", name = "iron-gear-wheel", amount = 2 }, -- was 1
		},
	})

	-- raw cost 0.5 -> 0.75 (1.5x)
	-- machines: vanilla 0.5 -> 0.069 (7.2x), mod 0.75 -> 0.29 (2.6x)
	meld(data.raw["recipe"]["copper-cable"], {
		energy_required = 1, -- was 0.5
		ingredients = meld.overwrite{
			{ type = "item", name = "copper-plate", amount = 3 }, -- was 1
		},
		results = meld.overwrite{
			{ type = "item", name = "copper-cable", amount = 4 }, -- was 2
		},
	})

	-- raw cost 5 -> 6 (1.2x)
	-- machines: vanilla 5 -> 0.83 (6.0x), mod 6 -> 2.68 (2.2x)
	meld(data.raw["recipe"]["steel-plate"], {
		energy_required = 16,
		ingredients = meld.overwrite{
			{ type = "item", name = "iron-plate", amount = 6 }, -- was 5
			--{ type = "item", name = "coal", amount = 1 }, -- furnace can only have one input slot!
		},
	})

	-- raw cost 9 -> 12 (1.33x)
	-- machines: vanilla 9 -> 1.19 (7.6x), mod 12 -> 4.26 (2.8x)
	meld(data.raw["recipe"]["engine-unit"], {
		energy_required = 12, -- was 10
		ingredients = meld.overwrite{
			{ type = "item", name = "iron-stick", amount = 1 }, -- new
			{ type = "item", name = "steel-plate", amount = 2 }, -- was 1
			{ type = "item", name = "iron-gear-wheel", amount = 3 }, -- was 1
			{ type = "item", name = "pipe", amount = 4 }, -- was 2
		},
		results = meld.overwrite{
			{ type = "item", name = "engine-unit", amount = 2 }, -- was 1
		},
	})

	-- raw cost 15.5 -> 24.25 (1.56x)
	-- machines: vanilla 15.5 -> 2.02 (7.7x), mod 24.25 -> 7.08 (3.4x)
	meld(data.raw["recipe"]["electric-engine-unit"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "electronic-circuit", amount = 2 },
			{ type = "item", name = "engine-unit", amount = 1 },
			{ type = "item", name = "copper-cable", amount = 5 }, -- new
			{ type = "fluid", name = "lubricant", amount = 15 },
		},
		results = meld.overwrite{
			{ type = "item", name = "electric-engine-unit", amount = 1 },
		},
	})

	-- explosives take petroleum, requiring oil production in space and potentially on gleba
	-- TODO: test how expensive this is in space, how much coal for the petroleum with coal liquefaction
	-- raw cost 1.25 -> 2.6 (2.08x)
	-- machines: vanilla 1.25 -> 0.83 (1.5x), mod 2.6 -> 1.96 (1.3x)
	meld(data.raw["recipe"]["explosives"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "coal", amount = 1 },
			{ type = "item", name = "sulfur", amount = 2 }, -- was 1
			{ type = "fluid", name = "petroleum-gas", amount = 12 }, -- was 10 water
		},
	})

	-- raw cost 10 -> 17.25 (1.73x)
	-- machines: vanilla 10 -> 1.53 (6.5x), mod 17.25 -> 4.63 (3.7x)
	meld(data.raw["recipe"]["advanced-circuit"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "plastic-bar",    amount = 3 }, -- was 2
			{ type = "item", name = "copper-cable",   amount = 4 },
			{ type = "item", name = "electronic-circuit", amount = 3 }, -- was 2
		},
	})

	-- raw cost 70.85 -> 132.47 (1.87x)
	-- machines: vanilla 70.85 -> 4.19 (16.9x), mod 132.47 -> 22.8 (5.8x)
	meld(data.raw["recipe"]["processing-unit"], {
		energy_required = 12, -- was 10
		ingredients = meld.overwrite{
			{ type = "item", name = "electronic-circuit", amount = 24 }, -- was 20
			{ type = "item", name = "advanced-circuit", amount = 3 }, -- was 2
			{ type = "fluid", name = "sulfuric-acid",  amount = 16 }, -- was 5
		},
	})
	
	-- make vulcanus lubricant cost more extreme
	-- raw cost 0.1 -> 0.133 (1.33x)
	-- machines: vanilla 0.1 -> 0.077 (1.3x), mod 0.133 -> 0.111 (1.2x)
	meld(data.raw["recipe"]["lubricant"], {
		energy_required = 4, -- was 1
		ingredients = meld.overwrite{
			{ type = "fluid", name = "heavy-oil", amount = 32 }, -- was 10
		},
		results = meld.overwrite{
			{ type = "fluid", name = "lubricant", amount = 24 }, -- was 10
		},
	})
	
	-- nerf LDS in a complex way: 0.8 LDS per craft, 20% chance of 2-5 plastic back (0.7 avg)
	-- raw cost 37.5 -> 48.06 (1.28x)
	-- machines: vanilla 37.5 -> 9.27 (4.0x), mod 48.06 -> 18.9 (2.5x), casting is the cheaper route
	meld(data.raw["recipe"]["low-density-structure"], {
		main_product = "low-density-structure",
		results = meld.overwrite{
			{ type = "item", name = "low-density-structure", amount = 1, shared_probability={min=0,max=0.8} },
			{ type = "item", name = "plastic-bar", amount_min = 2, amount_max = 5, shared_probability={min=0.8,max=1} },
		},
	})

	-- stick fuckery
	meld(data.raw["technology"]["automation"], {
		effects = common.meld_add_or_assign{{type = "unlock-recipe", recipe = "iron-stick"}}
	})
	for _,tech in pairs{"railway", "circuit-network", "electric-energy-distribution-1", "concrete"} do
		meld(data.raw["technology"][tech], {
			effects = common.meld_remove{{type = "unlock-recipe", recipe = "iron-stick"}},
			prerequisites = common.meld_add_or_assign{"automation"},
		})
	end
end

---- Science packs: harder recipes, plus the recipes and techs adjusted to match (hard science setting)
local function science()
	-- mostly stolen from Science Difficulty Overhaul: Harder Science Packs - Cubickman
	
	-- raw cost 3 -> 5.75 (1.92x)
	-- machines: vanilla 3 -> 0.40 (7.6x), mod 5.75 -> 1.97 (2.9x)
	meld(data.raw["recipe"]["automation-science-pack"], {
		energy_required = 6, -- was 5
		ingredients = meld.overwrite{
			{ type = "item", name = "copper-cable",    amount = 3 }, -- new, was 1 copper-plate
			{ type = "item", name = "burner-inserter", amount = 1 } -- new, was 1 iron-gear-wheel
		},
	})
	
	meld(data.raw["recipe"]["long-handed-inserter"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "inserter", amount = 1 },
			{ type = "item", name = "iron-stick", amount = 1 }, -- new, was 1 iron-plate
			{ type = "item", name = "iron-gear-wheel", amount = 1 },
		}
	})
	-- raw cost 7 -> 13.25 (1.89x)
	-- machines: vanilla 7 -> 0.77 (9.1x), mod 13.25 -> 4.29 (3.1x)
	meld(data.raw["recipe"]["logistic-science-pack"], {
		energy_required = 8, -- was 6
		ingredients = meld.overwrite{
			{ type = "item", name = "long-handed-inserter", amount = 1 }, -- new, was 1 inserter
			{ type = "item", name = "transport-belt",       amount = 2 } -- was 1
		},
	})
	meld(data.raw["technology"]["logistic-science-pack"], {
		prerequisites = common.meld_add_or_assign{"automation"}
	})

	-- raw cost 21.25 -> 48 (2.26x)
	-- machines: vanilla 21.25 -> 10.7 (2.0x), mod 48 -> 22.3 (2.2x)
	meld(data.raw["recipe"]["military-science-pack"], {
		energy_required = 14, -- was 10
		ingredients = meld.overwrite{
			{ type = "item", name = "piercing-rounds-magazine", amount = 3 }, -- was 1
			{ type = "item", name = "grenade",                  amount = 1 },
			{ type = "item", name = "gate",                     amount = 2 } -- new, was 2 stone-wall
		},
	})
	meld(data.raw["technology"]["military-science-pack"], {
		prerequisites = common.meld_add_or_assign{"gate"}
	})

	-- raw cost 24.75 -> 61.6 (2.49x)
	-- machines: vanilla 24.75 -> 2.90 (8.5x), mod 61.6 -> 16.4 (3.8x)
	-- pump is interesting, maybe a bit expensive?
	meld(data.raw["recipe"]["chemical-science-pack"], {
		energy_required = 28, -- was 24
		ingredients = meld.overwrite{
			{ type = "item", name = "pump",             amount = 2 }, -- new, was 2 engine-unit
			{ type = "item", name = "battery",          amount = 3 }, -- new, was 1 sulfur
			{ type = "item", name = "advanced-circuit", amount = 4 } -- was 3
		},
	})
	meld(data.raw["technology"]["chemical-science-pack"], {
		prerequisites = common.meld_add_or_assign{"battery"}
	})
	
	meld(data.raw["recipe"]["electric-furnace"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "steel-plate",      amount = 4 }, -- was 10, lowered to match steel going into steel-furnace
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "steel-furnace",    amount = 1 }, -- new, was 10 stone-brick
		},
	})
	-- raw cost 93.33 -> 157.81 (1.69x)
	-- machines: vanilla 93.33 -> 16.8 (5.6x), mod 157.81 -> 52.3 (3.0x)
	meld(data.raw["recipe"]["production-science-pack"], {
		energy_required = 28, -- was 21
		ingredients = meld.overwrite{
			{ type = "item", name = "rail",                  amount = 45 }, -- was 30
			{ type = "item", name = "electric-furnace",      amount = 2 }, -- was 1
			{ type = "item", name = "hazard-concrete",       amount = 25 }, -- new (was assembler 2 in the other mod)
			{ type = "item", name = "productivity-module",   amount = 1 }
		},
		results = meld.overwrite{
			{ type = "item", name = "production-science-pack", amount = 4 } -- was 3
		},
	})
	
	meld(data.raw["recipe"]["beacon"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "steel-plate",           amount = 4 }, -- was 10
			{ type = "item", name = "copper-cable",          amount = 32 }, -- was 10
			{ type = "item", name = "electronic-circuit",    amount = 25 }, -- was 20
			{ type = "item", name = "advanced-circuit",      amount = 12 } -- was 20
		},
	})
	-- raw cost 97.67 -> 201.34 (2.06x)
	-- machines: vanilla 97.67 -> 9.85 (9.9x), mod 201.34 -> 40.1 (5.0x)
	-- beacon can be made in EM plant!
	meld(data.raw["recipe"]["utility-science-pack"], {
		energy_required = 36, -- was 21
		ingredients = meld.overwrite{
			{ type = "item", name = "processing-unit",       amount = 4 }, -- was 2
			{ type = "item", name = "low-density-structure", amount = 5 }, -- was 3
			{ type = "item", name = "flying-robot-frame",    amount = 2 }, -- was 1
			{ type = "item", name = "beacon",                amount = 1 } -- new
		},
		results = meld.overwrite{
			{ type = "item", name = "utility-science-pack", amount = 6 } -- was 3
		},
	})
	meld(data.raw["technology"]["utility-science-pack"], {
		prerequisites = common.meld_add_or_assign{"effect-transmission"} -- electric-energy-distribution-2
	})
end

---- Machines and chests
local function machines()
	local function set_belt_speed(belt, underground, splitter, speed)
		meld(data.raw["transport-belt"][belt], {
			speed = speed/2/480, -- 0.0625*480 = 30 items/sec
			--animation_speed_coefficient = 32,
		})
		meld(data.raw["underground-belt"][underground], {
			speed = speed/2/480,
			--animation_speed_coefficient = 32,
		})
		meld(data.raw["splitter"][splitter], {
			speed = speed/2/480,
			--animation_speed_coefficient = 32,
		})
	end

	-- numbers are double from ingame number for some reason?
	-- only (ingame) multiples of 15 can exist as whole numbers, sad
	-- not a good idea...
	--set_belt_speed("transport-belt", "underground-belt", "splitter", 22.5)
	--set_belt_speed("fast-transport-belt", "underground-belt", "splitter", 45)
	--set_belt_speed("express-transport-belt", "express-underground-belt", "express-splitter", 75)
	--set_belt_speed("turbo-transport-belt", "turbo-underground-belt", "turbo-splitter", 112.5)

	-- chests feel a bit too big, I like how this prevents some unneeded chest limiting
	meld(data.raw["container"]["wooden-chest"], { inventory_size = 10 }) -- was 16
	meld(data.raw["container"]["iron-chest"], {   inventory_size = 16 }) -- was 32
	meld(data.raw["container"]["steel-chest"], {  inventory_size = 30 }) -- was 48
	for _,c in pairs({
		"active-provider-chest",
		"buffer-chest",
		"passive-provider-chest",
		"requester-chest",
		"storage-chest",
	}) do
		meld(data.raw["logistic-container"][c], { inventory_size = 30 }) -- was 48
	end
 
	--meld(data.raw["inserter"]["bulk-inserter"], {
	--	rotation_speed = 0.03, -- was 0.04
	--})
	
	-- why not
	meld(data.raw["offshore-pump"]["offshore-pump"], {
		pumping_speed = 10, -- was 20 -> 1200/s -> 600/s
	})
	
	-- 3 modules are a nice nerf, where it matters (except for science) we get more powerful machines later
	meld(data.raw["assembling-machine"]["assembling-machine-3"], {
		module_slots = 3 -- was 4
	})
	
	-- similar
	meld(data.raw["assembling-machine"]["chemical-plant"], {
		module_slots = 2 -- was 3
	})
	
	-- make large scale uranium a bit more balanced
	meld(data.raw["assembling-machine"]["centrifuge"], {
		module_slots = 3, -- was 2
		energy_usage = "875kW", -- was 350kW
	})
	
	-- why not
	meld(data.raw["mining-drill"]["electric-mining-drill"], {
		module_slots = 2 -- was 3
	})
	
	meld(data.raw["furnace"]["electric-furnace"], {
		energy_source = {
			emissions_per_minute = { pollution = 2 }, -- was 1 (0.5/speed -> 1/speed), steel furnace is 4 at same crafting speed
		},
	})
end

function M.data()
	hard_intermediates()
	if settings.startup[const.SETTING_HARD_SCIENCE].value then science() end
	machines()
end

return M
