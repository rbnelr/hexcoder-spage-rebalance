mod_name = "hexcoder-spage-rebalance-"

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

--[[
local min, max
local last_count
local last_spawn_tick

-- testing, might conflict with fulgora_defense_drones!
script.on_event(defines.events.on_tick, function(event)
	local platform
	for id,p in pairs(game.forces.player.platforms) do
		if p.name == "[planet=nauvis] Station [item=space-science-pack]" then
			platform = p
			break
		end
	end
	
	if platform then
		local chunks = platform.find_asteroid_chunks_filtered{}
		local count = #chunks
		
		if min == nil then min = 99999999 end
		if max == nil then max = -99999999 end
		
		if last_spawn_tick == nil then
			last_spawn_tick = 0
			last_count = 0
		end
		
		min = count < min and count or min
		max = count > max and count or max
		local delta = count - last_count
		last_count = count
		if delta > 0 then
			local elapsed = game.tick - last_spawn_tick
			last_spawn_tick = game.tick
			
			game.print("chunks on ".. platform.name ..": ".. serpent.line{
				count=count, min=min, max=max, delta=delta, elapsed=elapsed
			})
			log(count..", "..delta..", "..elapsed)
		end
	end
end)

commands.add_command("delete-chunks", nil, function(command)
	local platform
	for id,p in pairs(game.forces.player.platforms) do
		if p.name == "[planet=nauvis] Station [item=space-science-pack]" then
			platform = p
			break
		end
	end
	if platform then
		platform.destroy_asteroid_chunks{}
	end
end)
]]
