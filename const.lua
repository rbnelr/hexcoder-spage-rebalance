-- Constants shared by all stages (settings, data, control)
-- Only values, LUTs and small pure helpers. Don't touch stage-specific globals (settings, data, storage, game) at require time
local const = {}

const.MOD_NAME = "hexcoder-spage-rebalance"
const.MOD_DIR = "__"..const.MOD_NAME.."__"

-- Settings
const.SETTING_SCALES = const.MOD_NAME.."-scales"
const.SETTING_LAUNCH_POLLUTION = const.MOD_NAME.."-rocket-launch-pollution-amount"
const.SETTING_HARD_SCIENCE = const.MOD_NAME.."-hard-science"

const.LAUNCHED_SAT = const.MOD_NAME.."-launched-satellite"
const.SATELLITE_THRUSTER = const.MOD_NAME.."-satellite-thruster"
const.SATELLITE_THRUSTER_IGNITION = const.MOD_NAME.."-satellite-thruster-ignition"
const.SATELLITE_THRUSTER_SOUND = const.MOD_NAME.."-satellite-thruster-sound"
const.SATELLITE_SPRITE = const.MOD_NAME.."-satellite"
const.FILM_CAPSULE = const.MOD_NAME.."-film-capsule"

return const
