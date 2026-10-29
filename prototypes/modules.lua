-- Tier 3 module recipes and techs (ingredients from several planets)
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

function M.data()
	-- Make lvl 3 modules a bit more expensive (they actually used to cost 5 module-2)
	meld(data.raw["recipe"]["speed-module-3"], {
		ingredients = meld.overwrite{
			{type="item", name="advanced-circuit", amount=5},
			{type="item", name="processing-unit", amount=5},
			{type="item", name="tungsten-carbide", amount=10}, -- was 1, 10!
			{type="item", name="speed-module-2", amount=5}, -- 4->5 lvl2
		}
	})
	
	meld(data.raw["recipe"]["productivity-module-3"], {
		ingredients = meld.overwrite{
			{type="item", name="advanced-circuit", amount=5},
			{type="item", name="processing-unit", amount=5},
			{type="item", name="biter-egg", amount=1}, -- keep at 1
			{type="item", name="productivity-module-2", amount=5}, -- was 4
		}
	})
	
	meld(data.raw["recipe"]["efficiency-module-3"], {
		ingredients = meld.overwrite{
			{type="item", name="advanced-circuit", amount=5},
			{type="item", name="processing-unit", amount=5},
			{type="item", name="superconductor", amount=10}, -- new
			{type="item", name="efficiency-module-2", amount=5}, -- was 4
		}
	})
	meld(data.raw["technology"]["efficiency-module-3"], {
		prerequisites = common.meld_replace({"agricultural-science-pack"}, {"electromagnetic-science-pack"}),
		unit = {
			count = 300,
			ingredients = common.meld_replace({{"agricultural-science-pack", 1}}, {{"electromagnetic-science-pack", 1}}),
		}
	})
	
	if mods["quality"] then -- quality is an optional dependency of space-age
		meld(data.raw["recipe"]["quality-module-3"], {
			ingredients = meld.overwrite{
				{type="item", name="advanced-circuit", amount=5},
				{type="item", name="processing-unit", amount=5},
				{type="item", name="quantum-processor", amount=4}, -- new
				{type="item", name="quality-module-2", amount=5}, -- was 4
			}
		})
		
		meld(data.raw["technology"]["quality-module-3"], {
			prerequisites = common.meld_replace({"electromagnetic-science-pack"}, {"quantum-processor"}),
			unit = {
				count = 500, -- was 2000
				ingredients = common.meld_replace({{"electromagnetic-science-pack", 1}}, {{"cryogenic-science-pack", 1}}),
			}
		})
	end
end

return M
