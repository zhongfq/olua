local path = (...):gsub('test.lua$', '') .. '../../common/?.lua;'
package.path = path .. package.path

local Hello = require "example.Hello"
local Point = require "example.Point"
local ClickCallback = require "example.ClickCallback"
local util = require "util"
print('%%', util)

-- excluded
assert(not Hello.getExcludeType)
assert(not Hello.setExcludeType)
assert(not Hello.setExcludeTypes)

olua.debug(true)

print(Point.new(2, 4), Point {x = 4, y = 8}, Point.new(3, 4):length())

local obj = Hello.new()
obj.name = 'codetypes'
obj.id = 100
print('convert', obj:convertPoint(3, 10))
print("referenceCount", obj.referenceCount)
print('name', obj.name, obj.id, obj.ptr)
-- print('ptr', obj.ptr, obj.point, obj.valuePoint)
-- -- obj:say()

-- local p = obj.point
-- local vp = obj.valuePoint
-- local pp = obj.pointer
-- print('##', p, vp, pp)
-- print('p', p.x, p.y)
-- print('vp', vp.x, vp.y)

-- p.x = 100
-- print('set')
-- print('p', p.x, p.y)
-- print('vp', vp.x, vp.y)

-- print('set')
-- obj.point.x = 110
-- obj.point.y = 120
-- print('p', p.x, p.y)
-- print('vp', vp.x, vp.y)

olua.int = require "olua.int"
olua.string = require "olua.string"
olua.char = require "olua.char"
olua.size_t = require "olua.size_t"

local num = olua.int.new()
local str = olua.string.new()
obj:getIntRef(num)
obj:getStringRef(str)
print('ref', num.value, str.value)
assert(num.value == 120)
assert(str.value == "120")

-- callback
obj:setClickCallback(ClickCallback(function (...)
    print('click', ...)
end))

-- type repalce
local result = olua.char.new(12)
local result_len = olua.size_t.new()
obj:read(result, result_len)
assert(result:tostring(11) == 'hello read!')
assert(result_len.value == 11)