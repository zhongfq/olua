---AUTO GENERATED, DO NOT MODIFY!
---@meta example.VectorString

---
---@class example.VectorString 
---@field buffer any 
---@field length integer 
---@field value string[] 
local VectorString = {}

---@return any
function VectorString:__gc() end

---@param idx integer
---@return string[]
function VectorString:__index(idx) end

---@param idx integer
---@param v string[]
function VectorString:__newindex(idx, v) end

---@param len integer
---@return example.VectorString
---@overload fun(): example.VectorString
---@overload fun(v: example.VectorString, len: integer): example.VectorString
---@overload fun(v: example.VectorString): example.VectorString
function VectorString.new(len) end

---@param from integer
---@param to integer
---@return example.VectorString
---@overload fun(self: example.VectorString, from: integer): example.VectorString
function VectorString:slice(from, to) end

---@param from integer
---@param to integer
---@return example.VectorString
---@overload fun(self: example.VectorString, from: integer): example.VectorString
function VectorString:sub(from, to) end

---@return example.VectorString
function VectorString:take() end

---@param len integer
---@return any
function VectorString:tostring(len) end

return VectorString