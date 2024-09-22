---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.Module

---
---@class clang.Module : clang.IndexError
---@field astFile clang.File \param Module a module object. <br><br>\returns the module file where the provided module object came from.
---@field fullName string \param Module a module object. <br><br>\returns the full name of the module, e.g. "std.vector".
---@field name string \param Module a module object. <br><br>\returns the name of the module, e.g. for the 'std.vector' sub-module it will return "vector".
---@field parent clang.Module \param Module a module object. <br><br>\returns the parent of a sub-module or NULL if the given module is top-level, e.g. for 'std.vector' it will return the 'std' module.
local Module = {}

---@param cls string
---@return any
function Module:as(cls) end

---\param Module a module object.
---
---@return integer # s non-zero if the module is a system one.
function Module:isSystem() end

---@return clang.Module
function Module:shared_from_this() end

return Module