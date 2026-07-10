
-- Stolen from  Rocs-Improved-Platform-Drag  -  thesixthroc

--== Space Age 2.0.43 formula: ==--
-- data.raw["utility-constants"]["default"]["space_platform_acceleration_expression"] =
-- "(thrust / (1 + weight / 10000000) - ((1500 * speed * speed + 1500 * abs(speed)) * (width * 0.5) + 10000) * sign(speed)) / weight / 60"

--== New formula: ==--

local weight_of_platform_foundation_tiles = 200
local shape_constant = 1.27324 -- 4/pi. This value means that circular platforms are unaffected. A shape_constant of 1 would mean square platforms are unaffected.
local mass_scale = 5 -- pretend mass is higher -> slower accel, but same top speed
-- increase top speed
local drag_scale = 0.75

local replacement_for_width = "(weight / " .. weight_of_platform_foundation_tiles .. ") ^ 0.5 * " .. (shape_constant * drag_scale)

data.raw["utility-constants"]["default"]["space_platform_acceleration_expression"] =
	"(thrust / (1 + weight * "..mass_scale.." / 10000000) - ((1500 * speed * speed + 1500 * abs(speed)) * ("
	.. replacement_for_width
	.. " * 0.5) + 10000) * sign(speed)) / (weight * "..mass_scale..") / 60"

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
