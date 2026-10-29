-- Cryogenic plant, heating tower, quantum processor (made in space)
local meld = require("__core__.lualib.meld")

local M = {}

---- Quantum processor
local function quantum_processor()
	-- Rebalanced quantum processor, should be made in space now
	-- the recipe is still cheap in terms of resource cost of what will need to be produced elsewhere
	-- but requires a large platform now, that is the goal of nerfing stack sizes
	-- of course long platforms with a million cargo bays defeat this if you can afford the rocket launches
	meld(data.raw["recipe"]["quantum-processor"], {
		energy_required = 42, -- was 30
		--ingredients = meld.overwrite{
		--	{type = "item", name = "tungsten-carbide", amount = 1}, -- 50/500
		--	{type = "item", name = "processing-unit", amount = 3},  -- 40/160
		--	{type = "item", name = "superconductor", amount = 4},   -- 200/1000
		--	{type = "item", name = "carbon-fiber", amount = 1},     -- 100/500
		--	{type = "item", name = "lithium-plate", amount = 1},    -- 100/500
		--	{type = "fluid", name = "fluoroketone-cold", amount = 15, ignored_by_stats = 14}, -- 10/100 (barrel) -> 50/500 (fluid)
		--	{type = "fluid", name = "light-oil", amount = 12},                                -- 10/100 (barrel) -> 50/500 (fluid)
		--	--{type = "fluid", name = "lubricant", amount = 4}, -- Can't have 3 inputs for some reason
		--},
		--results = meld.overwrite{
		--	{type = "item", name = "quantum-processor", amount = 1}, -- 10/62
		--	{type = "fluid", name = "fluoroketone-hot", amount = 14, temperature = 180, ignored_by_stats = 14, ignored_by_productivity = 14}
		--},
		ingredients = meld.overwrite{
			{type = "item", name = "uranium-235", amount = 5}, -- new
			{type = "item", name = "tungsten-carbide", amount = 8}, -- was 1
			{type = "item", name = "processing-unit", amount = 10}, -- was 1, quality? maybe 2 rares or similar? how would quality QP work then?
			{type = "item", name = "superconductor", amount = 8}, -- was 1
			{type = "item", name = "carbon-fiber", amount = 6}, -- was 1
			{type = "item", name = "lithium-plate", amount = 6}, -- was 2
			{type = "fluid", name = "fluoroketone-cold", amount = 15, ignored_by_stats = 14}, -- was 10
			{type = "fluid", name = "light-oil", amount = 25}, -- new
		},
		results = meld.overwrite{
			{type = "item", name = "quantum-processor", amount = 1, independent_probability=0.72}, -- was 1 (100%)
			{type = "fluid", name = "fluoroketone-hot", amount = 14, temperature = 180, ignored_by_stats = 14, ignored_by_productivity = 14} -- was 5
		},
	})
	--[[
		100 QPs stacks=12.5 rocket=1.5625
	
		Ingredients for 100 QPs (no prod, 72% output -> 139 crafts):
		U235: 694 -> 6.9/34.7
		TC: 1111 -> 22.2/4.4
		PU: 1389 -> 34.7/11.6
		SC: 1111 -> 5.6/1.1
		CF: 833 -> 8.3/1.7
		LP: 833 -> 8.3/1.7
		Fl: 139 -> 2.8/0.03 (net, 15 in 14 back; barrels, 100 / rocket)
		LO: 3472 -> 69.4/0.69 (barrels)
	
		Ingredients for 1389 PU: (25% prod)
		EC: 26667 -> 133/13.3
		AC: 3333 -> 16.7/3.3
	]]
end

---- Machines
local function machines()
	meld(data.raw["assembling-machine"]["cryogenic-plant"], {
		energy_source = {
			emissions_per_minute = { pollution = 10 }, -- was 6, now more polluting than chem plant
		},
	})

	---- Heating tower:
	-- nerf power (still works fine on aquilo for me, and makes gleba powerplant not as OP)
	-- allow in space (for coal liquefaction)
	-- Might pair well with carbon as fuel, (steam-powered spaceships) which is not desirable, though
	-- is essentially a weaker nuclear reactor without neighbour bonus, so maybe its not as attractive as it seems
	-- What if we allow boiler instead? is that less power efficient?
	meld(data.raw["reactor"]["heating-tower"], {
		surface_conditions = meld.delete(),
		consumption = "14.25MW", -- was 40MW
		energy_source = { effectivity = 1.25 } -- was 2.5 (100MW heat, now 17.8MW)
		--neighbour_bonus = 0.15, -- interesting, but encourages too linear placement for my liking
	})
end

function M.data()
	quantum_processor()
	machines()
end

return M
