---@meta clang.Module

---@class clang.Module : clang.IndexError
---@field astFile clang.File 
---@field fullName string 
---@field isSystem number 
---@field name string 
---@field parent clang.Module 
local Module = {}

---@param cls string
---@return any
function Module:as(cls) end

---@return clang.Module
function Module:shared_from_this() end

return Module