---@meta clang.TemplateArgumentKind

---@type clang.TemplateArgumentKind
local VALUE

---
---@enum clang.TemplateArgumentKind
local TemplateArgumentKind = {
    Declaration = 2,
    Expression = 7,
    Integral = 4,
    Invalid = 9,
    Null = 0,
    NullPtr = 3,
    Pack = 8,
    Template = 5,
    TemplateExpansion = 6,
    Type = 1,
}

return TemplateArgumentKind