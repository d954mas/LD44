local BaseScene = require "libs.sm.scene"
local SM = require "libs.sm.sm"
local COMMON = require "libs.common"
local WORLD = require "world.world"

---@class GameScene:Scene
local Scene = BaseScene:subclass("GameScene")
function Scene:initialize()
    BaseScene.initialize(self, "GameScene", "/game#proxy", "game:/scene_controller")
    self.input = COMMON.INPUT()
    self.input:add(COMMON.HASHES.INPUT_CRAFT_1,function () WORLD:craft(1) end,true)
    self.input:add(COMMON.HASHES.INPUT_CRAFT_2,function () WORLD:craft(2) end,true)
    self.input:add(COMMON.HASHES.INPUT_CRAFT_3,function () WORLD:craft(3) end,true)
    self.input:add(COMMON.HASHES.INPUT_CRAFT_4,function () WORLD:craft(4) end,true)
end

function Scene:on_show(input)
    COMMON.input_acquire()
    WORLD:reset()
end

function Scene:final(go_self)
    COMMON.input_release()
    WORLD:reset()
end

function Scene:on_update(go_self, dt)
    BaseScene.on_update(self,go_self,dt)
    WORLD:update(dt)
end

function Scene:on_transition(transition)
end

function Scene:on_input(action_id, action)
    self.input:on_input(self,action_id,action)
end

return Scene