local mod_name = "hexcoder-spage-rebalance-"
local t0 = require("__0-things__.client.client") --[[@as things.client]]
local get_children = t0.parent_child_v1.get_children
local t0_tags = t0.tags_v1

---@class unit_number : integer

---@class ModStorage
---@field agri_towers table<unit_number, AgriTower>?
---@field assm2tower table<unit_number, AgriTower>?

---@class AgriTower
---@field tower LuaEntity
---@field assembler LuaEntity


local NEXT_DIRECTION = {
	[defines.direction.north] = defines.direction.east,
	[defines.direction.east] = defines.direction.south,
	[defines.direction.south] = defines.direction.west,
	[defines.direction.west] = defines.direction.north,
}
local PREV_DIRECTION = {
	[defines.direction.north] = defines.direction.west,
	[defines.direction.east] = defines.direction.north,
	[defines.direction.south] = defines.direction.east,
	[defines.direction.west] = defines.direction.south,
}
local FLIP_HORIZ = {
	[defines.direction.north] = defines.direction.north,
	[defines.direction.east] = defines.direction.west,
	[defines.direction.south] = defines.direction.south,
	[defines.direction.west] = defines.direction.east,
}
local FLIP_VERT = {
	[defines.direction.north] = defines.direction.south,
	[defines.direction.east] = defines.direction.east,
	[defines.direction.south] = defines.direction.north,
	[defines.direction.west] = defines.direction.west,
}

---@param event EventData.CustomInputEvent
---@param dir_lut table<defines.direction, defines.direction>
---@param mirror boolean
local function rotate_or_flip(event, dir_lut, mirror)
	if not event.selected_prototype then return end
	local player = game.get_player(event.player_index)
	local selected = player and player.selected
	
	if selected and (selected.type == "agricultural-tower" or
	                 selected.type == "entity-ghost" and selected.ghost_type == "agricultural-tower") then
		--game.print("rotate!")
		
		local thing = t0.get(selected)
		if thing then
			--local cur_ori = t0_tags.get_tag(thing.id, "orientation")
			
			local children = get_children(thing.id)
			local assembler = children and children[1] and children[1].entity
			if assembler and assembler.valid then
				assembler.direction = dir_lut[assembler.direction]
				if mirror then
					assembler.mirroring = not assembler.mirroring
				end
				--cur_ori.direction = dir_lut[cur_ori.direction]
				--if mirror then
				--	cur_ori.mirroring = not cur_ori.mirroring
				--end
				--assembler.direction = cur_ori.direction
				--assembler.mirroring = cur_ori.mirroring
				
				local new_ori = { direction=assembler.direction, mirroring=assembler.mirroring }
				t0_tags.set_tag(thing.id, "orientation", new_ori)
				
				game.print("rotate "..serpent.block{thing=thing, children=children, new_ori=new_ori})
			end
		end
	end
end
local function on_things_event(thing)
	local thing = thing.thing or thing
	
	local children = get_children(thing.id)
	local ori = t0_tags.get_tag(thing.id, "orientation")
	local assembler = children and children[1] and children[1].entity
	if assembler and assembler.valid and ori then
		assembler.direction = ori.direction
		assembler.mirroring = ori.mirroring
		assembler.destructible = false
	end
	
	game.print("sync_orientation "..serpent.block{thing, thing, ori})
end

--script.on_event(mod_name.."rotate", function(event) ---@cast event EventData.CustomInputEvent
--	rotate_or_flip(event, NEXT_DIRECTION, false)
--end)
--script.on_event(mod_name.."reverse-rotate", function(event) ---@cast event EventData.CustomInputEvent
--	rotate_or_flip(event, PREV_DIRECTION, false)
--end)
--script.on_event(mod_name.."flip-horizontal", function(event) ---@cast event EventData.CustomInputEvent
--	rotate_or_flip(event, FLIP_HORIZ, true)
--end)
--script.on_event(mod_name.."flip-vertical", function(event) ---@cast event EventData.CustomInputEvent
--	rotate_or_flip(event, FLIP_VERT, true)
--end)

--script.on_event(mod_name.."on_initialized", on_things_event)
--script.on_event(mod_name.."on_status", on_things_event)
--script.on_event(mod_name.."on_children_normalized", on_things_event)
--
--script.on_event(mod_name.."on_immediate_voided",
--	---@param ev things.EventData.on_immediate_voided
--	function(ev)
--		game.print("on_immediate_voided")
--	end
--)

-- TODO: can use LuaRendering render_mode = "build-cursor" to draw pipes!

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
	local player = game.get_player(event.player_index)
	local stack = player and player.cursor_stack
	
	game.print("on_player_cursor_stack_changed: "..serpent.block(stack))
end)

script.on_nth_tick(60, function(event)
	local surf = game.surfaces.gleba
	local found = surf.find_entities_filtered{name="hexcoder-agri-irrigation-furnace"}
	local entity = found and found[1]
	
	--local inv = entity.get_inventory(defines.inventory.crafter_output)
	
	entity.add_fluid(2, { name="heavy-oil", amount=1000 })
end)
