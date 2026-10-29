-- Helpers for the prototype stage, include from any prototypes/ file
-- A place for things to be put if too lazy to organize
-- or for anything shared between prototypes/ files
local meld = require("__core__.lualib.meld")
local util = require("util")

local common = {}

---- Common

---- Helpers
-- meld.append can create duplicates and meld can't remove entries by value (eg. name)

-- Default key to match list entries by:
--   "name"                                 -> itself                (prerequisites, categories, allowed_effects)
--   {type="item", name="x", amount=1}      -> "item/x"              (ingredients, results)
--   {type="unlock-recipe", recipe="x"}     -> "unlock-recipe/x"     (technology effects)
--   {"automation-science-pack", 1}         -> "automation-science-pack" (technology unit ingredients)
-- Effects without name or recipe (eg. gun-speed) all get the same key, pass a custom key_fn for those
local function entry_key(v)
	if type(v) ~= "table" then return v end
	if v[1] ~= nil then return v[1] end
	return (v.type or "").."/"..(v.name or v.recipe or "") -- combine type+name into unique string
end

local function add_or_assign(list, values, key_fn)
	local index = {}
	for i,v in pairs(list) do
		index[key_fn(v)] = i
	end

	for _,v in pairs(values) do
		local k = key_fn(v)
		if index[k] then
			list[index[k]] = util.copy(v) -- overwrite at index
		else
			-- push at back of list, update index
			table.insert(list, util.copy(v))
			index[k] = #list
		end
	end
	return list
end

local function remove(list, values, key_fn)
	local index = {}
	for _,v in pairs(values) do
		index[key_fn(v)] = true
	end

	-- iterate backwards, table.remove shifts the following entries down
	for i = #list, 1, -1 do
		if index[key_fn(list[i])] then
			table.remove(list, i)
		end
	end
	return list
end

-- Insert or overwrite entries in a list, matched by value or "name","type"+"name","recipe" or table[1] if value is table
-- eg. add prerequisite, category or allowed_effect without duplicates
--     add or modify ingredient or result
--     technology unit ingredient (first entry eg. {"automation-science-pack", 1})
---@param values any[]
---@param key_fn? fun(entry):any
function common.list_add_or_assign(values, key_fn)
	key_fn = key_fn or entry_key
	return meld.invoke(function(list)
		return add_or_assign(list or {}, values, key_fn)
	end)
end

-- Remove entries in a list, matched by value or "name","type"+"name","recipe" or table[1] if value is table
-- like list_add_or_assign, removing will not leave holes in array
---@param values any[]
---@param key_fn? fun(entry):any
function common.list_remove(values, key_fn)
	key_fn = key_fn or entry_key
	return meld.invoke(function(list)
		if list == nil then return nil end
		return remove(list, values, key_fn)
	end)
end

-- list_remove then list_add_or_assign, since a meld table can only have one op per key
-- eg. replace a prerequisite or science pack: prerequisites = common.list_replace({"agricultural-science-pack"}, {"electromagnetic-science-pack"})
---@param remove_values any[]
---@param add_values any[]
---@param key_fn? fun(entry):any
function common.list_replace(remove_values, add_values, key_fn)
	key_fn = key_fn or entry_key
	return meld.invoke(function(list)
		return add_or_assign(remove(list or {}, remove_values, key_fn), add_values, key_fn)
	end)
end

--local list = { a={"apple", "banana", {type="item", name="orange", count=3}} }
--
--meld(list, { a=common.list_add_or_assign{"chocolate"} })
--meld(list, { a=common.list_add_or_assign{{type="fluid", name="orange", count=1}} })
--meld(list, { a=common.list_add_or_assign{{type="item", name="orange", count=5}} })
--
--meld(list, { a=common.list_remove{"blah"} })
--meld(list, { a=common.list_remove{{type="fluid", name="orange", count=1}} })
--meld(list, { a=common.list_remove{"banana"} })

return common
