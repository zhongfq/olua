local path = (...):gsub('test.lua$', '') .. '../../common/?.lua;'
package.path = path .. package.path

local olua = require "olua"
local Node = require "example.Node"
local util = require "util"

olua.debug(true)

local scene = Node.new()
scene.name = 'scene'

local component = Node.new()
component.name = 'component'
scene.component = component

local childA = Node.new()
childA.name = 'A'

local childB = Node.new()
childB.name = 'B'

local childC = Node.new()
childC.name = 'C'

local childD = Node.new()
childD.name = 'D'

scene:addChild(childA)
scene:addChild(childB)
scene:addChild(childC)
scene:addChild(childD)

for i, v in ipairs(scene.children) do
    print('child:', i, v.name, v)
end

assert(childC.parent)
util.dumpUserValue(scene)
assert(util.hasRef(scene, 'children', childA))
assert(util.hasRef(scene, 'children', childB))
assert(util.hasRef(scene, 'children', childC))
scene:removeChildByName('D')
assert(util.hasNoRef(scene, 'children', childD))
scene:removeChild(childA)
assert(util.hasNoRef(scene, 'children', childA))
childB:removeSelf()
assert(util.hasNoRef(scene, 'children', childB))
assert(scene:getChildByName('C'))
scene:removeAllChildren()
assert(util.hasNoRef(scene, 'children', childC))
util.dumpUserValue(scene)
assert(childC.parent == nil)