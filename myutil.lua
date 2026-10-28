local meld = require("__core__.lualib.meld")
local myutil = {}

-- good idea, but this could be better
function myutil.overwrite_by_name(values)
	return meld.invoke(function(list)
		for k,v in pairs(list) do
			for _,val in pairs(values) do
				if v.type == val.type and v.name == val.name then
					list[k] = val
					break
				end
			end
		end
		return list
	end)
end
function myutil.delete_recipe_by_name(values)
	return meld.invoke(function(list)
		local new_list = {}
		for k,v in pairs(list) do
			local remove = false
			for _,val in pairs(values) do
				if v.type == val.type and v.recipe == val.recipe then
					remove = true
					break
				end
			end
			if not remove then
				table.insert(new_list, v)
			end
		end
		return new_list
	end)
end

-- append value if not already exist
-- ex. use instead of meld.append in tech prerequisites, if values could already exist
---@param values string[]
function myutil.meld_append_unique(values)
	local meld = require("__core__.lualib.meld")
	return { marker = meld.control_marker, op = "append_unique", data = values }
end
meld.control_handlers.append_unique = function(target, k, v)
	local list = target[k] or {}
	local existing_values = {}
	for _, value in pairs(list) do
		table.insert(existing_values, value)
	end
	for _, value in pairs(v.data) do
		if existing_values[value] == nil then
			table.insert(list, util.copy(value))
		end
	end
	target[k] = list
end

return myutil