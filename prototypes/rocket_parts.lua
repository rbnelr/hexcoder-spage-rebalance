-- Rocket control unit (displayed as "Signal processor") and its productivity tech, rocket part recipe, 100 parts per rocket,
-- RCU in atomic bomb and spidertron
-- Standalone: only references vanilla prototypes, could become its own mod
local const = require("const")
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

---- Rocket control unit
local function rcu()
	-- Stolen from  rcu-restored_1.1.2  -  SilentSimulacrum
	data:extend({
		{
			type = "item",
			name = "rocket-control-unit",
			icon = const.MOD_DIR.."/graphics/icons/rocket-control-unit.png",
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
			icon = const.MOD_DIR.."/graphics/technology/rocket-control-unit.png",
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
			icons = util.technology_icon_constant_recipe_productivity(const.MOD_DIR.."/graphics/technology/rocket-control-unit-productivity.png"),
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

---- Rocket part and silo
local function rocket()
	meld(data.raw["recipe"]["rocket-part"], {
		ingredients = meld.overwrite{
			{type="item", name="rocket-control-unit", amount=1}, -- new, replaces processing-unit
			{type="item", name="low-density-structure", amount=2}, -- was 1
			{type="item", name="rocket-fuel", amount=3}, -- was 1
		},
	})
	meld(data.raw["rocket-silo"]["rocket-silo"], {
		rocket_parts_required = 100, -- was 50
	})

	meld(data.raw["technology"]["rocket-silo"], {
		prerequisites = common.meld_replace({"processing-unit"}, {"rocket-control-unit"}) -- rocket-control-unit requires processing-unit
	})
end

---- RCU in other recipes
local function rcu_uses()
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
end

function M.data()
	rcu()
	rocket()
	rcu_uses()
end

return M
