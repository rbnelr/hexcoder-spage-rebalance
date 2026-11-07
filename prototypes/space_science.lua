-- Satellite, film capsule and new space science pack recipe, ice-melting unlocked by space science
-- Standalone: only references vanilla prototypes, could become its own mod (together with control/space_science.lua)
local const = require("const")
local meld = require("__core__.lualib.meld")
local common = require("prototypes.common")
require("__core__.lualib.sound-util") -- sound_variations

local M = {}

---- Satellite
local function satellite()
	-- Stolen from  Better Space Science  -  Cubickman

	local item_sounds = require("__base__.prototypes.item_sounds")

	-- make sending up ingredients cheaper/competitive with sending up solar panels
	-- TODO: check numbers
	-- actually now sending up circuits makes no sense
	--meld(data.raw["item"]["solar-panel"], {
	--	weight = 8000, -- 125 / rocket, was 20000 (50 / rocket)
	--})
	-- make radar heavier to encourage orbital production
	meld(data.raw["item"]["radar"], {
		weight = 40000, -- 25 / rocket, was 20000 (50 / rocket)
	})
	-- chosen numbers such that making more and more parts in orbit gets cheaper and cheaper in terms of rocket launches
	-- except green circuits, which are not worth to ship copper for, instead wait until advanced metallic crushing
	
	-- would be needed for destroyed_by_dropping_trigger
	--meld(data.raw["tile"]["empty-space"], {
	--	destroys_dropped_items = true,
	--})
	
	data:extend{
		--{
		--	type = "custom-event",
		--	name = const.MOD_NAME.."-on-satellite-launch"
		--},
		{
			type = "item",
			name = "satellite",
			icons = {{
				icon=const.MOD_DIR.."/graphics/icons/satellite.png",
				scale = 0.5*1.25, -- was 0.5, make it larger on belt
			}},
			subgroup = "intermediate-product",
			order = "d[rocket-parts]-eb[satellite]",
			stack_size = 1,
			weight = 333 * kg, -- 3 / rocket, shipping parts is cheaper
			inventory_move_sound = item_sounds.electric_small_inventory_move,
			pick_sound = item_sounds.electric_small_inventory_pickup,
			drop_sound = item_sounds.electric_small_inventory_move,
			--destroyed_by_dropping_trigger = {
			--	type="direct",
			--	action_delivery = {
			--		type="instant",
			--		target_effects={
			--			type="script",
			--			effect_id="satellite-launch",
			--			custom_event=const.MOD_NAME.."-on-satellite-launch",
			--		}
			--	}
			--}
		},
		{
			type = "recipe",
			name = "satellite",
			icon=const.MOD_DIR.."/graphics/icons/satellite.png",
			subgroup = "intermediate-product",
			order = "d[rocket-parts]-eb[satellite]",
			enabled = false,
			energy_required = 32,
			allow_productivity = false,
			categories = { "advanced-crafting", --[["electromagnetics"]] },
			ingredients = {
				{type = "item", name = "steel-plate", amount = 2},
				{type = "item", name = "solar-panel", amount = 8},
				{type = "item", name = "radar", amount = 1},
				{type = "item", name = "rocket-fuel", amount = 1},
			},
			results = {{type = "item", name = "satellite", amount = 1}}
		},
	}
end

---- Launched satellite
-- Thrown satellites become this asteroid (see control/space_science.lua)
local function launched_satellite()
	local icon = const.MOD_DIR.."/graphics/icons/satellite.png"
	local sat_scale = const.SATELLITE_SCALE
	local shift = {0.35 * sat_scale, 0.04 * sat_scale} -- tiles, towards the solar panel, to cover the ejected item better
	-- smooth when zoomed out and rotating, no linear-magnification so it stays subtly pixelated when zoomed in
	local sprite_flags = {"mipmap", "linear-minification", "linear-mip-level"}

	local function satellite_asteroid()
		-- was asteroid explosion and chunks. A satellite is made of a radar and solar panels: radar explosion for the flash, metal and sound
		local crash_effects = {
			{type="create-explosion", entity_name="radar-explosion"},
			{ -- on top of the collision damage, which is the same as a small asteroid
				type = "nested-result",
				action = {
					type = "area",
					radius = 2.5,
					action_delivery = {
						type = "instant",
						target_effects = {{type="damage", damage={amount=60, type="explosion"}}},
					},
				},
			},
		}
		-- only the shards and glass of the solar panel explosion, its sound is the same as the radar's and would play twice
		for _,effect in pairs(data.raw["explosion"]["solar-panel-explosion"].created_effect.action_delivery.target_effects) do
			table.insert(crash_effects, table.deepcopy(effect))
		end

		return meld(table.deepcopy(data.raw["asteroid"]["small-metallic-asteroid"]), {
			name = const.LAUNCHED_SAT,
			localised_name = {"item-name.satellite"},
			dying_trigger_effect = meld.overwrite(crash_effects),
			resistances = {
				{type="physical", percent=0},
				{type="explosion", percent=50},
				{type="fire", percent=100},
				{type="laser", percent=20},
				{type="electric", percent=0}, -- change for flavor
			},
			is_military_target = false,

			icon = icon,
			graphics_set = meld.delete(),
			-- the normal radar sound, follows the asteroid
			working_sound = table.deepcopy(data.raw["radar"]["radar"].working_sound),
		})
	end
	local function thruster_animation(name, file)
		return {
			type = "animation",
			name = name,
			filename = "__base__/graphics/entity/cargo-pod/"..file..".png",
			width = 172,
			height = 256,
			line_length = 5,
			frame_count = 10,
			scale = 0.25,
			draw_as_glow = true,
			blend_mode = "additive",
			flags = {"linear-minification", "linear-magnification"},
		}
	end

	data:extend{
		-- no graphics: asteroids render at a random start rotation and entity.orientation has no effect, control/space_science.lua draws SATELLITE_SPRITE instead
		satellite_asteroid(),
		{
			type = "sprite",
			name = const.SATELLITE_SPRITE,
			filename = const.MOD_DIR.."/graphics/entity/satellite/satellite-colour.png",
			size = 128,
			scale = 0.5 * sat_scale, -- 2 tiles at 1
			shift = shift,
			flags = sprite_flags,
		},
		-- the beacon. Render objects have no normal maps, but sprites can be additive and glow
		{
			type = "sprite",
			name = const.SATELLITE_GLOW_SPRITE,
			filename = const.MOD_DIR.."/graphics/entity/satellite/satellite-glow.png",
			size = 128,
			scale = 0.5 * sat_scale, -- 2 tiles at 1
			shift = shift,
			flags = sprite_flags,
			blend_mode = "additive",
			draw_as_glow = true,
		},
		-- same as vanilla cargo pod thruster_flames_start and thruster_flames_loop (base/prototypes/entity/cargo-pod-catalogue.lua), without the shift
		-- animation_speed is set when drawing, draw_animation defaults to 1 per tick
		thruster_animation(const.SATELLITE_THRUSTER_IGNITION, "pod-thruster-ignition"),
		thruster_animation(const.SATELLITE_THRUSTER, "pod-thruster-loop"),
		-- same as vanilla pod_thruster_burst (base/prototypes/entity/entities.lua)
		{
			type = "sound",
			name = const.SATELLITE_THRUSTER_SOUND,
			variations = sound_variations("__base__/sound/procession/cargo-pod-thruster-burst", 5, 0.6),
			aggregation = {max_count = 2, remove = true, count_already_playing = true},
		},
	}
	
	-- we have to hide ejected item with satellite on top, so make this faster, likely nobody cares
	data.raw["utility-constants"]["default"].ejected_item_lifetime = 12 * 60 -- was 1500 (25sec)
	data.raw["utility-constants"]["default"].ejected_item_speed = 5 * 1/256 -- was 0.005
	data.raw["utility-constants"]["default"].ejected_item_direction_variation = 0.04 -- was 0.05
end

---- Film capsules
-- Planned: launching a satellite makes film capsules drift past the platform as asteroid chunks. Not spawned yet
-- Theme: Corona spy satellites dropped film canisters that aircraft caught in mid-air, here collector arms catch them
local function film_capsule()
	local item_sounds = require("__base__.prototypes.item_sounds")
	local dir = const.MOD_DIR.."/graphics/entity/capsule/film-capsule-"
	local icon = const.MOD_DIR.."/graphics/icons/film-capsule.png"
	local chunk_scale = 0.5 -- 64 px images, so 0.5 is 1 tile. Vanilla chunks are 50 px at 0.5
	local chunk_brightness = 1.1 -- near white like plastic, was 0.9 on metallic chunks

	local variations = {}
	for i=1,4 do
		local function map(kind, premul_alpha)
			return { filename=dir..kind.."-0"..i..".png", premul_alpha=premul_alpha, size=64, scale=chunk_scale }
		end
		variations[i] = {
			color_texture = map("colour"),
			normal_map = map("normal", false),
			roughness_map = map("roughness", false),
			shadow_shift = {0.25, 0.25},
		}
	end

	data:extend{
		-- mirrors metallic-asteroid-chunk, including its particles and explosion
		{
			type = "asteroid-chunk",
			name = const.FILM_CAPSULE,
			localised_name = {"asteroid-chunk-name.film-capsule"},
			localised_description = {"item-description.film-capsule"},
			icon = icon,
			subgroup = "space-material",
			order = "e[film-capsule]-a[chunk]",
			dying_trigger_effect = table.deepcopy(data.raw["asteroid-chunk"]["metallic-asteroid-chunk"].dying_trigger_effect),
			minable = {
				mining_time = 0.2,
				result = const.FILM_CAPSULE,
				mining_particle = data.raw["asteroid-chunk"]["metallic-asteroid-chunk"].minable.mining_particle,
			},
			graphics_set = meld(table.deepcopy(data.raw["asteroid-chunk"]["metallic-asteroid-chunk"].graphics_set), {
				variations = meld.overwrite(variations),
				brightness = chunk_brightness,
			}),
			rotation_speed = 0.005, -- was 0.0015
		},
		{
			type = "item",
			name = const.FILM_CAPSULE,
			localised_name = {"item-name.film-capsule"},
			localised_description = {"item-description.film-capsule"},
			icon = icon,
			-- red bands glow on belts, same setup as vanilla nuclear-fuel. Icons in the inventory and chunks can't glow
			pictures = {
				layers = {
					{filename = icon, size = 64, scale = 0.5, mipmap_count = 4},
					{filename = const.MOD_DIR.."/graphics/icons/film-capsule-glow.png", size = 64, scale = 0.5, blend_mode = "additive", draw_as_glow = true},
				},
			},
			subgroup = "space-material",
			order = "e[film-capsule]-b[item]",
			stack_size = 1,
			weight = 20 * kg,
			inventory_move_sound = item_sounds.electric_small_inventory_move,
			pick_sound = item_sounds.electric_small_inventory_pickup,
			drop_sound = item_sounds.electric_small_inventory_move,
		},
	}
end

---- Space science
local function science()
	-- Uses the satellite directly until film capsules exist
	-- TODO: redo, these numbers are for the earlier plan of 4 capsules per satellite and 3 packs per capsule (12 packs per satellite, all caught)
	-- cost per pack, Nauvis raw cost (see nauvis.lua) + asteroid chunks on the platform, early / data_updates (foundry/EM, prod 3):
	--   1 launch satellites (333 kg, 27.8 rockets per 1000 packs early, 21.4 data_updates):  1015 / 154 ore
	--   2 launch satellite ingredients (217 kg, 18.1 / 13.9 rockets per 1000):       681 / 106 ore
	--   3 craft all but rocket fuel on platform (0.8 / 0.6 rockets per 1000):        29.5 / 4.6 ore + 5.71 / 1.29 chunks
	--   4 craft all on platform (rocket fuel via coal synthesis + liquefaction):      6.90 / 1.56 chunks
	--   the rocket is 84-94% of the ore cost in 1 and 2; carbon and water add 0.08 / 0.04 chunks to every route
	--   oil from coal liquefaction makes 1-3 about 13% more expensive early, the same data_updates
	--   asteroid productivity research not included; see tools/space_costs.py
	meld(data.raw["recipe"]["space-science-pack"], {
		categories = {"crafting-with-fluid"}, -- was crafting
		energy_required = 11, -- was 15
		ingredients = meld.overwrite{
			{type = "item", name = "satellite", amount = 1}, -- new, was 2 iron-plate
			{type = "item", name = "carbon", amount = 1}, -- was 1
			{type = "fluid", name = "water", amount = 20} -- new, was 1 ice
		},
		results = meld.overwrite{
			{type = "item", name = "space-science-pack", amount = 3} -- was 5
		}
	})
end

---- Techs
local function techs()
	meld(data.raw["technology"]["space-science-pack"], {
		effects = common.meld_add_or_assign{
			{type = "unlock-recipe", recipe = "satellite"},
			{type = "unlock-recipe", recipe = "ice-melting"},
		}
	})
	meld(data.raw["technology"]["space-platform-thruster"], {
		effects = common.meld_remove{{type = "unlock-recipe", recipe = "ice-melting"}}
	})
end

function M.data()
	satellite()
	launched_satellite()
	film_capsule()
	science()
	techs()
end

return M
