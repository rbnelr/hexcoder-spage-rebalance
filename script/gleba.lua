local mod_name = "hexcoder-spage-rebalance-"
local meld = require("__core__.lualib.meld")
local item_sounds = require("__base__.prototypes.item_sounds")

local BOGWATER_TEMP = 23
local BOGWATER_TINT = {0.35, 0.65, 0.45}
local FERTILIZER_TINT = {0.53, 0.64, 0.05}

--gleba_water_tiles = {
--	"wetland-yumako",
--	"wetland-jellynut",
--	"wetland-blue-slime",
--	"wetland-light-green-slime",
--	"wetland-green-slime",
--	"wetland-light-dead-skin",
--	"wetland-dead-skin",
--	"wetland-pink-tentacle",
--	"wetland-red-tentacle",
--	"gleba-deep-lake",
--}

data:extend{
	{
		type = "fluid",
		name = "hexcoder-bogwater",
		subgroup = "fluid",
		default_temperature = BOGWATER_TEMP,
		max_temperature = 100,
		heat_capacity = "2kJ",
		base_color = BOGWATER_TINT,
		flow_color = {0.7, 0.7, 0.7},
		icon = "__hexcoder-spage-rebalance__/graphics/icons/bogwater-2.png",
		order = "a[fluid]-a[water]-b[bogwater]"
	},
	{
		type = "fluid",
		name = "hexcoder-fertilizer",
		subgroup = "fluid",
		default_temperature = data.raw.fluid.water.default_temperature,
		max_temperature = 100,
		heat_capacity = "2kJ",
		base_color = FERTILIZER_TINT,
		flow_color = {0.7, 0.7, 0.7},
		icon = "__hexcoder-spage-rebalance__/graphics/icons/fertilizer.png",
		order = "b[new-fluid]-d[gleba]-a[fertilizer]" -- after fulgora (c)
	},
	{
		type = "recipe",
		name = "hexcoder-bogwater-filtration",
		--icon = "__space-age__/graphics/icons/fluid/ice-melting.png", -- icon from fluid?
		categories = {"chemistry","organic"},
		subgroup = "fluid-recipes",
		order = "d[other-chemistry]-d[fultration]",
		enabled = false,
		main_product = "water",
		icons = {
			{ icon = "__hexcoder-spage-rebalance__/graphics/icons/bogwater-2.png",
			  icon_size = 64, scale = .35, shift = {-2, -8} },
			{ icon = data.raw.fluid.water.icon,
			  icon_size = 64, scale = .30 },
		},
		ingredients = {
			{type = "fluid", name = "hexcoder-bogwater", amount = 100},
			{type = "item", name = "hexcoder-sand", amount = 2},
		},
		energy_required = 4.55,
		results = {
			{ type ="fluid", name = "water", amount = 65,
			  temperature = BOGWATER_TEMP -- just because we can
			},
			{ type = "item", name = "spoilage", amount_min = 2, amount_max = 4, ignored_by_productivity = 4 }
		},
		allow_productivity = true,
		crafting_machine_tint =
		{
			--primary = {r = 0.433, g = 0.773, b = 1.000, a = 1.000}, -- #6ec5ffff
			--secondary = {r = 0.591, g = 0.856, b = 1.000, a = 1.000}, -- #96daffff
			--tertiary = {r = 0.381, g = 0.428, b = 0.436, a = 0.502}, -- #616d6f80
			--quaternary = {r = 0.499, g = 0.797, b = 0.793, a = 0.733}, -- #7fcbcabb
			--primary = BOGWATER_TINT,
			primary = {r = 0.27, g = 0.30, b = 0.16, a = 1},
			secondary = {r = 0.30, g = 0.47, b = 0.6, a = 0.75},
			tertiary = {r = 0.43, g = 0.5, b = 0.5, a = 0.502}, -- #6D7F80
			quaternary = {r = 0.499, g = 0.797, b = 0.793, a = 0.733}, -- #7fcbcabb
		},
	},
	{
		type = "item",
		name = "hexcoder-sand",
		--icon = "__hexcoder-spage-rebalance__/graphics/icons/nutrients-sand.png",
		icon = "__hexcoder-spage-rebalance__/graphics/icons/Krastorio2 - items - sand.png",
		pictures = {
			--{size = 64, filename = "__hexcoder-spage-rebalance__/graphics/icons/nutrients-sand.png", scale = 0.5, mipmap_count = 4},
			{size = 64, filename = "__hexcoder-spage-rebalance__/graphics/icons/Krastorio2 - items - sand.png", scale = 0.55},
			{size = 64, filename = "__hexcoder-spage-rebalance__/graphics/icons/Krastorio2 - items - sand-1.png", scale = 0.55},
			{size = 64, filename = "__hexcoder-spage-rebalance__/graphics/icons/Krastorio2 - items - sand-2.png", scale = 0.55},
		},
		subgroup = "raw-resource",
		order = "k[stone-sand]",
		inventory_move_sound = item_sounds.sulfur_inventory_move,
		pick_sound = item_sounds.resource_inventory_pickup,
		drop_sound = item_sounds.sulfur_inventory_move,
		stack_size = 50,
		weight = 2 * kg
	},
	{
		type = "recipe",
		name = "hexcoder-sand",
		--icon = sand icon
		categories = {"crushing"},
		subgroup="raw-material",
		order = "mb[sand]",
		auto_recycle = false,
		enabled = true, -- TODO
		ingredients = {
			{type = "item", name = "stone", amount = 1},
		},
		energy_required = .65,
		results = {
			{type = "item", name = "hexcoder-sand", amount = 3}
		},
		allow_productivity = true
	},
}

meld(data.raw.technology["planet-discovery-gleba"], {
	effects = meld.append{
		{ type = "unlock-recipe", recipe = "hexcoder-bogwater-filtration" },
		{ type = "unlock-recipe", recipe = "hexcoder-sand" },
	}
})

meld(data.raw["assembling-machine"]["crusher"], {
	surface_conditions = meld.delete(),
})

-- gleba_water_tiles global in \space-age\prototypes\decorative\decoratives-gleba.lua
for _,tn in pairs(gleba_water_tiles) do
	local tile = data.raw["tile"][tn]
	tile.fluid = "hexcoder-bogwater"
end

meld(data.raw["noise-expression"]["gleba_stone_richness"], {
	--       was "4000 * max(starting, gleba_simple_spot(1000, 6 * size ^ 0.5, 80 / frequency ^ 0.5, gleba_highland) * max(gleba_highland, gleba_midland_aux_2)) * richness / size",
	expression = "8000 * max(starting, 4 * gleba_simple_spot(1000, 1.3*6 * size ^ 0.5, 80 / frequency ^ 0.5, gleba_highland) * max(gleba_highland, gleba_midland_aux_2)) * richness / (1.3*size)",
	--local_expressions = {
	--	richness = "control:gleba_stone:richness",
	--	frequency = "control:gleba_stone:frequency",
	--	size = "control:gleba_stone:size",
	--	starting = "starting_spot_at_angle{ angle = gleba_starting_angle + 85 * gleba_starting_direction,\z
	--										distance = 80 * gleba_starting_area_multiplier,\z
	--										radius = 7 * size ^ 0.5,\z
	--										x_distortion = gleba_wobble_x * 8,\z
	--										y_distortion = gleba_wobble_x * 8}"
	--}
})


---------

local minutes = 60*60

-- in vanilla, yumako and jellystem are type=plant, and the other gleba plants are type=tree
-- keep tree version for auto spawning, but add plant version which can actually be planted
-- the only thing needed to make it plantable is adding growth_ticks a seed item with plant_result

-- also need to delete created_effect, which will spawn decorations on every single planting without limit
-- the decorations are pretty, but I'm not sure how to handle them with regular planting

-- autoplace.tile_restriction seems to also effect manual and tower planting
-- and this collision_mask seems to cause it to only be placeable in water (instead of tile_restriction)
-- collision_mask = {layers={player=true, ground_tile=true, train=true, is_object=true, is_lower_object=true}},

-- I tried to delete them on harvest with this, but this does not seem to work
--slipstack_plant.dying_trigger_effect = {
--	{
--		type = "destroy-decoratives",
--		from_render_layer = "decorative",
--		to_render_layer = "object",
--		include_soft_decoratives = true,
--		include_decals = true,
--		invoke_decorative_trigger = true,
--		decoratives_with_trigger_only = false,
--		radius = 14
--	}
--}

---- Plantable trees:

-- ~24 / 6min = 4/min
data.raw["plant"]["yumako-tree"].minable.results = {
	{type = "item", name = "yumako",   amount_min = 4, amount_max = 40},
	{type = "item", name = "wood",     amount_min = 15, amount_max = 28},
	{type = "item", name = "spoilage", amount_min = 0, amount_max = 10},
}
data.raw["plant"]["yumako-tree"].growth_ticks = 6 * minutes

-- ~22.5 / 10min = 2.25/min
data.raw["plant"]["jellystem"].minable.results = {
	{type = "item", name = "jellynut", amount_min = 15, amount_max = 35},
	{type = "item", name = "spoilage", amount_min = 11, amount_max = 13},
}
data.raw["plant"]["jellystem"].growth_ticks = 10 * minutes

--
data.raw["tree"]["slipstack"].minable.results = {
	{type = "item", name = "jelly",   amount_min = 0, amount_max = 2},
	{type = "item", name = "spoilage", amount_min = 103, amount_max = 152},
	{type = "fluid", name = "lubricant", amount_min = 140, amount_max = 190},
}
data.raw["tree"]["slipstack"].growth_ticks = 5 * minutes

--
data.raw["tree"]["boompuff"].minable.results = {
	{type = "item", name = "sulfur",   amount_min = 0, amount_max = 2},
	{type = "item", name = "spoilage", amount_min = 32, amount_max = 70},
	{type = "item", name = "wood",     amount_min = 1, amount_max = 5}
}
data.raw["tree"]["boompuff"].growth_ticks = 5 * minutes

local function make_tree_plantable(name, tile_restriction, tint1, tint2)
	data.raw["tree"][name].autoplace.tile_restriction = tile_restriction
	data.raw["tree"][name].hidden_in_factoriopedia = true
	
	local plant = util.table.deepcopy(data.raw["tree"][name])
	plant.type = "plant"
	plant.name = name.."-plant"
	plant.localised_name = {"entity-name."..name}
	plant.localised_description = {"entity-description."..name}
	plant.hidden_in_factoriopedia = false
	--plant.growth_ticks = 1 * minutes -- for testing
	plant.created_effect = nil
	plant.agricultural_tower_tint = {
		primary = tint1,
		secondary = tint2,
	}
	data:extend({plant})
	
	return plant
end

--[[
descriptions removed in 2.1:

slipstack=A Gleba coral stack that excretes blobs of slippery mucus.
sunnycomb=A Gleba lichen with a sponge-like structure that accumulates a yellow crust when dried by the sun.
teflilly=A Gleba plant with strong plasticy leaves.
boompuff=A Gleba lichen with pressurised gas sacs that ferments decaying matter into explosive gasses.
hairyclubnub=A Gleba fungus with hard woody stems and club-like caps that catch flies with sticky hairs.
funneltrunk=A Gleba fungus that forms a hard outer funnel and cultivates symbiotic worms.
cuttlepop=A Gleba fungus with tentacle-like roots and rattling spore pods.
jellystem=A Gleba abomination with a jelly-like stem and soft fleshy lumps that grow wrinkled jellynuts.
yumako-tree=A Gleba tree that yields tasty nutritious yumako fruit.
lickmaw=A carnivorous Gleba abomination with tongue-like tentacles and many mouths.
stingfrond=A Gleba lichen with a dry wispy canopy that lowers exceptionally strong cords armed with tiny stinging barbs.
]]

local slipstack_plant = make_tree_plantable("slipstack", {
		-- Not on deep lake
		--"wetland-yumako",
		--"wetland-jellynut",
		"wetland-blue-slime",        -- Blue marsh
		"wetland-light-green-slime", -- Light green marsh
		"wetland-green-slime",       -- Green marsh
		"wetland-light-dead-skin",   -- Light deadskin marsh
		"wetland-dead-skin",         -- Deadskin marsh
		"wetland-pink-tentacle",     -- Pink marsh
		"wetland-red-tentacle"       -- Red coral marsh
	},
	{r=0.72, g=0.34, b=0.47},
	{r=0.33, g=0.54, b=0.44}
)
make_tree_plantable("boompuff", {
		"midland-yellow-crust",   -- Orange crust lichen
		"midland-yellow-crust-2", -- Red crust lichen
		"midland-yellow-crust-3", -- Beige crust lichen
		"midland-yellow-crust-4"  -- Yellow crust lichen
	},
	{r=0.82, g=0.44, b=0.24},
	{r=0.77, g=0.66, b=0.56}
)

slipstack_plant.dying_trigger_effect = {
	{
		type = "destroy-decoratives",
		from_render_layer = "decorative",
		to_render_layer = "object",
		include_soft_decoratives = true,
		include_decals = true,
		invoke_decorative_trigger = true,
		decoratives_with_trigger_only = false,
		radius = 14
	}
}

---- Seeds
local function add_seed(name, icon_name, order)
	-- copy most properties
	local seed = util.table.deepcopy(data.raw["item"]["yumako-seed"])
	seed.name = name.."-seed"
	seed.localised_name = {"item-name."..name.."-seed"}
	seed.localised_description = {"item-description."..name.."-seed"}
	seed.icon = "__hexcoder-spage-rebalance__/graphics/icons/"..icon_name..".png"
	seed.pictures[1].filename = "__hexcoder-spage-rebalance__/graphics/icons/"..icon_name.."-1.png"
	seed.pictures[2].filename = "__hexcoder-spage-rebalance__/graphics/icons/"..icon_name.."-2.png"
	seed.pictures[3].filename = "__hexcoder-spage-rebalance__/graphics/icons/"..icon_name.."-3.png"
	seed.pictures[4].filename = "__hexcoder-spage-rebalance__/graphics/icons/"..icon_name.."-4.png"
	seed.order = "a[seeds]-".. order .."[".. seed.name .."]"
	seed.plant_result = name.."-plant"
	seed.place_result = seed.plant_result
	data:extend({seed})
end

data.raw["item"]["yumako-seed"].order = "a[seeds]-a[yumako-seed]"
data.raw["item"]["jellynut-seed"].order = "a[seeds]-b[jellynut-seed]"
add_seed("slipstack", "slipstack-seed", "c")
add_seed("boompuff", "boompuff-seed", "d")


---- 

---- Agri tower
-- Add a reasonable idle drain to a machine of this size
local energy_usage_agri_drain = "320kW" -- from 0
-- increase the energy cost massively
local energy_usage_agri_arm = "2.11MW"  -- from "100kW"

local tower = data.raw["agricultural-tower"]["agricultural-tower"]
meld(tower, {
	energy_source = { drain = energy_usage_agri_drain },
	-- only crane_energy_usage seems to actually have an effect, set crane_energy_usage to same value like original
	energy_usage = energy_usage_agri_arm,
	crane_energy_usage = energy_usage_agri_arm,
	-- Make it turn a bit slower as a energy nerf and to be more believeable for the size
	crane = {
		speed = {
			arm = {
				turn_rate = 0.002 * 0.5,
				extension_speed = 0.005 * 0.7
			}
		}
	},
	--agri_tower.randomize_planting_tile = false
	--agri_tower.random_growth_offset = 0.9

	-- graphics for agri-tower without pipe
	-- TODO: they seem to have changed the sprite in in 2.1, with instead of the entire base being animated
	-- now there is a static base and then a cropped version that's animated, need to redo it (hopefully better this time)
	--graphics_set = {
	--	animation = {
	--		layers = {
	--			util.sprite_load("__hexcoder-spage-rebalance__/graphics/agricultural-tower/agricultural-tower-base", {
	--				priority = "high",
	--				animation_speed = 0.25,
	--				frame_count = 64,
	--				scale = 0.5
	--			}),
	--			-- There's something wrong with this edited image
	--			-- Originally the png seems the be a alpha-only/greyscale _indexed_ format, but I can't seem to save it in that format
	--			-- or if I eventually did, there seems to be some compression or bit depth or whatever going on
	--			-- the shadow ingame appears subtly less soft, and more "binary"
	--			util.sprite_load("__hexcoder-spage-rebalance__/graphics/agricultural-tower/agricultural-tower-base-shadow", {
	--				priority = "high",
	--				frame_count = 1,
	--				repeat_count = 64,
	--				draw_as_shadow = true,
	--				scale = 0.5
	--			})
	--		}
	--	}
	--},

	--agri_tower.flags = {
	--	"placeable-neutral",
	--	"placeable-player",
	--	"player-creation",
	--}
	--selection_box = {{0,0}, {0,0}}
	--selectable_in_game = false,
})

local pipe_pictures = {
	north = { -- north obscured by tower TODO: actually not, need to adjust
		layers = { util.empty_sprite() },
	},
	east = {
		layers = {
			util.sprite_load("__hexcoder-spage-rebalance__/graphics/agricultural-tower/pipe-connections-east",
				{
					priority = "extra-high",
					scale = 0.5
				})
		}
	},
	south = {
		layers = {
			util.sprite_load("__hexcoder-spage-rebalance__/graphics/agricultural-tower/pipe-connections-south",
				{
					priority = "extra-high",
					scale = 0.5
				})
		}
	},
	west = {
		layers = {
			util.sprite_load("__hexcoder-spage-rebalance__/graphics/agricultural-tower/pipe-connections-west",
				{
					priority = "extra-high",
					scale = 0.5
				})
		}
	}
}

data:extend({
	{
		type = "recipe-category",
		name = "agriculture-irrigation" -- don't prefix?
	},
	{
		type = "recipe-category",
		name = "agriculture-irrigation2" -- don't prefix?
	},
	{
		type = "assembling-machine",
		name = "hexcoder-agri-irrigation-assem",
		icon = "__space-age__/graphics/icons/agricultural-tower.png",
		subgroup = "agriculture",
		flags = {
			"placeable-neutral",
			"placeable-player",
			"player-creation",
			"not-on-map",
			"not-repairable",
			"not-deconstructable",
			"not-blueprintable",
			"not-upgradable",
			--"hide-alt-info",
			"not-flammable",
			"no-automated-item-removal",
			"no-automated-item-insertion",
		},
		collision_mask = {
			layers = {},
			not_colliding_with_itself = true,
		},
		
		-- to exist as ghost, entity has to have this not sure if I'd need to actively prevent it from being placed by bots, maybe by using a unobtainable item?
		-- it seems you need both placeable_by and not having not-blueprintable for ghosts to work (which things places for us)
		-- otherwise we get 
		--placeable_by = {item="assembling-machine-1", count=1},

		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		--collision_box = nil,

		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }, -- for electricity?
		--selection_box = {{0,0}, {0,0}},
		selectable_in_game = false,
		selection_priority = 1,
		--minable = {mining_time = tower.minable.mining_time},
		minable = nil,

		max_health = 300,

		picture = nil,
		sprites = nil,

		--allow_copy_paste = false,
		draw_copper_wires = false,
		draw_circuit_wires = false,
		create_ghost_on_death = false,
		show_recipe_icon = false, -- enable if different irrigations have actual recipe icons (this would appear on the map)
		--alert_icon_shift = util.by_pixel(0, -12),
		icon_draw_specification = { shift = { 0, -0.3 } },
		fluid_boxes_off_when_no_fluid_recipe = false,
		fluid_boxes = {
			{
				production_type = "input",
				pipe_picture = pipe_pictures,
				--pipe_picture_frozen = ,
				pipe_covers = pipecoverspictures(),
				volume = 500,
				secondary_draw_orders = { north = -1 },
				pipe_connections = { { flow_direction = "input-output", direction = defines.direction.north, position = { 0, -1 } } }
			},
			{
				production_type = "input",
				pipe_picture = pipe_pictures,
				--pipe_picture_frozen = ,
				pipe_covers = pipecoverspictures(),
				volume = 500,
				secondary_draw_orders = { north = -1 },
				pipe_connections = { { flow_direction = "input-output", direction = defines.direction.south, position = { 0, 1 } } }
			},
			{
				production_type = "output",
				pipe_picture = pipe_pictures,
				--pipe_picture_frozen = ,
				--always_draw_covers = true,
				pipe_covers = pipecoverspictures(),
				volume = 100,
				secondary_draw_orders = { north = -1 },
				pipe_connections = { { flow_direction = "output", direction = defines.direction.west, position = { -1, 0 } } }
			}
		},
		--[[
		graphics_set =
		{
			animation =
			{
				layers =
				{
					{
						filename = "__base__/graphics/entity/assembling-machine-1/assembling-machine-1.png",
						priority = "high",
						width = 214,
						height = 226,
						frame_count = 32,
						line_length = 8,
						shift = util.by_pixel(0, 2),
						scale = 0.5
					},
					{
						filename = "__base__/graphics/entity/assembling-machine-1/assembling-machine-1-shadow.png",
						priority = "high",
						width = 190,
						height = 165,
						line_length = 1,
						repeat_count = 32,
						draw_as_shadow = true,
						shift = util.by_pixel(8.5, 5),
						scale = 0.5
					}
				}
			}
		},
		]] --
		working_sound = {
			sound = { category = "enemy", filename = "__base__/sound/creatures/spawner.ogg", volume = 0.6 },
			sound_accents =
			{
				{ sound = { variations = sound_variations("__space-age__/sound/entity/spawner/spawner-respirator-push", 3, 0.3), audible_distance_modifier = 0.6 }, frame = 1 },
				{ sound = { variations = sound_variations("__space-age__/sound/entity/spawner/spawner-respirator-pull", 3, 0.3), audible_distance_modifier = 0.6 }, frame = 17 },
			},
		},
		crafting_categories = { "agriculture-irrigation" },
		fixed_recipe = mod_name.."agri-fertilizer",
		crafting_speed = 1,
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 0 }
		},
		energy_usage = "600kW",
		module_slots = 0,
		allowed_effects = {},
	},
	{
		type = "furnace",
		name = "hexcoder-agri-irrigation-furnace",
		icon = "__space-age__/graphics/icons/agricultural-tower.png",
		subgroup = "agriculture",
		flags = {
			"placeable-neutral",
			"placeable-player",
			"player-creation",
			"not-on-map",
			"not-repairable",
			"not-deconstructable",
			"not-blueprintable",
			"not-upgradable",
			--"hide-alt-info",
			"not-flammable",
			"no-automated-item-removal",
			"no-automated-item-insertion",
		},
		collision_mask = {
			layers = {},
			not_colliding_with_itself = true,
		},
		
		-- to exist as ghost, entity has to have this not sure if I'd need to actively prevent it from being placed by bots, maybe by using a unobtainable item?
		placeable_by = {item="stone-furnace", count=1},

		collision_box = { { -1.2, -1.2 }, { 1.2, 1.2 } },
		--collision_box = nil,
		
		selection_box = { { -1.5, -1.5 }, { 1.5, 1.5 } }, -- for electricity?
		--selection_box = {{0,0}, {0,0}},
		--selectable_in_game = false,
		selection_priority = 1,
		--minable = {mining_time = tower.minable.mining_time},
		minable = nil,
		
		max_health = 300,
		
		picture = nil,
		sprites = nil,
		
		--allow_copy_paste = false,
		draw_copper_wires = false,
		draw_circuit_wires = false,
		create_ghost_on_death = false,
		show_recipe_icon = false, -- enable if different irrigations have actual recipe icons (this would appear on the map)
		--alert_icon_shift = util.by_pixel(0, -12),
		icon_draw_specification = { shift = { 0, -0.3 } },
		fluid_boxes_off_when_no_fluid_recipe = false,
		fluid_boxes = {
			{
				production_type = "input",
				pipe_picture = pipe_pictures,
				--pipe_picture_frozen = ,
				pipe_covers = pipecoverspictures(),
				volume = 500,
				secondary_draw_orders = { north = -1 },
				pipe_connections = {
					{ flow_direction = "input-output", direction = defines.direction.north, position = { 0, -1 } },
					{ flow_direction = "input-output", direction = defines.direction.south, position = { 0, 1 } },
				}
			},
			{
				production_type = "output",
				pipe_picture = pipe_pictures,
				--pipe_picture_frozen = ,
				--always_draw_covers = true,
				pipe_covers = pipecoverspictures(),
				volume = 100,
				secondary_draw_orders = { north = -1 },
				pipe_connections = { { flow_direction = "output", direction = defines.direction.west, position = { -1, 0 } } }
			}
		},
		--working_sound = {
		--	-- why did I pick these?
		--	-- cryo plant cryogenic-plant.ogg might fit
		--	sound = { category = "enemy", filename = "__base__/sound/creatures/spawner.ogg", volume = 0.6 },
		--	sound_accents =
		--	{
		--		{ sound = { variations = sound_variations("__space-age__/sound/entity/spawner/spawner-respirator-push", 3, 0.3), audible_distance_modifier = 0.6 }, frame = 1 },
		--		{ sound = { variations = sound_variations("__space-age__/sound/entity/spawner/spawner-respirator-pull", 3, 0.3), audible_distance_modifier = 0.6 }, frame = 17 },
		--	},
		--},
		crafting_categories = { "agriculture-irrigation2" },
		--fixed_recipe = mod_name.."liquid-fertilizer",
		crafting_speed = 1,
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			emissions_per_minute = { pollution = 0 }
		},
		energy_usage = "600kW",
		module_slots = 0,
		allowed_effects = {},
		source_inventory_size = 0,
		result_inventory_size = 0,
	},
	{
		type = "recipe",
		name = mod_name.."agri-fertilizer",
		icon = "__space-age__/graphics/icons/agricultural-tower.png",
		categories = {"agriculture-irrigation"},
		order = "c[agriculture]-a[irrigation]",
		hide_from_player_crafting = true,
		auto_recycle = false,
		energy_required = 5,
		ingredients = {
			{ type = "fluid", name = "water",     amount = 750 },
			{ type = "fluid", name = "lubricant", amount = 20 },
		},
		results = {
			--{type = "fluid", name = "lubricant", amount = 0},
			{ type = "fluid", name = "heavy-oil", amount = 50 }
		},
		enabled = true
	},
	{
		type = "recipe",
		name = mod_name.."agri-fertilizer2",
		localised_name = {"", "A"},
		icon = "__space-age__/graphics/icons/agricultural-tower.png",
		categories = {"agriculture-irrigation2"},
		order = "c[agriculture]-a[irrigation]",
		hide_from_player_crafting = true,
		auto_recycle = false,
		energy_required = 5,
		ingredients = {
			{ type = "fluid", name = "water",     amount = 750 },
		},
		enabled = true
	},
	{
		type = "recipe",
		name = mod_name.."agri-fertilizer3",
		localised_name = {"", "B"},
		icon = "__space-age__/graphics/icons/agricultural-tower.png",
		categories = {"agriculture-irrigation2"},
		order = "c[agriculture]-a[irrigation]",
		hide_from_player_crafting = true,
		auto_recycle = false,
		energy_required = 5,
		ingredients = {
			{ type = "fluid", name = "lubricant", amount = 20 },
		},
		results = {
			{ type = "fluid", name = "heavy-oil", amount = 50 }
		},
		enabled = true
	}
})

--for _, name in pairs({ "rotate", "reverse-rotate", "flip-horizontal", "flip-vertical" }) do
--	data:extend({ {
--		type = "custom-input",
--		name = mod_name..name,
--		key_sequence = "",
--		linked_game_control = name,
--		include_selected_prototype = true,
--	} })
--end
data:extend({
	{ type = "custom-event", name = mod_name.."on_initialized" },
	{ type = "custom-event", name = mod_name.."on_status" },
	{ type = "custom-event", name = mod_name.."on_immediate_voided" },
	{ type = "custom-event", name = mod_name.."on_children_normalized" },
})

--[[
--local oc_lib = require("lib.core.orientation.orientation-class")
-- from factorio-mod-core
local OrientationClass = {
	"Unknown",
	"Unsupported",
	"Nil",
	"D2_r",
	"D2_R",
	"D2_1_RF",
	"d8_R",
	"d8_0_rf",
	"d8_0_rF",
	"d8_0_RF",
	"d8_1_RF",
	"d8_2_RF",
	"d8_3_RF",
	"d8_0_RFc",
	"D8_0_RF",
	"D8_1_RF",
	"D8_2_RF",
	"D8_3_RF",
	"D8_0_RFc",
	"D8_0_latent",
	"D8_1_latent",
	"D8_2_latent",
	"D8_3_latent",
	"d16_0_rf",

	---Unknown or unregistered entities that can't be classified.
	---Will be treated as OC_0.
	["Unknown"] = 1,

	---Deliberately unsupported entities. Will be treated as OC_0.
	---[all rails/rail signals]
	["Unsupported"] = 2,

	---No flip or rotation possible.
	["Nil"] = 3,

	---North/east only
	---R=s, H=id, V=id
	---[`steam-turbine`]
	["D2_r"] = 4,

	---North/east only
	---R=s, H=id, V=id
	---[`fusion-reactor` with `two_direction_only=true`, ????]
	["D2_R"] = 5,

	---North/east only, diagonal symmetry.
	---R=s, H=s, V=s
	---[storage-tank with `two_direction_only=true`]
	["D2_1_RF"] = 6,

	---NESW, rotations only, no flips.
	---R=r, H=id, V=id
	---[`burner-mining-drill`]
	["d8_R"] = 7,

	---NESW, rotations, flips when equivalent to a rotation, in-hand only
	---[`offshore-pump`]
	["d8_0_rf"] = 8,

	---NESW, rotations, flips when equivalent to a rotation.
	---Rotation in hand only, flips in hand or world.
	---[`gun-turret`]
	["d8_0_rF"] = 9,

	---NESW, rotations, flips only when equivalent to a rotation.
	---Transformation group = D8 / <s>
	---[`simple-entity-with-owner`, all belt, all inserter, `big-mining-drill`]
	["d8_0_RF"] = 10,
	["d8_1_RF"] = 11,
	["d8_2_RF"] = 12,
	["d8_3_RF"] = 13,

	---NESW, rotations, flips only when equivalent to a rotation.
	---Transformation group = D8 / <s>
	---Rotation while in world = r^2
	---[`pump`, 1x2-combinators]
	["d8_0_RFc"] = 14,

	---NESW + mirror bit
	---Transformation group = D8.
	---R = r, H = s, V = r^2*H
	---[AMs with active fluid boxes]
	["D8_0_RF"] = 15,
	["D8_1_RF"] = 16,
	["D8_2_RF"] = 17,
	["D8_3_RF"] = 18,

	---NESW + mirror bit, oblong shape, rotation = flip when placed
	---Transformation group = D8
	---While held: R = r, H = s, V = r^2*H
	---While in world:  R = r^2, H = s, V = r^2*H
	---[`recycler`]
	["D8_0_RFc"] = 19,

	---NESW + mirror bit, latent orientation. This applies to
	---assembling machines with disabled fluid boxes. If they are re-enabled
	---they become D8_n_RF and their latent orientation is restored.
	---(The orientation is still readable from world entities while they are
	--- latent, but they can't be changed.)
	["D8_0_latent"] = 20,
	["D8_1_latent"] = 21,
	["D8_2_latent"] = 22,
	["D8_3_latent"] = 23,

	---8-directional, sane transforms in hand, fixed when placed
	---[`railgun-turret`]
	["d16_0_rf"] = 24,
}
]]

local OrientationClass = {
	["D8_0_RF"] = 15,
}

---@type things.ThingRegistration
local tower_registration = {
	name = "agricultural-tower",
	intercept_construction = true,
	virtualize_orientation = OrientationClass.D8_0_RF,
	children = {
		[1] = {
			create = {
				name="hexcoder-agri-irrigation-assem",
			},
			lifecycle_type = "real-real"--"real-real" void-real
		} -- relative_pos?
	},
	custom_events = {
		on_initialized=mod_name.."on_initialized",
		on_status=mod_name.."on_status",
		on_immediate_voided=mod_name.."on_immediate_voided",
		on_children_normalized=mod_name.."on_children_normalized",
	}
}
---@type things.ThingRegistration
local assem_registration = {
	name = "hexcoder-agri-irrigation-assem",
	virtualize_orientation = OrientationClass.D8_0_RF,
}
data.raw["mod-data"]["things-names"].data["agricultural-tower"] = tower_registration
data.raw["mod-data"]["things-names"].data["hexcoder-agri-irrigation-assem"] = assem_registration
