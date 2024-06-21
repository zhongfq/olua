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

print('--from templdate')
local sg = Hello.create()
sg:printExportParent()
print('say', sg, sg:say())
sg:printSingleton()
local listenr = sg:as('example.TestWildcardListener')
listenr:onClick()
local as = sg:as('example.Singleton')
sg:setSingleton(as)
print('hello', sg:as('example.ExportParent'))
print('wildc', sg:as('example.TestWildcardListener'))
print('singl', sg:as('example.Singleton'))

local TestGC = require "example.TestGC"
local test = TestGC.new()
print('GC', test:as('example.GC'))
print('GC', test:as('example.GC'))

util.dumpUserValue(test)
util.dumpUserValue(test:as('example.GC'))


local int32 = require "olua.int32"

local v = int32.new()
v.value = 10
print('#1', v, v.length, v.value)

sg:checkValue(v)

print(v[1])
v[1] = 20
print(v[1])

local arr = int32.new(10)
arr[9] = 90

local int8 = require "olua.int8"
local str = int8.new(10)
str:assign('hello', 4)
print(str:tostring(4))
print(str:sub(2):tostring(4))
print(str:sub(2, 3):tostring(2))
print(str:sub(2, 4):tostring(3))
