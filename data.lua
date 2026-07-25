mod_name = "hexcoder-spage-rebalance-"

require("script/rcu").data()
require("script/space_sci").data()
require("script/fulgora_defense_drones").data()

-- do update-ish things in data since we run after base data.lua, needed to let me adjust recyler recipe
meld = require("__core__.lualib.meld")
myutil = require("myutil")

require("script/rcu").updates()
require("script/space_sci").updates()
require("script/fun_promethium")
require("script/hard_recipes")
require("script/spage_machine_nerfs")
require("script/fulgora_defense_drones").updates()
