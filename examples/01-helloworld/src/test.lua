local path = (...):gsub('test.lua$', '') .. '../../common/?.lua;'
package.path = path .. package.path

local Hello = require "example.Hello"
local util = require "util"
local olua = require "olua.c"

print('%%', util)

olua.debug(true)

local obj = Hello.new()
obj.name = 'codetypes'
print("referenceCount", obj.referenceCount)
obj:say()
