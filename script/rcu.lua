local mod_name = "hexcoder-spage-rebalance-"
local meld = require("__core__.lualib.meld")

local M = {}

function M.data()
	-- Stolen from  rcu-restored_1.1.2  -  SilentSimulacrum
	data:extend({
		{
			type = "item",
			name = "rocket-control-unit",
			icon = "__hexcoder-spage-rebalance__/graphics/icons/rocket-control-unit.png",
			order = "d[rocket-parts]-c[rocket-control-unit]",
			subgroup = "intermediate-product",
			stack_size = 25,
			weight = 10000, -- 100 / rocket
		},
		{
			type = "recipe",
			name = "rocket-control-unit",
			enabled = false,
			ingredients = {
				{type="item", name="processing-unit", amount=1},
				{type="item", name="speed-module", amount=1},
				{type="item", name="battery", amount=1},
			},
			results = {{type="item", name="rocket-control-unit", amount=1}},
			categories = { "crafting", "electromagnetics" },
			energy_required = 32.0,
			allow_productivity = true,
			order = "d[rocket-parts]-c[rocket-control-unit]"
		},
		{
			type = "technology",
			name = "rocket-control-unit",
			icon = "__hexcoder-spage-rebalance__/graphics/technology/rocket-control-unit.png",
			icon_size = 256,
			effects = {{
				type  = "unlock-recipe",
				recipe = "rocket-control-unit"
			}},
			unit = {
				count = 300,
				--count_formula = "300",
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1}
				},
				time = 45
			},
			prerequisites = {"speed-module", "processing-unit", "battery"},
			essential = true
		},
		{
			type = "technology",
			name = "rocket-control-unit-productivity",
			icons = util.technology_icon_constant_recipe_productivity("__hexcoder-spage-rebalance__/graphics/technology/rocket-control-unit-productivity.png"),
			icon_size = 256,
			effects = {{
				type = "change-recipe-productivity",
				recipe = "rocket-control-unit",
				change = 0.05
			}},
			prerequisites = {"electromagnetic-science-pack", "production-science-pack"},
			unit = {
				count_formula = "1.5^L*1200",
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1},
					{"electromagnetic-science-pack", 1},
				},
				time = 60
			},
			max_level = "infinite",
			upgrade = true
		},
	})
end

function M.updates()
	data.raw["recipe"]["rocket-part"].ingredients = {
		{ type = "item", name = "rocket-control-unit",   amount = 1 },
		{ type = "item", name = "low-density-structure", amount = 1 },
		{ type = "item", name = "rocket-fuel",           amount = 1 }
	}
	data.raw["recipe"]["atomic-bomb"].ingredients = {
		{ type = "item", name = "explosives",          amount = 10 },
		{ type = "item", name = "rocket-control-unit", amount = 10 },
		{ type = "item", name = "uranium-235",         amount = 100 }
	}
	data.raw["recipe"]["spidertron"].ingredients = {
		{ type = "item", name = "efficiency-module-3",       amount = 2 },
		{ type = "item", name = "exoskeleton-equipment",     amount = 4 },
		{ type = "item", name = "fission-reactor-equipment", amount = 2 },
		{ type = "item", name = "low-density-structure",     amount = 150 },
		{ type = "item", name = "rocket-control-unit",       amount = 16 },
		{ type = "item", name = "radar",                     amount = 2 },
		{ type = "item", name = "raw-fish",                  amount = 1 },
		{ type = "item", name = "rocket-launcher",           amount = 4 }
	}

	data.raw["technology"]["rocket-silo"].prerequisites = {
		"logistic-robotics",
		"rocket-fuel",
		"advanced-material-processing-2",
		"low-density-structure",
		"rocket-control-unit",
		"concrete"
	}
end

return M
