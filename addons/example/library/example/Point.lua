---AUTO GENERATED, DO NOT MODIFY!
---@meta example.Point

---
---@class example.Point 
---@field x number
---@field y number
---@operator add(example.Point):example.Point
---@operator div(number):example.Point
---@operator mul(number):example.Point
---@operator sub(example.Point):example.Point
---@operator unm:example.Point
local Point = {}

---@param p example.Point
---@return example.Point
---@overload fun(p1: example.Point, p2: example.Point): example.Point
function Point:__add(p) end

---@param s number
---@return example.Point
function Point:__div(s) end

---@param p1 example.Point
---@param p2 example.Point
---@return boolean
function Point.__eq(p1, p2) end

---@return any
function Point:__gc() end

---@param s number
---@return example.Point
function Point:__mul(s) end

---@param p example.Point
---@return example.Point
function Point:__sub(p) end

---@return any
function Point:__tostring() end

---@return example.Point
function Point:__unm() end

---@return number
function Point:length() end

---@return example.Point
---@overload fun(x: number, y: number): example.Point
function Point.new() end

return Point