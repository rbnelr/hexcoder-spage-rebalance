-- Fix references to prototypes we deleted, also in other mods' techs
require("prototypes/vulcanus").final()
require("prototypes/space").final()

-- tech cost tweaks, rocket-part-productivity split, global tech cost multiplier, keep last
require("prototypes/research_costs").final()
