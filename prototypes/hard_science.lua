local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

function M.updates()

	-- mostly stolen from Science Difficulty Overhaul: Harder Science Packs - Cubickman
	
	-- stick fuckery
	meld(data.raw["technology"]["automation"], {
		effects = common.list_add_or_assign{{type = "unlock-recipe", recipe = "iron-stick"}}
	})
	for _,tech in pairs{"railway", "circuit-network", "electric-energy-distribution-1", "concrete"} do
		meld(data.raw["technology"][tech], {
			effects = common.list_remove{{type = "unlock-recipe", recipe = "iron-stick"}},
			prerequisites = common.list_add_or_assign{"automation"},
		})
	end

	meld(data.raw["recipe"]["automation-science-pack"], {
		energy_required = 6,
		ingredients = meld.overwrite{
			{ type = "item", name = "copper-cable",    amount = 3 },
			{ type = "item", name = "burner-inserter", amount = 1 }
		},
	})

	meld(data.raw["recipe"]["long-handed-inserter"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "inserter", amount = 1 },
			{ type = "item", name = "iron-stick", amount = 1 },
			{ type = "item", name = "iron-gear-wheel", amount = 1 },
		}
	})
	meld(data.raw["recipe"]["logistic-science-pack"], {
		energy_required = 8,
		ingredients = meld.overwrite{
			{ type = "item", name = "long-handed-inserter", amount = 1 },
			{ type = "item", name = "transport-belt",       amount = 2 }
		},
	})
	meld(data.raw["technology"]["logistic-science-pack"], {
		prerequisites = common.list_add_or_assign{"automation"}
	})

	meld(data.raw["recipe"]["military-science-pack"], {
		energy_required = 14,
		ingredients = meld.overwrite{
			{ type = "item", name = "piercing-rounds-magazine", amount = 3 },
			{ type = "item", name = "grenade",                  amount = 1 },
			{ type = "item", name = "gate",                     amount = 2 }
		},
	})
	meld(data.raw["technology"]["military-science-pack"], {
		prerequisites = common.list_add_or_assign{"gate"}
	})

	meld(data.raw["recipe"]["chemical-science-pack"], {
		energy_required = 28,
		ingredients = meld.overwrite{
			{ type = "item", name = "battery",          amount = 3 },
			{ type = "item", name = "pump",             amount = 3 },
			{ type = "item", name = "advanced-circuit", amount = 4 }
		},
	})
	meld(data.raw["technology"]["chemical-science-pack"], {
		prerequisites = common.list_add_or_assign{"battery"}
	})

	meld(data.raw["recipe"]["electric-furnace"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "steel-plate",      amount = 4 },
			{ type = "item", name = "advanced-circuit", amount = 5 },
			{ type = "item", name = "steel-furnace",    amount = 1 },
		},
	})
	-- add concrete indirectly (or on utility-science?)
	meld(data.raw["recipe"]["production-science-pack"], {
		energy_required = 28,
		ingredients = meld.overwrite{
			{ type = "item", name = "rail",                  amount = 40 },
			{ type = "item", name = "electric-furnace",      amount = 2 },
			{ type = "item", name = "hazard-concrete",       amount = 25 }, -- was assembler 2 in the other mod
			{ type = "item", name = "productivity-module",   amount = 1 } -- "productivity-module-2"
		},
		results = meld.overwrite{
			{ type = "item", name = "production-science-pack", amount = 4 }
		},
	})
	--meld(data.raw["technology"]["production-science-pack"], {
	--	prerequisites = common.list_add_or_assign{"productivity-module-2"}
	--})

	meld(data.raw["recipe"]["beacon"], {
		ingredients = meld.overwrite{
			{ type = "item", name = "steel-plate",           amount = 4 },
			{ type = "item", name = "copper-cable",          amount = 30 },
			{ type = "item", name = "electronic-circuit",    amount = 25 },
			{ type = "item", name = "advanced-circuit",      amount = 10 }
		},
	})
	meld(data.raw["recipe"]["utility-science-pack"], {
		energy_required = 36,
		ingredients = meld.overwrite{
			{ type = "item", name = "processing-unit",       amount = 4 },
			{ type = "item", name = "low-density-structure", amount = 5 },
			{ type = "item", name = "flying-robot-frame",    amount = 2 },
			{ type = "item", name = "beacon",                amount = 1 }
		},
		results = meld.overwrite{
			{ type = "item", name = "utility-science-pack", amount = 6 }
		},
	})
	meld(data.raw["technology"]["utility-science-pack"], {
		prerequisites = common.list_add_or_assign{"effect-transmission"} -- electric-energy-distribution-2
	})
	
	-- metallurgic
	meld(data.raw["recipe"]["metallurgic-science-pack"], {
		energy_required = 36,
		ingredients = meld.overwrite{
			{ type = "item", name = "tungsten-carbide",      amount = 8 },
			{ type = "item", name = "tungsten-plate",        amount = 4 },
			{ type = "item", name = "big-electric-pole",     amount = 2 },
			{ type = "item", name = "steam-turbine",         amount = 1 },
			{ type = "fluid", name = "molten-copper",        amount = 400 },
		},
		results = meld.overwrite{
			{ type = "item", name = "metallurgic-science-pack", amount = 2 }
		},
	})
	meld(data.raw["technology"]["metallurgic-science-pack"], {
		prerequisites = common.list_add_or_assign{"nuclear-power"}
	})
	
	-- electromagnetic
	meld(data.raw["recipe"]["electromagnetic-science-pack"], {
		energy_required = 14,
		-- maybe kinda lame since its needed in rockets anyway, but the most thematically fitting extra ingredient I can think of
		-- this actually is a nice extra use of circuits
		ingredients = common.list_add_or_assign{
			{ type = "item", name = "rocket-control-unit", amount = 1 }
		}
	})
end

return M