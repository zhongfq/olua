---@meta clang.TemplateArgumentKind

---@type clang.TemplateArgumentKind
local VALUE

---@enum clang.TemplateArgumentKind
local TemplateArgumentKind = {
    Declaration = VALUE,
    Expression = VALUE,
    Integral = VALUE,
    Invalid = VALUE,
    Null = VALUE,
    NullPtr = VALUE,
    Pack = VALUE,
    Template = VALUE,
    TemplateExpansion = VALUE,
    Type = VALUE,
}

return TemplateArgumentKind