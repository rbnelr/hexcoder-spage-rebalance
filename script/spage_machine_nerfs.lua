local mod_name = "hexcoder-spage-rebalance-"
local meld = require("__core__.lualib.meld")
local myutil = require("myutil")

local M = {}

function M.updates()

local function set_belt_speed(belt, underground, splitter, speed)
	meld(data.raw["transport-belt"][belt], {
		speed = speed/2/480, -- 0.0625*480 = 30 items/sec
		--animation_speed_coefficient = 32,
	})
	meld(data.raw["underground-belt"][underground], {
		speed = speed/2/480,
		--animation_speed_coefficient = 32,
	})
	meld(data.raw["splitter"][splitter], {
		speed = speed/2/480,
		--animation_speed_coefficient = 32,
	})
end

meld(data.raw["cargo-bay"]["cargo-bay"], {    inventory_size_bonus = 10 })
meld(data.raw["cargo-bay"]["landing-pad-unloading-bay"], { inventory_size_bonus = 10 })
meld(data.raw["container"]["wooden-chest"], { inventory_size = 10 })
meld(data.raw["container"]["iron-chest"], {   inventory_size = 16 })
meld(data.raw["container"]["steel-chest"], {  inventory_size = 30 })
for _,c in pairs({
	"active-provider-chest",
	"buffer-chest",
	"passive-provider-chest",
	"requester-chest",
	"storage-chest",
}) do
	meld(data.raw["logistic-container"][c], { inventory_size = 30 })
end
 
--meld(data.raw["inserter"]["bulk-inserter"], {
--	rotation_speed = 0.03, -- was 0.04
--})

-- numbers are double from ingame number for some reason?
-- only (ingame) multiples of 15 can exist as whole numbers, sad
--set_belt_speed("transport-belt", "underground-belt", "splitter", 22.5)
--set_belt_speed("fast-transport-belt", "underground-belt", "splitter", 45)
--set_belt_speed("express-transport-belt", "express-underground-belt", "express-splitter", 75)
--set_belt_speed("turbo-transport-belt", "turbo-underground-belt", "turbo-splitter", 112.5)

meld(data.raw["item"]["processing-unit"], {
	stack_size = 40,
	--ingredient_to_weight_coefficient = 0.5, --> results in 160 (4 Stacks)
	weight = 8333, -- 120 / rocket
})
meld(data.raw["item"]["low-density-structure"], {
	stack_size = 20, -- it's low density, duh
})

meld(data.raw["recipe"]["rocket-part"], {
	ingredients = meld.overwrite({
		{type="item", name="low-density-structure", amount=2},
		{type="item", name="rocket-fuel", amount=3},
		{type="item", name="rocket-control-unit", amount=1},
	}),
})
meld(data.raw["rocket-silo"]["rocket-silo"], {
	rocket_parts_required = 100,
})

meld(data.raw["assembling-machine"]["assembling-machine-3"], {
	module_slots = 3
})

meld(data.raw["assembling-machine"]["chemical-plant"], {
	module_slots = 2
})

meld(data.raw["mining-drill"]["electric-mining-drill"], {
	module_slots = 2
})
meld(data.raw["mining-drill"]["big-mining-drill"], {
	module_slots = 3,
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
meld(data.raw["resource"]["tungsten-ore"], {
	minable = { required_fluid = "lubricant", fluid_amount = 50 }
})
-- mining with fluid actually needs to be unlocked
-- so either need to unlock mining with fluid with this tech like tungsten_mining_require_lube mod
-- or put the drill behind the uranium mining tech, which actually just unlocks this, so I'll rename it as I think this makes a lot more sense
meld(data.raw["technology"]["big-mining-drill"], {
	prerequisites = meld.append{"uranium-mining"}
})
meld(data.raw["technology"]["uranium-mining"], {
	localised_name = "Mining with fluid",
	localised_description = "Allows you to use fluids to mine resources.\nLike using [fluid=sulfuric-acid] in [entity=electric-mining-drill] to mine [entity=uranium-ore]",
})

meld(data.raw["furnace"]["electric-furnace"], {
	energy_source = {
		emissions_per_minute = { pollution = 2 }, -- was 1 (0.5/speed -> 1/speed)
	},
})
meld(data.raw["assembling-machine"]["foundry"], {
	module_slots = 3,
	crafting_speed = 3.5, -- was 4
	energy_source = {
		-- why are these so polluting in vanilla? was more polluting than electric furnance at speed=2 pollution=1 !
		emissions_per_minute = { pollution = 3.15 }, -- was 6 (1.5/speed (but lots of prod) -> 0.9/speed)
	},
	effect_receiver = {
		base_effect = meld.delete() -- no base prod
	},
})
meld(data.raw["furnace"]["recycler"], {
	module_slots = 2, -- was 4
})
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

meld(data.raw["assembling-machine"]["biochamber"], {
	module_slots = 0, -- was 4
})

require("script.gleba")

meld(data.raw["assembling-machine"]["cryogenic-plant"], {
	energy_source = {
		emissions_per_minute = { pollution = 10 }, -- was 6, now more polluting than chem plant
	},
})


-- buff the trickle of asteroids around nauvis to make stationary platforms more viable
meld(data.raw["planet"]["nauvis"], {
	asteroid_spawn_definitions = meld.invoke(function(list)
		for _,def in pairs(list) do
			def.probability = def.probability * 4
			def.speed = def.speed * 1.6
		end
		return list
	end)
})


meld(data.raw["recipe"]["metallic-asteroid-crushing"], {
	energy_required = 4, -- was 2
	results = myutil.overwrite_by_name{{type="item", name="iron-ore", amount_min=8, amount_max=24}}, -- avg 16 was 20
})
meld(data.raw["recipe"]["carbonic-asteroid-crushing"], {
	energy_required = 3.5, -- was 2
	results = myutil.overwrite_by_name{{type="item", name="carbon", amount_min=6, amount_max=12}}, -- was 10
})
meld(data.raw["recipe"]["oxide-asteroid-crushing"], {
	energy_required = 3.2, -- was 2
	results = myutil.overwrite_by_name{{type="item", name="ice", amount_min=2, amount_max=6}}, -- avg 4 was 5
})

meld(data.raw["recipe"]["advanced-metallic-asteroid-crushing"], {
	energy_required = 8, -- was 5
	results = meld.overwrite{
		{type="item", name="iron-ore", amount_min=4, amount_max=12},  -- avg 8   (100%)  - was 10 (100%)
		{type="item", name="copper-ore", amount_min=2, amount_max=5}, -- avg 3.5 (43.7%) - was 4   (40%)
		{type="item", name="metallic-asteroid-chunk", amount=1, independent_probability=0.1, ignored_by_stats = 1},
	},
})
meld(data.raw["recipe"]["advanced-carbonic-asteroid-crushing"], {
	energy_required = 7, -- was 5
	-- TODO
})
meld(data.raw["recipe"]["advanced-oxide-asteroid-crushing"], {
	energy_required = 6.4, -- was 5
	results = meld.overwrite{
		{type="item", name="ice", amount_min=1, amount_max=4},     -- avg 2.5 (100%) - was 3 (100%)
		{type="item", name="calcite", amount_min=0, amount_max=3}, -- avg 1.5  (60%) - was 2  (67%)
		{type="item", name="oxide-asteroid-chunk", amount=1, independent_probability=0.1, ignored_by_stats = 1},
	},
})

meld(data.raw["recipe"]["thruster-fuel"], {
	energy_required = 2,
	ingredients = meld.overwrite({
		{type="item", name="carbon", amount=10}, -- was 2, lots of fuel needed
		{type="fluid", name="water", amount=10}, -- was 10
	}),
	results = meld.overwrite({
		{type="fluid", name="thruster-fuel", amount=150}, -- was 75
	}),
	localised_description = "A inefficient method to produce hydrocarbon fuel."
})
meld(data.raw["recipe"]["thruster-oxidizer"], {
	energy_required = 5, -- slow, lore is electrolysis to get oxygen?
	ingredients = meld.overwrite({
		{type="item", name="iron-stick", amount=1}, -- was 2, this is just the electrode
		{type="fluid", name="water", amount=45}, -- was 10
	}),
	results = meld.overwrite({
		{type="fluid", name="thruster-oxidizer", amount=150}, -- was 75
	}),
	localised_description = "Electrolysis of water using iron electrodes.\nLiquid oxygen is captured but all hydrogen leaks away."
})
-- TODO: custom icon
meld(data.raw["recipe"]["advanced-thruster-oxidizer"], {
	energy_required = 12,
	ingredients = meld.overwrite({
		{type="item", name="copper-plate", amount=2},
		{type="item", name="iron-stick", amount=1},
		{type="fluid", name="water", amount=220}, -- was 100
	}),
	results = meld.overwrite({
		{type="fluid", name="thruster-oxidizer", amount=1500}, -- was 1500
		{type="fluid", name="thruster-fuel", amount=120},
	}),
	localised_description = "Electrolysis of water using copper-wrapped electrodes.\nLiquid oxygen is captured but most hydrogen leaks away."
})

-- TODO: advanced fuel recipe
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
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
				{"space-science-pack", 1},
				{"metallurgic-science-pack", 1}
			},
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
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
				{"space-science-pack", 1},
				{"electromagnetic-science-pack", 1}
			},
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
		},
		prerequisites = {"production-science-pack", "utility-science-pack", "agricultural-science-pack"},
		unit = {
			count = 800,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"production-science-pack", 1},
				{"utility-science-pack", 1},
				{"space-science-pack", 1},
				{"agricultural-science-pack", 1}
			},
			time = 60
		}
	},
})

data.raw["technology"]["advanced-asteroid-processing"] = nil

meld(data.raw["technology"]["asteroid-productivity"], {
	prerequisites = meld.overwrite{"advanced-metallic-asteroid-processing",
	                 "advanced-oxide-asteroid-processing",
	                 "advanced-carbonic-asteroid-processing"}
})
meld(data.raw["technology"]["planet-discovery-aquilo"], {
	prerequisites = meld.overwrite{"rocket-turret", "heating-tower", "asteroid-reprocessing",
		"advanced-metallic-asteroid-processing",
		"advanced-oxide-asteroid-processing",
		"advanced-carbonic-asteroid-processing"
	}
})

end

return M