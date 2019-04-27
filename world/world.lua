local COMMON = require "libs.common"
local RX = require "libs.rx"
local TAG = "World"

local RESET_SAVE = false

---@class World:Observable
local M = COMMON.class("World")

function M:reset()
end

function M:initialize()
	self.rx = RX.Subject()
	self.state = STATE
end


function M:update(dt)
end

function M:dispose()
	self:reset()
end

return M()