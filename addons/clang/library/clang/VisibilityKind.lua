---AUTO GENERATED, DO NOT MODIFY!
---@meta clang.VisibilityKind

---@type clang.VisibilityKind
local VALUE

---
---@enum clang.VisibilityKind
---@operator call(integer): clang.VisibilityKind
local VisibilityKind = {
    ---Symbol seen by the linker and acts like a normal symbol.
    Default = 3,
    ---Symbol not seen by the linker.
    Hidden = 1,
    ---This value indicates that no visibility information is available
    ---for a provided CXCursor.
    Invalid = 0,
    ---Symbol seen by the linker but resolves to a symbol inside this object.
    Protected = 2,
}

---@param v integer
---@return clang.VisibilityKind
function VisibilityKind:__call(v) end

return VisibilityKind