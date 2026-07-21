local util = require("util")

local M = {}

function M.updates()
	-- Make lvl 3 modules a bit more expensive
	for _,m in pairs{"speed-module-","efficiency-module-","productivity-module-","quality-module-"} do
		meld(data.raw["recipe"][m.."3"], {
			ingredients = util.overwrite_by_name{{type="item", name=m.."2", amount=5}}
		})
	end

	meld(data.raw["recipe"]["speed-module-3"], {
		ingredients = util.overwrite_by_name{{type="item", name="speed-module-2", amount=5}}
	})
	meld(data.raw["recipe"]["productivity-module-3"], {
		ingredients = util.overwrite_by_name{{type="item", name="productivity-module-2", amount=5}}
	})

	-- Eff 3 on fulgora with supercond
	-- Quality 3 on ?
	meld(data.raw["recipe"]["efficiency-module-3"], {
		ingredients = meld.overwrite{
			{type="item", name="advanced-circuit", amount=5},
			{type="item", name="processing-unit", amount=5},
			{type="item", name="superconductor", amount=2},
			{type="item", name="efficiency-module-2", amount=5},
		}
	})
	meld(data.raw["recipe"]["quality-module-3"], {
		ingredients = meld.overwrite{
			{type="item", name="advanced-circuit", amount=5},
			{type="item", name="processing-unit", amount=5},
			{type="item", name="quantum-processor", amount=1},
			{type="item", name="quality-module-2", amount=5},
		}
	})
	meld(data.raw["technology"]["efficiency-module-3"], {
		prerequisites = meld.overwrite{"electromagnetic-science-pack", "efficiency-module-2"},
		unit = {
			count = 300,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"space-science-pack", 1},
				{"electromagnetic-science-pack", 1}
			},
		}
	})
	meld(data.raw["technology"]["quality-module-3"], {
		prerequisites = meld.overwrite{"quantum-processor", "quality-module-2"},
		unit = {
			count = 500,
			ingredients = {
				{"automation-science-pack", 1},
				{"logistic-science-pack", 1},
				{"chemical-science-pack", 1},
				{"space-science-pack", 1},
				{"cryogenic-science-pack", 1}
			},
		}
	})
end
return M