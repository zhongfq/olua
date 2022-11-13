local path = (...):gsub('test.lua$', '') .. '../../common/?.lua;'
package.path = path .. package.path

local olua = require "olua"
local Hello = require "example.Hello"
local util = require "util"

olua.debug(true)

local obj = Hello.new()
obj.name = 'codetypes'
print("referenceCount", obj.referenceCount)
obj:say()

local this = obj.this
print('shared_ptr', this)
obj.this = this
print('obj', obj)
print('this', this)
util.dumpUserValue(obj)
util.dumpUserValue(this)
