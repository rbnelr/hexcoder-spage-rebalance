local const = require("const")
local space_science = require("control/space_science")

---@type ModStorage
storage = storage

---@class ModStorage
---@field ejected_satellites table<integer, EjectedSat>

-- Trigger pollution on rocket launch
-- TODO: reduce this with rocket part efficiency research?
-- Stolen from  dirty-launches  -  Blooha77
script.on_event(defines.events.on_rocket_launched, function(event)
	--game.print("on_rocket_launched: "..serpent.block{event})
	local silo = event.rocket_silo
	if silo and silo.valid
	   and silo.surface.pollutant_type
	   and silo.surface.pollutant_type.name == "pollution" then
		local pollution = settings.global[const.SETTING_LAUNCH_POLLUTION].value
		silo.surface.pollute(silo.position, pollution, silo.prototype)
	end
end)

-- only works if tile.empty-space.destroys_dropped_items = true
--script.on_event(const.MOD_NAME.."-on-satellite-launch", function(event)
--	game.print("on-satellite-launch: ".. serpent.block(event))
--end)

-- Satellite launch
script.on_nth_tick(space_science.LAUNCH_POLL_TICKS, space_science.on_launch_poll)
script.on_event(defines.events.on_tick, space_science.on_tick)
script.on_event(defines.events.on_entity_died, space_science.on_entity_died, {{filter="name", name=const.LAUNCHED_SAT}})
script.on_event(defines.events.on_built_entity, space_science.on_built_entity, space_science.BUILT_FILTER)
