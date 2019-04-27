local COMMON = require "libs.common"
local RECIPES = require "world.recipes"
local LUME = require "libs.lume"

local Controller = COMMON.class("UnitController")
local MAX_UNITS = 1
local START_POS = vmath.vector3(1240,141,0.1)
local END_POS = vmath.vector3(100,100,0.1)
local SCALE = 3
local RX = require "libs.rx"

local UNIT_STATES = {APPEARED = "APPEARED",MOVEMENT = "MOVEMENT",WAIT = "WAIT",DISAPPEARED = "DISAPPEARED",DELETED = "DELETED"}
---@class Unit
local Unit = COMMON.class("Unit")
function Unit:initialize(data)
    data = data or {}
    self.position = vmath.vector3(data.x or 0,data.y or 0, 0.1)
    ---@type Recipe
    self.item = data.item or LUME.randomchoice(RECIPES.Recipes)
    ---@type CooperativeScheduler
    self.scheduler = assert(data.scheduler)
    self.img = data.img
    self.STATES = UNIT_STATES
    self.state = UNIT_STATES.WAIT
end

function Unit:hide()
    assert(self.state == UNIT_STATES.WAIT)
    self.state = UNIT_STATES.DISAPPEARED
    self.scheduler:schedule(function ()
        print("DELETED1")
        go.animate(self.view.sprite_item,"tint.w",go.PLAYBACK_ONCE_FORWARD,0,go.EASING_OUTEXPO,1,0)
        go.animate(self.view.sprite,"tint.w",go.PLAYBACK_ONCE_FORWARD,0,go.EASING_OUTEXPO,1,0)
        coroutine.yield(1)
        print("DELETED")
        go.delete(self.view.url,true)
        self.state = UNIT_STATES.DELETED
        print("STATE CHANGED")
    end)
end

function Unit:is_visible()
    return self.position.x < 1920
end

function Unit:update(dt)

end
---@param url url
function Unit:set_view(url)
    self.view = {
        url = url,
        sprite_item = msg.url(url.socket,url.path,"sprite_item"),
        sprite = msg.url(url.socket,url.path,"sprite")
    }
    self:view_update()
end

function Unit:view_update()
    assert(self.view)
    sprite.play_flipbook(self.view.sprite_item,self.item.result_img)
end


---@param world World
function Controller:initialize(world)
    self.world = assert(world)
    ---@type Unit[]
    self.units = {}
    ---@type Unit[]
    self.units_disappeared = {}
    self.scheduler = RX.CooperativeScheduler.create()
end
function Controller:update(dt)
    assert(dt)
    for i=#self.units,1,-1 do
        local unit = self.units[i]
        unit:update(dt)
    end
    for i=#self.units_disappeared,1,-1 do
        local unit = self.units_disappeared[i]
        unit:update(dt)
        print(unit.state)
        if unit.state == UNIT_STATES.DELETED then
            table.remove(self.units_disappeared,i)
            print("deleted")
        end
    end
    self:update_appear()
    self:update_units_movement(dt)
    self.scheduler:update(dt)
end

function Controller:update_appear()
    --add new units
    if #self.units < MAX_UNITS and #self.units_disappeared == 0 then
        local unit = self:create_unit(self.prev_unit)
        table.insert(self.units,unit)
        self.prev_unit = unit
    end
end

function Controller:update_units_movement(dt)

end

function Controller:free_first()
    local unit = table.remove(self.units)
    table.insert(self.units_disappeared,unit)
    unit:hide()
end
---@param prev_unit Unit
function Controller:create_unit(prev_unit)
    local item
    if prev_unit then
        item = prev_unit.item
        while item == prev_unit.item do
            item = LUME.randomchoice(RECIPES.Recipes)
        end
    end
    local unit = Unit({x=START_POS.x,y=START_POS.y,item = item,scheduler = self.scheduler})
    local unit_go = factory.create("game:/factories#unit",unit.position,nil,nil,SCALE)
    unit:set_view(msg.url(unit_go))
    return unit

end

return Controller