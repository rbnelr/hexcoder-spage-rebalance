-- Tech cost tweaks, infinite research nerfs, rocket-part-productivity split,
-- global tech cost multiplier by number of science packs (applies to all mods' techs, keep last)
local const = require("const")
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

---- Individual tech cost tweaks
local function tweaks()
	-- Tweaks to costs
	
	meld(data.raw["technology"]["production-science-pack"], {
		unit = { count = 250 } -- was 100
	})
	meld(data.raw["technology"]["utility-science-pack"], {
		unit = { count = 350,  -- was 100
		         ingredients = common.meld_add_or_assign{{"production-science-pack", 1}} }
	})
	
	meld(data.raw["technology"]["automation-3"], { -- randomly really expensive in space age?
		unit = { count = 200 } -- was 500
	})
	meld(data.raw["technology"]["effect-transmission"], { -- way too cheap for how much of a powerup beacons can be
		unit = { count = 280 } -- was 75
	})
	meld(data.raw["technology"]["elevated-rail"], {
		unit = { count = 160, -- was 100
		         ingredients = common.meld_add_or_assign{{"space-science-pack", 1}} }
	})
	meld(data.raw["technology"]["nuclear-fuel-reprocessing"], { -- 50 is a joke
		unit = { count = 220 } -- was 50
	})
	meld(data.raw["technology"]["battery-mk2-equipment"], {
		unit = { count = 350, -- was 100
		         ingredients = common.meld_add_or_assign{{"space-science-pack", 1}} }
	})
	meld(data.raw["technology"]["battery-mk3-equipment"], {
		unit = { count = 900 }, -- was 500
	})
	meld(data.raw["technology"]["personal-roboport-mk2-equipment"], {
		unit = { count = 850 }, -- was 750
	})
	
	meld(data.raw["technology"]["power-armor-mk2"], {
		unit = { count = 600, -- was 400
			     ingredients = common.meld_add_or_assign{{"space-science-pack", 1}} }
	})
	meld(data.raw["technology"]["fission-reactor-equipment"], {
		unit = { count = 800, -- was 200
		         ingredients = common.meld_add_or_assign{{"space-science-pack", 1}} }
	})
	
	for _,num in pairs({"1","2","3","4","5","6"}) do
		local tech = data.raw["technology"]["worker-robots-speed-"..num]
		tech.unit.count = tech.unit.count * 3
	end
	data.raw["technology"]["worker-robots-speed-7"].unit.count_formula = "2^(L-6)*3500" -- was 1000
	for _,num in pairs({"1","2","3"}) do
		local tech = data.raw["technology"]["worker-robots-storage-"..num]
		tech.unit.count = tech.unit.count * 3.5
	end
end

---- Mod compat
local function compat()
	if mods["CargoBayLimitResearch"] then
		meld(data.raw["technology"]["cargo-bay-limit-1"], {
			unit = { count = 700 } -- was 500
		})
		meld(data.raw["technology"]["cargo-bay-limit-2"], {
			unit = { count = 1200, -- was 1000
			         ingredients = common.meld_add_or_assign{{"production-science-pack", 1}} }
		})
		meld(data.raw["technology"]["cargo-bay-limit-3"], {
			unit = { count = 2000, -- was 2000
			         ingredients = common.meld_add_or_assign{{"production-science-pack", 1}, {"utility-science-pack", 1}} }
		})
	end
end

---- Infinite research
-- mining prod scales crazy
-- maybe add more levels with additional science packs and manually adjust counts (don't scale with number of packs?)

-- add space science cost to some researches?

-- nerf infinite resource processing productivity research, but keep mining prod
--TODO: analyze and nerf robot speed
local inf_bonuses = {
	["carbonic-asteroid-crushing"] = 0.05,
	["oxide-asteroid-crushing"] = 0.05,
	["metallic-asteroid-crushing"] = 0.05,
	["advanced-carbonic-asteroid-crushing"] = 0.05,
	["advanced-oxide-asteroid-crushing"] = 0.05,
	["advanced-metallic-asteroid-crushing"] = 0.05,
	["scrap-recycling"] = 0.05,
	["processing-unit"] = 0.05,
	["steel-plate"] = 0.05,
	["casting-steel"] = 0.05,
	["low-density-structure"] = 0.05,
	["casting-low-density-structure"] = 0.05,
	["plastic-bar"] = 0.05,
	["bioplastic"] = 0.05,
	["rocket-fuel"] = 0.05,
	["rocket-fuel-from-jelly"] = 0.05,
	["ammonia-rocket-fuel"] = 0.05,
	["rocket-part"] = 0.05,
	["rocket-control-unit"] = 0.05,

	-- all were 0.1, keep mining prod, scrap prod, and damage the same
}
local inf_scl = 4/3
local inf_costs = { -- all were "1.5^L*1000"
	-- 1.225^L scales less than 1.5^L, but with halved prod bonus, to get the same prod 1.225^2L=1.5^L almost exactly matches
	-- I still want it to scale more, so things like 300% prod are impossible, but not that much more
	-- at the same prod bonus (level 2L vs L) (1.33334^2L*2)/(1.5^L) is 10.9x at Lvl10, 60x at Lvl20, 327x at Lvl30
	["steel-plate-productivity"] = inf_scl.."^L*2000",
	["plastic-bar-productivity"] = inf_scl.."^L*2000",
	["rocket-fuel-productivity"] = inf_scl.."^L*2000",
	["low-density-structure-productivity"] = inf_scl.."^L*2000",
	["processing-unit-productivity"] = inf_scl.."^L*2000",
}

-- split infinite rocket-part-productivity into 1, 2 and 3 (infinite)
local function rocket_part_productivity()
	local NAUVIS_SCI_AND_SPACE = {
		{"automation-science-pack", 1},
		{"logistic-science-pack", 1},
		{"chemical-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1},
		{"space-science-pack", 1},
	}
	data:extend{
		meld(table.deepcopy(data.raw["technology"]["rocket-part-productivity"]), {
			name = "rocket-part-productivity-1",
			prerequisites = meld.overwrite{"production-science-pack", "utility-science-pack", "space-science-pack"},
			unit = meld.overwrite{ count = 1000, ingredients = NAUVIS_SCI_AND_SPACE, time = 60 },
			max_level = meld.delete(),
		}),
		meld(table.deepcopy(data.raw["technology"]["rocket-part-productivity"]), {
			name = "rocket-part-productivity-2",
			prerequisites = meld.overwrite{"rocket-part-productivity-1"},
			unit = meld.overwrite{ count = 3000, ingredients = NAUVIS_SCI_AND_SPACE, time = 60 },
			max_level = meld.delete(),
		}),
		meld(table.deepcopy(data.raw["technology"]["rocket-part-productivity"]), {
			name = "rocket-part-productivity-3",
			unit = meld.overwrite{
				count_formula = "1.5^(L-2)*3000", -- was 1.5^L*2000
				ingredients = {
					{"automation-science-pack", 1},
					{"logistic-science-pack", 1},
					{"chemical-science-pack", 1},
					{"production-science-pack", 1},
					{"utility-science-pack", 1},
					{"space-science-pack", 1},
					{"cryogenic-science-pack", 1},
				},
				time = 60
			},
			prerequisites = meld.overwrite{"rocket-part-productivity-2"} -- was cryogenic-science-pack
		}),
	}
	data.raw["technology"]["rocket-part-productivity"] = nil
	
	common.replace_tech_references("rocket-part-productivity", {"rocket-part-productivity-1"})
end

---- Global cost multiplier by number of science packs, also applies inf_bonuses and inf_costs
local function scale_costs()
	-- Stolen from  ScalingScienceCounts  -  TeabagNation
	local multipliers = {}
	for cost in string.gmatch(settings.startup[const.SETTING_SCALES].value, '([^,]+)') do
		table.insert(multipliers, tonumber(cost))
	end

	-- set all multipliers
	for name,v in pairs(data.raw["technology"]) do
		if v.unit ~= nil and v.unit.ingredients ~= nil then
			local bottles = #v.unit.ingredients
			local mult = multipliers[bottles <= #multipliers and bottles or #multipliers]
			
			if v.unit.count ~= nil then
				v.unit.count = math.max(1, v.unit.count * mult)
			elseif v.unit.count_formula ~= nil then
				local formula = v.unit.count_formula
				
				if inf_costs[name] then formula = inf_costs[name] end
				
				if formula:match("(^%s*%d+%.?%d*%s*$)") then
					formula = tostring(tonumber(formula) * mult)
				else
					local res
					-- C*<formula> -> C*mult*<formula>
					formula, res = formula:gsub("(%d+%.?%d*)(%s*%*)", function(num, rest)
						return num.."*"..tostring(mult)..rest
					end)
					if res == 0 then
						-- <formula>*C -> <formula>*C*mult
						formula, res = formula:gsub("(%*%s*)(%d+%.?%d*)", function(rest, num)
							return rest..num.."*"..tostring(mult)
						end)
					end
				end
				
				v.unit.count_formula = formula
			end
			
			for _,eff in pairs(v.effects or {}) do
				if eff.type == "change-recipe-productivity" then
					local bonus = inf_bonuses[eff.recipe]
					if bonus ~= nil and eff.change ~= nil then
						eff.change = bonus
					end
				end
			end
		end
	end
end

---- Robot speed
local function robot_speed()
	-- nerf robot move speed
	for i,v in pairs({
		[1] = 0.50, -- 35%	 35% -> 50%	 50%
		[2] = 0.45, -- 40%	 75% -> 45%	 95%
		[3] = 0.40, -- 45%	120% -> 40%	135%
		[4] = 0.40, -- 55%	175% -> 40%	175%
		[5] = 0.35, -- 65%	240% -> 35%	210%
		[6] = 0.35, -- 65%	305% -> 35%	245%
		[7] = 0.30, -- 65%	370% -> 30%	275%
		-- inf 8       65%	435% -> 30%	305%
		-- inf 9       65%	500% -> 30%	335%
		-- inf 10      65%	565% -> 30%	365%
	}) do
		local tech = data.raw["technology"]["worker-robots-speed-"..i]
		tech.effects[1].modifier = v
	end
end

function M.final()
	tweaks()
	compat()
	rocket_part_productivity()
	scale_costs()
	robot_speed()
end

return M
