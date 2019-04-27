local COMMON = require "libs.common"
local RX = require "libs.rx"
local TAG = "World"
local RECIPES = require "world.recipes"

local RESET_SAVE = false

---@class World
local M = COMMON.class("World")

function M:reset()
end

function M:initialize()
	self.rx = RX.Subject()
	self.state = {IDLE = "IDLE",DROP = "DROP"}
    self.craft_recipe = {}
end


function M:update(dt)
end

function M:dispose()
	self:reset()
end

function M:craft(item)
    print("craft:" .. item)
    assert(item>0 and item<=4)
    table.insert(self.craft_recipe,item)
    if #self.craft_recipe == 5 then
     --   self.craft_recipe[1]=self.craft_recipe[5]
        self.craft_recipe[2] = nil
        self.craft_recipe[1] = nil
        self.craft_recipe[3] = nil
        self.craft_recipe[4] = nil
        self.craft_recipe[5] = nil
    end
end

return M()