local Node = require "example.Node"
local Point = require "example.Point"
local olua = require "olua.c"

olua.debug(true)

local obj = Node.new()

local color = 0x123456
obj.color = color
assert(obj.color == color)

local id = 'hello'
obj.identifier = id
assert(obj:getIdentifier() == id)

obj.position = Point {x = 1, y = 2}
assert(obj.position.x == 1)
assert(obj.position.y == 2)

local arr = {Node.new(), Node.new()}
arr[1].identifier = 'child1'
arr[2].identifier = 'child2'
obj.children = arr

assert(obj.child1 == arr[1])
assert(obj.child2 == arr[2])
