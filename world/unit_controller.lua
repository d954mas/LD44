local COMMON = require "libs.common"
local RECIPES = require "world.recipes"
local LUME = require "libs.lume"

local Controller = COMMON.class("UnitController")
local MAX_UNITS = 1
local START_POS = vmath.vector3(1240,141,0.1)
local END_POS = vmath.vector3(100,100,0.1)
local SCALE = 3

---@class Unit
local Unit = COMMON.class("Unit")
function Unit:initialize(data)
    data = data or {}
    self.position = vmath.vector3(data.x or 0,data.y or 0, 0.1)
    ---@type Recipe
    self.item = data.item or LUME.randomchoice(RECIPES.Recipes)
    self.img = data.img
end

function Unit:is_visible()
    return self.position.x < 1920
end
---@param url url
function Unit:set_view(url)
    self.view = {
        url = url,
        sprite_item = msg.url(url.socket,url.path,"sprite_item")
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
    self.units = {}
end
function Controller:update(dt)
    self:update_appear()
    self:update_units_movement(dt)
end

function Controller:update_appear()
    --add new units
    if #self.units < MAX_UNITS then
        local unit = self:create_unit(self.prev_unit)
        table.insert(self.units,unit)
        self.prev_unit = unit
    end
end

function Controller:update_units_movement(dt)

end

function Controller:free_first()
    local unit = table.remove(self.units,1)
    go.delete(unit.view.url,true)
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
    local unit = Unit({x=START_POS.x,y=START_POS.y,item = item})
    print(unit.item.result_img)
    local unit_go = factory.create("game:/factories#unit",unit.position,nil,nil,SCALE)
    unit:set_view(msg.url(unit_go))
    return unit
end

return Controller