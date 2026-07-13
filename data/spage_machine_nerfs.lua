local util = require("util")

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

-- numbers are double from ingame number for some reason?
-- only (ingame) multiples of 15 can exist as whole numbers, sad
--set_belt_speed("transport-belt", "underground-belt", "splitter", 22.5)
--set_belt_speed("fast-transport-belt", "underground-belt", "splitter", 45)
--set_belt_speed("express-transport-belt", "express-underground-belt", "express-splitter", 75)
--set_belt_speed("turbo-transport-belt", "turbo-underground-belt", "turbo-splitter", 112.5)

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

meld(data.raw["recipe"]["metallic-asteroid-crushing"], {
	energy_required = 5,
	results = util.overwrite_by_name{{type="item", name="iron-ore", amount_min=8, amount_max=20}},
})
meld(data.raw["recipe"]["carbonic-asteroid-crushing"], {
	energy_required = 4.5,
	results = util.overwrite_by_name{{type="item", name="carbon", amount_min=6, amount_max=12}},
})
meld(data.raw["recipe"]["oxide-asteroid-crushing"], {
	energy_required = 4,
	results = util.overwrite_by_name{{type="item", name="ice", amount_min=2, amount_max=5}},
})
-- TODO: advanced asteroid stuff

meld(data.raw["recipe"]["thruster-fuel"], {
	energy_required = 2,
	ingredients = meld.overwrite({
		{type="item", name="carbon", amount=10}, -- was 2, lots of fuel needed
		{type="fluid", name="water", amount=10}, -- was 10
	}),
	results = meld.overwrite({
		{type="fluid", name="thruster-fuel", amount=150}, -- was 75
	}),
	localised_description = "And inefficient method to produce hydrocarbon fuel."
})
meld(data.raw["recipe"]["thruster-oxidizer"], {
	energy_required = 5, -- slow, lore is electrolysis to get oxygen?
	ingredients = meld.overwrite({
		{type="item", name="iron-stick", amount=1}, -- was 2, this is just the electrode
		{type="fluid", name="water", amount=42}, -- was 10
	}),
	results = meld.overwrite({
		{type="fluid", name="thruster-oxidizer", amount=150}, -- was 75
	}),
	localised_description = "Electrolysis of water using iron electrodes.\nLiquid oxygen is captured but all hydrogen leaks."
})

-- Ideas: (Space AJ Rebalance)
-- Metallurgic science recipe changed to be tungsten carbide + refined concrete + big power poles. This demands heavy use of the foundry to make effectively, to better match Vulcanus’s theme on bigtime casting.
-- Scrap now requires lubricant to mine.

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
	mining_speed = 1.25,
	resource_drain_rate_percent = 75, -- should probably nerf quality here if I cared about quality
})
meld(data.raw["resource"]["tungsten-ore"], {
	minable = { required_fluid = "lubricant", fluid_amount = 50 }
})
-- mining with fluid actually needs to be unlocked
-- so either need to unlock mining with fluid with this tech like tungsten_mining_require_lube mod
-- or put the drill behind the uranium mining tech, which actually just unlocks this, so I'll rename it as I think this makes a lot more sense
meld(data.raw["technology"]["big-mining-drill"], {
	prerequisites = meld.append({"uranium-mining"})
})
meld(data.raw["technology"]["uranium-mining"], {
	localised_name = "Mining with fluid",
	localised_description = "Allows you to use fluids to mine resources.\nLike using [fluid=sulfuric-acid] in [entity=electric-mining-drill] to mine [entity=uranium-ore]",
})

meld(data.raw["assembling-machine"]["foundry"], {
	module_slots = 3,
	crafting_speed = 3,
	effect_receiver = {
		base_effect = meld.delete() -- no base prod
	},
})


for _,m in pairs{"speed-module-","efficiency-module-","productivity-module-","quality-module-"} do
	meld(data.raw["recipe"][m.."3"], {
		ingredients = util.overwrite_by_name{{type="item", name=m.."2", amount=5}}
	})
end

-- buff the trickle of asteroids around nauvis to make stationary platforms more viable
meld(data.raw["planet"]["nauvis"], {
	asteroid_spawn_definitions = meld.invoke(function(list)
		for _,def in pairs(list) do
			def.probability = def.probability * 2
		end
		return list
	end)
})
