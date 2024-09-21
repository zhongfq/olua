---AUTO GENERATED, DO NOT MODIFY!
---@meta example.PointArray

---
---@class example.PointArray 
---@field buffer any 
---@field length integer 
---@field value example.Point 
local PointArray = {}

---@return any
function PointArray:__gc() end

---@param idx integer
---@return example.Point
function PointArray:__index(idx) end

---@param idx integer
---@param v example.Point
function PointArray:__newindex(idx, v) end

---@param len integer
---@return example.PointArray
---@overload fun(): example.PointArray
---@overload fun(v: example.Point, len: integer): example.PointArray
---@overload fun(v: example.Point): example.PointArray
function PointArray.new(len) end

---@param from integer
---@param to integer
---@return example.PointArray
---@overload fun(self: example.PointArray, from: integer): example.PointArray
function PointArray:slice(from, to) end

---@param from integer
---@param to integer
---@return example.PointArray
---@overload fun(self: example.PointArray, from: integer): example.PointArray
function PointArray:sub(from, to) end

---@return example.PointArray
function PointArray:take() end

---@param len integer
---@return any
function PointArray:tostring(len) end

return PointArray