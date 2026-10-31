-- Satellite and new space science pack recipe, ice-melting unlocked by space science
-- Standalone: only references vanilla prototypes, could become its own mod
local const = require("const")
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

---- Satellite
local function satellite()
	-- Stolen from  Better Space Science  -  Cubickman

	local item_sounds = require("__base__.prototypes.item_sounds")

	data:extend({
		{
			type = "item",
			name = "satellite",
			icon = const.MOD_DIR.."/graphics/icons/satellite.png",
			subgroup = "intermediate-product",
			order = "d[rocket-parts]-eb[satellite]",
			stack_size = 5,
			weight = 200 * kg, -- 5 / rocket
			inventory_move_sound = item_sounds.electric_small_inventory_move,
			pick_sound = item_sounds.electric_small_inventory_pickup,
			drop_sound = item_sounds.electric_small_inventory_move,
		},
		{
			type = "recipe",
			name = "satellite",
			subgroup = "intermediate-product",
			order = "d[rocket-parts]-eb[satellite]",
			enabled = false,
			energy_required = 32,
			allow_productivity = false,
			categories = { "advanced-crafting", --[["electromagnetics"]] },
			ingredients = {
				{type = "item", name = "steel-plate", amount = 2},
				{type = "item", name = "solar-panel", amount = 4},
				{type = "item", name = "radar", amount = 1},
				{type = "item", name = "rocket-fuel", amount = 1},
			},
			results = {{type = "item", name = "satellite", amount = 1}}
		},
	})
end

---- Space science
local function science()
	-- cost per pack (12.5 avg per craft), Nauvis raw cost (see nauvis.lua) + asteroid chunks on the platform, early / data_updates (foundry/EM, prod 3):
	--   1 launch satellites (240 kg, 20 rockets per 1000 packs early, 15.4 data_updates):  771 / 110 ore
	--   2 launch satellite ingredients (117 kg, 9.3 / 7.2 rockets per 1000):       377 / 56 ore
	--   3 craft all but rocket fuel on platform (0.8 / 0.6 rockets per 1000):        30.4 / 4.5 ore + 2.93 / 0.68 chunks
	--   4 craft all on platform (rocket fuel via coal synthesis + liquefaction):      4.07 / 0.94 chunks
	--   the rocket is 84-96% of the ore cost in 1 and 2; carbon and water add 0.09 / 0.05 chunks to every route
	--   oil from coal liquefaction makes 1-3 about 12% more expensive early, the same data_updates
	--   asteroid productivity research not included; see tools/space_costs.py
	meld(data.raw["recipe"]["space-science-pack"], {
		categories = {"crafting-with-fluid"}, -- was crafting
		energy_required = 11, -- was 15
		ingredients = meld.overwrite{
			{type = "item", name = "satellite", amount = 1}, -- new
			{type = "item", name = "carbon", amount = 5}, -- was 1 (and 2 iron-plate, 1 ice)
			{type = "fluid", name = "water", amount = 80} -- new
		},
		results = meld.overwrite{
			{type = "item", name = "space-science-pack", amount_min=0, amount_max=25} -- avg 12.5, was 5
		}
	})
end

---- Techs
local function techs()
	meld(data.raw["technology"]["space-science-pack"], {
		effects = common.meld_add_or_assign{
			{type = "unlock-recipe", recipe = "satellite"},
			{type = "unlock-recipe", recipe = "ice-melting"},
		}
	})
	meld(data.raw["technology"]["space-platform-thruster"], {
		effects = common.meld_remove{{type = "unlock-recipe", recipe = "ice-melting"}}
	})
end

function M.data()
	satellite()
	science()
	techs()
end

return M
