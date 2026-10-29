local const = require("const")

data:extend({
	{
		type = "string-setting",
		name = const.SETTING_SCALES,
		localised_name = "Research multiplier by number of science packs",
		localised_description = "",
		setting_type = "startup",
		default_value = "2,5,10,15,25,50,100",
		auto_trim = true,
	},
	{
		type = "int-setting",
		name = const.SETTING_LAUNCH_POLLUTION,
		localised_name = "Rocket launch pollution amount",
		localised_description = "",
		setting_type = "runtime-global",
		default_value = 1000,
	}
})