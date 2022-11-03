local path = (...):gsub('test.lua$', '') .. '../../common/?.lua;'
package.path = path .. package.path

local olua = require "olua"
local Hello = require "example.Hello"

olua.debug(true)

local obj = Hello.new()
obj.name = 'codetypes'
print("referenceCount", obj.referenceCount)
obj:say()