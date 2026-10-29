-- Foundry nerf and lava rework, ore melting and casting recipes, complex/mixed casting techs, tungsten, big mining drill
local const = require("const")
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

---- Lava
local function lava()
	-- Foundry recipe rework (balanced for spage_machine_nerfs foundry nerf)
	data.raw["recipe"]["molten-iron-from-lava"] = nil
	data.raw["recipe"]["molten-copper-from-lava"] = nil

	data:extend({
		{
			type = "recipe",
			name = "molten-metal-from-lava",
			icon = "__space-age__/graphics/icons/fluid/molten-iron-from-lava.png",
			localised_name = "Molten metals from lava",
			categories = {"metallurgy"},
			subgroup = "vulcanus-processes",
			order = "a[melting]-a[lava]",
			auto_recycle = false,
			enabled = false,
			energy_required = 30,
			ingredients = {
				{type = "fluid", name = "lava", amount = 1000},
				{type = "item", name = "calcite", amount = 2},
			},
			results = {
				{type = "fluid", name = "molten-iron", amount_min = 100, amount_max = 400},
				{type = "fluid", name = "molten-copper", amount_min = 100, amount_max = 300},
				{type = "item", name = "stone", amount = 23},
			},
			allow_productivity = true
		},
		-- with basegame 300% prod limit (1 ore -> 40 liquid metal), there is the danger if allowing infinite metal generation via a loop
		-- so don't allow prod here and pick numbers carefully
		-- can be abused to turn iron into stone. Does that matter? If so just remove stone output
		{
			type = "recipe",
			name = "solidify-molten-iron",
			icons = {
				{ icon = "__base__/graphics/icons/iron-ore.png",
				  icon_size = 64, scale = .35 },
				{ icon = "__space-age__/graphics/icons/fluid/molten-iron.png",
				  icon_size = 64, scale = .35, shift = {8, -8} },
			},
			localised_name = "Solidify molten iron",
			localised_description = "Quickly soldify metal into slag (ore)",
			categories = {"metallurgy"},
			subgroup = "vulcanus-processes",
			order = "a[melting]-b[voiding-iron]",
			auto_recycle = false,
			enabled = false,
			energy_required = 7.5,
			ingredients = {
				{type = "fluid", name = "molten-iron", amount = 275, fluidbox_multiplier = 3},
				{type = "fluid", name = "water", amount = 40 },
			},
			-- at 300% max prod  275 / 10 / 4 = 6.875 is the safe amount of ore output to prevent duping
			-- at 150% max prod on melting its 11
			results = {
				{type = "item", name = "iron-ore", amount = 10},
				{type = "item", name = "stone", amount = 17} -- reduce stone? but this is supposed to be a challenge to lava-void
			},
			allow_productivity = false
		},
		{
			type = "recipe",
			name = "solidify-molten-copper",
			icons = {
				{ icon = "__base__/graphics/icons/copper-ore.png",
				  icon_size = 64, scale = .35 },
				{ icon = "__space-age__/graphics/icons/fluid/molten-copper.png",
				  icon_size = 64, scale = .35, shift = {8, -8} },
			},
			localised_name = "Solidify molten copper",
			localised_description = "Quickly soldify metal into slag (ore)",
			categories = {"metallurgy"},
			subgroup = "vulcanus-processes",
			order = "a[melting]-c[voiding-copper]",
			auto_recycle = false,
			enabled = false,
			energy_required = 7.5,
			ingredients = {
				{type = "fluid", name = "molten-copper", amount = 275, fluidbox_multiplier = 3},
				{type = "fluid", name = "water", amount = 40},
			},
			-- at 300% max prod  275 / 10 / 4 = 6.875 is the safe amount of ore output to prevent duping
			-- at 150% max prod on melting its 11
			results = {
				{type = "item", name = "copper-ore", amount = 10},
				{type = "item", name = "stone", amount = 17}
			},
			allow_productivity = false
		},
	})
end

---- Ore melting and casting
local function casting()
	-- in vanilla casting gears is base 2x better than assemblers, gets 50% prod for free, and 4 module slots (90% prod) + 90% prod on ores, which is ridiciously OP
	-- instead allow prod on ore step, nerf modules to 3, and disallow prod on regular casting (except steel)
	-- numbers chosen such that casting plates -> assembler with prod is not better than casting
	-- but this is super dodgy, probably need to check and document these numbers more
	meld(data.raw["recipe"]["iron-ore-melting"], {
		order = "a[melting]-d[iron-ore-melting]",
		allow_productivity = true,
		maximum_productivity = 1.5, -- 150% to avoid infinite metal generation with solidify-molten-iron
	})
	meld(data.raw["recipe"]["copper-ore-melting"], {
		order = "a[melting]-e[copper-ore-melting]",
		allow_productivity = true,
		maximum_productivity = 1.5, -- see iron-ore-melting
	})

	-- plate casting 20% prod seems fair
	meld(data.raw["recipe"]["casting-iron"], {
		energy_required = 14, -- was 3.2
		ingredients = meld.overwrite{
			{type = "fluid", name = "molten-iron", amount = 100, fluidbox_multiplier = 4}, -- was 20
		},
		results = meld.overwrite{
			{type = "item", name = "iron-plate", amount = 12} -- was 2
		}, -- 100->12 (20% buff to vanilla furnance)
		allow_productivity = false -- was true
	})
	meld(data.raw["recipe"]["casting-copper"], {
		energy_required = 14, -- was 3.2
		ingredients = meld.overwrite{
			{type = "fluid", name = "molten-copper", amount = 100, fluidbox_multiplier = 4}, -- was 20
		},
		results = meld.overwrite{
			{type = "item", name = "copper-plate", amount = 12} -- was 2
		},
		allow_productivity = false -- was true
	})

	-- gears, wires, sticks need better prod to avoid casting plate -> assembler being better, so need at least 1.2*1.3 prod (?)
	meld(data.raw["recipe"]["casting-iron-gear-wheel"], {
		-- in/out, base cost, prodded assembler, plate casting + prodded assembler, direct casting, base effiency %
		-- 5/2: 2.5, 1.92, 1.60, 1.375 (5.5/4), unprodded 80% better
		energy_required = 4.5, -- was 1
		ingredients = meld.overwrite{
			{ type = "fluid", name = "molten-iron", amount = 55 }, -- was 10
		},
		results = meld.overwrite{
			{ type = "item", name = "iron-gear-wheel", amount = 4 }, -- was 1
		},
		allow_productivity = false, -- was true
	})
	meld(data.raw["recipe"]["casting-iron-stick"], {
		-- 1/2: 0.5, 0.38, 0.32, 0.28 (1.3/5), unprodded 78% better
		energy_required = 2, -- was 1
		ingredients = meld.overwrite{
			{ type = "fluid", name = "molten-iron", amount = 14 }, -- was 20
		},
		results = meld.overwrite{
			{ type = "item", name = "iron-stick", amount = 5 }, -- was 4
		},
		allow_productivity = false, -- was true
	})
	meld(data.raw["recipe"]["casting-copper-cable"], {
		-- 3/4: 0.75, 0.58, 0.48, 0.375 (1.5/4), unprodded 100% better
		-- EM plant gets up to 60% prod, so adjust this again from 13->3 in 1.5 to 15->4 
		energy_required = 2, -- was 1
		ingredients = meld.overwrite{
			{ type = "fluid", name = "molten-copper", amount = 15 }, -- was 5
		},
		results = meld.overwrite{
			{ type = "item", name = "copper-cable", amount = 4 }, -- was 2
		},
		allow_productivity = false, -- was true
	})
	meld(data.raw["recipe"]["casting-pipe"], {
		-- 1/1: 1, 0.77, 0.64, 0.76 (3.8/5), unprodded 32% better, but worse than plate casting + prodded assembler
		energy_required = 5, -- was 1
		ingredients = meld.overwrite{
			{ type = "fluid", name = "molten-iron", amount = 38 }, -- was 10
		},
		results = meld.overwrite{
			{ type = "item", name = "pipe", amount = 5 }, -- was 1
		},
		allow_productivity = false,
	})
	meld(data.raw["recipe"]["casting-pipe-to-ground"], {
		energy_required = 1.5, -- was 1
		ingredients = meld.overwrite{
			{ type = "item", name = "pipe", amount = 10 },
			{ type = "fluid", name = "molten-iron", amount = 42 }, -- was 50
		},
		results = meld.overwrite{
			{ type = "item", name = "pipe-to-ground", amount = 2 },
		},
		allow_productivity = false,
	})
	meld(data.raw["recipe"]["casting-steel"], {
		-- 6/1: 6, 5, 4.16, 3.75, unprodded 60% better, prodded 108% better
		energy_required = 20, -- was 3.2
		ingredients = meld.overwrite{
			{ type = "item", name = "carbon", amount = 1 }, -- new
			{ type = "fluid", name = "molten-iron", amount = 225 }, -- was 30
		},
		results = meld.overwrite{
			{ type = "item", name = "steel-plate", amount = 6 }, -- was 1
		},
		allow_productivity = true,
	})
	meld(data.raw["recipe"]["casting-low-density-structure"], {
		-- for some wierd reason, in vanilla the LDS casting recipe has a higher copper cost than the assembler
		-- though it is negated by the free 50% prod
		energy_required = 15,
		ingredients = meld.overwrite{
			{ type = "item", name = "plastic-bar", amount = 5 },
			{ type = "fluid", name = "molten-copper", amount = 165 }, -- was 250
			{ type = "fluid", name = "molten-iron", amount = 80 },
		},
		results = meld.overwrite{
			{ type = "item", name = "low-density-structure", amount = 1 },
		},
		allow_productivity = true,
	})
	meld(data.raw["recipe"]["concrete-from-molten-iron"], {
		-- like LDS, here the iron cost is 2x compared to assembler, maybe to account for melting+casting 50% free prod?
		-- barely matters, but lets buff it slightly?
		energy_required = 10,
		ingredients = meld.overwrite{
			{ type = "item", name = "stone-brick", amount = 5 },
			{ type = "fluid", name = "molten-iron", amount = 14 }, -- was 20
			{ type = "fluid", name = "water", amount = 100 },
		},
		results = meld.overwrite{
			{ type = "item", name = "concrete", amount = 12 }, -- was 10
		},
		allow_productivity = true,
	})
end

---- Tungsten
local function tungsten()
	meld(data.raw["recipe"]["tungsten-plate"], {
		localised_description = "A strong tungsten-steel-alloy beam.\nCalcite flushes out impurities from the molten alloy before it is quenched in a lubricant bath.",
		main_product = "tungsten-plate",
		ingredients = meld.overwrite{
			{ type = "item", name = "tungsten-ore", amount = 4 },
			{ type = "item", name = "steel-plate",  amount = 3 }, -- new
			{ type = "item", name = "calcite",      amount = 1 }, -- new
			{ type = "fluid", name = "molten-iron", amount = 30 }, -- was 10
			{ type = "fluid", name = "lubricant",   amount = 2 }, -- new
		},
		results = meld.overwrite{
			{ type = "item", name = "tungsten-plate", amount = 1 },
			{ type = "item", name = "stone", amount_min = 0, amount_max = 4 } -- new
		},
	})
end

---- Techs
local function techs()
	meld(data.raw["technology"]["foundry"], {
		--effects = common.meld_remove{
		--	{type="unlock-recipe", recipe="molten-iron-from-lava"},
		--	{type="unlock-recipe", recipe="molten-copper-from-lava"},
		--},
		effects = meld.overwrite{
			{type = "unlock-recipe",recipe = "foundry" },
			--{type = "unlock-recipe",recipe = "molten-iron-from-lava"},
			--{type = "unlock-recipe",recipe = "molten-copper-from-lava"},
			{type = "unlock-recipe",recipe = "molten-metal-from-lava"},
			{type = "unlock-recipe",recipe = "solidify-molten-iron"},
			{type = "unlock-recipe",recipe = "solidify-molten-copper"},
			{type = "unlock-recipe",recipe = "iron-ore-melting"},
			{type = "unlock-recipe",recipe = "copper-ore-melting"},
			{type = "unlock-recipe",recipe = "casting-iron"},
			--{type = "unlock-recipe",recipe = "casting-steel"},
			{type = "unlock-recipe",recipe = "casting-copper"},
			--{type = "unlock-recipe",recipe = "concrete-from-molten-iron"},
			--{type = "unlock-recipe",recipe = "casting-low-density-structure"},
			--{type = "unlock-recipe",recipe = "casting-iron-gear-wheel"},
			--type = "unlock-recipe",recipe = "casting-iron-stick"},
			--{type = "unlock-recipe",recipe = "casting-pipe"},
			--{type = "unlock-recipe",recipe = "casting-pipe-to-ground"},
			--{type = "unlock-recipe",recipe = "casting-copper-cable"},
		},
	})
	-- had to change this to fix an error, but the tips and tricks entry is still broken
	-- TODO: remove it?
	meld(data.raw["tips-and-tricks-item"]["lava-processing"], {
		skip_trigger = { recipe = "molten-metal-from-lava" }
	})

	data:extend({
		{
			type = "technology",
			name = "foundry-complex-casting",
			localised_name = "Complex casting",
			localised_description = "Metal-efficient casting of items with complex shapes.",
			icons = {
				{ icon = "__space-age__/graphics/technology/foundry.png",
				  icon_size = 256 },
				{ icon = "__base__/graphics/icons/copper-cable.png",
				  icon_size = 64, scale = 1, shift = {0, 32}, draw_background = true },
				{ icon = "__base__/graphics/icons/iron-gear-wheel.png",
				  icon_size = 64, scale = 1, shift = {48, 32}, draw_background = true },
			},
			effects = {
				{type = "unlock-recipe",recipe = "casting-iron-gear-wheel"},
				{type = "unlock-recipe",recipe = "casting-iron-stick"},
				{type = "unlock-recipe",recipe = "casting-copper-cable"},
				{type = "unlock-recipe",recipe = "casting-pipe"},
			},
			prerequisites = {"metallurgic-science-pack"},
			unit = {
				count = 120,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1},
					{"metallurgic-science-pack", 1}
				},
				time = 30
			}
		},
		{
			type = "technology",
			name = "foundry-mixed-casting",
			localised_name = "Mixed casting",
			localised_description = "Metal-efficient casting of alloys and composite materials.", -- TODO: wording?
			icons = {
				{ icon = "__space-age__/graphics/technology/foundry.png",
				  icon_size = 256 },
				{ icon = "__base__/graphics/icons/low-density-structure.png",
				  icon_size = 64, scale = 1, shift = {0, 32}, draw_background = true },
				{ icon = "__base__/graphics/icons/steel-plate.png",
				  icon_size = 64, scale = 1, shift = {48, 32}, draw_background = true },
			},
			effects = {
				{type = "unlock-recipe",recipe = "casting-steel"},
				{type = "unlock-recipe",recipe = "casting-low-density-structure"},
				{type = "unlock-recipe",recipe = "casting-pipe-to-ground"},
				{type = "unlock-recipe",recipe = "concrete-from-molten-iron"},
			},
			prerequisites = {"foundry-complex-casting","metallurgic-science-pack"},
			unit = {
				count = 200,
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1},
					{"metallurgic-science-pack", 1}
				},
				time = 60
			}
		},
	})
end

---- Metallurgic science (hard science setting)
local function science()
	-- raw cost per pack 31.8 -> 183 (5.8x), casting everything on vulcanus, molten metal and sulfuric acid counted as raw (10 = 1 ore),
	--   foundry base prod 50% -> 0%: molten iron 8.9 -> 915 (steam turbine, big poles, steel in tungsten plate), molten copper 133 -> 423,
	--   tungsten ore 7.6 -> 16, sulfuric acid 60 -> 157
	meld(data.raw["recipe"]["metallurgic-science-pack"], {
		energy_required = 36, -- was 10
		ingredients = meld.overwrite{
			{ type = "item", name = "tungsten-carbide",      amount = 8 }, -- was 3
			{ type = "item", name = "tungsten-plate",        amount = 4 }, -- was 2
			{ type = "item", name = "big-electric-pole",     amount = 2 }, -- new
			{ type = "item", name = "steam-turbine",         amount = 1 }, -- new
			{ type = "fluid", name = "molten-copper",        amount = 400 }, -- was 200
		},
		results = meld.overwrite{
			{ type = "item", name = "metallurgic-science-pack", amount = 2 } -- was 1
		},
	})
	meld(data.raw["technology"]["metallurgic-science-pack"], {
		prerequisites = common.meld_add_or_assign{"nuclear-power"}
	})
end

---- Resources
local function resources()
	meld(data.raw["resource"]["tungsten-ore"], {
		minable = { required_fluid = "lubricant", fluid_amount = 120 } -- was none
	})

	--local vulcanus_autoplace = data.raw["planet"].vulcanus.map_gen_settings.autoplace_controls
	--meld(data.raw["autoplace-control"]["tungsten_ore"], {
	--	--frequency = vulcanus_autoplace.tungsten_ore.frequency * 1.25,
	--	--size = vulcanus_autoplace.tungsten_ore.size * 1.1,
	--	--richness = vulcanus_autoplace.tungsten_ore.richness * 1.5
	--	frequency = 2,
	--	size = 1,
	--})
end

---- Machines
local function machines()
	meld(data.raw["assembling-machine"]["foundry"], {
		module_slots = 3, -- was 4
		crafting_speed = 3.5, -- was 4
		energy_source = {
			-- why are these so polluting in vanilla? was more polluting than electric furnance at speed=2 pollution=1 !
			emissions_per_minute = { pollution = 3.15 }, -- was 6 (1.5/speed (but lots of prod) -> 0.9/speed)
		},
		effect_receiver = {
			base_effect = meld.delete() -- no base prod
		},
	})

	meld(data.raw["mining-drill"]["big-mining-drill"], {
		module_slots = 3, -- was 4
		-- 5x5/3x3 is about 2.5x, 5x6/3x4 is exactly 2.5x, but slower mining in exchange for less resource drain is fine
		-- mining prod and modules can make up for it
		-- wait normal drill speed is 0.5, so 2.2 is still OP
		--mining_speed = 2.2,
		mining_speed = 1.25, -- was 2.5
		energy_source = {
			emissions_per_minute = { pollution = 20.0 }, -- was 40
		},
		-- keep at 50% drain, even though I think 2x anything is a bit OP, it just reduces the frequency of havint to build new mining sites
		--resource_drain_rate_percent = 75, -- should probably nerf quality here if I cared about quality
	
	})
end

---- Out of place: big mining drill behind uranium mining, renamed to mining with fluid (Nauvis techs)
local function mining_with_fluid()
	-- mining with fluid actually needs to be unlocked
	-- so either need to unlock mining with fluid with this tech like tungsten_mining_require_lube mod
	-- or put the drill behind the uranium mining tech, which actually just unlocks this, so I'll rename it as I think this makes a lot more sense
	meld(data.raw["technology"]["big-mining-drill"], {
		prerequisites = common.meld_add_or_assign{"uranium-mining"}
	})
	meld(data.raw["technology"]["uranium-mining"], {
		localised_name = "Mining with fluid",
		localised_description = "Allows you to use fluids to mine resources.\nLike using [fluid=sulfuric-acid] in [entity=electric-mining-drill] to mine [entity=uranium-ore]",
	})
end

function M.data()
	lava()
	casting()
	tungsten()
	techs()
	if settings.startup[const.SETTING_HARD_SCIENCE].value then science() end
	resources()
	machines()
	mining_with_fluid()
end

function M.final()
	-- deleted lava recipes, unlocks could have been added by other mods
	common.remove_recipe_references{"molten-iron-from-lava", "molten-copper-from-lava"}
end

return M
