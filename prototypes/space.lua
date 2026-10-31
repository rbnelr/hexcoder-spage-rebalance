-- Space: asteroid spawns and crushing, advanced asteroid processing split per asteroid type, thruster fuel recipes
-- Standalone: only references vanilla prototypes, could become its own mod (the crushing productivity nerfs are in research_costs.lua)
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

---- Asteroid spawns
local function asteroid_spawns()
	local NAUVIS_CHUNKS = 0.05*2.0 -- was 0.0125 metallic, 0.0083 carbonic, 0.0042 oxide
	local NAUVIS_CHUNKS_SPEED = 0.0266667*1.2 -- was 1/60 = 0.0167
	local NAUVIS_SMALL = 0.05*0.3 -- new, vanilla has no asteroids around nauvis
	local NAUVIS_SMALL_SPEED = 0.0266667*0.75

	-- buff the trickle of asteroids around nauvis to make stationary platforms more viable
	meld(data.raw["planet"]["nauvis"], {
		--asteroid_spawn_definitions = meld.invoke(function(list)
		--	for _,def in pairs(list) do
		--		def.probability = def.probability * 4
		--		def.speed = def.speed * 1.6
		--	end
		--	return list
		--end)
		asteroid_spawn_definitions = meld.overwrite{
			{ type="asteroid-chunk", asteroid="metallic-asteroid-chunk", probability=NAUVIS_CHUNKS, speed=NAUVIS_CHUNKS_SPEED, angle_when_stopped=1 },
			{ type="asteroid-chunk", asteroid="carbonic-asteroid-chunk", probability=NAUVIS_CHUNKS, speed=NAUVIS_CHUNKS_SPEED, angle_when_stopped=1 },
			{ type="asteroid-chunk", asteroid="oxide-asteroid-chunk"   , probability=NAUVIS_CHUNKS, speed=NAUVIS_CHUNKS_SPEED, angle_when_stopped=1 },
			{ type="entity", asteroid="small-metallic-asteroid", probability=NAUVIS_SMALL, speed=NAUVIS_SMALL_SPEED, angle_when_stopped=1 },
			{ type="entity", asteroid="small-carbonic-asteroid", probability=NAUVIS_SMALL, speed=NAUVIS_SMALL_SPEED, angle_when_stopped=1 },
			{ type="entity", asteroid="small-oxide-asteroid"   , probability=NAUVIS_SMALL, speed=NAUVIS_SMALL_SPEED, angle_when_stopped=1 },
		}
	})
	-- TODO: adjust other planets?
	-- esp. aquilo
end

---- Asteroid crushing
local function crushing()
	meld(data.raw["recipe"]["metallic-asteroid-crushing"], {
		energy_required = 10/3, -- 3.333334 was 2
		results = common.meld_add_or_assign{{type="item", name="iron-ore", amount_min=7, amount_max=24}}, -- avg 15.5 was 20
	})
	meld(data.raw["recipe"]["carbonic-asteroid-crushing"], {
		energy_required = 3.1, -- was 2
		results = common.meld_add_or_assign{{type="item", name="carbon", amount_min=6, amount_max=12}}, -- avg 9 was 10
	})
	meld(data.raw["recipe"]["oxide-asteroid-crushing"], {
		energy_required = 3.2, -- was 2
		results = common.meld_add_or_assign{{type="item", name="ice", amount_min=2, amount_max=6}}, -- avg 4 was 5
	})

	meld(data.raw["recipe"]["advanced-metallic-asteroid-crushing"], {
		energy_required = 7.25, -- was 5
		results = meld.overwrite{
			{type="item", name="iron-ore", amount_min=4, amount_max=12},  -- avg 8   (100%)  - was 10 (100%)
			{type="item", name="copper-ore", amount_min=2, amount_max=5}, -- avg 3.5 (43.7%) - was 4   (40%)
			{type="item", name="metallic-asteroid-chunk", amount=1, independent_probability=0.1, ignored_by_stats = 1},
		},
	})
	meld(data.raw["recipe"]["advanced-carbonic-asteroid-crushing"], {
		energy_required = 6.25, -- was 5
		results = meld.overwrite{
			{type="item", name="carbon", amount_min=3, amount_max=5}, -- avg 4   (100%)  - was 5 (100%)
			{type="item", name="sulfur", amount_min=1, amount_max=2}, -- avg 1.5 (37.5%) - was 2  (40%)
			{type="item", name="carbonic-asteroid-chunk", amount=1, independent_probability=0.1, ignored_by_stats = 1},
		},
	})
	meld(data.raw["recipe"]["advanced-oxide-asteroid-crushing"], {
		energy_required = 6.4, -- was 5
		results = meld.overwrite{
			{type="item", name="ice", amount_min=1, amount_max=4},     -- avg 2.5 (100%) - was 3 (100%)
			{type="item", name="calcite", amount_min=0, amount_max=2}, -- avg 1.0  (40%) - was 2  (67%)
			{type="item", name="oxide-asteroid-chunk", amount=1, independent_probability=0.1, ignored_by_stats = 1},
		},
	})
end

---- Thruster fuel
local function thruster_fuel()
	meld(data.raw["recipe"]["thruster-fuel"], {
		energy_required = 2,
		ingredients = meld.overwrite{
			{type="item", name="carbon", amount=10}, -- was 2, lots of fuel needed
			{type="fluid", name="water", amount=10}, -- was 10
		},
		results = meld.overwrite{
			{type="fluid", name="thruster-fuel", amount=125}, -- was 75
		},
		localised_description = "A inefficient method to produce hydrocarbon fuel."
	})
	meld(data.raw["recipe"]["thruster-oxidizer"], {
		energy_required = 5, -- was 2, slow, lore is electrolysis to get oxygen?
		ingredients = meld.overwrite{
			{type="item", name="iron-stick", amount=1}, -- new, was 2 iron-ore, this is just the electrode
			{type="fluid", name="water", amount=45}, -- was 10
		},
		results = meld.overwrite{
			{type="fluid", name="thruster-oxidizer", amount=100}, -- was 75
		},
		localised_description = "Electrolysis of water using iron electrodes.\nLiquid oxygen is captured but all hydrogen leaks away."
	})
	-- carbon->coal->liquefaction->cracking->light oil + petro gas is about 10carbon->10fluid (5+5)
	-- but carbon+sulfur is gets less carbon than just carbon
	-- 1 solid-fuel = 10 light oil
	-- for 10+10 fluid maybe around 25 (?) water needed
	-- TODO: add ammonia thruster fuel recipe?
	-- TODO: this sadly depends on coal liquefaction or simple coal liquefaction, soe is behind vulcanus, unlock on gleba too?
	meld(data.raw["recipe"]["advanced-thruster-fuel"], {
		energy_required = 4, -- was 10
		ingredients = meld.overwrite{
			{type="item", name="solid-fuel", amount=1}, -- new, 10 light oil (was 2 carbon, 1 calcite, 100 water)
			{type="fluid", name="petroleum-gas", amount=8}, -- new
		},
		results = meld.overwrite{
			{type="fluid", name="thruster-fuel", amount=500}, -- was 1500, 4x may be fair with all the oil processing involved
			-- consider refunding water or steam here?
		},
		localised_description = "" -- TODO:
	})
	-- TODO: custom icon
	-- more efficient water use but slower?
	meld(data.raw["recipe"]["advanced-thruster-oxidizer"], {
		energy_required = 18, -- was 10
		categories = {"chemistry", "cryogenics"}, -- was chemistry
		ingredients = meld.overwrite{
			{type="item", name="copper-plate", amount=6}, -- new (was 2 iron-ore, 1 calcite)
			{type="item", name="iron-stick", amount=6}, -- new
			{type="fluid", name="water", amount=252}, -- was 100, 45*6=270 -> cheaper
		},
		results = meld.overwrite{
			{type="fluid", name="thruster-oxidizer", amount=600}, -- was 1500
			{type="fluid", name="thruster-fuel", amount_min=50, amount_max=70}, -- new
		},
		localised_description = "Electrolysis of water using copper-wrapped electrodes.\nLiquid oxygen is captured but most hydrogen leaks away."
	})

	-- TODO: advanced fuel recipe
end

---- Techs: advanced asteroid processing split per asteroid type
local function techs()
	local NAUVIS_PREREQ = { -- no military
		{"automation-science-pack", 1},
		{"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1},
		{"space-science-pack", 1},
	}

	data:extend({
		{
			type = "technology",
			name = "advanced-metallic-asteroid-processing",
			localised_name = "Advanced metallic asteroid processing",
			icon = "__space-age__/graphics/technology/advanced-asteroid-processing.png", -- TODO: make reasonable icon
			icon_size = 256,
			effects = {
				{type = "unlock-recipe", recipe = "advanced-metallic-asteroid-crushing"},
				{type = "unlock-recipe", recipe = "advanced-thruster-oxidizer"}
			},
			prerequisites = {"production-science-pack", "utility-science-pack", "metallurgic-science-pack"},
			unit = {
				count = 800,
				ingredients = common.list_concat(NAUVIS_PREREQ, {
					{"metallurgic-science-pack", 1}
				}),
				time = 60
			}
		},
		{
			type = "technology",
			name = "advanced-oxide-asteroid-processing",
			localised_name = "Advanced oxide asteroid processing",
			icon = "__space-age__/graphics/technology/advanced-asteroid-processing.png", -- TODO: make reasonable icon
			icon_size = 256,
			effects = {
				{type = "unlock-recipe", recipe = "advanced-oxide-asteroid-crushing"},
			},
			prerequisites = {"production-science-pack", "utility-science-pack", "electromagnetic-science-pack"},
			unit = {
				count = 800,
				ingredients = common.list_concat(NAUVIS_PREREQ, {
					{"electromagnetic-science-pack", 1}
				}),
				time = 60
			}
		},
		{
			type = "technology",
			name = "advanced-carbonic-asteroid-processing",
			localised_name = "Advanced carbonic asteroid processing",
			icon = "__space-age__/graphics/technology/advanced-asteroid-processing.png", -- TODO: make reasonable icon
			icon_size = 256,
			effects = {
				{type = "unlock-recipe", recipe = "advanced-carbonic-asteroid-crushing"},
				{type = "unlock-recipe", recipe = "advanced-thruster-fuel"} -- needs coal liquefaction, but could still launch barrels and solid fuel?
			},
			prerequisites = {"production-science-pack", "utility-science-pack", "agricultural-science-pack"},
			unit = {
				count = 800,
				ingredients = common.list_concat(NAUVIS_PREREQ, {
					{"agricultural-science-pack", 1}
				}),
				time = 60
			}
		},
	})

	-- replaced by the split techs above
	data.raw["technology"]["advanced-asteroid-processing"] = nil
end

function M.data()
	asteroid_spawns()
	crushing()
	thruster_fuel()
	techs()
end

function M.final_fixes()
	-- replace advanced-asteroid-processing with the split techs, also in other mods' techs
	common.replace_tech_references("advanced-asteroid-processing", {
		"advanced-metallic-asteroid-processing",
		"advanced-oxide-asteroid-processing",
		"advanced-carbonic-asteroid-processing"
	})
end

return M
