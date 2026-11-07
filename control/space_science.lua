-- Satellite launch: a satellite thrown off the platform becomes an asteroid drawn as a sprite, following the ejected item until shortly before that fades out,
-- then it turns, fires a thruster and accelerates away. It either crashes into the platform or fades out and departs
-- Standalone: runtime half of prototypes/space_science.lua
local const = require("const")

local M = {}

---@class EjectedSat
---@field e LuaEntity
---@field platform LuaSpacePlatform
---@field flame LuaRenderObject? set once the thruster fired
---@field ejection_position MapPosition
---@field ejection_velocity Vector
---@field ejection_tick MapTick
---@field thrust_tick MapTick
---@field orientation RealOrientation of the sprite now, the front points SPRITE_FRONT further
---@field target_orientation RealOrientation of the sprite in the end
---@field angular_velocity number rotations/tick, starts as a random drift
---@field rendering LuaRenderObject
---@field glow LuaRenderObject? the beacon, separate so it can be additive
---@field ignition LuaRenderObject? set once the thruster fired
---@field vx number? tiles/tick, set once the thruster fired
---@field vy number?

-- Reading ejected_items for every platform is the expensive part, so launches are detected less often than satellites get updated
-- launch() places a late satellite where the item is by now
M.LAUNCH_POLL_TICKS = 15
local UPDATE_TICKS = 2 -- on_tick
local THRUST_UPDATE_TICKS = 12 -- the engine moves it smoothly between these, the small speed steps do not show
local SATELLITE_ITEM = "satellite"

-- orientation the dish points to in the graphics, this is the front of the satellite
local SPRITE_FRONT = 0.36
local GLOW_BLINK_TICKS = 30 -- beacon on and off time, same as game alerts
local FINAL_ROT_VARIATION = 35/360 -- rotations, +- front from the throw direction after the turn
local INITIAL_ROT_VARIATION = 5/360 -- rotations, +- at launch
local MAX_DRIFT = 4/360/60 -- rotations/tick, slow random rotation until the turn starts
local TURN_LEAD_TICKS = 0 -- starts turning this long before the thruster fires
local THRUST_LEAD_TICKS = 100 -- starts thrusting before item actually fades (it's already barely visible)
local TURN_MAX_SPEED = 360/360/60 -- rotations/tick
local TURN_ACCEL = 14/360/3600 -- rotations/tick^2, 1 s to reach the max speed
local TURN_BRAKE_MARGIN = 0.9
local THRUST_ACCEL = 0.00025 -- tiles/tick^2
local FLAME_OFFSET = 1.4 -- tiles behind the center
local FLAME_SCALE = 0.7
local FLAME_ANIMATION_SPEED = 0.5 -- frames/tick, same as vanilla
local FLAME_FRAMES = 10
local IGNITION_TICKS = FLAME_FRAMES / FLAME_ANIMATION_SPEED

-- Fade: asteroids get removed asteroid_spawning_offset tiles beyond the platform (measured 72 above the top tile), and asteroid_fading_range = 16 suggests fading over the last 16
-- The platform bounds can't be read, so this measures from the launch position, which is only right when launching from the outermost edge
-- From further in the sprite fades early and the asteroid gets removed by us, counting as departed
local DESPAWN_DISTANCE_UP = 72
local DESPAWN_DISTANCE_OTHER = 48
local FADE_RANGE = 16

-- prints when a satellite crashes or departs
local DEBUG = true

-- factorio libs don't have this?
---@param vec Vector
---@return Vector
---@return number
local function normalized_vector(vec)
	local x = vec.x or vec[1]
	local y = vec.y or vec[2]
	local length = math.sqrt(x*x + y*y)
	if length == 0 then return { x=0, y=-1 }, 0 end
	return { x=x/length, y=y/length }, length
end

-- Direction the front points in
---@param sat EjectedSat
---@return number x
---@return number y
local function front_direction(sat)
	local angle = (sat.orientation + SPRITE_FRONT) * 2*math.pi
	return math.sin(angle), -math.cos(angle)
end

-- Keep a flame behind the satellite, destroyed along with the entity
local function place_flame(flame, sat)
	local x, y = front_direction(sat)
	flame.target = { entity=sat.e, offset={ -x * FLAME_OFFSET, -y * FLAME_OFFSET } }
	flame.orientation = (sat.orientation + SPRITE_FRONT) % 1
end

---@param sat EjectedSat
local function fire_thruster(sat, tick)
	sat.vx = sat.ejection_velocity[1]
	sat.vy = sat.ejection_velocity[2]

	local function draw(animation)
		local flame = rendering.draw_animation{
			animation = animation,
			animation_speed = FLAME_ANIMATION_SPEED,
			-- animations run off the game tick, this makes it start at frame 0 now
			animation_offset = -(tick * FLAME_ANIMATION_SPEED) % FLAME_FRAMES,
			surface = sat.e.surface,
			target = sat.e,
			x_scale = FLAME_SCALE,
			y_scale = FLAME_SCALE,
			render_layer = "object-under",
		}
		place_flame(flame, sat)
		return flame
	end

	sat.ignition = draw(const.SATELLITE_THRUSTER_IGNITION)
	sat.ignition.time_to_live = IGNITION_TICKS
	sat.flame = draw(const.SATELLITE_THRUSTER)
	sat.flame.visible = false

	sat.e.surface.play_sound{ path=const.SATELLITE_THRUSTER_SOUND, position=sat.e.position }
end

-- Drift slowly, then turn the shortest way with limited acceleration, starting a bit before the thruster fires
-- Speeds up, slows down in time to stop on target without overshooting. Starts from the drift, so one drifting the wrong way has to stop first
---@param sat EjectedSat
local function update_turn(sat, tick)
	local dt = UPDATE_TICKS
	if tick < sat.thrust_tick - TURN_LEAD_TICKS then
		sat.orientation = sat.orientation + sat.angular_velocity * dt
		sat.rendering.orientation = sat.orientation % 1
		if sat.glow then sat.glow.orientation = sat.orientation % 1 end
		return
	end
	if sat.orientation == sat.target_orientation then return end

	local remaining = (sat.target_orientation - sat.orientation + 0.5) % 1 - 0.5
	local max_dv = TURN_ACCEL * dt
	if math.abs(remaining) <= max_dv * dt and math.abs(sat.angular_velocity) <= max_dv then
		sat.orientation = sat.target_orientation
		sat.angular_velocity = 0
	else
		-- fastest speed from which it can still stop in time (v^2 = 2*a*d), with some margin since this runs in steps
		local stopping_speed = math.sqrt(2 * TURN_ACCEL * TURN_BRAKE_MARGIN * math.abs(remaining))
		local wanted = (remaining > 0 and 1 or -1) * math.min(stopping_speed, TURN_MAX_SPEED)
		local dv = wanted - sat.angular_velocity
		sat.angular_velocity = sat.angular_velocity + math.max(math.min(dv, max_dv), -max_dv)
		sat.orientation = sat.orientation + sat.angular_velocity * dt
	end

	sat.rendering.orientation = sat.orientation % 1
	if sat.glow then sat.glow.orientation = sat.orientation % 1 end
	if sat.flame then
		place_flame(sat.flame, sat)
		if sat.ignition.valid then place_flame(sat.ignition, sat) end
	end
end

-- Fade out towards where the asteroid would get removed
---@return boolean finished
local function update_fade(sat)
	local position = sat.e.position
	local remaining
	if math.abs(sat.ejection_velocity[1]) > math.abs(sat.ejection_velocity[2]) then
		remaining = DESPAWN_DISTANCE_OTHER - math.abs(position.x - sat.ejection_position.x)
	elseif sat.ejection_velocity[2] < 0 then
		remaining = DESPAWN_DISTANCE_UP - (sat.ejection_position.y - position.y)
	else
		remaining = DESPAWN_DISTANCE_OTHER - (position.y - sat.ejection_position.y)
	end

	local alpha = math.max(math.min(remaining / FADE_RANGE, 1), 0)
	if alpha < 1 then
		local color = { alpha, alpha, alpha, alpha } -- premultiplied
		sat.rendering.color = color
		if sat.glow then sat.glow.color = color end
		if sat.flame then sat.flame.color = color end
	end
	return alpha == 0
end

-- TODO: stubs for what happens next

-- Hit a wall (or got shot)
---@param sat EjectedSat
---@param position MapPosition
local function on_satellite_crashed(sat, position)
	--if DEBUG then game.print("satellite crashed at "..serpent.line(position)) end
end

-- Left the platform: faded out, or removed by the game
---@param sat EjectedSat
local function on_satellite_departed(sat)
	if not (sat.platform and sat.platform.valid) then return end
	--if DEBUG then game.print("satellite departed from "..sat.platform.name) end
end

local function update_satellite(sat, tick)
	local elasped = tick - sat.ejection_tick

	update_turn(sat, tick)

	if tick >= sat.thrust_tick then
		if not sat.flame then
			fire_thruster(sat, tick)
		end
		sat.flame.visible = tick >= sat.thrust_tick + IGNITION_TICKS
		if update_fade(sat) then
			sat.e.destroy() -- next update counts it as departed
			return
		end
		if (tick - sat.thrust_tick) % THRUST_UPDATE_TICKS == 0 then
			-- thrust along wherever it points right now, it may still be turning
			local thrust_x, thrust_y = front_direction(sat)
			sat.vx = sat.vx + thrust_x * THRUST_ACCEL * THRUST_UPDATE_TICKS
			sat.vy = sat.vy + thrust_y * THRUST_ACCEL * THRUST_UPDATE_TICKS
			-- no teleport: fast enough that truncating the movement doesn't matter, and the path no longer has to match anything
			local dir, speed = normalized_vector{ x=sat.vx, y=sat.vy }
			sat.e.set_movement(dir, speed)
		end
		return
	end

	--local actual = sat.e.position

	local target_x = sat.ejection_position.x + sat.ejection_velocity[1] * elasped
	local target_y = sat.ejection_position.y + sat.ejection_velocity[2] * elasped
	
	--local next_t = elasped + UPDATE_TICKS
	--local next_target_x = sat.ejection_position.x + sat.ejection_velocity[1] * next_t
	--local next_target_y = sat.ejection_position.y + sat.ejection_velocity[2] * next_t
--
	--local offset_x = target_x - actual.x
	--local offset_y = target_y - actual.y
	--
	--local movement_x = next_target_x - actual.x
	--local movement_y = next_target_y - actual.y
	--
	--local abs_err = math.max(math.abs(offset_x), math.abs(offset_y))
	--if abs_err > FIXEDPOINT_STEP then
	--	sat.e.teleport{x=target_x,y=target_y}
	--end
	
	sat.e.teleport{x=target_x,y=target_y}

	--local dir, speed = normalized_vector{
	--	x = movement_x / UPDATE_TICKS,
	--	y = movement_y / UPDATE_TICKS,
	--}
	--sat.e.set_movement(dir, speed)
	
end

local function launch(platform, ejected, tick)
	local entity = platform.surface.create_entity{type="asteroid", name=const.LAUNCHED_SAT, position=ejected.position}
	if not entity then return end
	
	-- sum of 2 randoms: more likely near 0, full range is rare
	local initial_tilt = ((math.random() + math.random()) - 1) * INITIAL_ROT_VARIATION - 0.25 -- front forward right, not backwards right
	local target_tilt = (math.random() * 2 - 1) * FINAL_ROT_VARIATION - SPRITE_FRONT
	local throw_orientation = math.atan2(ejected.movement[1], -ejected.movement[2]) / (2*math.pi)

	storage.ejected_satellites = storage.ejected_satellites or {}
	local sat = {
		e = entity,
		platform = platform,
		ejection_position = ejected.position,
		ejection_velocity = ejected.movement,
		ejection_tick = ejected.creation_tick,
		thrust_tick = ejected.expiration_tick - THRUST_LEAD_TICKS,
		orientation = throw_orientation + initial_tilt, -- diagonal like on a belt, relative to the throw direction
		target_orientation = throw_orientation + target_tilt, -- front away from the inserter
		angular_velocity = (math.random() * 2 - 1) * MAX_DRIFT,
		rendering = rendering.draw_sprite{
			sprite = const.SATELLITE_SPRITE,
			surface = platform.surface,
			target = entity,
			orientation = (throw_orientation + initial_tilt) % 1,
			render_layer = "object",
		},
	}
	storage.ejected_satellites[entity.unit_number] = sat
	
	local dir, speed = normalized_vector(ejected.movement)
	entity.set_movement(dir, speed)

	update_satellite(sat, tick)
end

function M.on_launch_poll(event)
	local tick = event.tick
	for _,force in pairs(game.forces) do
		for _,platform in pairs(force.platforms) do
			for _,ejected in pairs(platform.ejected_items) do
				-- Stateless window: entries created since the last poll, excluding the current tick, so a same-tick ejection is seen next poll
				if ejected.item.name.name == SATELLITE_ITEM and ejected.creation_tick >= tick - M.LAUNCH_POLL_TICKS and ejected.creation_tick < tick then
					launch(platform, ejected, tick)
				end
			end
		end
	end
end

function M.on_tick(event)
	local satellites = storage.ejected_satellites
	if not satellites or next(satellites) == nil then return end
	
	local tick = event.tick
	for uid,sat in pairs(satellites) do
		if sat.e.valid then
			update_satellite(sat, tick)
		else -- not removed by on_entity_died, so it wasn't a crash
			satellites[uid] = nil
			on_satellite_departed(sat)
		end
	end
end

function M.on_entity_died(event)
	local entity = event.entity
	local satellites = storage.ejected_satellites
	local sat = satellites and satellites[entity.unit_number]
	if sat then
		satellites[entity.unit_number] = nil
		on_satellite_crashed(sat, entity.position)
	end
end

-- Test looks placed in the editor: only draw them, they stay wherever they were placed
M.BUILT_FILTER = {}
for _,variant in pairs(const.SATELLITE_VARIANTS) do
	table.insert(M.BUILT_FILTER, {filter="name", name=const.LAUNCHED_SAT.."-"..variant})
end

function M.on_built_entity(event)
	local entity = event.entity
	local variant = entity.name:sub(#const.LAUNCHED_SAT + 2)
	rendering.draw_sprite{
		sprite = const.SATELLITE_SPRITE.."-"..variant,
		surface = entity.surface,
		target = entity,
		render_layer = "object",
	}
	rendering.draw_sprite{
		sprite = const.SATELLITE_GLOW_SPRITE,
		blink_interval = GLOW_BLINK_TICKS,
		surface = entity.surface,
		target = entity,
		render_layer = "object",
	}
end

return M
