local const = require("const")

---@type ModStorage
storage = storage

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

local timeout = nil

-- factorio libs don't have this?
---@param vec Vector
---@return Vector
---@return number
local function normalized_vector(vec)
	local x = vec.x or vec[1]
	local y = vec.y or vec[2]
	local length = math.sqrt(x*x + y*y)
	return { x=x/length, y=y/length }, length
end

script.on_nth_tick(10, function(event)
	for _,platform in pairs(game.planets["nauvis"].get_space_platforms("player")) do
		for _,ejected in pairs(platform.ejected_items) do
			if ejected.item.name.name == "satellite" and timeout == nil then
				game.print("")
				local asteroid = platform.surface.create_entity{type="asteroid", name=const.LAUNCHED_SAT, position=ejected.position}
				
				local dir, speed = normalized_vector(ejected.movement)
				asteroid.set_movement(dir, speed)
				
				timeout = 120
			end
		end
	end
	if timeout ~= nil then
		timeout = timeout - 10
		if timeout <= 0 then timeout = nil end
	end
end)

---@class ModStorage
-----@field ejected_satellites table<>

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
