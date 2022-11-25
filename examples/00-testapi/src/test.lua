local path = (...):gsub('test.lua$', '') .. '../../common/?.lua;'
package.path = path .. package.path

local Hello = require "example.Hello"
local util = require "util"
print('%%', util)

olua.debug(true)

local obj = Hello.new()
obj.name = 'codetypes'
obj.id = 100
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