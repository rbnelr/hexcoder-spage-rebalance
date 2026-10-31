local const = require("const")
local meld = require("__core__.lualib.meld")
local common = require("prototypes/common")

local M = {}

function M.data_updates()
	
	for _,name in pairs{"vulcanus","fulgora","gleba","aquilo"} do
		data:extend{{
			type = "item-group",
			name = name.."-group",
			icon = data.raw["planet"][name].icon,
			icon_size = 64,
			order = data.raw["item-group"]["intermediate-products"].order.."-b["..name.."]",
			order_in_recipe = data.raw["item-group"]["intermediate-products"].order_in_recipe,
		}}
	end
	
	data.raw["item-subgroup"]["vulcanus-processes"].group = "vulcanus-group"
	data.raw["item-subgroup"]["fulgora-processes"].group = "fulgora-group"
	data.raw["item-subgroup"]["agriculture-processes"].group = "gleba-group"
	data.raw["item-subgroup"]["agriculture-products"].group = "gleba-group"
	data.raw["item-subgroup"]["aquilo-processes"].group = "aquilo-group"
	
	data.raw["item-subgroup"]["barrel"].group = "fluids"
	data.raw["item-subgroup"]["fill-barrel"].group = "fluids"
	data.raw["item-subgroup"]["empty-barrel"].group = "fluids"
	
end

return M
