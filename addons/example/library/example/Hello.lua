---AUTO GENERATED, DO NOT MODIFY!
---@meta example.Hello

---
---@class example.Hello : example.ExportParent
---@field aliasHello example.Hello 
---@field cName string 
---@field cStrs string[] 
---@field cgLchar string 
---@field deque example.Hello[] 
---@field gLchar string 
---@field gLvoid any 
---@field id integer 
---@field intPtr olua.int 
---@field intPtrs olua.short[] 
---@field ints integer[] 
---@field map { [string]: integer } 
---@field name string 
---@field pointers example.Point[] 
---@field points example.Point[] 
---@field ptr any 
---@field type example.Type 
---@field vec2 example.Point 
---@field vectorIntPtr example.VectorInt 
---@field voids any[] 
---@field readonlyInt integer
local Hello = {}

---@param cls string
---@return any
function Hello:as(cls) end

---@param arg1 example.VectorString
function Hello:checkString(arg1) end

---@param v example.VectorInt
function Hello:checkVectorInt(v) end

---@param v example.VectorPoint
function Hello:checkVectorPoint(v) end

---@param p example.Point
---@return example.Point
---@overload fun(self: example.Hello, x: number, y: number): number, number
function Hello:convertPoint(p) end

---@return example.Hello
function Hello.create() end

function Hello:doCallback() end

---@return example.Hello
function Hello:getAliasHello() end

---@return string
function Hello:getCGLchar() end

---@return string
function Hello:getCName() end

---@return string[]
function Hello:getCStrs() end

---@param arg integer
---@return fun(arg1: example.Hello, arg2: example.Point): integer
function Hello:getCallback(arg) end

---@return example.Hello[]
function Hello:getDeque() end

---@return string
function Hello:getGLchar() end

---@return any
function Hello:getGLvoid() end

---@return integer
function Hello:getID() end

---@return olua.int
function Hello:getIntPtr() end

---@return olua.short[]
function Hello:getIntPtrs() end

---@param ref olua.int
function Hello:getIntRef(ref) end

---@return integer[]
function Hello:getInts() end

---@return { [string]: integer }
function Hello:getMap() end

---@return string
function Hello:getName() end

---@return example.Point[]
function Hello:getPointers() end

---@return example.Point[]
function Hello:getPoints() end

---@return any
function Hello:getPtr() end

---@param ref olua.string
function Hello:getStringRef(ref) end

---@return example.Type
function Hello:getType() end

---@return number, number
function Hello:getVec2() end

---@return example.VectorInt
function Hello:getVectorIntPtr() end

---@return any[]
function Hello:getVoids() end

---@param path string
---@param callback fun(arg1: example.Hello, arg2: integer): string
---@return integer
function Hello.load(path, callback) end

---@return example.Hello
function Hello.new() end

function Hello:printSingleton() end

---@param result olua.char
---@param len olua.size_t
function Hello:read(result, len) end

---@param obj example.Hello
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello, obj__7: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello, obj__7: example.Hello, obj__8: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello, obj__7: example.Hello, obj__8: example.Hello, obj__9: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello, obj__7: example.Hello, obj__8: example.Hello, obj__9: example.Hello, obj__10: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello, obj__7: example.Hello, obj__8: example.Hello, obj__9: example.Hello, obj__10: example.Hello, obj__11: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello, obj__7: example.Hello, obj__8: example.Hello, obj__9: example.Hello, obj__10: example.Hello, obj__11: example.Hello, obj__12: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello, obj__7: example.Hello, obj__8: example.Hello, obj__9: example.Hello, obj__10: example.Hello, obj__11: example.Hello, obj__12: example.Hello, obj__13: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello, obj__7: example.Hello, obj__8: example.Hello, obj__9: example.Hello, obj__10: example.Hello, obj__11: example.Hello, obj__12: example.Hello, obj__13: example.Hello, obj__14: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello, obj__7: example.Hello, obj__8: example.Hello, obj__9: example.Hello, obj__10: example.Hello, obj__11: example.Hello, obj__12: example.Hello, obj__13: example.Hello, obj__14: example.Hello, obj__15: example.Hello)
---@overload fun(self: example.Hello, obj: example.Hello, obj__1: example.Hello, obj__2: example.Hello, obj__3: example.Hello, obj__4: example.Hello, obj__5: example.Hello, obj__6: example.Hello, obj__7: example.Hello, obj__8: example.Hello, obj__9: example.Hello, obj__10: example.Hello, obj__11: example.Hello, obj__12: example.Hello, obj__13: example.Hello, obj__14: example.Hello, obj__15: example.Hello, obj__16: example.Hello)
function Hello:run(obj) end

---@param arg1 string
function Hello:setCGLchar(arg1) end

---@param value string
function Hello:setCName(value) end

---@param v string[]
function Hello:setCStrs(v) end

---@param callback fun(arg1: example.Hello, arg2: example.Point): integer
function Hello:setCallback(callback) end

---@param callback example.ClickCallback
---@overload fun(self: example.Hello, callback: fun(arg1: example.Hello, arg2: integer): string)
function Hello:setClickCallback(callback) end

---@param deque example.Hello[]
function Hello:setDeque(deque) end

---@param callback fun(arg1: example.Hello)
function Hello:setDragCallback(callback) end

---@param arg1 string
function Hello:setGLchar(arg1) end

---@param arg1 olua.float
function Hello:setGLfloat(arg1) end

---@param arg1 any
function Hello:setGLvoid(arg1) end

---@param id integer
function Hello:setID(id) end

---@param v olua.short[]
function Hello:setIntPtrs(v) end

---@param v integer[]
function Hello:setInts(v) end

---@param v { [string]: integer }
function Hello:setMap(v) end

---@param value string
function Hello:setName(value) end

---@param callback fun(arg1: example.Hello, arg2: integer): string
function Hello:setNotifyCallback(callback) end

---@param v example.Point[]
function Hello:setPointers(v) end

---@param v example.Point[]
function Hello:setPoints(v) end

---@param p any
function Hello:setPtr(p) end

---@param callback example.ClickCallback
function Hello:setTouchCallback(callback) end

---@param t example.Type
function Hello:setType(t) end

---@param v any[]
function Hello:setVoids(v) end

function Hello:testMacro() end

---@param callback fun(arg1: example.Hello, arg2: integer): string
function Hello:testMoveCallback(callback) end

---@param arg1 olua.char
---@param arg2 olua.uchar
---@param arg3 olua.short
---@param arg4 olua.short
---@param arg5 integer[]
---@param arg6 olua.ushort
---@param arg7 olua.ushort
---@param arg8 integer[]
---@param arg9 olua.int
---@param arg10 olua.int
---@param arg11 example.VectorInt
---@param arg12 olua.uint
---@param arg13 olua.uint
---@param arg14 integer[]
---@param arg15 olua.long
---@param arg16 olua.long
---@param arg17 integer[]
---@param arg18 olua.ulong
---@param arg19 olua.ulong
---@param arg20 integer[]
---@param arg21 olua.llong
---@param arg22 olua.llong
---@param arg23 integer[]
---@param arg24 olua.ullong
---@param arg25 olua.ullong
---@param arg26 integer[]
---@param arg27 olua.float
---@param arg28 number[]
---@param arg29 olua.double
---@param arg30 number[]
---@param arg31 olua.ldouble
---@param arg32 number[]
---@overload fun(self: example.Hello, arg1: fun(arg1: string, arg2: string, arg3: olua.short, arg4: olua.short, arg5: integer[], arg6: olua.ushort, arg7: olua.ushort, arg8: integer[], arg9: olua.int, arg10: olua.int, arg11: example.VectorInt, arg12: olua.uint, arg13: olua.uint, arg14: integer[], arg15: olua.long, arg16: olua.long, arg17: integer[], arg18: olua.ulong, arg19: olua.ulong, arg20: integer[], arg21: olua.llong, arg22: olua.llong, arg23: integer[], arg24: olua.ullong, arg25: olua.ullong, arg26: integer[], arg27: olua.float, arg28: number[], arg29: olua.double, arg30: number[], arg31: olua.ldouble, arg32: number[]))
function Hello:testPointerTypes(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20, arg21, arg22, arg23, arg24, arg25, arg26, arg27, arg28, arg29, arg30, arg31, arg32) end

return Hello