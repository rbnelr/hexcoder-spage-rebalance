
local M = {}

local DRONE_FORCE = "enemy-fulgoran-drones"
local IS_DRONE = {
	["defender"] = true,
	["distractor"] = true,
	["destroyer"] = true,
	["laser-turret"] = true, -- testing
}
local TARGETS = {
	"mining-drill",
	"assembling-machine", "furnace",
	"radar",
	--"roboport" -- dont want to be disabled, but can't be anyway?
	--"lab",
	"pump", 
	--"lamp", "arithmetic-combinator", "decider-combinator", "selector-combinator",
}
local VAULT_DEFENSE_RADIUS = 50
local MAX_POLL = 8 -- rotate through list of damaged buildings, checking MAX_POLL per tick

function M.data()
	
end

function M.updates()
	for _,type in pairs(TARGETS) do
		for _,e in pairs(data.raw[type]) do
			e.allow_run_time_change_of_is_military_target = true
		end
	end
end

function M.control()
	-- set allow_run_time_change_of_is_military_target on miners etc.
	-- on_entity_damaged has powerful filter conditions, and can cancel entity dying (?)
	-- -> disable buildings via disabled_by_script, change is_military_target so it stops being attacked
	
	local function building_fully_damaged(e, force)
		--e.destructible = false
		e.is_military_target = false
		e.disabled_by_script = true
		e.custom_status = {
			diode=defines.entity_status_diode.red,
			label="damaged by drones"
		}
		
		force.set_friend("player", true)
		
		local store = storage or {}
		storage = store
		local poll = store.poll_repaired or {}
		store.poll_repaired = poll
		
		store.friend_end_tick = game.tick + 2
		
		local data = poll[e.unit_number]
		if not data then
			local status_icon = rendering.draw_sprite{
				sprite = "virtual-signal/signal-explosion",
				tint = {1.0,0.85,0,1.0},
				x_scale = 1.7, y_scale = 1.7,
				render_layer = "entity-info-icon-above",
				blink_interval = 30,
				target = e,
				surface = e.surface,
				render_mode = "game",
				only_in_alt_mode = true,
			}
			
			poll[e.unit_number] = { entity = e, icon = status_icon } -- safe to use as key, but dont compare LuaX
		end
	end
	local function building_partially_repaired(data)
		local e = data.entity
		--e.destructible = true
		e.is_military_target = true
	end
	local function building_restored(id, data, is_military_target)
		local e = data.entity
		if e.valid then
			--e.destructible = true
			e.is_military_target = is_military_target or false
			e.disabled_by_script = false
			if e.custom_status.label == "damaged by drones" then
				e.custom_status = nil
			end
		end
		if data.icon then
			data.icon.destroy()
		end
		
		storage.poll_repaired[id] = nil
	end
	
	local function make_close_entities_military_targets(surface, position)
		for _,e in pairs(surface.find_entities_filtered{position=position, radius=VAULT_DEFENSE_RADIUS,
			type = TARGETS
			--is_military_target
		}) do
			--game.print(serpent.line(e))
			if not e.disabled_by_script then
				e.is_military_target = true
			end
		end
	end
	local function reset_close_entities_military_targets(surface, position)
		for _,e in pairs(surface.find_entities_filtered{
			position=position, radius=VAULT_DEFENSE_RADIUS, type = TARGETS
		}) do
			building_restored(e.unit_number, { entity=e }, false) -- make buildings safe again I guess
			e.health = e.max_health
		end
	end
	
	local function random_military_target(surface, position)
		local targets = surface.find_entities_filtered{position=position, radius=VAULT_DEFENSE_RADIUS,
			type = TARGETS
			--is_military_target
		}
		local count = #targets
		local idx = math.floor(math.random() * (count-0.001))
		return targets[idx]
	end
	
	-- -42.5, 31.9375
	local TEST_POS = {x=-42.5, y=31.9375}
	
	local function check_ore_depletion(surface, position)
		-- TODO: profile, if at all significant, split it into smaller chunks to rotate through
		local count = 0
		for _,ore_tile in pairs(surface.find_entities_filtered{
		  position=position, radius=VAULT_DEFENSE_RADIUS, type="resource", name="scrap"}) do
			count = count + ore_tile.amount
		end
		return count
	end
	
	local function spawn_drones(wave, surface, position, hub_entity, bot_type, count)
		for i = 1,count do
			local x = (math.random()-0.5) * 3
			local y = (math.random()-0.5) * 3
			
			local bot = surface.create_entity{
				name=bot_type,
				position={ position.x+x, position.y+y },
				force=DRONE_FORCE,
			}
			bot.combat_robot_owner = hub_entity
			
			table.insert(wave, bot)
		end
	end
	
	local function start_test_attack(surface, position)
		
		local hub = surface.find_entity("fulgoran-ruin-vault", position)
		-- lazily mark vulnerable buildings
		make_close_entities_military_targets(surface, position)
		
		local wave = storage.bot_wave or {}
		storage.bot_wave = wave
		spawn_drones(wave, surface, position, hub, "defender", 55)
		spawn_drones(wave, surface, position, hub, "distractor", 30)
		spawn_drones(wave, surface, position, hub, "destroyer", 20)
	end
	
	script.on_nth_tick(60*10, function(event)
		local surface = game.get_surface("fulgora")
		local position = TEST_POS
		local count = check_ore_depletion(surface, position)
		
		if storage.prev_attack_ore_amount == nil then
			storage.prev_attack_ore_amount = count
		end
		
		local diff = count - storage.prev_attack_ore_amount
		
		game.print("ore: ".. count .."  (".. (diff or "nil") ..") at ("..position.x..", "..position.y..")")
		
		if diff < -2000 then
			storage.prev_attack_ore_amount = count
			start_test_attack(surface, TEST_POS)
		end
	end)
	
	local _prev_ore = nil
	commands.add_command("fulg-ore", nil, function(command)
		local player = game.get_player(command.player_index)
		
		local surface = player.surface
		local selected = player.selected
		local position = selected and selected.position or player.position
		
		local count = check_ore_depletion(surface, position, VAULT_DEFENSE_RADIUS)
		
		local diff = _prev_ore and count - _prev_ore or nil
		_prev_ore = count
		game.print("ore: ".. count .."  (".. (diff or "nil") ..") at ("..position.x..", "..position.y..")")
	end)
	
	commands.add_command("fulg-spawn", nil, function(command)
		if game.forces[DRONE_FORCE] == nil then
			local ef = game.create_force(DRONE_FORCE)
			ef.custom_color = {1,0,1,1}
			ef.set_friend("player", false)
		end
		
		local commands = {}
		if command.parameter then
			for cmd in string.gmatch(command.parameter or "", "%w+") do
				table.insert(commands, cmd)
			end
		end
		local bot_type = commands and commands[1] or "defender"
		local count = commands and tonumber(commands[2]) or 5
	
		local player = game.get_player(command.player_index)
		
		local surface = player.surface
		local selected = player.selected
		
		local position = selected and selected.position or player.position
		
		-- lazily mark vulnerable buildings
		make_close_entities_military_targets(surface, position)
		
		for i = 1,count do
			local x = (math.random()-0.5) * 3
			local y = (math.random()-0.5) * 3
			
			local bot = surface.create_entity{
				name=bot_type,
				position={ position.x+x, position.y+y },
				--force="enemy",
				force=DRONE_FORCE,
				--target = { x=position.x+y, y=position.y-3 },
			}
			--bot.combat_robot_owner = player.character
			bot.combat_robot_owner = selected
		end
	end)
	
	local _bots = {}
	commands.add_command("fulg-spawn-2", nil, function(command)
		local commands = {}
		if command.parameter then
			for cmd in string.gmatch(command.parameter or "", "%w+") do
				table.insert(commands, cmd)
			end
		end
		local bot_type = commands and commands[1] or "defender"
		local count = commands and tonumber(commands[2]) or 5
	
		local player = game.get_player(command.player_index)
		
		local surface = player.surface
		local selected = player.selected
		
		local position = selected and selected.position or player.position
		
		local bots = {}
		for i = 1,count do
			local x = (math.random()-0.5) * 3
			local y = (math.random()-0.5) * 3
			
			local bot = surface.create_entity{
				name=bot_type,
				position={ position.x+x, position.y+y },
				force="player",
			}
			bot.combat_robot_owner = selected
			
			--bot.set_movement({-1,0}, 1)
			
			table.insert(bots, bot)
		end
		_bots = bots
	end)
	commands.add_command("fulg-reset", nil, function(command)
		local player = game.get_player(command.player_index)
		
		local selected = player.selected
		local position = selected and selected.position or player.position
		
		reset_close_entities_military_targets(player.surface, position)
		
		game.forces[DRONE_FORCE].set_friend("player", true)
		
		local store = storage or {}
		storage = store
		store.friend_end_tick = game.tick + 2
	end)
	
	script.on_event(defines.events.on_player_repaired_entity, function(event)
		--game.print("on_player_repaired_entity: ".. serpent.line(event))
	end)
	
	for _, event in ipairs({
		defines.events.on_built_entity,
		defines.events.on_robot_built_entity,
		defines.events.on_space_platform_built_entity,
		defines.events.script_raised_built,
		defines.events.script_raised_revive,
		defines.events.on_entity_cloned, -- source to destination
	}) do
		script.on_event(event, function(event)
			local e = event.entity or event.destination --[[@as LuaEntity]]
			e.is_military_target = false
			e.disabled_by_script = false
			e.custom_status = nil
		end, {
			{filter="type", type="mining-drill"},
			{filter="type", type="assembling-machine"},
			{filter="type", type="furnace"},
			{filter="type", type="radar"},
			{filter="type", type="pump"},
		})
	end
	local deathrattles = {} ---@type function(EventData.on_object_destroyed)[]
	deathrattles[defines.target_type.entity] = function(event)
		
	end
	script.on_event(defines.events.on_object_destroyed, function(event)
		local handler = deathrattles[event.type]
		if handler then handler(event) end
	end)
	
	script.on_event(defines.events.on_entity_damaged, function(event)
		--game.print("on_entity_damaged: ".. serpent.line(event))
		
		if event.force and event.force.name == DRONE_FORCE
		   --and event.cause and IS_DRONE[event.cause.name] -- don't really need this check
		then
			local e = event.entity
			building_fully_damaged(e, event.force)
			e.health = 1 -- hp was 0, but this cancels building being killed
			--e.health = math.max(1, e.max_health * 0.1) -- would be nice if individual thresholds in on_entity_damaged filter, since this may make hp bar jump
			--e.health = 0
		else -- likely player killed the building, need to reset state since the game seems to revive building with it
			if storage and storage.poll_repaired then
				local e = event.entity
				local id = e.valid and e.unit_number
				building_restored(id, storage.poll_repaired[id])
			end
		end
	end, {
		{filter="type", type="mining-drill"},
		{filter="final-health", value=0, comparison="<=", mode="and"},
		{filter="type", type="assembling-machine"},
		{filter="final-health", value=0, comparison="<=", mode="and"},
		{filter="type", type="furnace"},
		{filter="final-health", value=0, comparison="<=", mode="and"},
		{filter="type", type="radar"},
		{filter="final-health", value=0, comparison="<=", mode="and"},
		{filter="type", type="pump"},
		{filter="final-health", value=0, comparison="<=", mode="and"},
	})
	
	local function bot_movement(bots)
		local surface = game.get_surface("fulgora")
		local count = #bots
		local tick = game.tick
		for idx,bot in ipairs(bots) do
			-- move all at once (robotic hivemind feeling)
			-- or move staggered
			-- or move in random intervals (including switching target if target dies)
			-- maybe switch target to closest if it dies, but move to purely random otherwise?
			-- could also divide robots into clusters and stagger clusters, might look cool
			if bot.valid
				--and (tick % 300) == 0
				--and (tick % 300) == math.floor(idx / count * 300)
				and (tick % 300) == math.floor(math.floor(idx / 6) / count * 300)
			then
				local target = random_military_target(surface, TEST_POS)
				if target and target.valid then
					-- abuse this to make defenders and destroyers move to targets
					-- unfortunately this only appears to work if the force matches,
					--  so I'd have to spawn invisible enemy (simple?) entities where the buildings are
					bot.combat_robot_owner = target
				end
			else
				bots[idx] = nil -- safe?
			end
		end
		
		if #bots > 0 then
			return bots
		end
		return nil
	end
	
	script.on_event(defines.events.on_tick, function(event)
		--for _,e in pairs(_test[event.tick] or {}) do
		--	--e.teleport(-40, 0)
		--	--e.disabled_by_script = false
		--end
		if storage then
			if storage.friend_end_tick ~= nil and event.tick >= storage.friend_end_tick then
				game.forces[DRONE_FORCE].set_friend("player", false)
				storage.friend_end_tick = nil
			end
			
			local id = storage.poll_prev
			for i = 1,MAX_POLL do
				id, data = next(storage.poll_repaired or {}, id)
				if data == nil then break end
				if not data.entity.valid then
					--building_restored(data) -- cleanup in on_object_destroyed
				elseif data.entity.health >= data.entity.max_health*0.666666667 then -- 2/3 is where HP bar becomes green
					-- apparently deleting is safe with next() iteration, not sure if also if inserting inbetween
					-- but worst case next returns nil, which restarts iteration(?)
					building_restored(data.entity.unit_number, data, true) -- this has to be the actual LuaEntity, not a new one!
				elseif data.entity.health > 1 then
					building_partially_repaired(data)
				end
			end
			storage.poll_prev = id
		end
		
		if storage.bot_wave then
			storage.bot_wave = bot_movement(storage.bot_wave)
		end
		if _bots then
			_bots = bot_movement(_bots)
		end
	end)
	
	script.on_init(function()
		local force = game.create_force(DRONE_FORCE)
		force.custom_color = {1,0,1,1}
		
		storage = {
			prev_attack_ore_amount = nil,
			friend_end_tick = nil,
			bot_wave = nil,
			poll_repaired = {},
			poll_prev = nil
		}
	end)
end

return M