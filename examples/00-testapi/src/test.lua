local path = (...):gsub('test.lua$', '') .. '../../common/?.lua;'
package.path = path .. package.path

local olua = require "olua.c"

local OLUA_REF_ALONE = 1 << 1 -- add & remove: only ref one
local OLUA_REF_MULTI = 1 << 2 -- add & remove: can ref one or more
local OLUA_REF_TABLE = 1 << 3 -- obj is table

local Hello = require "example.Hello"
local Point = require "example.Point"
local NoGC = require "example.NoGC"
local ClickCallback = require "example.ClickCallback"
local util = require "util"

local SubHello = olua.class('SubHello', Hello)
print('SubHello', SubHello, SubHello.class, SubHello.classname)

-- excluded
assert(not Hello.getExcludeType)
assert(not Hello.setExcludeType)
assert(not Hello.setExcludeTypes)

local nogc = NoGC.new(0, function () end)
print("nogc", NoGC.create(), nogc)
olua.printobj("brefore take", nogc)
olua.take(nogc)
olua.printobj("after take  ", nogc)

olua.debug(true)

print(Point.new(2, 4), Point {x = 4, y = 8}, Point.new(3, 4):length())
print("point.x == 4", (Point {x = 4, y = 8}).x == 4)

local obj = Hello.new()
obj.name = 'codetypes'
obj.id = 100
olua.printobj("TAG", obj);
olua.printobj(obj);
print('convert', obj:convertPoint(3, 10))
print("referenceCount", obj.referenceCount)
print('name', obj.name, obj.id, obj.ptr)
print('as', obj, obj:as('example.Singleton'))
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
num.name = "num *"
obj:getIntRef(num)
obj:getStringRef(str)
print('sizeof(int)', num.sizeof)
print('sizeof(string)', str.sizeof)
print('ref', num.value, str.value)
print('rawdata', num.rawdata)
assert(num.value == 120)
assert(str.value == "120")
assert(olua.isa(obj, 'void *'))

-- callback
obj:setClickCallback(ClickCallback(function (...)
    print('click', ...)
end))
obj:setClickCallback(function (...)
    print('click', ...)
end)
obj:setCallback(function (this, p)
    print("callback", this, p, p.x, p.y)
end)
obj:doCallback()

-- type repalce
local result = olua.char.new(12)
local result_len = olua.size_t.new()
obj:read(result, result_len)
assert(result:tostring(11) == 'hello read!')
assert(result_len.value == 11)

-- test enum
local Type = require "example.Type"
assert(olua.enum(0) == Type.LVALUE)
assert(olua.enum(Type.RVALUE) == 1)
obj.type = Type.POINTER
assert(obj.type == Type.POINTER)
assert(olua.enum(obj.type) == 2)
assert(Type.LVALUE < Type.RVALUE)
assert(Type.LVALUE <= Type.RVALUE)
assert(Type.POINTER > Type.RVALUE)
assert(Type.POINTER >= Type.RVALUE)
assert(Type.POINTER < 3)

-- test vector int
local VectorInt = require "example.VectorInt"
local vect = VectorInt.new()
obj:checkVectorInt(vect)
print('sizeof(VectorInt)', vect.sizeof)
vect = vect.value
assert(vect[1] == 1)
assert(vect[2] == 2)

-- test vector point
local VectorPoint = require "example.VectorPoint"
local vectP = VectorPoint.new()
obj:checkVectorPoint(vectP)
print('sizeof(VectorPoint)', vectP.sizeof)
vectP = vectP.value
assert(vectP[1].x == 10)
assert(vectP[2].y == 100)

-- test ptr
assert(obj.intPtr == nil)
print("vector int ptr 1", obj.vectorIntPtr)
print("vector int ptr 2", obj.vectorIntPtr)
assert(obj.vectorIntPtr.value[1] == 100)

-- test const
local Const = require "example.Const"
assert(Const.BOOL == true)
assert(Const.INT == -1)
assert(Const.ULLONG == 1)

-- test ref
local obja = Hello.new()
local objb = Hello.new()
print("------------olua.ref------------")
-- olua.ref {
--     action = 'add',
--     name = 'children',
--     where = obj,
--     object = obja,
--     flags = OLUA_REF_MULTI,
-- }
olua.ref('add', obj, 'children', obja, OLUA_REF_MULTI)
olua.ref('add', obj, 'children', objb, OLUA_REF_MULTI)
olua.ref('add', obj, 'objecta', obja, OLUA_REF_ALONE)
util.dumpUserValue(obj)
assert(util.hasRef(obj, "children", obja))
assert(util.hasRef(obj, "children", objb))
olua.ref('del', obj, 'children', obja, OLUA_REF_MULTI)
assert(util.hasNoRef(obj, 'children', obja))
olua.ref('delall', obj, 'children')
assert(util.hasNoRef(obj, 'children', objb))
util.dumpUserValue(obj)
util.dump(olua.uservalue(obj))

-- test smart ptr
local SharedHello = require "example.SharedHello"
local shared = SharedHello.new()
print(shared.this)

local int8 = require "olua.int8"
local chars = int8.new(10)
local slice = chars:slice(2, 4)
chars:assign('hello', 4)
print("slice", slice:tostring(2))
assert(slice[1] == string.byte('e'))
assert(slice[2] == string.byte('l'))
print(chars:tostring(4))
print(chars:sub(2):tostring(4))
print(chars:sub(2, 3):tostring(2))
print(chars:sub(2, 4):tostring(3))
