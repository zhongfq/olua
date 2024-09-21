---AUTO GENERATED, DO NOT MODIFY!
---@meta example.VectorInt

---
---@class example.VectorInt 
---@field buffer any 
---@field length integer 
---@field value integer[] 
local VectorInt = {}

---@return any
function VectorInt:__gc() end

---@param idx integer
---@return integer[]
function VectorInt:__index(idx) end

---@param idx integer
---@param v integer[]
function VectorInt:__newindex(idx, v) end

---@param len integer
---@return example.VectorInt
---@overload fun(): example.VectorInt
---@overload fun(v: example.VectorInt, len: integer): example.VectorInt
---@overload fun(v: example.VectorInt): example.VectorInt
function VectorInt.new(len) end

---@param from integer
---@param to integer
---@return example.VectorInt
---@overload fun(self: example.VectorInt, from: integer): example.VectorInt
function VectorInt:slice(from, to) end

---@param from integer
---@param to integer
---@return example.VectorInt
---@overload fun(self: example.VectorInt, from: integer): example.VectorInt
function VectorInt:sub(from, to) end

---@return example.VectorInt
function VectorInt:take() end

---@param len integer
---@return any
function VectorInt:tostring(len) end

return VectorInt