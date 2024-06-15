---@meta clang.LanguageKind

---@type clang.LanguageKind
local VALUE

---@enum clang.LanguageKind
local LanguageKind = {
    C = VALUE,
    CPlusPlus = VALUE,
    Invalid = VALUE,
    ObjC = VALUE,
}

return LanguageKind