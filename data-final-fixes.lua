-- Fix references to prototypes we deleted, also in other mods' techs
require("prototypes/vulcanus").final_fixes()
require("prototypes/space").final_fixes()

-- tech cost tweaks, rocket-part-productivity split, global tech cost multiplier, keep last
require("prototypes/research_costs").final_fixes()
