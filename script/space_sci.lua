local mod_name = "hexcoder-spage-rebalance-"
local meld = require("__core__.lualib.meld")

local M = {}

function M.data()
	-- Stolen from  Better Space Science  -  Cubickman

	local item_sounds = require("__base__.prototypes.item_sounds")

	data:extend({
		{
			type = "item",
			name = "satellite",
			icon = "__hexcoder-spage-rebalance__/graphics/icons/satellite.png",
			subgroup = "intermediate-product",
			order = "d[rocket-parts]-eb[satellite]",
			stack_size = 5,
			weight = 240 * kg, -- 4 / rocket
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

function M.updates()
	table.insert(data.raw["technology"]["space-science-pack"].effects, {type = "unlock-recipe", recipe = "satellite"})
	table.insert(data.raw["technology"]["space-science-pack"].effects, {type = "unlock-recipe", recipe = "ice-melting"})
	data.raw["technology"]["space-platform-thruster"].effects = { -- remove ice-melting
		{type = "unlock-recipe", recipe = "thruster"},
		{type = "unlock-recipe", recipe = "thruster-fuel"},
		{type = "unlock-recipe", recipe = "thruster-oxidizer"},
	}

	meld(data.raw["recipe"]["space-science-pack"], {
		categories = {"crafting-with-fluid"},
		energy_required = 11,
		ingredients = meld.overwrite({
			{type = "item", name = "satellite", amount = 1},
			{type = "item", name = "carbon", amount = 5},
			{type = "fluid", name = "water", amount = 80}
		}),
		results = meld.overwrite({{type = "item", name = "space-science-pack", amount_min=0, amount_max=25}})
	})
end

return M