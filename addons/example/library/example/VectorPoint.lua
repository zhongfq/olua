---AUTO GENERATED, DO NOT MODIFY!
---@meta example.VectorPoint

---
---@class example.VectorPoint 
---@field buffer any 
---@field length integer 
---@field value example.Point[] 
local VectorPoint = {}

---@return any
function VectorPoint:__gc() end

---@param idx integer
---@return example.Point[]
function VectorPoint:__index(idx) end

---@param idx integer
---@param v example.Point[]
function VectorPoint:__newindex(idx, v) end

---@param len integer
---@return example.VectorPoint
---@overload fun(): example.VectorPoint
---@overload fun(v: example.VectorPoint, len: integer): example.VectorPoint
---@overload fun(v: example.VectorPoint): example.VectorPoint
function VectorPoint.new(len) end

---@param from integer
---@param to integer
---@return example.VectorPoint
---@overload fun(self: example.VectorPoint, from: integer): example.VectorPoint
function VectorPoint:slice(from, to) end

---@param from integer
---@param to integer
---@return example.VectorPoint
---@overload fun(self: example.VectorPoint, from: integer): example.VectorPoint
function VectorPoint:sub(from, to) end

---@return example.VectorPoint
function VectorPoint:take() end

---@param len integer
---@return any
function VectorPoint:tostring(len) end

return VectorPoint