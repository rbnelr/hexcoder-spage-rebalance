require("prototypes/rcu").data()
require("prototypes/space_sci").data()

-- do update-ish things in data since we run after base data.lua
-- otherwise recyler recipes will be wrong

require("prototypes/rcu").updates()
require("prototypes/space_sci").updates()
require("prototypes/fun_promethium").updates()
require("prototypes/hard_recipes").updates()
require("prototypes/hard_science").updates()
require("prototypes/spage_machine_nerfs").updates()
