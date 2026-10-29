local meld = require("__core__.lualib.meld")

local M = {}

function M.updates()
	-- Stolen from  Rocs-Improved-Platform-Drag  -  thesixthroc

	-- reference:
	-- https://wiki.factorio.com/Thruster (F thrust is not MN, but MN/60)
	-- https://www.desmos.com/calculator/eykhbatbn6

	--== Space Age 2.0.43 formula: ==--
	-- data.raw["utility-constants"]["default"]["space_platform_acceleration_expression"] =
	-- "(thrust / (1 + weight / 10000000) - ((1500 * speed * speed + 1500 * abs(speed)) * (width * 0.5) + 10000) * sign(speed)) / weight / 60"

	--== New formula: ==--

	local weight_of_platform_foundation_tiles = 200
	local shape_constant = 1.27324 -- 4/pi. This value means that circular platforms are unaffected. A shape_constant of 1 would mean square platforms are unaffected.
	local mass_scale = 6 -- pretend mass is higher -> slower accel, but same top speed
	-- increase top speed
	local drag_scale = 0.5
	local base_drag = 40000

	-- The logic here seems to be that drag is not linear to mass,
	-- but instead we take the mass (=number of tiles) and pretend the platform is circular
	-- and get the drag of that circle's width (?)
	-- This could simply be made linear with mass, I don't know why drag has to depend on width or fictional width at all
	-- currently doubling the mass of a ship and doubling the thrusters actually makes it go faster
	-- but if doubling width and height, and thus likely doubling thrusters, this formula retains the speed, not sure which is better
	local replacement_for_width = "(weight / " .. weight_of_platform_foundation_tiles .. ") ^ 0.5 * " .. (shape_constant * drag_scale)

	local breaking_fac = 4 -- 400% extra decell at 0 thrust, 0% at cutoff
	local breaking_cutoff = 20 -- [thrust in MN/60]  25 = 1.5GN, one thruster has 6.1GN
	local breaking_expr = "(max("..breaking_fac.."*(1-thrust/"..breaking_cutoff.."), 0) + 1)"

	-- TODO: I like slow accel, but deccel is so slow that stopping in response to asteroid damage is barely even viable
	-- using thrusters to slow down is sadly not a thing
	-- I could try adjusting the function, It's likely possible to add a arbitrary drag force whenever thrust is 0, if min() is a thing

	-- could multiply drag expression by (max(k*(1-thrust/cutoff), 0) + 1)
	-- multiplies deccel by k at 0 thrust, ramping down to 1 at cutoff thrust

	data.raw["utility-constants"]["default"]["space_platform_acceleration_expression"] =
		"(thrust / (1 + weight * "..mass_scale.." / 10000000) - ((1500 * speed * speed + 1500 * abs(speed)) * ("
		.. replacement_for_width .." * ".. breaking_expr
		.. " * 0.5) + "..base_drag..") * sign(speed)) / (weight * "..mass_scale..") / 60"

	-- even medium asteroids instantly nuke ship now, if I understand correctly a medium asteroid can punch through 64 tiles, and does not slow down?
	for _,a in pairs(data.raw["asteroid"]) do
		a.damage_per_hp = a.damage_per_hp * 0.25 -- if this feels right, probably do 1,2,3,4 damage for small,medium,big,huge (other than promethium)
	end

	--== Planet distances
	-- TODO: This may really mess with biter egg transport, what do?
	local dist_mult = 3
	local dist_mult2 = 2.5
	local dist_mult3 = 2

	data.raw["space-connection"]["nauvis-vulcanus"].length = math.floor(
		data.raw["space-connection"]["nauvis-vulcanus"].length * dist_mult)
	data.raw["space-connection"]["nauvis-gleba"].length = math.floor(
		data.raw["space-connection"]["nauvis-gleba"].length * dist_mult)
	data.raw["space-connection"]["nauvis-fulgora"].length = math.floor(
		data.raw["space-connection"]["nauvis-fulgora"].length * dist_mult)
	data.raw["space-connection"]["vulcanus-gleba"].length = math.floor(
		data.raw["space-connection"]["vulcanus-gleba"].length * dist_mult)
	data.raw["space-connection"]["gleba-fulgora"].length = math.floor(
		data.raw["space-connection"]["gleba-fulgora"].length * dist_mult)

	data.raw["space-connection"]["gleba-aquilo"].length = math.floor(
		data.raw["space-connection"]["gleba-aquilo"].length * dist_mult2)
	data.raw["space-connection"]["fulgora-aquilo"].length = math.floor(
		data.raw["space-connection"]["fulgora-aquilo"].length * dist_mult2)

	data.raw["space-connection"]["aquilo-solar-system-edge"].length = math.floor(
		data.raw["space-connection"]["aquilo-solar-system-edge"].length * dist_mult3)
	
	-- what determines thrust? fuel value of fluids?
	-- (effectivity of at min/max_performance seemingly is meant to go up to 100%)
	meld(data.raw["thruster"]["thruster"], {
		min_performance = { fluid_volume = 0.05, fluid_usage = 6/60, effectivity=1 }, -- fluid_usage was .1 (6/s)
		max_performance = { fluid_volume = 0.9, fluid_usage = 250/60, effectivity=0.55 }, -- fluid_usage was 2 (120/s)
	})
end
return M