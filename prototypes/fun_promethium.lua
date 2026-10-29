local meld = require("__core__.lualib.meld")

local M = {}

function M.updates()

---- Heating tower:
-- nerf power (still works fine on aquilo for me, and makes gleba powerplant not as OP)
-- allow in space
-- Might pair well with carbon as fuel, which is not desirable, though
-- What if we allow boiler instead? is that less power efficient?
meld(data.raw["reactor"]["heating-tower"], {
	surface_conditions = meld.delete(),
	consumption = "14.25MW",
	energy_source = { effectivity = 1.25 }
	--neighbour_bonus = 0.15, -- interesting, but encourages too linear placement for my liking
})

------ Item stack and rocket rebalance to encourage production in space

meld(data.raw["item"]["quantum-processor"], {
	stack_size = 8,
	weight = 15625, -- 64 / rocket
})

-- faster spoiling for a challenge
-- promethium ship will need a (circuit-driven?) spoil refresher
-- or could be exploited by recycling spidertron? is that a good thing?
meld(data.raw["capsule"]["raw-fish"], {
	stack_size = 20,
	spoil_ticks = 10500, -- 453000=2h5m50s  10500=2m55s
	spoil_result = "spoilage",
})

-- Rebalanced quantum processor, should be made in space now
-- the recipe is still cheap in terms of resource cost of what will need to be produced elsewhere
-- but requires a large platform now, that is the goal of nerfing stack sizes
-- of course long platforms with a million cargo bays defeat this if you can afford the rocket launches
meld(data.raw["recipe"]["quantum-processor"], {
	energy_required = 42,
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
		{type = "item", name = "uranium-235", amount = 5},
		{type = "item", name = "tungsten-carbide", amount = 8},
		{type = "item", name = "processing-unit", amount = 10}, -- quality? maybe 2 rares or similar? how would quality QP work then?
		{type = "item", name = "superconductor", amount = 8},
		{type = "item", name = "carbon-fiber", amount = 6},
		{type = "item", name = "lithium-plate", amount = 6},
		{type = "fluid", name = "fluoroketone-cold", amount = 15, ignored_by_stats = 14},
		{type = "fluid", name = "light-oil", amount = 25},
	},
	results = meld.overwrite{
		{type = "item", name = "quantum-processor", amount = 1, independent_probability=0.72},
		{type = "fluid", name = "fluoroketone-hot", amount = 14, temperature = 180, ignored_by_stats = 14, ignored_by_productivity = 14}
	},
})
--[[
	100 QPs stacks=12.5 rocket=1.5625
	
	Ingredients for 100 QPs (no prod):
	TC: 100 -> 2/0.2
	PU: 300 -> 7.5/2.5
	SC: 400 -> 2/0.4
	CF: 100 -> 1/0.2
	LP: 100 -> 1/0.2
	Fl: 100 -> 2/0.2
	LO: 1200 -> 24/2.4
	
	Ingredients for 300 PU: (50% prod)
	EC: 4000 -> 20/2
	AC: 600 -> 3/0.6
]]

meld(data.raw["recipe"]["fish-breeding"], {
	surface_conditions = meld.delete(), -- allow in space
	ingredients = meld.overwrite{
		{type = "item", name = "raw-fish", amount = 2, ignored_by_stats = 2},
		{type = "item", name = "nutrients", amount = 50}, -- was 100
		--{type = "fluid", name = "water", amount = 250, fluidbox_multiplier=4} -- was 100
		{type = "fluid", name = "water", amount = 250, fluidbox_multiplier=2, ignored_by_stats=240},
	},
	results = meld.overwrite{
		{type="item", name="raw-fish", amount=3, ignored_by_stats = 2, ignored_by_productivity = 2},
		{type="fluid", name="water", amount=240, ignored_by_productivity=240},
	},
})

---- New promethium recipe
-- fish for extra spice, which unlike eggs will spoil if not refreshed
-- still fast enough to be made in 1 or 2 machines next to hub, could nerf futher to force actual belt-based designs
-- way more QPs needed, to actually add some required production on top of building a fast shattered planet capable ship
-- because I want a flying factory in space that makes more than just ammo?
-- could add uranium? -> yeah, that might encourage uranium ammo production, which could be helpful if we nerf damage infinites or buff asteroid physical resistance?

--meld(data.raw["recipe"]["promethium-science-pack"], {
--	main_product = "promethium-science-pack",
--	ingredients = meld.overwrite{
--		{type = "item", name = "promethium-asteroid-chunk", amount = 25},
--		{type = "item", name = "quantum-processor", amount = 5},
--		{type = "item", name = "biter-egg", amount = 10},
--		{type = "item", name = "raw-fish", amount = 5}
--	},
--	results = meld.overwrite{
--		{type="item", name="promethium-science-pack", amount=10, probability=0.9},
--		{type="item", name="quantum-processor", amount_min=1, amount_max=5, ignored_by_productivity=5},
--		{type="item", name="raw-fish", amount=25, probability=0.1, percent_spoiled=0.8, ignored_by_productivity=25}
--	},
--})
meld(data.raw["recipe"]["promethium-science-pack"], {
	main_product = "promethium-science-pack",
	energy_required = 14,
	ingredients = meld.overwrite{
		{type="item", name="promethium-asteroid-chunk", amount=50},
		{type="item", name="quantum-processor", amount=15},
		{type="item", name="biter-egg", amount=24},
		{type="item", name="raw-fish", amount=15},
		{type="item", name="uranium-235", amount=1},
		-- If done gleba overhaul, make this require warm water? and make it output cold dirty water
		-- TODO: how does fluid temperature work?
		--> fluid network equializes to the average
		--> can't actually warm anything up, need to create recepies for that?
		--> but how would we even balance temperatures if we can't measure them? -> add temperature reading circuit output to tanks?
		{type = "fluid", name = "water", amount = 1400, fluidbox_multiplier=2, ignored_by_stats=1350},
	},
	results = meld.overwrite{
		{type="item", name="promethium-science-pack", amount=10, shared_probability={min=0, max=0.75}},
		{type="item", name="raw-fish", amount=100, shared_probability={min=0.75,max=0.85}, percent_spoiled=0.9, ignored_by_productivity=100},
		{type="item", name="spoilage", amount=100, shared_probability={min=0.85,max=1}, ignored_by_productivity=100},
		{type="item", name="quantum-processor", amount_min=3, amount_max=10, ignored_by_productivity=10},
		{type="item", name="uranium-238", amount=1},
		{type="fluid", name="water", amount=1350, ignored_by_productivity=1350},
	},
})
--[[
	1000 Sci: 5 Stacks (assuming 100 crafts, ingnoring 75% as with prod it's actually like 1400)
	Eggs: 2400  24/5
	QP: 900     112/14
	
]]

--[[

  {
    type = "recipe",
    name = "nutrients-from-biter-egg",
    icon = "__space-age__/graphics/icons/nutrients-from-biter-egg.png",
    category = "organic-or-assembling",
    subgroup = "nauvis-agriculture",
    order = "b[nauvis-agriculture]-d[nutrients-from-biter-egg]",
    auto_recycle = false,
    enabled = false,
    energy_required = 2,
    ingredients = {{type = "item", name = "biter-egg", amount = 1}},
    results = {{type="item", name="nutrients", amount=20}},
    allow_productivity = true,
    allow_quality = false,
    crafting_machine_tint =
    {
      primary = {r = 130, g = 130, b = 120, a = 1},
      secondary = {r = 194, g = 162, b = 117, a = 1},
    },
  },
]]
end

return M