local util = require("util")

--meld(data.raw["recipe"]["iron-gear-wheel"], {
--	energy_required = 0.75,
--	ingredients = meld.overwrite({
--		{ type = "item", name = "iron-plate", amount = 3 },
--	}),
--	results = meld.overwrite({
--		{ type = "item", name = "iron-gear-wheel", amount = 1 }, -- oops... this being 2 was a buff, not nerf
--	}),
--})
meld(data.raw["recipe"]["iron-gear-wheel"], {
	energy_required = 1.5,
	ingredients = meld.overwrite({
		{ type = "item", name = "iron-plate", amount = 5 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "iron-gear-wheel", amount = 2 },
	}),
})

meld(data.raw["recipe"]["copper-cable"], {
	energy_required = 1,
	ingredients = meld.overwrite({
		{ type = "item", name = "copper-plate", amount = 3 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "copper-cable", amount = 4 },
	}),
})

meld(data.raw["recipe"]["steel-plate"], {
	energy_required = 16,
	ingredients = meld.overwrite({
		{ type = "item", name = "iron-plate", amount = 6 },
		--{ type = "item", name = "coal", amount = 1 }, -- furnace can only have one input slot!
	}),
})

meld(data.raw["recipe"]["casting-steel"], {
	energy_required = 35,
	ingredients = meld.overwrite({
		{ type = "fluid", name = "molten-iron", amount = 30*4 }, -- TODO:
		{ type = "item", name = "coal", amount = 1 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "steel-plate", amount = 4 },
	}),
})

--meld(data.raw["recipe"]["pipe-casting"], {
--	energy_required = 35,
--	ingredients = meld.overwrite({
--		{ type = "fluid", name = "molten-iron", amount = 30*4 }, -- TODO:
--		{ type = "item", name = "coal", amount = 1 },
--	}),
--	results = meld.overwrite({
--		{ type = "item", name = "steel-plate", amount = 4 },
--	}),
--})

meld(data.raw["technology"]["engine"], {
	effects = meld.append({
		{
			type = "unlock-recipe",
			recipe = "iron-stick"
		}
	})
})
meld(data.raw["recipe"]["engine-unit"], {
	energy_required = 12,
	ingredients = meld.overwrite({
		{ type = "item", name = "iron-stick", amount = 1 },
		{ type = "item", name = "steel-plate", amount = 2 },
		{ type = "item", name = "iron-gear-wheel", amount = 3 },
		{ type = "item", name = "pipe", amount = 4 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "engine-unit", amount = 2 },
	}),
})

meld(data.raw["recipe"]["electric-engine-unit"], {
	ingredients = meld.overwrite({
		{ type = "item", name = "electronic-circuit", amount = 2 },
		{ type = "item", name = "engine-unit", amount = 1 },
		{ type = "item", name = "copper-cable", amount = 5 },
		{ type = "fluid", name = "lubricant", amount = 15 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "electric-engine-unit", amount = 2 },
	}),
})

-- green circ more expensive? or maybe just slower?

meld(data.raw["recipe"]["advanced-circuit"], {
	ingredients = meld.overwrite({
		{ type = "item", name = "plastic-bar",    amount = 3 },
		{ type = "item", name = "copper-cable",   amount = 4 },
		{ type = "item", name = "electronic-circuit", amount = 3 },
	}),
})

meld(data.raw["recipe"]["processing-unit"], {
	energy_required = 12,
	ingredients = meld.overwrite({
		{ type = "item", name = "electronic-circuit", amount = 24 },
		{ type = "item", name = "advanced-circuit", amount = 3 },
		{ type = "fluid", name = "sulfuric-acid",  amount = 16 },
	}),
})

-- foundry steel: molten iron + coal ?

meld(data.raw["recipe"]["quantum-processor"], {
	energy_required = 42,
	ingredients = meld.overwrite({
		{ type = "item",  name = "tungsten-carbide",  amount = 1 },                 -- 50/500
		{ type = "item",  name = "processing-unit",   amount = 3 },                 -- 40/160
		{ type = "item",  name = "superconductor",    amount = 4 },                 -- 200/1000
		{ type = "item",  name = "carbon-fiber",      amount = 1 },                 -- 100/500
		{ type = "item",  name = "lithium-plate",     amount = 1 },                 -- 100/500
		{ type = "fluid", name = "fluoroketone-cold", amount = 15, ignored_by_stats = 14 }, -- 10/100 (barrel) -> 50/500 (fluid)
		{ type = "fluid", name = "light-oil",         amount = 12 },                -- 10/100 (barrel) -> 50/500 (fluid)
		--{type = "fluid", name = "lubricant", amount = 4}, -- Can't have 3 inputs for some reason
	}),
	results = meld.overwrite({
		{ type = "item",  name = "quantum-processor", amount = 1 }, -- 10/62
		{ type = "fluid", name = "fluoroketone-hot",  amount = 14, temperature = 180, ignored_by_stats = 14, ignored_by_productivity = 14 }
	}),
})

meld(data.raw["recipe"]["automation-science-pack"], {
	energy_required = 6,
	ingredients = meld.overwrite({
		{ type = "item", name = "copper-cable",    amount = 3 },
		{ type = "item", name = "burner-inserter", amount = 1 }
	}),
})

meld(data.raw["recipe"]["long-handed-inserter"], {
	ingredients = {
		{ type = "item", name = "inserter", amount = 1 },
		{ type = "item", name = "iron-stick", amount = 1 },
		{ type = "item", name = "iron-gear-wheel", amount = 1 },
	}
})
meld(data.raw["recipe"]["logistic-science-pack"], {
	energy_required = 8,
	ingredients = meld.overwrite({
		{ type = "item", name = "long-handed-inserter", amount = 1 },
		{ type = "item", name = "transport-belt",       amount = 2 }
	}),
})

meld(data.raw["recipe"]["military-science-pack"], {
	energy_required = 14,
	ingredients = meld.overwrite({
		{ type = "item", name = "piercing-rounds-magazine", amount = 3 },
		{ type = "item", name = "grenade",                  amount = 1 },
		{ type = "item", name = "gate",                     amount = 2 }
	}),
})
meld(data.raw["technology"]["military-science-pack"], {
	prerequisites = meld.append({"gate"})
})

meld(data.raw["recipe"]["chemical-science-pack"], {
	energy_required = 28,
	ingredients = meld.overwrite({
		{ type = "item", name = "battery",          amount = 3 },
		{ type = "item", name = "pump",             amount = 3 },
		{ type = "item", name = "advanced-circuit", amount = 4 }
	}),
})
meld(data.raw["technology"]["chemical-science-pack"], {
	prerequisites = meld.append({"battery"})
})

meld(data.raw["recipe"]["electric-furnace"], {
	ingredients = meld.overwrite({
		{ type = "item", name = "steel-plate",      amount = 4 },
		{ type = "item", name = "advanced-circuit", amount = 5 },
		{ type = "item", name = "steel-furnace",    amount = 1 },
	}),
})
-- add concrete indirectly (or on utility-science?)
meld(data.raw["recipe"]["production-science-pack"], {
	energy_required = 28,
	ingredients = meld.overwrite({
		{ type = "item", name = "rail",                  amount = 40 },
		{ type = "item", name = "electric-furnace",      amount = 2 },
		{ type = "item", name = "hazard-concrete",       amount = 25 }, -- was assembler 2 in the other mod
		{ type = "item", name = "productivity-module",   amount = 1 } -- "productivity-module-2"
	}),
	results = meld.overwrite({
		{ type = "item", name = "production-science-pack", amount = 4 }
	}),
})
--meld(data.raw["technology"]["production-science-pack"], {
--	prerequisites = meld.append({"productivity-module-2"})
--})

-- TODO: tune this
meld(data.raw["recipe"]["utility-science-pack"], {
	energy_required = 36,
	ingredients = meld.overwrite({
		{ type = "item", name = "processing-unit",       amount = 2 },
		{ type = "item", name = "low-density-structure", amount = 3 },
		{ type = "item", name = "logistic-robot",        amount = 3 }, -- just make this the frame again?
		{ type = "item", name = "beacon",                amount = 1 } --- substation
	}),
	results = meld.overwrite({
		{ type = "item", name = "utility-science-pack", amount = 4 }
	}),
})
meld(data.raw["technology"]["utility-science-pack"], {
	prerequisites = meld.append({"effect-transmission"}) -- electric-energy-distribution-2
})
--meld(data.raw["technology"]["utility-science-pack"], {
--	prerequisites = meld.append({"effect-transmission"})
--})

-- Steel casting recipe: more efficent than my edited base from plate recipe
-- calculate furnace(plate)->furnace(steel) (prod/non-prod)
--           foundry(molten)->foundry(plate)->furnace(steel) (prod/non-prod)
--           foundry(molten)->foundry(steel) (prod/non-prod)
-- with no base prod, what steel recipe makes sense without being too strong (eg 4x the steel as vanilla gets)

-- huge carbon demand for tungsten carbide, but allow crushers on ground, so can drop asteroid chunks?
 -- why did nobody ever do this in vanilla?
 
-- thruster weaker?
-- increase planet dist 10x
-- slow down fuel recipies, maybe 3 chem plants per thruster?
-- fuel: carbon to solid fuel recipe, then lots of solid fuel to thruster fuel? (both a nerf, and later oil in space may be upgrade, does this affect planets?)
-- oxidizer: req iron stick (act as electrolizer electrode, req little iron but more water this would be a slow recipe)

--local vulcanus_autoplace = data.raw["planet"].vulcanus.map_gen_settings.autoplace_controls
--meld(data.raw["autoplace-control"]["tungsten_ore"], {
--	--frequency = vulcanus_autoplace.tungsten_ore.frequency * 1.25,
--	--size = vulcanus_autoplace.tungsten_ore.size * 1.1,
--	--richness = vulcanus_autoplace.tungsten_ore.richness * 1.5
--	frequency = 2,
--	size = 1,
--})
--[[ Shemp:
You can define an additional MapGenPreset, but you can't change the sliders on the Default one.
The developers expect you to overwrite the noise expressions on the resource prototype.
(You can see how their parameters are specified here in the base mod, but I'm not practised with these.) 

]]

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
			{type = "item", name = "calcite", amount = 3},
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
	maximum_productivity = 1.5,
})

-- plate casting 20% prod seems fair
meld(data.raw["recipe"]["casting-iron"], {
	energy_required = 15,
	ingredients = {
		{type = "fluid", name = "molten-iron", amount = 100, fluidbox_multiplier = 4},
	},
	results = {{type = "item", name = "iron-plate", amount = 12}}, -- 100->12 (20% buff to vanilla furnance)
	allow_productivity = false
})
meld(data.raw["recipe"]["casting-copper"], {
	energy_required = 15,
	ingredients = {
		{type = "fluid", name = "molten-copper", amount = 100, fluidbox_multiplier = 4},
	},
	results = {{type = "item", name = "copper-plate", amount = 12}},
	allow_productivity = false
})
-- gears, wires, sticks need better prod to avoid casting plate -> assembler being better, so need at least 1.2*1.3 prod (?)
meld(data.raw["recipe"]["casting-iron-gear-wheel"], {
	-- in/out, base cost, prodded assembler, plate casting + prodded assembler, direct casting, base effiency %
	-- 5/2: 2.5, 1.92, 1.60, 1.375 (5.5/4), unprodded 80% better
	energy_required = 4.5,
	ingredients = meld.overwrite({
		{ type = "fluid", name = "molten-iron", amount = 55 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "iron-gear-wheel", amount = 4 },
	}),
	allow_productivity = false,
})
meld(data.raw["recipe"]["casting-iron-stick"], {
	-- 1/2: 0.5, 0.38, 0.32, 0.28 (1.3/5), unprodded 78% better
	energy_required = 2,
	ingredients = meld.overwrite({
		{ type = "fluid", name = "molten-iron", amount = 14 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "iron-stick", amount = 5 },
	}),
	allow_productivity = false,
})
meld(data.raw["recipe"]["casting-copper-cable"], {
	-- 3/4: 0.75, 0.58, 0.48, 0.43 (1.3/3), unprodded 73% better
	energy_required = 1.5,
	ingredients = meld.overwrite({
		{ type = "fluid", name = "molten-copper", amount = 13 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "copper-cable", amount = 3 },
	}),
	allow_productivity = false,
})
meld(data.raw["recipe"]["casting-pipe"], {
	energy_required = 5,
	ingredients = meld.overwrite({
		{ type = "fluid", name = "molten-iron", amount = 38 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "pipe", amount = 5 },
	}),
	allow_productivity = false,
})
meld(data.raw["recipe"]["casting-pipe-to-ground"], {
	energy_required = 1.5,
	ingredients = meld.overwrite({
		{ type = "item", name = "pipe", amount = 10 },
		{ type = "fluid", name = "molten-iron", amount = 42 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "pipe-to-ground", amount = 2 },
	}),
	allow_productivity = false,
})
meld(data.raw["recipe"]["casting-steel"], {
	-- 6/1: 6, 5, 4.16, 3.75, unprodded 60% better, prodded 108% better
	energy_required = 20,
	ingredients = meld.overwrite({
		{ type = "item", name = "carbon", amount = 1 },
		{ type = "fluid", name = "molten-iron", amount = 225 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "steel-plate", amount = 6 },
	}),
	allow_productivity = true,
})
meld(data.raw["recipe"]["casting-low-density-structure"], {
	-- for some wierd reason, in vanilla the LDS casting recipe has a higher copper cost than the assembler
	-- though it is negated by the free 50% prod
	energy_required = 15,
	ingredients = meld.overwrite({
		{ type = "item", name = "plastic-bar", amount = 5 },
		{ type = "fluid", name = "molten-copper", amount = 165 },
		{ type = "fluid", name = "molten-iron", amount = 80 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "low-density-structure", amount = 1 },
	}),
	allow_productivity = true,
})
meld(data.raw["recipe"]["concrete-from-molten-iron"], {
	-- like LDS, here the iron cost is 2x compared to assembler, maybe to account for melting+casting 50% free prod?
	-- barely matters, but lets buff it slightly?
	energy_required = 10,
	ingredients = meld.overwrite({
		{ type = "item", name = "stone-brick", amount = 5 },
		{ type = "fluid", name = "molten-iron", amount = 14 },
		{ type = "fluid", name = "water", amount = 100 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "concrete", amount = 12 },
	}),
	allow_productivity = true,
})

meld(data.raw["technology"]["foundry"], {
	--effects = util.delete_recipe_by_name{
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

meld(data.raw["item"]["tungsten-ore"], {
	stack_size = 25,
})
meld(data.raw["item"]["tungsten-carbide"], {
	stack_size = 50,
	weight = 4000, -- 250 / rocket
})
meld(data.raw["item"]["tungsten-plate"], {
	stack_size = 40,
	weight = 6250, -- 160 / rocket
})
meld(data.raw["recipe"]["tungsten-plate"], {
	localised_description = "A strong tungsten-steel-alloy beam.\nCalcite flushes out impurities from the molten alloy before it is quenched in a lubricant bath.",
	main_product = "tungsten-plate",
	ingredients = meld.overwrite({
		{ type = "item", name = "tungsten-ore", amount = 4 },
		{ type = "item", name = "steel-plate",  amount = 3 },
		{ type = "item", name = "calcite",      amount = 1 },
		{ type = "fluid", name = "molten-iron", amount = 30 },
		{ type = "fluid", name = "lubricant",   amount = 2 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "tungsten-plate", amount = 1 },
		{ type = "item", name = "stone", amount_min = 0, amount_max = 4 }
	}),
})

meld(data.raw["recipe"]["metallurgic-science-pack"], {
	energy_required = 36,
	ingredients = meld.overwrite({
		{ type = "item", name = "tungsten-carbide",      amount = 8 },
		{ type = "item", name = "tungsten-plate",        amount = 4 },
		{ type = "item", name = "big-electric-pole",     amount = 2 },
		{ type = "item", name = "steam-turbine",         amount = 1 },
		{ type = "fluid", name = "molten-copper",        amount = 400 },
	}),
	results = meld.overwrite({
		{ type = "item", name = "metallurgic-science-pack", amount = 2 }
	}),
})
meld(data.raw["technology"]["metallurgic-science-pack"], {
	prerequisites = meld.append({"nuclear-power"})
})
