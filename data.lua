-- Edits to vanilla prototypes go here, not in data-updates:
-- the recycler mod generates recycling recipes in its data-updates, which runs before ours (space-age depends on it)
-- our dependencies already ran their data.lua, so this is effectively "data-updates" for vanilla

require("prototypes/nauvis").data()
require("prototypes/rocket_parts").data() -- creates rocket-control-unit used by fulgora.lua
require("prototypes/space").data()
require("prototypes/space_science").data()
require("prototypes/vulcanus").data()
require("prototypes/fulgora").data()
require("prototypes/gleba").data()
require("prototypes/aquilo").data()
require("prototypes/promethium").data()
require("prototypes/modules").data()
require("prototypes/stack_sizes").data()
