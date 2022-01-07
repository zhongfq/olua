local olua = require "olua"
local Node = require "example.Node"

olua.debug(true)

local obj = Node.new()

local color = 0x123456
obj.color = color
assert(obj.color == color)

local id = 'hello'
obj.identifier = id
assert(obj:getIdentifier() == id)

obj.position = {x = 1, y = 2}
assert(obj.position.x == 1)
assert(obj.position.y == 2)

local arr = {Node.new(), Node.new()}
obj.children = arr