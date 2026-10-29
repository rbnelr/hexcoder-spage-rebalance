-- Constants shared by all stages (settings, data, control)
-- Only values, LUTs and small pure helpers. Don't touch stage-specific globals (settings, data, storage, game) at require time
local const = {}

const.MOD_NAME = "hexcoder-spage-rebalance"
const.MOD_DIR = "__"..const.MOD_NAME.."__"

-- Settings
const.SETTING_SCALES = const.MOD_NAME.."-scales"
const.SETTING_LAUNCH_POLLUTION = const.MOD_NAME.."-rocket-launch-pollution-amount"

return const
