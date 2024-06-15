---@meta clang.CXXAccessSpecifier

---@type clang.CXXAccessSpecifier
local VALUE

---@enum clang.CXXAccessSpecifier
local CXXAccessSpecifier = {
    InvalidAccessSpecifier = VALUE,
    Private = VALUE,
    Protected = VALUE,
    Public = VALUE,
}

return CXXAccessSpecifier