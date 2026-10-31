-- Item stack sizes and rocket weights
local meld = require("__core__.lualib.meld")

local M = {}

function M.data()
	-- Nauvis
	meld(data.raw["item"]["processing-unit"], {
		stack_size = 40, -- was 100
		--ingredient_to_weight_coefficient = 0.5, --> results in 160 (4 Stacks)
		weight = 8333, -- 120 / rocket
	})
	
	---- make launching rocket parts really expensive
	---- >1 launch per launch even with high productivity
	-- ~33% rocket worth per rocket
	meld(data.raw["item"]["rocket-fuel"], {
		--stack_size = 20,
		--weight = 10000, -- 100 / rocket, was 10000 (100 / rocket)
	})
	-- ~40% rocket worth per rocket
	meld(data.raw["item"]["low-density-structure"], {
		stack_size = 20, -- was 50, it's low density, duh
		weight = 12500, -- 80 / rocket, was 5000 (200 / rocket)
	})
	-- ~1 rocket worth per rocket
	meld(data.raw["item"]["rocket-control-unit"], {
		stack_size = 25,
		weight = 1000000/75, -- 75 / rocket
	})

	-- Vulcanus
	meld(data.raw["item"]["tungsten-ore"], {
		stack_size = 25, -- was 50
	})
	meld(data.raw["item"]["tungsten-carbide"], {
		stack_size = 100, -- was 50, increased for QP stack tradeoff
		weight = 4000, -- 250 / rocket, was 2000 (500 / rocket)
	})
	meld(data.raw["item"]["tungsten-plate"], {
		stack_size = 40, -- was 50
		weight = 6250, -- 160 / rocket, was 4000 (250 / rocket)
	})

	-- Aquilo
	------ Item stack and rocket rebalance to encourage production in space

	meld(data.raw["item"]["lithium-plate"], {
		stack_size = 200, -- was 100, increased for QP stack tradeoff
		weight = 1000000/600, -- 600 / rocket, was 2000 (500 / rocket)
	})
	
	meld(data.raw["item"]["quantum-processor"], {
		stack_size = 8, -- was 100
		weight = 15625, -- 64 / rocket, was 5000 (200 / rocket)
	})

	-- Fish (promethium.lua)
	meld(data.raw["capsule"]["raw-fish"], {
		stack_size = 20, -- was 100
	})
end

return M
