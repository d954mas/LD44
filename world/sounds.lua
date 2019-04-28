local COMMON = require "libs.common"

local M = COMMON.class("Sounds")
M.sounds = {
	CORRECT = msg.url("main:/sounds#correct"),
	SMOKE_OK = msg.url("main:/sounds#smoke_ok"),
	WRONG = msg.url("main:/sounds#wrong"),
	TIME_OVER = msg.url("main:/sounds#time_over"),
}

function M:play(url,delay)
	sound.play(url,{delay = delay})
end

return M