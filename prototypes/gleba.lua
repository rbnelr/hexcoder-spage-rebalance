-- Biochamber nerf
local meld = require("__core__.lualib.meld")

local M = {}

---- Machines
local function machines()
	meld(data.raw["assembling-machine"]["biochamber"], {
		module_slots = 2, -- was 4
		effect_receiver = {
			--uses_module_effects = false,
			uses_beacon_effects = true,
		},
		allowed_effects = {"speed", "productivity", "pollution", "quality"} -- no "consumption"
	})
end

function M.data()
	machines()
end

return M
