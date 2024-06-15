---@meta clang.RefQualifierKind

---@type clang.RefQualifierKind
local VALUE

---
---@enum clang.RefQualifierKind
local RefQualifierKind = {
    ---An lvalue ref-qualifier was provided (\c &).
    LValue = 1,
    ---No ref-qualifier was provided.
    None = 0,
    ---An rvalue ref-qualifier was provided (\c &&).
    RValue = 2,
}

return RefQualifierKind