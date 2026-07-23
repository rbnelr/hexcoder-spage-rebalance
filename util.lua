local util = {}

-- good idea, but this could be better
function util.overwrite_by_name(values)
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
function util.delete_recipe_by_name(values)
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

return util