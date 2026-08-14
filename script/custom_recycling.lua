local mod_name = "hexcoder-spage-rebalance-"
local meld = require("__core__.lualib.meld")

---@param recipe LuaRecipePrototype
local function adjust_recipe(recipe)
	if recipe.ingredients == nil or recipe.results == nil then return end
	if #recipe.ingredients ~= 1 or recipe.ingredients[1].type ~= "item" then return end
	local item = recipe.ingredients[1].name
	local orig_recipe = data.raw.recipe[item]
	
	-- make self recycling slower
	--if #recipe.results == 1 and recipe.ingredients[1].name == recipe.results[1].name then
	--	-- self recyling (eg. stone -> stone)
	--	-- was (energy_required or 0.5)/16, effectively taking no time to recyle these things compared to others
	--	recipe.energy_required = orig_recipe and (orig_recipe.energy_required / 16) or 1.5/16
	--end
	
	-- original recycling logic takes into account result amount like concrete making 10
	-- for the recycled products, but not for the speed so fix that
	-- Now fixed in 2.1.13, don't do this as this makes it even faster!
	--if orig_recipe and #orig_recipe.results == 1 then
	--	local res = orig_recipe.results[1]
	--	if res and (res.amount or (res.amount_min and res.amount_max)) then
	--		-- multiplier original formula uses for recycling results, but not for energy_required
	--		local multiplier = res.amount or res.amount_min
	--		recipe.energy_required = recipe.energy_required / multiplier
	--	end
	--end
	
	-- nerf fast recipes, including the self recycling ones at 0.5/16  (0.03 -> 0.1, so about 3x nerf)
	if recipe.energy_required < 0.1 then
		recipe.energy_required = 0.1
	end
end

for name, recipe in pairs(data.raw.recipe) do
	if name:find("-recycling$") then
		adjust_recipe(recipe)
	end
end
