local COMMON = require "libs.common"
local RX = require "libs.rx"
local TAG = "World"
local RECIPES = require "world.recipes"
local LUME = require "libs.lume"
local UnitController = require "world.unit_controller"
local SOUNDS = require "world.sounds"

local RESET_SAVE = false


local EVENTS = {
    CRAFT_SUCCESS = {"CRAFT_SUCCESS"},
    CRAFT_FAILED = {"CRAFT_FAILED"}
}


local MAX_TIME = 20
---@class World
local M = COMMON.class("World")

function M:reset()
    self.craft_recipe = {}
    self.unit_controller = UnitController(self) --reset
    self.current_time = 0
    self.started = false
    self.score = 0
end

---@return Recipe
function M:get_current_item()
    local unit = self.unit_controller.units[1]
    return unit and (unit:is_visible() and unit.state == unit.STATES.WAIT and unit.item )
end

function M:initialize()
    self.event_subject = RX.Subject()
    self.unit_controller = UnitController(self)
    self:reset()
    self.highscore = 0
end


function M:update(dt)
    assert(dt)
    if self.started then self.current_time = self.current_time+dt end
    if self.current_time > MAX_TIME then
        SOUNDS:play(SOUNDS.sounds.TIME_OVER,0.0)
        self.current_time = 0
        self.started = false
        self.highscore = math.max(self.highscore ,self.score)
        self:clear_craft()
    end
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
    if self.blocked then return end
    if self.current_time > MAX_TIME then return end
    if not self:get_current_item() then return end
    assert(item_idx>0 and item_idx<=4)
    table.insert(self.craft_recipe,item_idx)
   -- if #self.craft_recipe ~= 4 then SOUNDS:play(SOUNDS.sounds.BREATH_IN,0.0) end
    local idx = #self.craft_recipe
    if self.craft_recipe[idx] ~= self:get_current_item().components[idx] then
        self.blocked = true
        self.unit_controller.scheduler:schedule(function()
            self:clear_craft()
            self.blocked = false
            SOUNDS:play(SOUNDS.sounds.WRONG)
        end,0.2)
    end
    if #self.craft_recipe == 4 then
        local item = self:get_current_item()
        local equals = item:check(self.craft_recipe)
        self:event(equals and EVENTS.CRAFT_SUCCESS,EVENTS.CRAFT_FAILED,{item = item})

        local particles = {
            "/particles#smoke",
            "/particles#smoke1",
            "/particles#smoke2",
            "/particles#smoke3",
            "/particles#smoke4",
            "/particles#smoke5",
        }
        if equals then
            local count = math.ceil((self.score+1)/3)
            for i=1,count do
                particlefx.play(LUME.randomchoice(particles))
            end
            self.unit_controller:free_first()
            if not self.started then self.started = true self.score = 0 end
            --SOUNDS:play(SOUNDS.sounds.CORRECT)
            self.score = self.score + 1
            SOUNDS:play(SOUNDS.sounds.SMOKE_OK,0.0)
            particlefx.play("/particles#money")
        else
            self.blocked = true
            self.unit_controller.scheduler:schedule(function()
                self:clear_craft()
                SOUNDS:play(SOUNDS.sounds.WRONG)
                self.blocked = false
            end,0.2)
        end
    end
end

function M:clear_craft()
    LUME.cleari(self.craft_recipe)
end

function M:unit_added()
    LUME.cleari(self.craft_recipe)
end

return M()