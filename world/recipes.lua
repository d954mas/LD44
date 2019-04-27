local COMMON = require "libs.common"

---@class Recipe
local Recipe = COMMON.class("Recipe")
function Recipe:initialize(data)
    self.result_img = data.result_img
    self.components = assert(data.components)
    assert(#self.components==4)
    for _,comp in ipairs(self.components)do
        assert(type(comp)=="number")
        assert(comp > 0 and comp <= 4)
    end
end

---@type Recipe[]
local Recipes = {
    Recipe({result_img = "reciept_1",components={1,2,3,4}}),
    Recipe({result_img = "reciept_2",components={2,2,1,4}}),
    Recipe({result_img = "reciept_3",components={4,3,2,1}}),
    Recipe({result_img = "reciept_4",components={3,4,4,1}}),
    Recipe({result_img = "reciept_5",components={2,2,1,1}}),
    Recipe({result_img = "reciept_6",components={3,1,3,4}})
}

local M = {}
M.Recipes = Recipes
M.Recipe = Recipe

return M
