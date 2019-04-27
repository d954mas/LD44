local COMMON = require "libs.common"
local RX = require "libs.rx"
local TAG = "World"
local RECIPES = require "world.recipes"
local LUME = require "libs.lume"
local UnitController = require "world.unit_controller"

local RESET_SAVE = false


local EVENTS = {
    CRAFT_SUCCESS = {"CRAFT_SUCCESS"},
    CRAFT_FAILED = {"CRAFT_FAILED"}
}



---@class World
local M = COMMON.class("World")

function M:reset()
    self.craft_recipe = {}
    self.unit_controller = UnitController(self) --reset
end

---@return Recipe
function M:get_current_item()
    local unit = self.unit_controller.units[1]
    return unit and (unit:is_visible() and unit.item)
end

function M:initialize()
    self.event_subject = RX.Subject()
    self.unit_controller = UnitController(self)
    self:reset()
end


function M:update(dt)
    self.unit_controller:update(dt)
end
--region units


--endregion
function M:dispose()
	self:reset()
end

function M:event(event,data)
    self.event_subject:onNext({event = event,data = data})
end

function M:craft(item_idx)
    --can't craft if no requests
    if not self:get_current_item() then return end
    assert(item_idx>0 and item_idx<=4)
    table.insert(self.craft_recipe,item_idx)
    if #self.craft_recipe == 4 then
        local item = self:get_current_item()
        local equals = item:check(self.craft_recipe)
        self:event(equals and EVENTS.CRAFT_SUCCESS,EVENTS.CRAFT_FAILED,{item = item})
        LUME.cleari(self.craft_recipe)
        if equals then
            self.unit_controller:free_first()
        end
    end
end

return M()