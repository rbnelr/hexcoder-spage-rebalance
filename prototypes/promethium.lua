-- Fish spoiling and breeding in space, promethium science rework
local meld = require("__core__.lualib.meld")

local M = {}

---- Fish
local function fish()
	-- faster spoiling for a challenge
	-- promethium ship will need a (circuit-driven?) spoil refresher
	-- or could be exploited by recycling spidertron? is that a good thing?
	meld(data.raw["capsule"]["raw-fish"], {
		spoil_ticks = 10500, -- 453000=2h5m50s  10500=2m55s
		spoil_result = "spoilage",
	})

	meld(data.raw["recipe"]["fish-breeding"], {
		surface_conditions = meld.delete(), -- allow in space
		ingredients = meld.overwrite{
			{type = "item", name = "raw-fish", amount = 2, ignored_by_stats = 2},
			{type = "item", name = "nutrients", amount = 50}, -- was 100
			--{type = "fluid", name = "water", amount = 250, fluidbox_multiplier=4} -- was 100
			{type = "fluid", name = "water", amount = 250, fluidbox_multiplier=2, ignored_by_stats=240}, -- was 100
		},
		results = meld.overwrite{
			{type="item", name="raw-fish", amount=3, ignored_by_stats = 2, ignored_by_productivity = 2},
			{type="fluid", name="water", amount=240, ignored_by_productivity=240}, -- new
		},
	})
end

---- Promethium science
local function science()
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
		energy_required = 14, -- was 5
		ingredients = meld.overwrite{
			{type="item", name="promethium-asteroid-chunk", amount=50}, -- was 25
			{type="item", name="quantum-processor", amount=15}, -- was 1
			{type="item", name="biter-egg", amount=24}, -- was 10
			{type="item", name="raw-fish", amount=15}, -- new
			{type="item", name="uranium-235", amount=1}, -- new
			-- If done gleba overhaul, make this require warm water? and make it output cold dirty water
			-- TODO: how does fluid temperature work?
			--> fluid network equializes to the average
			--> can't actually warm anything up, need to create recepies for that?
			--> but how would we even balance temperatures if we can't measure them? -> add temperature reading circuit output to tanks?
			{type = "fluid", name = "water", amount = 1400, fluidbox_multiplier=2, ignored_by_stats=1350}, -- new
		},
		results = meld.overwrite{
			{type="item", name="promethium-science-pack", amount=10, shared_probability={min=0, max=0.75}}, -- was 10 (100%)
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
		QP: 850     106/13.3 (15 in, avg 6.5 back)
	
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

function M.data()
	fish()
	science()
end

return M
