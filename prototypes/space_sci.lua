local const = require("const")
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

function M.data()
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
	meld(data.raw["technology"]["space-science-pack"], {
		effects = common.list_add_or_assign{
			{type = "unlock-recipe", recipe = "satellite"},
			{type = "unlock-recipe", recipe = "ice-melting"},
		}
	})
	meld(data.raw["technology"]["space-platform-thruster"], {
		effects = common.list_remove{{type = "unlock-recipe", recipe = "ice-melting"}}
	})

	meld(data.raw["recipe"]["space-science-pack"], {
		categories = {"crafting-with-fluid"},
		energy_required = 11,
		ingredients = meld.overwrite{
			{type = "item", name = "satellite", amount = 1},
			{type = "item", name = "carbon", amount = 5},
			{type = "fluid", name = "water", amount = 80}
		},
		results = meld.overwrite{
			{type = "item", name = "space-science-pack", amount_min=0, amount_max=25}
		}
	})
end

return M