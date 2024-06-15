---@meta clang.VisibilityKind

---@type clang.VisibilityKind
local VALUE

---@enum clang.VisibilityKind
local VisibilityKind = {
    ---Symbol seen by the linker and acts like a normal symbol.
    Default = VALUE,
    ---Symbol not seen by the linker.
    Hidden = VALUE,
    ---This value indicates that no visibility information is available
    ---for a provided CXCursor.
    Invalid = VALUE,
    ---Symbol seen by the linker but resolves to a symbol inside this object.
    Protected = VALUE,
}

return VisibilityKind