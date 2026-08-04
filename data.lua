mod_name = "hexcoder-spage-rebalance-"

require("script/rcu").data()
require("script/space_sci").data()

-- do update-ish things in data since we run after base data.lua
-- otherwise recyler recipes will be wrong
meld = require("__core__.lualib.meld")
myutil = require("myutil")

require("script/rcu").updates()
require("script/space_sci").updates()
require("script/fun_promethium").updates()
require("script/hard_recipes").updates()
require("script/hard_science").updates()
require("script/spage_machine_nerfs").updates()
