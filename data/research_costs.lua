local M = {}

function M.final_fixes()
	-- Tweaks to costs
	
	meld(data.raw["technology"]["production-science-pack"], {
		unit = { count = 250 } -- was 100
	})
	meld(data.raw["technology"]["utility-science-pack"], {
		unit = { count = 350,  -- was 100
		         ingredients = meld.append{{"production-science-pack", 1}} }
	})
	
	meld(data.raw["technology"]["automation-3"], { -- randomly really expensive in space age?
		unit = { count = 200 } -- was 500
	})
	meld(data.raw["technology"]["effect-transmission"], { -- way too cheap for how much of a powerup beacons can be
		unit = { count = 280 } -- was 75
	})
	meld(data.raw["technology"]["elevated-rail"], {
		unit = { count = 160, -- was 100
		         ingredients = meld.append({{"space-science-pack", 1}}) }
	})
	meld(data.raw["technology"]["nuclear-fuel-reprocessing"], { -- 50 is a joke
		unit = { count = 220 } -- was 50
	})
	meld(data.raw["technology"]["battery-mk2-equipment"], {
		unit = { count = 350, -- was 100
		         ingredients = meld.append({{"space-science-pack", 1}}) }
	})
	meld(data.raw["technology"]["battery-mk3-equipment"], {
		unit = { count = 900 }, -- was 500
	})
	meld(data.raw["technology"]["personal-roboport-mk2-equipment"], {
		unit = { count = 850 }, -- was 750
	})
	
	meld(data.raw["technology"]["power-armor-mk2"], {
		unit = { count = 600, -- was 400
			     ingredients = meld.append({{"space-science-pack", 1}}) }
	})
	meld(data.raw["technology"]["fission-reactor-equipment"], {
		unit = { count = 800, -- was 200
		         ingredients = meld.append({{"space-science-pack", 1}}) }
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
	
	-- mining prod scales crazy
	-- maybe add more levels with additional science packs and manually adjust counts (don't scale with number of packs?)
	
	-- add space science cost to some researches?
	
	-- Stolen from  ScalingScienceCounts  -  TeabagNation
	local multipliers = {}
	for cost in string.gmatch(settings.startup[mod_name.."scales"].value, '([^,]+)') do
		table.insert(multipliers, tonumber(cost))
	end
	
	-- nerf infinite resource processing productivity research, but keep mining prod
	local bonuses = {
		["carbonic-asteroid-crushing"] = 0.05,
		["oxide-asteroid-crushing"] = 0.05,
		["metallic-asteroid-crushing"] = 0.05,
		["advanced-carbonic-asteroid-crushing"] = 0.05,
		["advanced-oxide-asteroid-crushing"] = 0.05,
		["advanced-metallic-asteroid-crushing"] = 0.05,
		["processing-unit"] = 0.05,
		--"scrap-recycling"
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

		-- keep mining prod, scrap prod, and damage the same
	}
	
	-- set all multipliers
	for k,v in pairs(data.raw["technology"]) do
		if v.unit ~= nil and v.unit.ingredients ~= nil then
			local bottles = #v.unit.ingredients
			local mult = multipliers[bottles <= #multipliers and bottles or #multipliers]
			
			if v.unit.count ~= nil then
				v.unit.count = math.max(1, v.unit.count * mult)
			elseif v.unit.count_formula ~= nil then
				local formula = v.unit.count_formula
				
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
					local bonus = bonuses[eff.recipe]
					if bonus ~= nil and eff.change ~= nil then
						eff.change = bonus
					end
				end
			end
		end
	end
end

return M