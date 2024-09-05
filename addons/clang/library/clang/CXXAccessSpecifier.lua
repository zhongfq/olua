---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.CXXAccessSpecifier

---@type clang.CXXAccessSpecifier
local VALUE

---
---@enum clang.CXXAccessSpecifier
---@operator call(integer): clang.CXXAccessSpecifier
local CXXAccessSpecifier = {
    InvalidAccessSpecifier = 0,
    Private = 3,
    Protected = 2,
    Public = 1,
}

---@param v integer
---@return clang.CXXAccessSpecifier
function CXXAccessSpecifier:__call(v) end

return CXXAccessSpecifier