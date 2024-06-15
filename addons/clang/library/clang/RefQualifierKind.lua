---@meta clang.RefQualifierKind

---@type clang.RefQualifierKind
local VALUE

---@enum clang.RefQualifierKind
local RefQualifierKind = {
    ---An lvalue ref-qualifier was provided (\c &).
    LValue = VALUE,
    ---No ref-qualifier was provided.
    None = VALUE,
    ---An rvalue ref-qualifier was provided (\c &&).
    RValue = VALUE,
}

return RefQualifierKind