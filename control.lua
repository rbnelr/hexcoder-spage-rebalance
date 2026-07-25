mod_name = "hexcoder-spage-rebalance-"

--require("script/fulgora_defense_drones").control()

-- Trigger pollution on rocket launch
-- TODO: reduce this with rocket part efficiency research?
-- Stolen from  dirty-launches  -  Blooha77
script.on_event(defines.events.on_rocket_launched, function(event)
	--game.print("on_rocket_launched: "..serpent.block{event})
	local silo = event.rocket_silo
	if silo and silo.valid
	   and silo.surface.pollutant_type
	   and silo.surface.pollutant_type.name == "pollution" then
		local pollution = settings.global[mod_name.."rocket-launch-pollution-amount"].value
		silo.surface.pollute(silo.position, pollution, silo.prototype)
	end
end)
