-- Nauvis / pre-space changes: intermediates, science packs, machines and chests
local const = require("const")
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

---- Intermediates, and iron-stick unlocked by automation (engine-unit and long-handed-inserter need it)
local function intermediates()
	-- More expensive basic resources
	meld(data.raw["recipe"]["iron-gear-wheel"], {
		energy_required = 1.5, -- was 0.5
		ingredients = meld.overwrite{
			{ type = "item", name = "iron-plate", amount = 5 }, -- was 2
		},
		results = meld.overwrite{
			{ type = "item", name = "iron-gear-wheel", amount = 2 }, -- was 1
		},
	})

	meld(data.raw["recipe"]["copper-cable"], {
		energy_required = 1, -- was 0.5
		ingredients = meld.overwrite{
			{ type = "item", name = "copper-plate", amount = 3 }, -- was 1
		},
		results = meld.overwrite{
			{ type = "item", name = "copper-cable", amount = 4 }, -- was 2
		},
	})

	meld(data.raw["recipe"]["steel-plate"], {
		energy_required = 16,
		ingredients = meld.overwrite{
			{ type = "item", name = "iron-plate", amount = 6 }, -- was 5
			--{ type = "item", name = "coal", amount = 1 }, -- furnace can only have one input slot!
		},
	})

	--meld(data.raw["technology"]["engine"], {
	--	effects = common.meld_add_or_assign{
	--		{
	--			type = "unlock-recipe",
	--			recipe = "iron-stick"
	--		}
	--	}
	--})
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
	meld(data.raw["recipe"]["explosives"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "coal", amount = 1 },
			{ type = "item", name = "sulfur", amount = 2 }, -- was 1
			{ type = "fluid", name = "petroleum-gas", amount = 12 }, -- was 10 water
		},
	})

	meld(data.raw["recipe"]["advanced-circuit"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "plastic-bar",    amount = 3 }, -- was 2
			{ type = "item", name = "copper-cable",   amount = 4 },
			{ type = "item", name = "electronic-circuit", amount = 3 }, -- was 2
		},
	})

	meld(data.raw["recipe"]["processing-unit"], {
		energy_required = 12, -- was 10
		ingredients = meld.overwrite{
			{ type = "item", name = "electronic-circuit", amount = 24 }, -- was 20
			{ type = "item", name = "advanced-circuit", amount = 3 }, -- was 2
			{ type = "fluid", name = "sulfuric-acid",  amount = 16 }, -- was 5
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

	-- raw cost per pack vanilla -> now (ore/coal/stone 1, oil fluids 1/10, water ignored), assemblers and furnaces without productivity
	-- intermediates: gear 1.25x, cable 1.5x, steel 1.2x, circuit 1.3x, advanced circuit 1.73x, processing unit 1.87x, engine 1.33x,
	--   electric engine 1.53x, explosives 2.1x, LDS 1.05x, robot frame 1.3x, electric furnace 1.39x, beacon 0.98x, modules 1.64x
	--   max assembler prod is also 40% -> 30% (AM3 4 -> 3 module slots), so with full prod intermediates cost another 1.08x
	-- raw cost 3 -> 5.75 (1.9x)
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
	-- raw cost 7 -> 13.3 (1.9x)
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

	-- raw cost 21.3 -> 48 (2.3x), mostly iron ore 5.8 -> 27
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

	-- raw cost 24.8 -> 71.1 (2.9x)
	meld(data.raw["recipe"]["chemical-science-pack"], {
		energy_required = 28, -- was 24
		ingredients = meld.overwrite{
			{ type = "item", name = "battery",          amount = 3 }, -- new, was 2 engine-unit
			{ type = "item", name = "pump",             amount = 3 }, -- new, was 1 sulfur
			{ type = "item", name = "advanced-circuit", amount = 4 } -- was 3
		},
	})
	meld(data.raw["technology"]["chemical-science-pack"], {
		prerequisites = common.meld_add_or_assign{"battery"}
	})

	meld(data.raw["recipe"]["electric-furnace"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "steel-plate",      amount = 4 }, -- was 10
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "steel-furnace",    amount = 1 }, -- new, was 10 stone-brick
		},
	})
	-- add concrete indirectly (or on utility-science?)
	-- raw cost 93.3 -> 153 (1.6x)
	meld(data.raw["recipe"]["production-science-pack"], {
		energy_required = 28, -- was 21
		ingredients = meld.overwrite{
			{ type = "item", name = "rail",                  amount = 40 }, -- was 30
			{ type = "item", name = "electric-furnace",      amount = 2 }, -- was 1
			{ type = "item", name = "hazard-concrete",       amount = 25 }, -- new (was assembler 2 in the other mod)
			{ type = "item", name = "productivity-module",   amount = 1 }
		},
		results = meld.overwrite{
			{ type = "item", name = "production-science-pack", amount = 4 } -- was 3
		},
	})
	--meld(data.raw["technology"]["production-science-pack"], {
	--	prerequisites = common.meld_add_or_assign{"productivity-module-2"}
	--})

	meld(data.raw["recipe"]["beacon"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "steel-plate",           amount = 4 }, -- was 10
			{ type = "item", name = "copper-cable",          amount = 30 }, -- was 10
			{ type = "item", name = "electronic-circuit",    amount = 25 }, -- was 20
			{ type = "item", name = "advanced-circuit",      amount = 10 } -- was 20
		},
	})
	-- raw cost 97.7 -> 188 (1.9x)
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
	--set_belt_speed("transport-belt", "underground-belt", "splitter", 22.5)
	--set_belt_speed("fast-transport-belt", "underground-belt", "splitter", 45)
	--set_belt_speed("express-transport-belt", "express-underground-belt", "express-splitter", 75)
	--set_belt_speed("turbo-transport-belt", "turbo-underground-belt", "turbo-splitter", 112.5)

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
	
	meld(data.raw["offshore-pump"]["offshore-pump"], {
		pumping_speed = 10, -- was 20 -> 1200/s -> 600/s
	})

	meld(data.raw["assembling-machine"]["assembling-machine-3"], {
		module_slots = 3 -- was 4
	})

	meld(data.raw["assembling-machine"]["chemical-plant"], {
		module_slots = 2 -- was 3
	})

	meld(data.raw["assembling-machine"]["centrifuge"], {
		module_slots = 3, -- was 2
		energy_usage = "875kW", -- was 350kW
	})

	meld(data.raw["mining-drill"]["electric-mining-drill"], {
		module_slots = 2 -- was 3
	})

	meld(data.raw["furnace"]["electric-furnace"], {
		energy_source = {
			emissions_per_minute = { pollution = 2 }, -- was 1 (0.5/speed -> 1/speed)
		},
	})
end

function M.data()
	intermediates()
	if settings.startup[const.SETTING_HARD_SCIENCE].value then science() end
	machines()
end

return M
