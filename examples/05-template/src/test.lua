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
