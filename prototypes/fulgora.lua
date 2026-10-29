-- EM plant and recycler nerfs, holmium
local const = require("const")
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

---- Recipes
local function recipes()
	-- holmium in endgame: biochamber + foundry
	meld(data.raw["recipe"]["holmium-plate"], {
		energy_required = 2, -- was 1
		categories = meld.overwrite{"crafting-with-fluid"} -- was crafting-with-fluid, metallurgy (foundry uses holmium-casting instead)
	})
	-- foundry version has to be more efficent or else its pointless to use foundry on fuglora
	local holmium_foundry = table.deepcopy(data.raw["recipe"]["holmium-plate"])
	meld(holmium_foundry, {
		name = "holmium-casting",
		localised_name = {"", "Holmium casting"},
		energy_required = 3.2,
		categories = meld.overwrite{"metallurgy"},
		ingredients = common.meld_add_or_assign{
			{type = "fluid", name = "holmium-solution", amount = 30, fluidbox_multiplier = 4},
		},
		results = common.meld_add_or_assign{
			{type = "item", name = "holmium-plate", amount = 2}
		},
		allow_productivity = true
	})
	data:extend{holmium_foundry}
	-- allow holmium solution in a machine with more prod
	meld(data.raw["recipe"]["holmium-solution"], {
		--categories = common.meld_add_or_assign{"cryogenics"} -- cryogenic plant
		categories = common.meld_add_or_assign{"organic"} -- biochamber
	})
end

---- Electromagnetic science (hard science setting)
local function science()
	-- raw cost per pack 29.2 -> 130.7 (4.5x), EM plant base prod 50% -> 25% on everything it can make, holmium plate in foundry,
	--   holmium solution in biochamber (mod only), other intermediates from Nauvis resources (ignores scrap)
	--   the rocket-control-unit is 91 of that, without it 1.4x
	-- late (prod 3) 11.8 -> 41.3 (3.5x, RCU 23.7 of it), legendary prod 3 4.5 -> 12.8 (2.8x, RCU 5.5); see tools/planet_costs.py
	-- TODO: could consider making this more expensive? would have to compare base sizes
	meld(data.raw["recipe"]["electromagnetic-science-pack"], {
		energy_required = 14, -- was 10
	})
	if data.raw["item"]["rocket-control-unit"] then -- from rocket_parts.lua
		meld(data.raw["recipe"]["electromagnetic-science-pack"], {
			-- maybe kinda lame since its needed in rockets anyway, but the most thematically fitting extra ingredient I can think of
			-- this actually is a nice extra use of circuits
			ingredients = common.meld_add_or_assign{
				{ type = "item", name = "rocket-control-unit", amount = 1 } -- new
			}
		})
	end
end

---- Resources
local function resources()
	-- now handled by my fulgoran vault drone mod
	-- which can make scrap on vaults infinite
	--meld(data.raw["resource"]["scrap"], {
	--	minable = {
	--		mining_time = 1.4, -- was 0.5
	--		-- oops this of course multiplies total scrap amount from patch
	--		-- we should probably adjust richness of mapgen (autoplace richness expression)
	--		-- it's also a bit confusing, but hovering over in map view actually accounts for this
	--		-- but my fulgora mod did not
	--		result = meld.delete(),
	--		results = {{
	--			type="item", -- avg 2.5 in 1.4 sec = 1.78/s instead of 2
	--			name = "scrap",
	--			amount_min = 1,
	--			amount_max = 4,
	--		}}
	--	}
	--}) -- TODO: adjust noise expression
end

---- Machines
local function machines()
	-- speed prodded recycler feels way too fast
	-- maybe also a good nerf for quality upcycling?
	meld(data.raw["furnace"]["recycler"], {
		module_slots = 2, -- was 4
	})
	-- 25% prod feels fine, is now less polluting than AM3, but maybe should leave it,
	-- since prod bonus saves us pollution for blue chips etc., but compared to 50% free prod it's probably still balanced compared to vanilla?)
	meld(data.raw["assembling-machine"]["electromagnetic-plant"], {
		module_slots = 4, -- was 5
		crafting_speed = 2, -- was 2
		effect_receiver = {
			base_effect = {
				productivity = 0.25 -- was 0.5
			}
		},
		energy_source = {
			emissions_per_minute = { pollution = 2.5 }, -- was 4, now less polluting than assembler
		},
	})
end

function M.data()
	recipes()
	if settings.startup[const.SETTING_HARD_SCIENCE].value then science() end
	resources()
	machines()
end

return M
