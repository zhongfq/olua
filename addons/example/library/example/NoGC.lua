---AUTO GENERATED, DO NOT MODIFY!
---@meta example.NoGC

---
---@class example.NoGC 
local NoGC = {}

---@return any
function NoGC:__gc() end

---@return example.NoGC
function NoGC.create() end

---@param i integer
---@param callbak fun(arg1: example.NoGC): integer
---@return example.NoGC
function NoGC.new(i, callbak) end

return NoGC