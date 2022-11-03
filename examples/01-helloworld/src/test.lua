local path = (...):gsub('test.lua$', '') .. '../../common/?.lua;'
package.path = path .. package.path

local olua = require "olua"
local Hello = require "example.Hello"
local util = require "util"
print('%%', util)

olua.debug(true)

local obj = Hello.new()
obj.name = 'codetypes'
print("referenceCount", obj.referenceCount)
obj:say()

print('--from templdate')
local sg = Hello.create()
sg:printExportParent()
print(sg, sg:say())
sg:printSingleton()