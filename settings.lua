mod_name = "hexcoder-spage-rebalance-"

data:extend({
	{
		type = "string-setting",
		name = mod_name.."scales",
		localised_name = "Research multiplier by number of science packs",
		localised_description = "",
		setting_type = "startup",
		default_value = "2,5,10,15,25,50,100",
		auto_trim = true,
		order = "aa"
	},
	{
		type = "int-setting",
		name = mod_name.."rocket-launch-pollution-amount",
		localised_name = "Rocket launch pollution amount",
		localised_description = "",
		setting_type = "runtime-global",
		default_value = 1000,
		order = "aa"
	}
})